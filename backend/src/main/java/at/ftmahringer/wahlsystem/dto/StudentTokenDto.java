package at.ftmahringer.wahlsystem.dto;

import at.ftmahringer.wahlsystem.enums.ElectionStatus;
import at.ftmahringer.wahlsystem.enums.ElectionType;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StudentTokenDto {

    private Long id;
    private String token;
    private Boolean used;
    private LocalDateTime usedAt;
    private LocalDateTime createdAt;

    // Election info
    private Long electionId;
    private String electionTitle;
    private ElectionType electionType;
    private ElectionStatus electionStatus;
    private LocalDateTime electionEndAt;
}
