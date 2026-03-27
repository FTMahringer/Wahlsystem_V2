package com.example.wahlsystem.repository;

import com.example.wahlsystem.entity.Teacher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TeacherRepository extends JpaRepository<Teacher, Long> {

    Optional<Teacher> findByEmployeeId(String employeeId);

    List<Teacher> findByDepartment(String department);

    Optional<Teacher> findByUsername(String username);
}
