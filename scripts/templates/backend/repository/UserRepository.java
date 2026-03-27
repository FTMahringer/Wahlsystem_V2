package com.example.wahlsystem.repository;

import com.example.wahlsystem.entity.User;
import com.example.wahlsystem.enums.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUsername(String username);

    Optional<User> findByEmail(String email);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);

    List<User> findByRole(UserRole role);

    List<User> findByActiveTrue();

    @Query("SELECT u FROM User u WHERE u.role IN (:roles)")
    List<User> findByRoles(@Param("roles") List<UserRole> roles);

    @Query("SELECT u FROM User u WHERE u.role = 'ADMIN' OR u.role = 'TEACHER'")
    List<User> findAllAdminsAndTeachers();
}
