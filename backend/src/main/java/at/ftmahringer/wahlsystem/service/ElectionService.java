package at.ftmahringer.wahlsystem.service;

import at.ftmahringer.wahlsystem.dto.ElectionDto;
import at.ftmahringer.wahlsystem.dto.ElectionResultDto;
import at.ftmahringer.wahlsystem.dto.ElectionUpsertRequest;
import at.ftmahringer.wahlsystem.entity.Candidate;
import at.ftmahringer.wahlsystem.entity.Election;
import at.ftmahringer.wahlsystem.entity.SchoolClass;
import at.ftmahringer.wahlsystem.entity.Teacher;
import at.ftmahringer.wahlsystem.entity.User;
import at.ftmahringer.wahlsystem.enums.ElectionStatus;
import at.ftmahringer.wahlsystem.enums.ElectionType;
import at.ftmahringer.wahlsystem.repository.CandidateRepository;
import at.ftmahringer.wahlsystem.repository.ElectionRepository;
import at.ftmahringer.wahlsystem.repository.SchoolClassRepository;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ElectionService {

    private final ElectionRepository electionRepository;
    private final CandidateRepository candidateRepository;
    private final SchoolClassRepository schoolClassRepository;

    public List<ElectionDto> getAllPublicElections() {
        return electionRepository
            .findAllByOrderByCreatedAtDesc()
            .stream()
            .map(this::mapToDto)
            .collect(Collectors.toList());
    }

    public List<ElectionDto> getActiveElections() {
        return electionRepository
            .findByStatus(ElectionStatus.ACTIVE)
            .stream()
            .map(this::mapToDto)
            .collect(Collectors.toList());
    }

    public List<ElectionDto> getEndedElections() {
        return electionRepository
            .findByStatus(ElectionStatus.ENDED)
            .stream()
            .map(this::mapToDto)
            .collect(Collectors.toList());
    }

    public ElectionDto getElectionById(Long id) {
        return mapToDto(getElection(id));
    }

    public ElectionResultDto getElectionResults(Long electionId) {
        Election election = getElection(electionId);

        if (election.getStatus() != ElectionStatus.ENDED) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Election results are only available for ended elections"
            );
        }

        List<Candidate> candidates =
            candidateRepository.findByElectionIdOrderBySortOrderAscIdAsc(
                electionId
            );
        int totalVotes = candidates
            .stream()
            .mapToInt(Candidate::getVoteCount)
            .sum();
        int maxVotes = candidates
            .stream()
            .mapToInt(Candidate::getVoteCount)
            .max()
            .orElse(0);

        List<ElectionResultDto.CandidateResultDto> results = candidates
            .stream()
            .map(candidate ->
                ElectionResultDto.CandidateResultDto.builder()
                    .candidateId(candidate.getId())
                    .firstName(candidate.getFirstName())
                    .lastName(candidate.getLastName())
                    .className(candidate.getClassName())
                    .description(candidate.getDescription())
                    .voteCount(candidate.getVoteCount())
                    .percentage(
                        totalVotes > 0
                            ? ((candidate.getVoteCount() * 100.0) / totalVotes)
                            : 0.0
                    )
                    .winner(
                        candidate.getVoteCount() == maxVotes && maxVotes > 0
                    )
                    .build()
            )
            .sorted(
                Comparator.comparingInt(
                    ElectionResultDto.CandidateResultDto::getVoteCount
                ).reversed()
            )
            .collect(Collectors.toList());

        List<ElectionResultDto.CandidateResultDto> winners = results
            .stream()
            .filter(ElectionResultDto.CandidateResultDto::isWinner)
            .collect(Collectors.toList());

        return ElectionResultDto.builder()
            .electionId(election.getId())
            .electionTitle(election.getTitle())
            .endedAt(election.getEndAt())
            .totalVotes(totalVotes)
            .resultMetricLabel(
                election.getType() == ElectionType.BORDA_COUNT
                    ? "points"
                    : "votes"
            )
            .results(results)
            .winners(winners)
            .build();
    }

    @Transactional
    public ElectionDto createElection(
        ElectionUpsertRequest request,
        String createdByUsername,
        User creator
    ) {
        validateRequest(request);

        // If creator is a teacher and a school class is specified,
        // verify they are the class teacher
        if (
            request.getSchoolClassId() != null &&
            creator instanceof Teacher teacher
        ) {
            SchoolClass schoolClass = schoolClassRepository
                .findById(request.getSchoolClassId())
                .orElseThrow(() ->
                    new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "School class not found"
                    )
                );
            if (
                schoolClass.getClassTeacher() == null ||
                !schoolClass.getClassTeacher().getId().equals(teacher.getId())
            ) {
                throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "You can only create elections for classes you teach"
                );
            }
        }

        Election election = Election.builder()
            .title(request.getTitle().trim())
            .description(normalize(request.getDescription()))
            .type(request.getType())
            .status(
                resolveStatus(
                    request.getStatus(),
                    request.getStartAt(),
                    request.getEndAt(),
                    true
                )
            )
            .startAt(request.getStartAt())
            .endAt(request.getEndAt())
            .maxSelections(resolveMaxSelections(request))
            .createdBy(createdByUsername)
            .build();

        if (request.getSchoolClassId() != null) {
            SchoolClass schoolClass = schoolClassRepository
                .findById(request.getSchoolClassId())
                .orElseThrow(() ->
                    new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "School class not found"
                    )
                );
            election.setSchoolClass(schoolClass);
        }

        return mapToDto(electionRepository.save(election));
    }

    @Transactional
    public ElectionDto updateElection(Long id, ElectionUpsertRequest request) {
        validateRequest(request);

        Election election = getElection(id);
        election.setTitle(request.getTitle().trim());
        election.setDescription(normalize(request.getDescription()));
        election.setType(request.getType());
        election.setStartAt(request.getStartAt());
        election.setEndAt(request.getEndAt());
        election.setMaxSelections(resolveMaxSelections(request));
        election.setStatus(
            resolveStatus(
                request.getStatus(),
                request.getStartAt(),
                request.getEndAt(),
                false
            )
        );

        if (request.getSchoolClassId() != null) {
            SchoolClass schoolClass = schoolClassRepository
                .findById(request.getSchoolClassId())
                .orElseThrow(() ->
                    new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "School class not found"
                    )
                );
            election.setSchoolClass(schoolClass);
        } else {
            election.setSchoolClass(null);
        }

        return mapToDto(electionRepository.save(election));
    }

    @Transactional
    public void deleteElection(Long id) {
        Election election = getElection(id);
        List<Candidate> candidates = candidateRepository.findByElectionId(id);
        if (!candidates.isEmpty()) {
            candidateRepository.deleteAll(candidates);
        }
        electionRepository.delete(election);
    }

    private Election getElection(Long id) {
        return electionRepository
            .findById(id)
            .orElseThrow(() ->
                new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "Election not found"
                )
            );
    }

    private void validateRequest(ElectionUpsertRequest request) {
        if (
            request.getStartAt() != null &&
            request.getEndAt() != null &&
            !request.getEndAt().isAfter(request.getStartAt())
        ) {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "End date must be after the start date"
            );
        }

        if (request.getType() == ElectionType.LIMITED_VOTE) {
            if (
                request.getMaxSelections() == null ||
                request.getMaxSelections() < 1
            ) {
                throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Limited vote elections require a max selection limit"
                );
            }
        }
    }

    private Integer resolveMaxSelections(ElectionUpsertRequest request) {
        return request.getType() == ElectionType.LIMITED_VOTE
            ? request.getMaxSelections()
            : null;
    }

    private ElectionStatus resolveStatus(
        ElectionStatus requestedStatus,
        LocalDateTime startAt,
        LocalDateTime endAt,
        boolean creating
    ) {
        if (requestedStatus == null) {
            return creating
                ? ElectionStatus.DRAFT
                : determinePublishedStatus(startAt, endAt);
        }

        if (requestedStatus == ElectionStatus.DRAFT) {
            return ElectionStatus.DRAFT;
        }

        if (requestedStatus == ElectionStatus.ARCHIVED) {
            return ElectionStatus.ARCHIVED;
        }

        return determinePublishedStatus(startAt, endAt);
    }

    private ElectionStatus determinePublishedStatus(
        LocalDateTime startAt,
        LocalDateTime endAt
    ) {
        LocalDateTime now = LocalDateTime.now();

        if (endAt != null && !endAt.isAfter(now)) {
            return ElectionStatus.ENDED;
        }

        if (startAt != null && startAt.isAfter(now)) {
            return ElectionStatus.PLANNED;
        }

        return ElectionStatus.ACTIVE;
    }

    private ElectionDto mapToDto(Election election) {
        ElectionDto.ElectionDtoBuilder builder = ElectionDto.builder()
            .id(election.getId())
            .title(election.getTitle())
            .description(election.getDescription())
            .type(election.getType())
            .status(election.getStatus())
            .startAt(election.getStartAt())
            .endAt(election.getEndAt())
            .maxSelections(election.getMaxSelections())
            .createdBy(election.getCreatedBy())
            .createdAt(election.getCreatedAt())
            .updatedAt(election.getUpdatedAt());

        if (election.getSchoolClass() != null) {
            builder.schoolClassId(election.getSchoolClass().getId());
            builder.schoolClassName(election.getSchoolClass().getName());
        }

        return builder.build();
    }

    private String normalize(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
