package at.ftmahringer.wahlsystem.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class ElectionResultDto {

    private Long electionId;
    private String electionTitle;
    private LocalDateTime endedAt;
    private int totalVotes;
    private String resultMetricLabel;
    private List<CandidateResultDto> results;
    private List<CandidateResultDto> winners;

    @Data
    @Builder
    public static class CandidateResultDto {
        private Long candidateId;
        private String firstName;
        private String lastName;
        private String className;
        private String description;
        private int voteCount;
        private double percentage;
        private boolean winner;
    }
}
