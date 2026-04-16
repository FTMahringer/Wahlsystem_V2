package at.ftmahringer.wahlsystem.repository;

import at.ftmahringer.wahlsystem.entity.SchoolClass;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SchoolClassRepository extends JpaRepository<SchoolClass, Long> {

    Optional<SchoolClass> findByName(String name);

    List<SchoolClass> findByClassTeacherId(Long classTeacherId);

    List<SchoolClass> findByActiveTrue();
}
