package at.ftmahringer.wahlsystem.controller;

import at.ftmahringer.wahlsystem.dto.AuthResponse;
import at.ftmahringer.wahlsystem.dto.DevLoginRequest;
import at.ftmahringer.wahlsystem.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Profile("dev")
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(
    name = "Development Authentication",
    description = "Dev-only authentication helpers"
)
public class DevAuthController {

    private final AuthService authService;

    @PostMapping("/dev-login")
    @Operation(summary = "Dev-only login by username")
    public ResponseEntity<AuthResponse> devLogin(
        @Valid @RequestBody DevLoginRequest request
    ) {
        return ResponseEntity.ok(authService.devLogin(request.getUsername()));
    }
}
