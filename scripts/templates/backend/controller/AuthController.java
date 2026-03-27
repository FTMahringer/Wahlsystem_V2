package com.example.wahlsystem.controller;

import com.example.wahlsystem.dto.AuthResponse;
import com.example.wahlsystem.dto.LoginRequest;
import com.example.wahlsystem.dto.RegisterRequest;
import com.example.wahlsystem.dto.UserDto;
import com.example.wahlsystem.security.UserPrincipal;
import com.example.wahlsystem.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Authentication and authorization endpoints")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "Login with username and password")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/register")
    @Operation(summary = "Register a new user")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/register/admin")
    @Operation(summary = "Register a new admin (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AuthResponse> registerAdmin(@Valid @RequestBody RegisterRequest request) {
        request.setRole(com.example.wahlsystem.enums.UserRole.ADMIN);
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/register/teacher")
    @Operation(summary = "Register a new teacher (admin only)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AuthResponse> registerTeacher(@Valid @RequestBody RegisterRequest request) {
        request.setRole(com.example.wahlsystem.enums.UserRole.TEACHER);
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/register/student")
    @Operation(summary = "Register a new student (admin or teacher)")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    public ResponseEntity<AuthResponse> registerStudent(@Valid @RequestBody RegisterRequest request) {
        request.setRole(com.example.wahlsystem.enums.UserRole.STUDENT);
        return ResponseEntity.ok(authService.register(request));
    }

    @GetMapping("/me")
    @Operation(summary = "Get current authenticated user")
    public ResponseEntity<UserDto> getCurrentUser(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        return ResponseEntity.ok(authService.getCurrentUser(userPrincipal.getId()));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh access token")
    public ResponseEntity<AuthResponse> refreshToken(@RequestBody Map<String, String> request) {
        String refreshToken = request.get("refreshToken");
        return ResponseEntity.ok(authService.refreshToken(refreshToken));
    }

    @PostMapping("/logout")
    @Operation(summary = "Logout (client-side token removal)")
    public ResponseEntity<Map<String, String>> logout() {
        // JWT is stateless, so we just return success
        // Client should remove the token
        return ResponseEntity.ok(Map.of("message", "Logged out successfully"));
    }
}
