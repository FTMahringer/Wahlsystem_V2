package at.ftmahringer.wahlsystem.controller;

import at.ftmahringer.wahlsystem.dto.TokenDistributionDto;
import at.ftmahringer.wahlsystem.security.UserPrincipal;
import at.ftmahringer.wahlsystem.service.TokenService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/teacher/elections")
@RequiredArgsConstructor
@Tag(
    name = "Teacher Token Distribution",
    description = "Token distribution endpoints for teachers"
)
public class TeacherTokenController {

    private final TokenService tokenService;

    @GetMapping("/{electionId}/tokens")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(
        summary = "Get token distribution for an election and school class"
    )
    public ResponseEntity<TokenDistributionDto> getTokenDistribution(
        @PathVariable Long electionId,
        @RequestParam Long schoolClassId,
        @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        return ResponseEntity.ok(
            tokenService.getTokenDistribution(
                electionId,
                schoolClassId,
                userPrincipal.getId()
            )
        );
    }

    @PostMapping("/{electionId}/tokens/generate")
    @PreAuthorize("hasAnyRole('TEACHER', 'ADMIN')")
    @Operation(
        summary = "Generate tokens for all students in a class for an election"
    )
    public ResponseEntity<TokenDistributionDto> generateTokens(
        @PathVariable Long electionId,
        @RequestParam Long schoolClassId,
        @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        return ResponseEntity.ok(
            tokenService.generateTokensForElection(
                electionId,
                schoolClassId,
                userPrincipal.getId()
            )
        );
    }
}
