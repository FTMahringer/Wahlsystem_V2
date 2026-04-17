package at.ftmahringer.wahlsystem.controller;

import at.ftmahringer.wahlsystem.dto.CastVoteRequest;
import at.ftmahringer.wahlsystem.service.VotingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/votes")
@RequiredArgsConstructor
@Tag(name = "Voting", description = "Voting endpoints")
public class VoteController {

    private final VotingService votingService;

    @PostMapping
    @Operation(summary = "Cast a vote using a student election token")
    public ResponseEntity<Map<String, String>> castVote(
        @Valid @RequestBody CastVoteRequest request
    ) {
        votingService.castVote(request);
        return ResponseEntity.ok(Map.of("message", "Vote submitted successfully"));
    }
}
