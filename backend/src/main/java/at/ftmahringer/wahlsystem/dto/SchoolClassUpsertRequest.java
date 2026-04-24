package at.ftmahringer.wahlsystem.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SchoolClassUpsertRequest {

    @NotBlank
    private String name;

    private Integer gradeLevel;

    private String room;

    private Long classTeacherId;
}
