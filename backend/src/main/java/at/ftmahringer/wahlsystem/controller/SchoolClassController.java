package at.ftmahringer.wahlsystem.controller;

import at.ftmahringer.wahlsystem.dto.SchoolClassDto;
import at.ftmahringer.wahlsystem.dto.SchoolClassUpsertRequest;
import at.ftmahringer.wahlsystem.security.UserPrincipal;
import at.ftmahringer.wahlsystem.service.SchoolClassService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/school-classes")
@RequiredArgsConstructor
@Tag(name = "School Classes", description = "School class management endpoints")
public class SchoolClassController {

    private final SchoolClassService schoolClassService;

    @GetMapping
    @Operation(summary = "List all school classes")
    public ResponseEntity<List<SchoolClassDto>> getAllClasses() {
        return ResponseEntity.ok(schoolClassService.getAllClasses());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a school class by ID")
    public ResponseEntity<SchoolClassDto> getClassById(@PathVariable Long id) {
        return ResponseEntity.ok(schoolClassService.getClassById(id));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Create a school class")
    public ResponseEntity<SchoolClassDto> createClass(
            @Valid @RequestBody SchoolClassUpsertRequest request
    ) {
        return ResponseEntity.ok(schoolClassService.createClass(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Update a school class")
    public ResponseEntity<SchoolClassDto> updateClass(
            @PathVariable Long id,
            @Valid @RequestBody SchoolClassUpsertRequest request
    ) {
        return ResponseEntity.ok(schoolClassService.updateClass(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a school class")
    public ResponseEntity<Void> deleteClass(@PathVariable Long id) {
        schoolClassService.deleteClass(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{classId}/students/{studentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Assign a student to a school class")
    public ResponseEntity<SchoolClassDto> assignStudent(
            @PathVariable Long classId,
            @PathVariable Long studentId
    ) {
        return ResponseEntity.ok(schoolClassService.assignStudent(classId, studentId));
    }

    @DeleteMapping("/{classId}/students/{studentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Remove a student from a school class")
    public ResponseEntity<SchoolClassDto> removeStudent(
            @PathVariable Long classId,
            @PathVariable Long studentId
    ) {
        return ResponseEntity.ok(schoolClassService.removeStudent(classId, studentId));
    }

    @GetMapping("/my-classes")
    @PreAuthorize("hasRole('TEACHER')")
    @Operation(summary = "Get classes for the authenticated teacher")
    public ResponseEntity<List<SchoolClassDto>> getMyClasses(
            @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        return ResponseEntity.ok(schoolClassService.getClassesByTeacherId(userPrincipal.getId()));
    }
}
