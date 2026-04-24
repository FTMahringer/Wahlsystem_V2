package at.ftmahringer.wahlsystem.service;

import at.ftmahringer.wahlsystem.dto.AuditLogDto;
import at.ftmahringer.wahlsystem.entity.AuditLog;
import at.ftmahringer.wahlsystem.repository.AuditLogRepository;
import at.ftmahringer.wahlsystem.security.UserPrincipal;
import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final AuditLogRepository auditLogRepository;

    @Transactional
    public void log(
        String action,
        UserPrincipal actor,
        String resourceType,
        Long resourceId,
        String details,
        HttpServletRequest request,
        boolean success,
        String errorMessage
    ) {
        AuditLog.AuditLogBuilder builder = AuditLog.builder()
            .action(action)
            .resourceType(resourceType)
            .resourceId(resourceId)
            .details(details)
            .success(success)
            .errorMessage(errorMessage);

        if (actor != null) {
            builder
                .actorId(actor.getId())
                .actorUsername(actor.getUsername())
                .actorRole(
                    actor.getAuthorities().isEmpty()
                        ? null
                        : actor.getAuthorities().iterator().next().getAuthority()
                );
        }

        if (request != null) {
            builder
                .ipAddress(getClientIp(request))
                .userAgent(request.getHeader("User-Agent"))
                .endpoint(request.getRequestURI())
                .httpMethod(request.getMethod());
        }

        auditLogRepository.save(builder.build());
    }

    @Transactional
    public void logSimple(
        String action,
        Long actorId,
        String actorUsername,
        String actorRole,
        String resourceType,
        Long resourceId,
        String details,
        boolean success
    ) {
        AuditLog log = AuditLog.builder()
            .action(action)
            .actorId(actorId)
            .actorUsername(actorUsername)
            .actorRole(actorRole)
            .resourceType(resourceType)
            .resourceId(resourceId)
            .details(details)
            .success(success)
            .build();
        auditLogRepository.save(log);
    }

    @Transactional(readOnly = true)
    public List<AuditLogDto> getRecentLogs(int limit) {
        Pageable pageable = PageRequest.of(0, limit);
        return auditLogRepository
            .findByOrderByTimestampDesc(pageable)
            .stream()
            .map(this::mapToDto)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<AuditLogDto> getLogsByActor(Long actorId, int limit) {
        Pageable pageable = PageRequest.of(0, limit);
        return auditLogRepository
            .findByActorIdOrderByTimestampDesc(actorId, pageable)
            .stream()
            .map(this::mapToDto)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<AuditLogDto> getLogsByResource(
        String resourceType,
        Long resourceId,
        int limit
    ) {
        Pageable pageable = PageRequest.of(0, limit);
        return auditLogRepository
            .findByResourceTypeAndResourceIdOrderByTimestampDesc(
                resourceType,
                resourceId,
                pageable
            )
            .stream()
            .map(this::mapToDto)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<AuditLogDto> searchLogs(String query, int limit) {
        Pageable pageable = PageRequest.of(0, limit);
        return auditLogRepository
            .findByActionContainingIgnoreCaseOrderByTimestampDesc(query, pageable)
            .stream()
            .map(this::mapToDto)
            .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<AuditLogDto> getLogsInRange(
        LocalDateTime start,
        LocalDateTime end,
        int limit
    ) {
        Pageable pageable = PageRequest.of(0, limit);
        return auditLogRepository
            .findByTimestampBetweenOrderByTimestampDesc(start, end, pageable)
            .stream()
            .map(this::mapToDto)
            .collect(Collectors.toList());
    }

    private AuditLogDto mapToDto(AuditLog log) {
        return AuditLogDto.builder()
            .id(log.getId())
            .timestamp(log.getTimestamp())
            .action(log.getAction())
            .actorId(log.getActorId())
            .actorUsername(log.getActorUsername())
            .actorRole(log.getActorRole())
            .resourceType(log.getResourceType())
            .resourceId(log.getResourceId())
            .details(log.getDetails())
            .ipAddress(log.getIpAddress())
            .success(log.getSuccess())
            .errorMessage(log.getErrorMessage())
            .endpoint(log.getEndpoint())
            .httpMethod(log.getHttpMethod())
            .build();
    }

    private String getClientIp(HttpServletRequest request) {
        String xfHeader = request.getHeader("X-Forwarded-For");
        if (xfHeader != null && !xfHeader.isBlank()) {
            return xfHeader.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
