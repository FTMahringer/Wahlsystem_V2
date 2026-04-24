package at.ftmahringer.wahlsystem.service;

import at.ftmahringer.wahlsystem.dto.StudentTokenDto;
import at.ftmahringer.wahlsystem.dto.TokenDistributionDto;
import at.ftmahringer.wahlsystem.entity.Election;
import at.ftmahringer.wahlsystem.entity.SchoolClass;
import at.ftmahringer.wahlsystem.entity.Student;
import at.ftmahringer.wahlsystem.entity.StudentVoteToken;
import at.ftmahringer.wahlsystem.entity.Teacher;
import at.ftmahringer.wahlsystem.entity.User;
import at.ftmahringer.wahlsystem.repository.ElectionRepository;
import at.ftmahringer.wahlsystem.repository.SchoolClassRepository;
import at.ftmahringer.wahlsystem.repository.StudentRepository;
import at.ftmahringer.wahlsystem.repository.StudentVoteTokenRepository;
import at.ftmahringer.wahlsystem.repository.UserRepository;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class TokenService {

    private final StudentVoteTokenRepository tokenRepository;
    private final StudentRepository studentRepository;
    private final ElectionRepository electionRepository;
    private final SchoolClassRepository schoolClassRepository;
    private final UserRepository userRepository;

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    private static final int TOKEN_LENGTH = 12; // 16 chars in Base64

    /**
     * Get all tokens for the currently authenticated student.
     */
    @Transactional(readOnly = true)
    public List<StudentTokenDto> getMyTokens(Long studentUserId) {
        User user = userRepository
            .findById(studentUserId)
            .orElseThrow(() ->
                new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "User not found"
                )
            );

        if (!(user instanceof Student student)) {
            throw new ResponseStatusException(
                HttpStatus.FORBIDDEN,
                "Only students can access voting tokens"
            );
        }

        return tokenRepository
            .findByStudentId(student.getId())
            .stream()
            .map(this::mapToStudentTokenDto)
            .collect(Collectors.toList());
    }

    /**
     * Generate tokens for all students in a school class for a given election.
     * If tokens already exist, they are returned (no duplicates).
     * Only class teachers or admins can do this.
     */
    @Transactional
    public TokenDistributionDto generateTokensForElection(
        Long electionId,
        Long schoolClassId,
        Long requestingUserId
    ) {
        Election election = electionRepository
            .findById(electionId)
            .orElseThrow(() ->
                new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "Election not found"
                )
            );

        SchoolClass schoolClass = schoolClassRepository
            .findById(schoolClassId)
            .orElseThrow(() ->
                new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "School class not found"
                )
            );

        User requester = userRepository
            .findById(requestingUserId)
            .orElseThrow(() ->
                new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "User not found"
                )
            );

        // Check permission: admin or class teacher
        boolean isAdmin = requester instanceof at.ftmahringer.wahlsystem.entity.Admin;
        boolean isClassTeacher =
            requester instanceof Teacher teacher &&
            schoolClass.getClassTeacher() != null &&
            schoolClass.getClassTeacher().getId().equals(teacher.getId());

        if (!isAdmin && !isClassTeacher) {
            throw new ResponseStatusException(
                HttpStatus.FORBIDDEN,
                "Only admins or the class teacher can generate tokens"
            );
        }

        List<Student> students = studentRepository.findBySchoolClassId(
            schoolClassId
        );

        List<TokenDistributionDto.StudentTokenEntryDto> entries =
            new ArrayList<>();

        for (Student student : students) {
            // Check if token already exists for this student+election
            Optional<StudentVoteToken> existingToken = tokenRepository
                .findByStudentId(student.getId())
                .stream()
                .filter(t ->
                    t.getElection() != null &&
                    t.getElection().getId().equals(electionId)
                )
                .findFirst();

            StudentVoteToken token;
            if (existingToken.isPresent()) {
                token = existingToken.get();
            } else {
                token = createTokenForStudent(student, election);
            }

            entries.add(
                TokenDistributionDto.StudentTokenEntryDto
                    .builder()
                    .studentId(student.getId())
                    .studentName(student.getFullName())
                    .studentUsername(student.getUsername())
                    .token(token.getToken())
                    .used(token.getUsed())
                    .build()
            );
        }

        return TokenDistributionDto
            .builder()
            .electionId(election.getId())
            .electionTitle(election.getTitle())
            .schoolClassId(schoolClass.getId())
            .schoolClassName(schoolClass.getName())
            .entries(entries)
            .build();
    }

    /**
     * Get token distribution for an election and class (without generating new ones).
     */
    @Transactional(readOnly = true)
    public TokenDistributionDto getTokenDistribution(
        Long electionId,
        Long schoolClassId,
        Long requestingUserId
    ) {
        Election election = electionRepository
            .findById(electionId)
            .orElseThrow(() ->
                new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "Election not found"
                )
            );

        SchoolClass schoolClass = schoolClassRepository
            .findById(schoolClassId)
            .orElseThrow(() ->
                new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "School class not found"
                )
            );

        User requester = userRepository
            .findById(requestingUserId)
            .orElseThrow(() ->
                new ResponseStatusException(
                    HttpStatus.NOT_FOUND,
                    "User not found"
                )
            );

        boolean isAdmin = requester instanceof at.ftmahringer.wahlsystem.entity.Admin;
        boolean isClassTeacher =
            requester instanceof Teacher teacher &&
            schoolClass.getClassTeacher() != null &&
            schoolClass.getClassTeacher().getId().equals(teacher.getId());

        if (!isAdmin && !isClassTeacher) {
            throw new ResponseStatusException(
                HttpStatus.FORBIDDEN,
                "Only admins or the class teacher can view token distribution"
            );
        }

        List<Student> students = studentRepository.findBySchoolClassId(
            schoolClassId
        );

        List<TokenDistributionDto.StudentTokenEntryDto> entries =
            new ArrayList<>();

        for (Student student : students) {
            Optional<StudentVoteToken> existingToken = tokenRepository
                .findByStudentId(student.getId())
                .stream()
                .filter(t ->
                    t.getElection() != null &&
                    t.getElection().getId().equals(electionId)
                )
                .findFirst();

            if (existingToken.isPresent()) {
                StudentVoteToken token = existingToken.get();
                entries.add(
                    TokenDistributionDto.StudentTokenEntryDto
                        .builder()
                        .studentId(student.getId())
                        .studentName(student.getFullName())
                        .studentUsername(student.getUsername())
                        .token(token.getToken())
                        .used(token.getUsed())
                        .build()
                );
            }
        }

        return TokenDistributionDto
            .builder()
            .electionId(election.getId())
            .electionTitle(election.getTitle())
            .schoolClassId(schoolClass.getId())
            .schoolClassName(schoolClass.getName())
            .entries(entries)
            .build();
    }

    private StudentVoteToken createTokenForStudent(
        Student student,
        Election election
    ) {
        String tokenValue = generateSecureToken();

        // Ensure uniqueness
        while (tokenRepository.findByToken(tokenValue).isPresent()) {
            tokenValue = generateSecureToken();
        }

        StudentVoteToken token = StudentVoteToken
            .builder()
            .student(student)
            .token(tokenValue)
            .election(election)
            .used(false)
            .build();

        return tokenRepository.save(token);
    }

    private String generateSecureToken() {
        byte[] bytes = new byte[TOKEN_LENGTH];
        SECURE_RANDOM.nextBytes(bytes);
        return Base64
            .getUrlEncoder()
            .withoutPadding()
            .encodeToString(bytes)
            .toUpperCase();
    }

    private StudentTokenDto mapToStudentTokenDto(StudentVoteToken token) {
        StudentTokenDto.StudentTokenDtoBuilder builder = StudentTokenDto
            .builder()
            .id(token.getId())
            .token(token.getToken())
            .used(token.getUsed())
            .usedAt(token.getUsedAt())
            .createdAt(token.getCreatedAt());

        if (token.getElection() != null) {
            Election election = token.getElection();
            builder
                .electionId(election.getId())
                .electionTitle(election.getTitle())
                .electionType(election.getType())
                .electionStatus(election.getStatus())
                .electionEndAt(election.getEndAt());
        }

        return builder.build();
    }
}
