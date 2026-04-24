export interface SchoolClass {
  id: number;
  name: string;
  gradeLevel: number | null;
  room: string | null;
  active: boolean;
  classTeacher: TeacherSummary | null;
  students: StudentSummary[];
}

export interface TeacherSummary {
  id: number;
  fullName: string;
  username: string;
  employeeId: string;
}

export interface StudentSummary {
  id: number;
  fullName: string;
  username: string;
  studentId: string;
  canVote: boolean;
}

export interface SchoolClassUpsertRequest {
  name: string;
  gradeLevel?: number;
  room?: string;
  classTeacherId?: number;
}
