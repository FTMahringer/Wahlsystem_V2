package at.ftmahringer.wahlsystem.service;

import at.ftmahringer.wahlsystem.dto.CastVoteRequest;
import at.ftmahringer.wahlsystem.entity.Candidate;
import at.ftmahringer.wahlsystem.entity.Election;
import at.ftmahringer.wahlsystem.entity.StudentVoteToken;
import at.ftmahringer.wahlsystem.enums.ElectionStatus;
import at.ftmahringer.wahlsystem.enums.ElectionType;
import at.ftmahringer.wahlsystem.repository.CandidateRepository;
import at.ftmahringer.wahlsystem.repository.StudentVoteTokenRepository;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class VotingService {

    private final StudentVoteTokenRepository studentVoteTokenRepository;
    private final CandidateRepository candidateRepository;
    private final AuditLogService auditLogService;

    @Transactional
    public void castVote(CastVoteRequest request) {
        StudentVoteToken voteToken = getUnusedToken(request.getToken().trim());
        Election election = getElectionForToken(voteToken);

        if (!election.getId().equals(request.getElectionId())) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Voting token does not match the selected election"
            );
        }

        validateElectionOpen(election);

        List<Candidate> candidates =
            candidateRepository.findByElectionIdOrderBySortOrderAscIdAsc(
                election.getId()
            );
        Map<Long, Candidate> candidatesById = candidates
            .stream()
            .collect(Collectors.toMap(Candidate::getId, Function.identity()));

        switch (election.getType()) {
            case SINGLE_CHOICE, BINARY_CHOICE -> applySingleChoiceVote(
                request,
                candidatesById,
                election
            );
            case APPROVAL_VOTING -> applyApprovalVote(request, candidatesById);
            case LIMITED_VOTE -> applyLimitedVote(
                request,
                candidatesById,
                election
            );
            case BORDA_COUNT -> applyBordaVote(
                request,
                candidatesById,
                candidates.size()
            );
        }

        voteToken.setUsed(true);
        voteToken.setUsedAt(LocalDateTime.now());
        if (voteToken.getStudent() != null) {
            voteToken.getStudent().setHasVoted(true);
        }
        studentVoteTokenRepository.save(voteToken);

        auditLogService.logSimple(
            "VOTE_CAST",
            voteToken.getStudent() != null
                ? voteToken.getStudent().getId()
                : null,
            voteToken.getStudent() != null
                ? voteToken.getStudent().getUsername()
                : "anonymous",
            "ROLE_STUDENT",
            "ELECTION",
            election.getId(),
            "Vote cast in election: " +
                election.getTitle() +
                " (type: " +
                election.getType() +
                ")",
            true
        );
    }

    private void applySingleChoiceVote(
        CastVoteRequest request,
        Map<Long, Candidate> candidatesById,
        Election election
    ) {
        Candidate candidate = getCandidate(
            request.getCandidateId(),
            candidatesById,
            "A valid candidate selection is required"
        );

        if (
            election.getType() == ElectionType.BINARY_CHOICE &&
            candidatesById.size() != 2
        ) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Binary choice elections require exactly two candidates"
            );
        }

        incrementCandidate(candidate, 1);
    }

    private void applyApprovalVote(
        CastVoteRequest request,
        Map<Long, Candidate> candidatesById
    ) {
        List<Long> candidateIds = normalizeDistinctIds(
            request.getCandidateIds()
        );
        if (candidateIds.isEmpty()) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Select at least one candidate"
            );
        }

        for (Long candidateId : candidateIds) {
            incrementCandidate(
                getCandidate(
                    candidateId,
                    candidatesById,
                    "One or more selected candidates are invalid"
                ),
                1
            );
        }
    }

    private void applyLimitedVote(
        CastVoteRequest request,
        Map<Long, Candidate> candidatesById,
        Election election
    ) {
        List<Long> candidateIds = normalizeDistinctIds(
            request.getCandidateIds()
        );
        if (candidateIds.isEmpty()) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Select at least one candidate"
            );
        }

        Integer maxSelections = election.getMaxSelections();
        if (maxSelections == null || maxSelections < 1) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "This limited vote election is misconfigured"
            );
        }

        if (candidateIds.size() > maxSelections) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "You can select at most " + maxSelections + " candidates"
            );
        }

        for (Long candidateId : candidateIds) {
            incrementCandidate(
                getCandidate(
                    candidateId,
                    candidatesById,
                    "One or more selected candidates are invalid"
                ),
                1
            );
        }
    }

    private void applyBordaVote(
        CastVoteRequest request,
        Map<Long, Candidate> candidatesById,
        int candidateCount
    ) {
        List<Long> rankedCandidateIds = normalizeDistinctIds(
            request.getRankedCandidateIds()
        );
        if (rankedCandidateIds.size() != candidateCount) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Rank all candidates exactly once"
            );
        }

        int points = rankedCandidateIds.size();
        for (Long candidateId : rankedCandidateIds) {
            incrementCandidate(
                getCandidate(
                    candidateId,
                    candidatesById,
                    "One or more ranked candidates are invalid"
                ),
                points
            );
            points--;
        }
    }

    private Candidate getCandidate(
        Long candidateId,
        Map<Long, Candidate> candidatesById,
        String errorMessage
    ) {
        if (candidateId == null) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                errorMessage
            );
        }

        Candidate candidate = candidatesById.get(candidateId);
        if (candidate == null || !Boolean.TRUE.equals(candidate.getActive())) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                errorMessage
            );
        }

        return candidate;
    }

    private void incrementCandidate(Candidate candidate, int delta) {
        candidate.setVoteCount(candidate.getVoteCount() + delta);
        candidateRepository.save(candidate);
    }

    private List<Long> normalizeDistinctIds(List<Long> ids) {
        if (ids == null) {
            return List.of();
        }

        List<Long> cleanedIds = ids
            .stream()
            .filter(id -> id != null)
            .collect(Collectors.toCollection(ArrayList::new));

        if (cleanedIds.size() != new HashSet<>(cleanedIds).size()) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Duplicate candidate selections are not allowed"
            );
        }

        return cleanedIds;
    }

    private StudentVoteToken getUnusedToken(String token) {
        return studentVoteTokenRepository
            .findByTokenAndUsedFalse(token)
            .orElseThrow(() ->
                new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Invalid or already used voting token"
                )
            );
    }

    private Election getElectionForToken(StudentVoteToken voteToken) {
        if (voteToken.getElection() == null) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Voting token is not assigned to an election"
            );
        }
        return voteToken.getElection();
    }

    private void validateElectionOpen(Election election) {
        LocalDateTime now = LocalDateTime.now();

        if (
            election.getStatus() == ElectionStatus.DRAFT ||
            election.getStatus() == ElectionStatus.ARCHIVED ||
            election.getStatus() == ElectionStatus.ENDED
        ) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "This election is not open for voting"
            );
        }

        if (
            election.getStartAt() != null && election.getStartAt().isAfter(now)
        ) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "This election has not started yet"
            );
        }

        if (election.getEndAt() != null && !election.getEndAt().isAfter(now)) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "This election has already ended"
            );
        }
    }
}
