package at.ftmahringer.wahlsystem.dto;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuditLogDto {

    private Long id;
    private LocalDateTime timestamp;
    private String action;
    private Long actorId;
    private String actorUsername;
    private String actorRole;
    private String resourceType;
    private Long resourceId;
    private String details;
    private String ipAddress;
    private Boolean success;
    private String errorMessage;
    private String endpoint;
    private String httpMethod;
}
