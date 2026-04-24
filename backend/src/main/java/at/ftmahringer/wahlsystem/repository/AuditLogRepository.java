package at.ftmahringer.wahlsystem.repository;

import at.ftmahringer.wahlsystem.entity.AuditLog;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    List<AuditLog> findByOrderByTimestampDesc(Pageable pageable);

    List<AuditLog> findByActorIdOrderByTimestampDesc(Long actorId, Pageable pageable);

    List<AuditLog> findByResourceTypeAndResourceIdOrderByTimestampDesc(
        String resourceType,
        Long resourceId,
        Pageable pageable
    );

    List<AuditLog> findByActionContainingIgnoreCaseOrderByTimestampDesc(
        String action,
        Pageable pageable
    );

    List<AuditLog> findByTimestampBetweenOrderByTimestampDesc(
        LocalDateTime start,
        LocalDateTime end,
        Pageable pageable
    );

    long countByTimestampBetween(LocalDateTime start, LocalDateTime end);
}
