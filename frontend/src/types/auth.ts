export type UserRole = "ADMIN" | "TEACHER" | "STUDENT" | "VOTER";

export interface User {
  id: number;
  username: string;
  email: string;
  firstName?: string;
  lastName?: string;
  fullName?: string;
  role: UserRole;
  active: boolean;
  emailVerified?: boolean;
  lastLoginAt?: string;
  createdAt?: string;
  updatedAt?: string;
  // Admin fields
  adminLevel?: number;
  canManageUsers?: boolean;
  canManageElections?: boolean;
  // Teacher fields
  employeeId?: string;
  department?: string;
  subjects?: string;
  canCreateElections?: boolean;
  // Student fields
  studentId?: string;
  className?: string;
  gradeLevel?: number;
  canVote?: boolean;
  schoolClassId?: number;
}

export interface AuthState {
  user: User | null;
  token: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
}

export interface LoginCredentials {
  username: string;
  password: string;
}

export interface RegisterRequest {
  username: string;
  email: string;
  password: string;
  firstName?: string;
  lastName?: string;
  role: UserRole;
  // Admin fields
  adminLevel?: number;
  department?: string;
  phone?: string;
  // Teacher fields
  employeeId?: string;
  subjects?: string;
  maxActiveElections?: number;
  // Student fields
  studentId?: string;
  className?: string;
  gradeLevel?: number;
}

export interface AuthResponse {
  token: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
  user: User;
}

export interface TokenLoginCredentials {
  token: string;
}

export interface ManagedUserFilters {
  role?: Exclude<UserRole, "ADMIN" | "VOTER">;
  active?: boolean;
  search?: string;
}

export interface UserActiveUpdateRequest {
  active: boolean;
}

export interface UserUpdateRequest {
  username?: string;
  email?: string;
  firstName?: string;
  lastName?: string;
  role?: UserRole;
  active?: boolean;
  // Admin
  adminLevel?: number;
  department?: string;
  phone?: string;
  // Teacher
  employeeId?: string;
  subjects?: string;
  departmentTeacher?: string;
  maxActiveElections?: number;
  canCreateElections?: boolean;
  // Student
  studentId?: string;
  className?: string;
  gradeLevel?: number;
  canVote?: boolean;
  schoolClassId?: number;
}
