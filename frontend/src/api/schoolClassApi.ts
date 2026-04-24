import apiClient from './axios';
import type { SchoolClass, SchoolClassUpsertRequest } from '@/types';

export const schoolClassApi = {
  getAll: async (): Promise<SchoolClass[]> => {
    const response = await apiClient.get('/school-classes');
    return response.data;
  },

  getById: async (id: number): Promise<SchoolClass> => {
    const response = await apiClient.get(`/school-classes/${id}`);
    return response.data;
  },

  create: async (data: SchoolClassUpsertRequest): Promise<SchoolClass> => {
    const response = await apiClient.post('/school-classes', data);
    return response.data;
  },

  update: async (id: number, data: SchoolClassUpsertRequest): Promise<SchoolClass> => {
    const response = await apiClient.put(`/school-classes/${id}`, data);
    return response.data;
  },

  delete: async (id: number): Promise<void> => {
    await apiClient.delete(`/school-classes/${id}`);
  },

  assignStudent: async (classId: number, studentId: number): Promise<SchoolClass> => {
    const response = await apiClient.post(`/school-classes/${classId}/students/${studentId}`);
    return response.data;
  },

  removeStudent: async (classId: number, studentId: number): Promise<SchoolClass> => {
    const response = await apiClient.delete(`/school-classes/${classId}/students/${studentId}`);
    return response.data;
  },

  getMyClasses: async (): Promise<SchoolClass[]> => {
    const response = await apiClient.get('/school-classes/my-classes');
    return response.data;
  },
};
