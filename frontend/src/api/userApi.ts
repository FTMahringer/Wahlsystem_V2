import apiClient from "./axios";
import type {
  ManagedUserFilters,
  RegisterRequest,
  User,
  UserActiveUpdateRequest,
} from "@/types";

export const userApi = {
  getAll: async (filters: ManagedUserFilters = {}): Promise<User[]> => {
    const response = await apiClient.get("/users", { params: filters });
    return response.data;
  },

  createTeacher: async (data: RegisterRequest): Promise<User> => {
    const response = await apiClient.post("/users/teachers", data);
    return response.data;
  },

  createStudent: async (data: RegisterRequest): Promise<User> => {
    const response = await apiClient.post("/users/students", data);
    return response.data;
  },

  createTeachersBatch: async (data: RegisterRequest[]): Promise<User[]> => {
    const response = await apiClient.post("/users/teachers/batch", data);
    return response.data;
  },

  createStudentsBatch: async (data: RegisterRequest[]): Promise<User[]> => {
    const response = await apiClient.post("/users/students/batch", data);
    return response.data;
  },

  updateActiveState: async (
    id: number,
    data: UserActiveUpdateRequest,
  ): Promise<User> => {
    const response = await apiClient.patch(`/users/${id}/active`, data);
    return response.data;
  },
};
