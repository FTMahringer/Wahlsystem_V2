package at.ftmahringer.wahlsystem.service;

import at.ftmahringer.wahlsystem.dto.ElectionDto;
import at.ftmahringer.wahlsystem.dto.ElectionResultDto;
import at.ftmahringer.wahlsystem.entity.Candidate;
import at.ftmahringer.wahlsystem.entity.Election;
import at.ftmahringer.wahlsystem.enums.ElectionStatus;
import at.ftmahringer.wahlsystem.repository.CandidateRepository;
import at.ftmahringer.wahlsystem.repository.ElectionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ElectionService {

    private final ElectionRepository electionRepository;
    private final CandidateRepository candidateRepository;

    public List<ElectionDto> getAllPublicElections() {
        return electionRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public List<ElectionDto> getActiveElections() {
        return electionRepository.findByStatus(ElectionStatus.ACTIVE).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public List<ElectionDto> getEndedElections() {
        return electionRepository.findByStatus(ElectionStatus.ENDED).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public ElectionDto getElectionById(Long id) {
        Election election = electionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Election not found"));
        return mapToDto(election);
    }

    public ElectionResultDto getElectionResults(Long electionId) {
        Election election = electionRepository.findById(electionId)
                .orElseThrow(() -> new RuntimeException("Election not found"));

        if (election.getStatus() != ElectionStatus.ENDED) {
            throw new RuntimeException("Election results are only available for ended elections");
        }

        List<Candidate> candidates = candidateRepository.findByElectionId(electionId);

        // Calculate total votes
        int totalVotes = candidates.stream().mapToInt(Candidate::getVoteCount).sum();

        // Find max votes
        int maxVotes = candidates.stream().mapToInt(Candidate::getVoteCount).max().orElse(0);

        // Build candidate results
        List<ElectionResultDto.CandidateResultDto> results = candidates.stream()
                .map(c -> ElectionResultDto.CandidateResultDto.builder()
                        .candidateId(c.getId())
                        .firstName(c.getFirstName())
                        .lastName(c.getLastName())
                        .className(c.getClassName())
                        .description(c.getDescription())
                        .voteCount(c.getVoteCount())
                        .percentage(totalVotes > 0 ? (c.getVoteCount() * 100.0 / totalVotes) : 0.0)
                        .winner(c.getVoteCount() == maxVotes && maxVotes > 0)
                        .build())
                .sorted(Comparator.comparingInt(ElectionResultDto.CandidateResultDto::getVoteCount).reversed())
                .collect(Collectors.toList());

        List<ElectionResultDto.CandidateResultDto> winners = results.stream()
                .filter(ElectionResultDto.CandidateResultDto::isWinner)
                .collect(Collectors.toList());

        return ElectionResultDto.builder()
                .electionId(election.getId())
                .electionTitle(election.getTitle())
                .endedAt(election.getEndAt())
                .totalVotes(totalVotes)
                .results(results)
                .winners(winners)
                .build();
    }

    private ElectionDto mapToDto(Election election) {
        return ElectionDto.builder()
                .id(election.getId())
                .title(election.getTitle())
                .description(election.getDescription())
                .type(election.getType())
                .status(election.getStatus())
                .startAt(election.getStartAt())
                .endAt(election.getEndAt())
                .createdBy(election.getCreatedBy())
                .createdAt(election.getCreatedAt())
                .updatedAt(election.getUpdatedAt())
                .build();
    }
}
