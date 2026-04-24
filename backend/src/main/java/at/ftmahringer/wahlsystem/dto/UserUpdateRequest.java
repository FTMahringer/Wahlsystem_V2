package at.ftmahringer.wahlsystem.dto;

import at.ftmahringer.wahlsystem.enums.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UserUpdateRequest {

    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    private String username;

    @Email(message = "Email must be valid")
    private String email;

    private String firstName;
    private String lastName;
    private UserRole role;
    private Boolean active;

    // Admin specific
    private Integer adminLevel;
    private String department;
    private String phone;

    // Teacher specific
    private String employeeId;
    private String subjects;
    private String departmentTeacher; // alias to avoid clash
    private Integer maxActiveElections;
    private Boolean canCreateElections;

    // Student specific
    private String studentId;
    private String className;
    private Integer gradeLevel;
    private Boolean canVote;
    private Long schoolClassId;
}
