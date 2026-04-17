package at.ftmahringer.wahlsystem.service;

import at.ftmahringer.wahlsystem.dto.RegisterRequest;
import at.ftmahringer.wahlsystem.dto.UserDto;
import at.ftmahringer.wahlsystem.entity.User;
import at.ftmahringer.wahlsystem.enums.UserRole;
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

    @Transactional(readOnly = true)
    public List<UserDto> getUsers(UserRole role, Boolean active, String search) {
        String normalizedSearch = search == null ? null : search.trim().toLowerCase(Locale.ROOT);

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
                new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found")
            );
        user.setActive(active);
        return authService.mapToUserDto(userRepository.save(user));
    }

    private boolean matchesSearch(User user, String search) {
        if (search == null || search.isBlank()) {
            return true;
        }

        return contains(user.getUsername(), search) ||
        contains(user.getEmail(), search) ||
        contains(user.getFirstName(), search) ||
        contains(user.getLastName(), search) ||
        contains(user.getFullName(), search);
    }

    private boolean contains(String value, String search) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(search);
    }
}
