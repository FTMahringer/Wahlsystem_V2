package at.ftmahringer.wahlsystem.controller;

import at.ftmahringer.wahlsystem.dto.StudentTokenDto;
import at.ftmahringer.wahlsystem.security.UserPrincipal;
import at.ftmahringer.wahlsystem.service.TokenService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/student/tokens")
@RequiredArgsConstructor
@Tag(name = "Student Tokens", description = "Student voting token endpoints")
public class StudentTokenController {

    private final TokenService tokenService;

    @GetMapping
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Get my voting tokens")
    public ResponseEntity<List<StudentTokenDto>> getMyTokens(
        @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        return ResponseEntity.ok(
            tokenService.getMyTokens(userPrincipal.getId())
        );
    }
}
