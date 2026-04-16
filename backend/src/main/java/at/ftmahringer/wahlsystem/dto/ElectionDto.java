package at.ftmahringer.wahlsystem.dto;

import at.ftmahringer.wahlsystem.enums.ElectionStatus;
import at.ftmahringer.wahlsystem.enums.ElectionType;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

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
    private String createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
