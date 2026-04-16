package at.ftmahringer.wahlsystem.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "teachers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder(toBuilder = true)
@PrimaryKeyJoinColumn(name = "user_id")
@DiscriminatorValue("TEACHER")
public class Teacher extends User {

    @Column(name = "employee_id")
    private String employeeId;

    @Column(name = "department")
    private String department;

    @Column(name = "subjects")
    private String subjects;

    @Column(name = "phone")
    private String phone;

    @Builder.Default
    @Column(name = "can_create_elections")
    private Boolean canCreateElections = true;

    @Builder.Default
    @Column(name = "can_manage_own_elections")
    private Boolean canManageOwnElections = true;

    @Builder.Default
    @Column(name = "max_active_elections")
    private Integer maxActiveElections = 5;

    public Teacher(String username, String email, String password, String firstName, String lastName) {
        setUsername(username);
        setEmail(email);
        setPassword(password);
        setFirstName(firstName);
        setLastName(lastName);
        setRole(at.ftmahringer.wahlsystem.enums.UserRole.TEACHER);
        setActive(true);
    }
}
