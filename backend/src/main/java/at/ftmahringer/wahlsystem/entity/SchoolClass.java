package at.ftmahringer.wahlsystem.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "school_classes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SchoolClass {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "grade_level")
    private Integer gradeLevel;

    @Column(name = "room")
    private String room;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "class_teacher_id")
    private Teacher classTeacher;

    @Builder.Default
    @OneToMany(mappedBy = "schoolClass", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Student> students = new ArrayList<>();

    @Builder.Default
    @Column(name = "active")
    private Boolean active = true;

    public void addStudent(Student student) {
        students.add(student);
        student.setSchoolClass(this);
    }

    public void removeStudent(Student student) {
        students.remove(student);
        student.setSchoolClass(null);
    }
}
