package at.ftmahringer.wahlsystem.dto;

import at.ftmahringer.wahlsystem.enums.ElectionStatus;
import at.ftmahringer.wahlsystem.enums.ElectionType;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ElectionDto {

    private Long id;
    private String title;
    private String description;
    private ElectionType type;
    private ElectionStatus status;
    private LocalDateTime startAt;
    private LocalDateTime endAt;
    private Integer maxSelections;
    private String createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Optional class scope
    private Long schoolClassId;
    private String schoolClassName;
}
