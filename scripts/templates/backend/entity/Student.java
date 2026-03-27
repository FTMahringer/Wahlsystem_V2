package com.example.wahlsystem.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDate;

@Entity
@Table(name = "students")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
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

    @Column(name = "can_vote")
    private Boolean canVote = true;

    @Column(name = "voting_token")
    private String votingToken;

    @Column(name = "has_voted")
    private Boolean hasVoted = false;

    public Student(String username, String email, String password, String firstName, String lastName, String studentId) {
        setUsername(username);
        setEmail(email);
        setPassword(password);
        setFirstName(firstName);
        setLastName(lastName);
        setStudentId(studentId);
        setRole(com.example.wahlsystem.enums.UserRole.STUDENT);
        setActive(true);
    }
}
