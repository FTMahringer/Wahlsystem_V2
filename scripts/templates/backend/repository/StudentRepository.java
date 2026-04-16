package at.ftmahringer.wahlsystem.repository;

import at.ftmahringer.wahlsystem.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, Long> {

    Optional<Student> findByStudentId(String studentId);

    List<Student> findByClassName(String className);

    List<Student> findByGradeLevel(Integer gradeLevel);

    Optional<Student> findByVotingToken(String votingToken);

    Optional<Student> findByUsername(String username);

    List<Student> findByCanVoteTrue();
}
