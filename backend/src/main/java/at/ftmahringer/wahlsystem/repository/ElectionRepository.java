package at.ftmahringer.wahlsystem.repository;

import at.ftmahringer.wahlsystem.entity.Election;
import at.ftmahringer.wahlsystem.enums.ElectionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ElectionRepository extends JpaRepository<Election, Long> {

    List<Election> findByStatus(ElectionStatus status);

    List<Election> findAllByOrderByCreatedAtDesc();
}
