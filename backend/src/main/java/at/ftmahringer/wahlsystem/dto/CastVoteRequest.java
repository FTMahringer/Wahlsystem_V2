package at.ftmahringer.wahlsystem.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import lombok.Data;

@Data
public class CastVoteRequest {

    @NotNull
    private Long electionId;

    @NotBlank
    private String token;

    private Long candidateId;

    private List<Long> candidateIds;

    private List<Long> rankedCandidateIds;
}
