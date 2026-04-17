package at.ftmahringer.wahlsystem.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CandidateDto {

    private Long id;
    private String firstName;
    private String lastName;
    private String className;
    private String description;
    private Integer sortOrder;
    private Boolean active;
    private Long electionId;
}
