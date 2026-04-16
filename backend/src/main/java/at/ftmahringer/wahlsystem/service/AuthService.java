package at.ftmahringer.wahlsystem.service;

import at.ftmahringer.wahlsystem.dto.AuthResponse;
import at.ftmahringer.wahlsystem.dto.LoginRequest;
import at.ftmahringer.wahlsystem.dto.RegisterRequest;
import at.ftmahringer.wahlsystem.dto.UserDto;
import at.ftmahringer.wahlsystem.entity.Admin;
import at.ftmahringer.wahlsystem.entity.Student;
import at.ftmahringer.wahlsystem.entity.Teacher;
import at.ftmahringer.wahlsystem.entity.User;
import at.ftmahringer.wahlsystem.enums.UserRole;
import at.ftmahringer.wahlsystem.repository.AdminRepository;
import at.ftmahringer.wahlsystem.repository.StudentRepository;
import at.ftmahringer.wahlsystem.repository.TeacherRepository;
import at.ftmahringer.wahlsystem.repository.UserRepository;
import at.ftmahringer.wahlsystem.security.JwtTokenProvider;
import at.ftmahringer.wahlsystem.security.UserPrincipal;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final AdminRepository adminRepository;
    private final TeacherRepository teacherRepository;
    private final StudentRepository studentRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final TokenBlacklistService tokenBlacklistService;
    private final LoginAttemptService loginAttemptService;

    @Transactional
    public AuthResponse login(LoginRequest request) {
        String username = request.getUsername();

        if (loginAttemptService.isBlocked(username)) {
            long secs = loginAttemptService.remainingLockSeconds(username);
            throw new ResponseStatusException(
                HttpStatus.TOO_MANY_REQUESTS,
                "Too many failed attempts. Please try again in " + secs + " seconds."
            );
        }

        try {
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(username, request.getPassword())
            );

            loginAttemptService.loginSucceeded(username);
            SecurityContextHolder.getContext().setAuthentication(authentication);
            UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();

            User user = userRepository
                .findById(userPrincipal.getId())
                .orElseThrow(() -> new BadCredentialsException("User not found"));

            user.setLastLoginAt(LocalDateTime.now());
            user.setActive(true);
            userRepository.save(user);

            String token = tokenProvider.generateToken(authentication);
            String refreshToken = tokenProvider.generateRefreshToken(user.getId());

            return buildAuthResponse(token, refreshToken, user);
        } catch (BadCredentialsException e) {
            loginAttemptService.loginFailed(username);
            throw new BadCredentialsException("Invalid username or password");
        }
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // Check if username or email already exists
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already taken");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already registered");
        }

        User user = createUserFromRequest(request);
        User savedUser = userRepository.save(user);

        String token = tokenProvider.generateTokenFromUserId(
            savedUser.getId(),
            savedUser.getUsername(),
            "ROLE_" + savedUser.getRole().name()
        );
        String refreshToken = tokenProvider.generateRefreshToken(
            savedUser.getId()
        );

        return buildAuthResponse(token, refreshToken, savedUser);
    }

    private User createUserFromRequest(RegisterRequest request) {
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        return switch (request.getRole()) {
            case ADMIN -> createAdmin(request, encodedPassword);
            case TEACHER -> createTeacher(request, encodedPassword);
            case STUDENT -> createStudent(request, encodedPassword);
            default -> createBasicUser(request, encodedPassword);
        };
    }

    private Admin createAdmin(RegisterRequest request, String encodedPassword) {
        return Admin.builder()
            .username(request.getUsername())
            .email(request.getEmail())
            .password(encodedPassword)
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .role(UserRole.ADMIN)
            .active(true)
            .adminLevel(
                request.getAdminLevel() != null ? request.getAdminLevel() : 1
            )
            .department(request.getDepartment())
            .phone(request.getPhone())
            .canManageUsers(true)
            .canManageElections(true)
            .canViewAllResults(true)
            .build();
    }

    private Teacher createTeacher(
        RegisterRequest request,
        String encodedPassword
    ) {
        return Teacher.builder()
            .username(request.getUsername())
            .email(request.getEmail())
            .password(encodedPassword)
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .role(UserRole.TEACHER)
            .active(true)
            .employeeId(request.getEmployeeId())
            .department(request.getDepartment())
            .subjects(request.getSubjects())
            .phone(request.getPhone())
            .canCreateElections(true)
            .canManageOwnElections(true)
            .maxActiveElections(
                request.getMaxActiveElections() != null
                    ? request.getMaxActiveElections()
                    : 5
            )
            .build();
    }

    private Student createStudent(
        RegisterRequest request,
        String encodedPassword
    ) {
        return Student.builder()
            .username(request.getUsername())
            .email(request.getEmail())
            .password(encodedPassword)
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .role(UserRole.STUDENT)
            .active(true)
            .studentId(request.getStudentId())
            .className(request.getClassName())
            .gradeLevel(request.getGradeLevel())
            .canVote(true)
            .hasVoted(false)
            .build();
    }

    private User createBasicUser(
        RegisterRequest request,
        String encodedPassword
    ) {
        return User.builder()
            .username(request.getUsername())
            .email(request.getEmail())
            .password(encodedPassword)
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .role(request.getRole())
            .active(true)
            .build();
    }

    @Transactional(readOnly = true)
    public UserDto getCurrentUser(Long userId) {
        User user = userRepository
            .findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        return mapToUserDto(user);
    }

    @Transactional
    public AuthResponse refreshToken(String refreshToken) {
        if (!tokenProvider.validateToken(refreshToken)) {
            throw new BadCredentialsException("Invalid refresh token");
        }

        Long userId = tokenProvider.getUserIdFromToken(refreshToken);
        User user = userRepository
            .findById(userId)
            .orElseThrow(() -> new BadCredentialsException("User not found"));

        String newToken = tokenProvider.generateTokenFromUserId(
            user.getId(),
            user.getUsername(),
            "ROLE_" + user.getRole().name()
        );
        String newRefreshToken = tokenProvider.generateRefreshToken(
            user.getId()
        );

        return buildAuthResponse(newToken, newRefreshToken, user);
    }

    @Transactional
    public void logout(String token) {
        if (StringUtils.hasText(token) && tokenProvider.validateToken(token)) {
            long expirationTime = tokenProvider.getExpirationTime();
            tokenBlacklistService.blacklistToken(token, expirationTime);
        }
        SecurityContextHolder.clearContext();
    }

    private AuthResponse buildAuthResponse(
        String token,
        String refreshToken,
        User user
    ) {
        return AuthResponse.builder()
            .token(token)
            .refreshToken(refreshToken)
            .tokenType("Bearer")
            .expiresIn(tokenProvider.getExpirationTime())
            .user(
                AuthResponse.UserInfo.builder()
                    .id(user.getId())
                    .username(user.getUsername())
                    .email(user.getEmail())
                    .firstName(user.getFirstName())
                    .lastName(user.getLastName())
                    .fullName(user.getFullName())
                    .role(user.getRole())
                    .active(user.getActive())
                    .lastLoginAt(user.getLastLoginAt())
                    .build()
            )
            .build();
    }

    private UserDto mapToUserDto(User user) {
        UserDto.UserDtoBuilder builder = UserDto.builder()
            .id(user.getId())
            .username(user.getUsername())
            .email(user.getEmail())
            .firstName(user.getFirstName())
            .lastName(user.getLastName())
            .fullName(user.getFullName())
            .role(user.getRole())
            .active(user.getActive())
            .emailVerified(user.getEmailVerified())
            .createdAt(user.getCreatedAt())
            .updatedAt(user.getUpdatedAt())
            .lastLoginAt(user.getLastLoginAt());

        if (user instanceof Admin admin) {
            builder
                .adminLevel(admin.getAdminLevel())
                .canManageUsers(admin.getCanManageUsers())
                .canManageElections(admin.getCanManageElections());
        } else if (user instanceof Teacher teacher) {
            builder
                .employeeId(teacher.getEmployeeId())
                .department(teacher.getDepartment())
                .subjects(teacher.getSubjects())
                .canCreateElections(teacher.getCanCreateElections());
        } else if (user instanceof Student student) {
            builder
                .studentId(student.getStudentId())
                .className(student.getClassName())
                .gradeLevel(student.getGradeLevel())
                .canVote(student.getCanVote());
        }

        return builder.build();
    }
}
