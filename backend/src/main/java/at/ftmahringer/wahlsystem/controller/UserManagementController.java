package at.ftmahringer.wahlsystem.controller;

import at.ftmahringer.wahlsystem.dto.RegisterRequest;
import at.ftmahringer.wahlsystem.dto.UserActiveUpdateRequest;
import at.ftmahringer.wahlsystem.dto.UserDto;
import at.ftmahringer.wahlsystem.dto.UserUpdateRequest;
import at.ftmahringer.wahlsystem.enums.UserRole;
import at.ftmahringer.wahlsystem.security.UserPrincipal;
import at.ftmahringer.wahlsystem.service.UserManagementService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "User Management", description = "Admin user management endpoints")
public class UserManagementController {

    private final UserManagementService userManagementService;

    @GetMapping
    @Operation(summary = "List users")
    public ResponseEntity<List<UserDto>> getUsers(
        @RequestParam(required = false) UserRole role,
        @RequestParam(required = false) Boolean active,
        @RequestParam(required = false) String search
    ) {
        return ResponseEntity.ok(
            userManagementService.getUsers(role, active, search)
        );
    }

    @PostMapping("/teachers")
    @Operation(summary = "Create a teacher")
    public ResponseEntity<UserDto> createTeacher(
        @Valid @RequestBody RegisterRequest request
    ) {
        return ResponseEntity.ok(userManagementService.createTeacher(request));
    }

    @PostMapping("/students")
    @Operation(summary = "Create a student")
    public ResponseEntity<UserDto> createStudent(
        @Valid @RequestBody RegisterRequest request
    ) {
        return ResponseEntity.ok(userManagementService.createStudent(request));
    }

    @PostMapping("/teachers/batch")
    @Operation(summary = "Create teachers in bulk")
    public ResponseEntity<List<UserDto>> createTeachers(
        @Valid @RequestBody List<RegisterRequest> requests
    ) {
        return ResponseEntity.ok(
            userManagementService.createTeachers(requests)
        );
    }

    @PostMapping("/students/batch")
    @Operation(summary = "Create students in bulk")
    public ResponseEntity<List<UserDto>> createStudents(
        @Valid @RequestBody List<RegisterRequest> requests
    ) {
        return ResponseEntity.ok(
            userManagementService.createStudents(requests)
        );
    }

    @PatchMapping("/{id}/active")
    @Operation(summary = "Activate or deactivate a user")
    public ResponseEntity<UserDto> updateUserActiveState(
        @PathVariable Long id,
        @Valid @RequestBody UserActiveUpdateRequest request
    ) {
        return ResponseEntity.ok(
            userManagementService.updateUserActiveState(id, request.getActive())
        );
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update a user (admin only, cannot edit other admins)")
    public ResponseEntity<UserDto> updateUser(
        @PathVariable Long id,
        @Valid @RequestBody UserUpdateRequest request,
        @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        return ResponseEntity.ok(
            userManagementService.updateUser(id, request, userPrincipal.getId())
        );
    }
}
