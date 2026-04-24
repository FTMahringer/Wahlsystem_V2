package at.ftmahringer.wahlsystem.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SchoolClassDto {

    private Long id;
    private String name;
    private Integer gradeLevel;
    private String room;
    private Boolean active;
    private TeacherSummaryDto classTeacher;
    private List<StudentSummaryDto> students;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TeacherSummaryDto {
        private Long id;
        private String fullName;
        private String username;
        private String employeeId;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StudentSummaryDto {
        private Long id;
        private String fullName;
        private String username;
        private String studentId;
        private Boolean canVote;
    }
}
