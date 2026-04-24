package at.ftmahringer.wahlsystem.dto;

import at.ftmahringer.wahlsystem.enums.ElectionStatus;
import at.ftmahringer.wahlsystem.enums.ElectionType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
import lombok.Data;

@Data
public class ElectionUpsertRequest {

    @NotBlank
    private String title;

    private String description;

    @NotNull
    private ElectionType type;

    private ElectionStatus status;

    private LocalDateTime startAt;

    private LocalDateTime endAt;

    @Min(1)
    private Integer maxSelections;

    private Long schoolClassId;
}
