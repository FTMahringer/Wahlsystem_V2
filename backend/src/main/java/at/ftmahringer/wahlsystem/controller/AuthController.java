package at.ftmahringer.wahlsystem.controller;

import at.ftmahringer.wahlsystem.dto.AuthResponse;
import at.ftmahringer.wahlsystem.dto.LoginRequest;
import at.ftmahringer.wahlsystem.dto.RegisterRequest;
import at.ftmahringer.wahlsystem.dto.UserDto;
import at.ftmahringer.wahlsystem.security.UserPrincipal;
import at.ftmahringer.wahlsystem.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(
    name = "Authentication",
    description = "Authentication and authorization endpoints"
)
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "Login with username and password")
    public ResponseEntity<AuthResponse> login(
        @Valid @RequestBody LoginRequest request
    ) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/register/admin")
    @Operation(summary = "Register a new admin (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AuthResponse> registerAdmin(
        @Valid @RequestBody RegisterRequest request
    ) {
        request.setRole(at.ftmahringer.wahlsystem.enums.UserRole.ADMIN);
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/register/teacher")
    @Operation(summary = "Register a new teacher (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AuthResponse> registerTeacher(
        @Valid @RequestBody RegisterRequest request
    ) {
        request.setRole(at.ftmahringer.wahlsystem.enums.UserRole.TEACHER);
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/register/student")
    @Operation(summary = "Register a new student (admin or teacher)")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    public ResponseEntity<AuthResponse> registerStudent(
        @Valid @RequestBody RegisterRequest request
    ) {
        request.setRole(at.ftmahringer.wahlsystem.enums.UserRole.STUDENT);
        return ResponseEntity.ok(authService.register(request));
    }

    @GetMapping("/me")
    @Operation(summary = "Get current authenticated user")
    public ResponseEntity<UserDto> getCurrentUser(
        @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        return ResponseEntity.ok(
            authService.getCurrentUser(userPrincipal.getId())
        );
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh access token")
    public ResponseEntity<AuthResponse> refreshToken(
        @RequestBody Map<String, String> request
    ) {
        String refreshToken = request.get("refreshToken");
        return ResponseEntity.ok(authService.refreshToken(refreshToken));
    }

    @PostMapping("/logout")
    @Operation(summary = "Logout and invalidate token")
    public ResponseEntity<Map<String, String>> logout(
        HttpServletRequest request
    ) {
        String jwt = getJwtFromRequest(request);
        authService.logout(jwt);
        return ResponseEntity.ok(Map.of("message", "Logged out successfully"));
    }

    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
