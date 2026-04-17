package at.ftmahringer.wahlsystem.controller;

import at.ftmahringer.wahlsystem.dto.CandidateDto;
import at.ftmahringer.wahlsystem.dto.CandidateUpsertRequest;
import at.ftmahringer.wahlsystem.service.CandidateService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/candidates")
@RequiredArgsConstructor
@Tag(name = "Admin Candidates", description = "Admin candidate management endpoints")
public class AdminCandidateController {

    private final CandidateService candidateService;

    @PostMapping
    @Operation(summary = "Create a candidate")
    public ResponseEntity<CandidateDto> createCandidate(
        @Valid @RequestBody CandidateUpsertRequest request
    ) {
        return ResponseEntity.ok(candidateService.createCandidate(request));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update a candidate")
    public ResponseEntity<CandidateDto> updateCandidate(
        @PathVariable Long id,
        @Valid @RequestBody CandidateUpsertRequest request
    ) {
        return ResponseEntity.ok(candidateService.updateCandidate(id, request));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a candidate")
    public ResponseEntity<Map<String, String>> deleteCandidate(
        @PathVariable Long id
    ) {
        candidateService.deleteCandidate(id);
        return ResponseEntity.ok(Map.of("message", "Candidate deleted successfully"));
    }
}
