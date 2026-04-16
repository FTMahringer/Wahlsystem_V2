package at.ftmahringer.wahlsystem.repository;

import at.ftmahringer.wahlsystem.entity.StudentVoteToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentVoteTokenRepository extends JpaRepository<StudentVoteToken, Long> {

    Optional<StudentVoteToken> findByToken(String token);

    List<StudentVoteToken> findByStudentId(Long studentId);

    List<StudentVoteToken> findByElectionId(Long electionId);

    List<StudentVoteToken> findByStudentIdAndUsedFalse(Long studentId);

    Optional<StudentVoteToken> findByTokenAndUsedFalse(String token);
}
