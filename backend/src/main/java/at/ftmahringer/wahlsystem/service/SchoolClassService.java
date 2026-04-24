package at.ftmahringer.wahlsystem.service;

import at.ftmahringer.wahlsystem.dto.SchoolClassDto;
import at.ftmahringer.wahlsystem.dto.SchoolClassUpsertRequest;
import at.ftmahringer.wahlsystem.entity.SchoolClass;
import at.ftmahringer.wahlsystem.entity.Student;
import at.ftmahringer.wahlsystem.entity.Teacher;
import at.ftmahringer.wahlsystem.repository.SchoolClassRepository;
import at.ftmahringer.wahlsystem.repository.StudentRepository;
import at.ftmahringer.wahlsystem.repository.TeacherRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SchoolClassService {

    private final SchoolClassRepository schoolClassRepository;
    private final TeacherRepository teacherRepository;
    private final StudentRepository studentRepository;

    @Transactional(readOnly = true)
    public List<SchoolClassDto> getAllClasses() {
        return schoolClassRepository.findAll().stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public SchoolClassDto getClassById(Long id) {
        SchoolClass schoolClass = schoolClassRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "School class not found"));
        return mapToDto(schoolClass);
    }

    @Transactional(readOnly = true)
    public List<SchoolClassDto> getClassesByTeacherId(Long teacherId) {
        return schoolClassRepository.findByClassTeacherId(teacherId).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public SchoolClassDto createClass(SchoolClassUpsertRequest request) {
        SchoolClass schoolClass = new SchoolClass();
        schoolClass.setName(request.getName().trim());
        schoolClass.setGradeLevel(request.getGradeLevel());
        schoolClass.setRoom(request.getRoom());
        schoolClass.setActive(true);

        if (request.getClassTeacherId() != null) {
            Teacher teacher = teacherRepository.findById(request.getClassTeacherId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Teacher not found"));
            schoolClass.setClassTeacher(teacher);
        }

        return mapToDto(schoolClassRepository.save(schoolClass));
    }

    @Transactional
    public SchoolClassDto updateClass(Long id, SchoolClassUpsertRequest request) {
        SchoolClass schoolClass = schoolClassRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "School class not found"));

        schoolClass.setName(request.getName().trim());
        schoolClass.setGradeLevel(request.getGradeLevel());
        schoolClass.setRoom(request.getRoom());

        if (request.getClassTeacherId() != null) {
            Teacher teacher = teacherRepository.findById(request.getClassTeacherId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Teacher not found"));
            schoolClass.setClassTeacher(teacher);
        } else {
            schoolClass.setClassTeacher(null);
        }

        return mapToDto(schoolClassRepository.save(schoolClass));
    }

    @Transactional
    public void deleteClass(Long id) {
        SchoolClass schoolClass = schoolClassRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "School class not found"));

        // Remove students from class to avoid constraint issues
        for (Student student : schoolClass.getStudents()) {
            student.setSchoolClass(null);
        }
        schoolClass.getStudents().clear();

        schoolClassRepository.delete(schoolClass);
    }

    @Transactional
    public SchoolClassDto assignStudent(Long classId, Long studentId) {
        SchoolClass schoolClass = schoolClassRepository.findById(classId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "School class not found"));

        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found"));

        schoolClass.addStudent(student);
        return mapToDto(schoolClassRepository.save(schoolClass));
    }

    @Transactional
    public SchoolClassDto removeStudent(Long classId, Long studentId) {
        SchoolClass schoolClass = schoolClassRepository.findById(classId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "School class not found"));

        Student student = studentRepository.findById(studentId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found"));

        schoolClass.removeStudent(student);
        return mapToDto(schoolClassRepository.save(schoolClass));
    }

    private SchoolClassDto mapToDto(SchoolClass schoolClass) {
        SchoolClassDto.SchoolClassDtoBuilder builder = SchoolClassDto.builder()
                .id(schoolClass.getId())
                .name(schoolClass.getName())
                .gradeLevel(schoolClass.getGradeLevel())
                .room(schoolClass.getRoom())
                .active(schoolClass.getActive());

        if (schoolClass.getClassTeacher() != null) {
            Teacher t = schoolClass.getClassTeacher();
            builder.classTeacher(SchoolClassDto.TeacherSummaryDto.builder()
                    .id(t.getId())
                    .fullName(t.getFullName())
                    .username(t.getUsername())
                    .employeeId(t.getEmployeeId())
                    .build());
        }

        if (schoolClass.getStudents() != null) {
            builder.students(schoolClass.getStudents().stream()
                    .map(s -> SchoolClassDto.StudentSummaryDto.builder()
                            .id(s.getId())
                            .fullName(s.getFullName())
                            .username(s.getUsername())
                            .studentId(s.getStudentId())
                            .canVote(s.getCanVote())
                            .build())
                    .collect(Collectors.toList()));
        }

        return builder.build();
    }
}
