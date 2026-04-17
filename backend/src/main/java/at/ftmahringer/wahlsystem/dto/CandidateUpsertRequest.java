package at.ftmahringer.wahlsystem.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CandidateUpsertRequest {

    @NotBlank
    private String firstName;

    @NotBlank
    private String lastName;

    private String className;

    private String description;

    private Integer sortOrder;

    @NotNull
    private Long electionId;
}
