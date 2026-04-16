package at.ftmahringer.wahlsystem.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "students")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder(toBuilder = true)
@PrimaryKeyJoinColumn(name = "user_id")
@DiscriminatorValue("STUDENT")
public class Student extends User {

    @Column(name = "student_id", unique = true)
    private String studentId;

    @Column(name = "class_name")
    private String className;

    @Column(name = "grade_level")
    private Integer gradeLevel;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Builder.Default
    @Column(name = "can_vote")
    private Boolean canVote = true;

    @Builder.Default
    @Column(name = "has_voted")
    private Boolean hasVoted = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "school_class_id")
    private SchoolClass schoolClass;

    @Builder.Default
    @OneToMany(
        mappedBy = "student",
        cascade = CascadeType.ALL,
        orphanRemoval = true
    )
    private List<StudentVoteToken> voteTokens = new ArrayList<>();

    public Student(
        String username,
        String email,
        String password,
        String firstName,
        String lastName,
        String studentId
    ) {
        setUsername(username);
        setEmail(email);
        setPassword(password);
        setFirstName(firstName);
        setLastName(lastName);
        setStudentId(studentId);
        setRole(at.ftmahringer.wahlsystem.enums.UserRole.STUDENT);
        setActive(true);
    }
}
