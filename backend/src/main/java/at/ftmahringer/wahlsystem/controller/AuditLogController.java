package at.ftmahringer.wahlsystem.controller;

import at.ftmahringer.wahlsystem.dto.AuditLogDto;
import at.ftmahringer.wahlsystem.service.AuditLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/audit")
@RequiredArgsConstructor
@Tag(name = "Audit Logs", description = "Audit log endpoints")
public class AuditLogController {

    private final AuditLogService auditLogService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Get recent audit logs")
    public ResponseEntity<List<AuditLogDto>> getRecentLogs(
        @RequestParam(defaultValue = "100") int limit
    ) {
        return ResponseEntity.ok(auditLogService.getRecentLogs(limit));
    }

    @GetMapping("/search")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Search audit logs by action")
    public ResponseEntity<List<AuditLogDto>> searchLogs(
        @RequestParam String query,
        @RequestParam(defaultValue = "100") int limit
    ) {
        return ResponseEntity.ok(auditLogService.searchLogs(query, limit));
    }

    @GetMapping("/range")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Get audit logs in a date range")
    public ResponseEntity<List<AuditLogDto>> getLogsInRange(
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end,
        @RequestParam(defaultValue = "100") int limit
    ) {
        return ResponseEntity.ok(auditLogService.getLogsInRange(start, end, limit));
    }
}
