package at.ftmahringer.wahlsystem.dto;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TokenDistributionDto {

    private Long electionId;
    private String electionTitle;
    private Long schoolClassId;
    private String schoolClassName;
    private List<StudentTokenEntryDto> entries;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StudentTokenEntryDto {

        private Long studentId;
        private String studentName;
        private String studentUsername;
        private String token;
        private Boolean used;
    }
}
