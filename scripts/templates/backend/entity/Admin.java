package com.example.wahlsystem.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Entity
@Table(name = "admins")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@PrimaryKeyJoinColumn(name = "user_id")
@DiscriminatorValue("ADMIN")
public class Admin extends User {

    @Column(name = "admin_level")
    private Integer adminLevel = 1;

    @Column(name = "can_manage_users")
    private Boolean canManageUsers = true;

    @Column(name = "can_manage_elections")
    private Boolean canManageElections = true;

    @Column(name = "can_view_all_results")
    private Boolean canViewAllResults = true;

    @Column(name = "department")
    private String department;

    @Column(name = "phone")
    private String phone;

    public Admin(String username, String email, String password, String firstName, String lastName) {
        setUsername(username);
        setEmail(email);
        setPassword(password);
        setFirstName(firstName);
        setLastName(lastName);
        setRole(com.example.wahlsystem.enums.UserRole.ADMIN);
        setActive(true);
    }
}
