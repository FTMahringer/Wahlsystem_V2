package at.ftmahringer.wahlsystem.controller;

import at.ftmahringer.wahlsystem.dto.ElectionDto;
import at.ftmahringer.wahlsystem.dto.ElectionResultDto;
import at.ftmahringer.wahlsystem.service.ElectionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/elections")
@RequiredArgsConstructor
@Tag(name = "Public Elections", description = "Public election information endpoints")
public class ElectionController {

    private final ElectionService electionService;

    @GetMapping
    @Operation(summary = "Get all public elections")
    public ResponseEntity<List<ElectionDto>> getAllElections() {
        return ResponseEntity.ok(electionService.getAllPublicElections());
    }

    @GetMapping("/active")
    @Operation(summary = "Get all active elections")
    public ResponseEntity<List<ElectionDto>> getActiveElections() {
        return ResponseEntity.ok(electionService.getActiveElections());
    }

    @GetMapping("/ended")
    @Operation(summary = "Get all ended elections")
    public ResponseEntity<List<ElectionDto>> getEndedElections() {
        return ResponseEntity.ok(electionService.getEndedElections());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get election by ID")
    public ResponseEntity<ElectionDto> getElectionById(@PathVariable Long id) {
        return ResponseEntity.ok(electionService.getElectionById(id));
    }

    @GetMapping("/{id}/results")
    @Operation(summary = "Get results for an ended election")
    public ResponseEntity<ElectionResultDto> getElectionResults(@PathVariable Long id) {
        return ResponseEntity.ok(electionService.getElectionResults(id));
    }
}
