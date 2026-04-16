package at.ftmahringer.wahlsystem.dto;

import at.ftmahringer.wahlsystem.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserDto {

    private Long id;
    private String username;
    private String email;
    private String firstName;
    private String lastName;
    private String fullName;
    private UserRole role;
    private Boolean active;
    private Boolean emailVerified;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime lastLoginAt;

    // Admin fields
    private Integer adminLevel;
    private Boolean canManageUsers;
    private Boolean canManageElections;

    // Teacher fields
    private String employeeId;
    private String department;
    private String subjects;
    private Boolean canCreateElections;

    // Student fields
    private String studentId;
    private String className;
    private Integer gradeLevel;
    private Boolean canVote;
}
