package at.ftmahringer.wahlsystem.service;

import at.ftmahringer.wahlsystem.dto.RegisterRequest;
import at.ftmahringer.wahlsystem.dto.UserDto;
import at.ftmahringer.wahlsystem.dto.UserUpdateRequest;
import at.ftmahringer.wahlsystem.entity.Admin;
import at.ftmahringer.wahlsystem.entity.Student;
import at.ftmahringer.wahlsystem.entity.Teacher;
import at.ftmahringer.wahlsystem.entity.User;
import at.ftmahringer.wahlsystem.enums.UserRole;
import at.ftmahringer.wahlsystem.repository.SchoolClassRepository;
import at.ftmahringer.wahlsystem.repository.UserRepository;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class UserManagementService {

    private final UserRepository userRepository;
    private final AuthService authService;
    private final SchoolClassRepository schoolClassRepository;
    private final AuditLogService auditLogService;

    @Transactional(readOnly = true)
    public List<UserDto> getUsers(
        UserRole role,
        Boolean active,
        String search
    ) {
        String normalizedSearch =
            search == null ? null : search.trim().toLowerCase(Locale.ROOT);

        return userRepository
            .findAll()
            .stream()
            .filter(user -> role == null || user.getRole() == role)
            .filter(user -> active == null || user.getActive().equals(active))
            .filter(user -> matchesSearch(user, normalizedSearch))
            .sorted(Comparator.comparing(User::getCreatedAt).reversed())
            .map(authService::mapToUserDto)
            .toList();
    }

    @Transactional
    public UserDto createTeacher(RegisterRequest request) {
        request.setRole(UserRole.TEACHER);
        return authService.createManagedUser(request);
    }

    @Transactional
    public UserDto createStudent(RegisterRequest request) {
        request.setRole(UserRole.STUDENT);
        return authService.createManagedUser(request);
    }

    @Transactional
    public List<UserDto> createTeachers(List<RegisterRequest> requests) {
        requests.forEach(request -> request.setRole(UserRole.TEACHER));
        return authService.createManagedUsers(requests);
    }

    @Transactional
    public List<UserDto> createStudents(List<RegisterRequest> requests) {
        requests.forEach(request -> request.setRole(UserRole.STUDENT));
        return authService.createManagedUsers(requests);
    }

    @Transactional
    public UserDto updateUserActiveState(Long userId, boolean active) {
        User user = userRepository
            .findById(userId)
            .orElseThrow(() ->
                new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "User not found"
                )
            );
        boolean previousState = user.getActive();
        user.setActive(active);
        User saved = userRepository.save(user);

        auditLogService.logSimple(
            "USER_ACTIVE_STATE_CHANGED",
            null,
            "system",
            null,
            "USER",
            userId,
            "User " +
                user.getUsername() +
                " active state changed from " +
                previousState +
                " to " +
                active,
            true
        );

        return authService.mapToUserDto(saved);
    }

    @Transactional
    public UserDto updateUser(
        Long userId,
        UserUpdateRequest request,
        Long currentAdminId
    ) {
        User user = userRepository
            .findById(userId)
            .orElseThrow(() ->
                new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "User not found"
                )
            );

        User currentAdmin = userRepository
            .findById(currentAdminId)
            .orElseThrow(() ->
                new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "Current user not found"
                )
            );

        // Prevent editing other admins
        if (user instanceof Admin && !user.getId().equals(currentAdminId)) {
            throw new ResponseStatusException(
                HttpStatus.FORBIDDEN,
                "Admins cannot edit other admins"
            );
        }

        // Update basic fields
        if (request.getUsername() != null) {
            if (
                !request.getUsername().equals(user.getUsername()) &&
                userRepository.existsByUsername(request.getUsername())
            ) {
                throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Username already taken"
                );
            }
            user.setUsername(request.getUsername().trim());
        }
        if (request.getEmail() != null) {
            if (
                !request.getEmail().equals(user.getEmail()) &&
                userRepository.existsByEmail(request.getEmail())
            ) {
                throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Email already registered"
                );
            }
            user.setEmail(request.getEmail().trim());
        }
        if (request.getFirstName() != null) user.setFirstName(
            request.getFirstName().trim()
        );
        if (request.getLastName() != null) user.setLastName(
            request.getLastName().trim()
        );
        if (request.getActive() != null) user.setActive(request.getActive());

        // Role-specific updates
        if (user instanceof Teacher teacher) {
            if (request.getEmployeeId() != null) teacher.setEmployeeId(
                request.getEmployeeId().trim()
            );
            if (request.getSubjects() != null) teacher.setSubjects(
                request.getSubjects().trim()
            );
            if (request.getDepartmentTeacher() != null) teacher.setDepartment(
                request.getDepartmentTeacher().trim()
            );
            if (
                request.getCanCreateElections() != null
            ) teacher.setCanCreateElections(request.getCanCreateElections());
            if (
                request.getMaxActiveElections() != null
            ) teacher.setMaxActiveElections(request.getMaxActiveElections());
        } else if (user instanceof Student student) {
            if (request.getStudentId() != null) student.setStudentId(
                request.getStudentId().trim()
            );
            if (request.getClassName() != null) student.setClassName(
                request.getClassName().trim()
            );
            if (request.getGradeLevel() != null) student.setGradeLevel(
                request.getGradeLevel()
            );
            if (request.getCanVote() != null) student.setCanVote(
                request.getCanVote()
            );
            if (request.getSchoolClassId() != null) {
                student.setSchoolClass(
                    schoolClassRepository
                        .findById(request.getSchoolClassId())
                        .orElseThrow(() ->
                            new ResponseStatusException(
                                HttpStatus.NOT_FOUND,
                                "School class not found"
                            )
                        )
                );
            }
        } else if (user instanceof Admin admin) {
            if (request.getAdminLevel() != null) admin.setAdminLevel(
                request.getAdminLevel()
            );
            if (request.getDepartment() != null) admin.setDepartment(
                request.getDepartment().trim()
            );
            if (request.getPhone() != null) admin.setPhone(
                request.getPhone().trim()
            );
        }

        User saved = userRepository.save(user);

        auditLogService.logSimple(
            "USER_UPDATED",
            currentAdminId,
            "admin",
            "ROLE_ADMIN",
            "USER",
            userId,
            "User " + user.getUsername() + " updated by admin",
            true
        );

        return authService.mapToUserDto(saved);
    }

    private boolean matchesSearch(User user, String search) {
        if (search == null || search.isBlank()) {
            return true;
        }

        return (
            contains(user.getUsername(), search) ||
            contains(user.getEmail(), search) ||
            contains(user.getFirstName(), search) ||
            contains(user.getLastName(), search) ||
            contains(user.getFullName(), search)
        );
    }

    private boolean contains(String value, String search) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(search);
    }
}
