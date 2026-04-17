package at.ftmahringer.wahlsystem.service;

import at.ftmahringer.wahlsystem.dto.CandidateDto;
import at.ftmahringer.wahlsystem.dto.CandidateUpsertRequest;
import at.ftmahringer.wahlsystem.entity.Candidate;
import at.ftmahringer.wahlsystem.entity.Election;
import at.ftmahringer.wahlsystem.enums.ElectionType;
import at.ftmahringer.wahlsystem.repository.CandidateRepository;
import at.ftmahringer.wahlsystem.repository.ElectionRepository;
import java.util.List;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class CandidateService {

    private final CandidateRepository candidateRepository;
    private final ElectionRepository electionRepository;

    @Transactional(readOnly = true)
    public List<CandidateDto> getCandidatesByElection(Long electionId) {
        ensureElectionExists(electionId);
        return candidateRepository
            .findByElectionIdOrderBySortOrderAscIdAsc(electionId)
            .stream()
            .map(this::mapToDto)
            .collect(Collectors.toList());
    }

    @Transactional
    public CandidateDto createCandidate(CandidateUpsertRequest request) {
        Election election = getElection(request.getElectionId());
        validateCandidateLimit(election, null);

        Candidate candidate = Candidate
            .builder()
            .firstName(request.getFirstName().trim())
            .lastName(request.getLastName().trim())
            .className(normalize(request.getClassName()))
            .description(normalize(request.getDescription()))
            .sortOrder(resolveSortOrder(request.getSortOrder(), election.getId()))
            .active(true)
            .voteCount(0)
            .election(election)
            .build();

        return mapToDto(candidateRepository.save(candidate));
    }

    @Transactional
    public CandidateDto updateCandidate(Long id, CandidateUpsertRequest request) {
        Candidate candidate = candidateRepository
            .findById(id)
            .orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "Candidate not found")
            );

        Election election = getElection(request.getElectionId());
        validateCandidateLimit(election, candidate.getId());

        candidate.setElection(election);
        candidate.setFirstName(request.getFirstName().trim());
        candidate.setLastName(request.getLastName().trim());
        candidate.setClassName(normalize(request.getClassName()));
        candidate.setDescription(normalize(request.getDescription()));
        candidate.setSortOrder(resolveSortOrder(request.getSortOrder(), election.getId()));

        return mapToDto(candidateRepository.save(candidate));
    }

    @Transactional
    public void deleteCandidate(Long id) {
        Candidate candidate = candidateRepository
            .findById(id)
            .orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "Candidate not found")
            );
        candidateRepository.delete(candidate);
    }

    private void ensureElectionExists(Long electionId) {
        if (!electionRepository.existsById(electionId)) {
            throw new ResponseStatusException(
                HttpStatus.NOT_FOUND,
                "Election not found"
            );
        }
    }

    private Election getElection(Long electionId) {
        return electionRepository
            .findById(electionId)
            .orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "Election not found")
            );
    }

    private void validateCandidateLimit(Election election, Long currentCandidateId) {
        if (election.getType() != ElectionType.BINARY_CHOICE) {
            return;
        }

        long candidateCount = candidateRepository.countByElectionId(election.getId());
        boolean addingNewCandidate = currentCandidateId == null;
        if (addingNewCandidate && candidateCount >= 2) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Binary choice elections can only have exactly two candidates"
            );
        }
    }

    private Integer resolveSortOrder(Integer requestedSortOrder, Long electionId) {
        if (requestedSortOrder != null) {
            return requestedSortOrder;
        }

        return candidateRepository
                .findByElectionIdOrderBySortOrderAscIdAsc(electionId)
                .stream()
                .map(Candidate::getSortOrder)
                .max(Integer::compareTo)
                .orElse(-1) +
            1;
    }

    private CandidateDto mapToDto(Candidate candidate) {
        return CandidateDto
            .builder()
            .id(candidate.getId())
            .firstName(candidate.getFirstName())
            .lastName(candidate.getLastName())
            .className(candidate.getClassName())
            .description(candidate.getDescription())
            .sortOrder(candidate.getSortOrder())
            .active(candidate.getActive())
            .electionId(candidate.getElection().getId())
            .build();
    }

    private String normalize(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
