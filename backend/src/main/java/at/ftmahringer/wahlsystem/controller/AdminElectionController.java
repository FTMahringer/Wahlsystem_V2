package at.ftmahringer.wahlsystem.controller;

import at.ftmahringer.wahlsystem.dto.ElectionDto;
import at.ftmahringer.wahlsystem.dto.ElectionResultDto;
import at.ftmahringer.wahlsystem.dto.ElectionUpsertRequest;
import at.ftmahringer.wahlsystem.entity.User;
import at.ftmahringer.wahlsystem.security.UserPrincipal;
import at.ftmahringer.wahlsystem.service.AuthService;
import at.ftmahringer.wahlsystem.service.ElectionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/elections")
@RequiredArgsConstructor
@Tag(
    name = "Admin Elections",
    description = "Admin election management endpoints"
)
public class AdminElectionController {

    private final ElectionService electionService;
    private final AuthService authService;

    @PostMapping
    @Operation(summary = "Create a new election")
    public ResponseEntity<ElectionDto> createElection(
        @Valid @RequestBody ElectionUpsertRequest request,
        @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        User creator = authService.getUserById(userPrincipal.getId());
        return ResponseEntity.ok(
            electionService.createElection(
                request,
                userPrincipal.getUsername(),
                creator
            )
        );
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update an election")
    public ResponseEntity<ElectionDto> updateElection(
        @PathVariable Long id,
        @Valid @RequestBody ElectionUpsertRequest request
    ) {
        return ResponseEntity.ok(electionService.updateElection(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete an election")
    public ResponseEntity<Map<String, String>> deleteElection(
        @PathVariable Long id
    ) {
        electionService.deleteElection(id);
        return ResponseEntity.ok(
            Map.of("message", "Election deleted successfully")
        );
    }

    @GetMapping("/{id}/results")
    @Operation(summary = "Get results for an election")
    public ResponseEntity<ElectionResultDto> getElectionResults(
        @PathVariable Long id
    ) {
        return ResponseEntity.ok(electionService.getElectionResults(id));
    }
}
