import apiClient from './axios';
import type { Election, CreateElectionRequest } from '@/types';

export const electionApi = {
  // Get all elections
  getAll: async (): Promise<Election[]> => {
    const response = await apiClient.get('/elections');
    return response.data;
  },

  // Get election by ID
  getById: async (id: number): Promise<Election> => {
    const response = await apiClient.get(`/elections/${id}`);
    return response.data;
  },

  // Create election (admin only)
  create: async (data: CreateElectionRequest): Promise<Election> => {
    const response = await apiClient.post('/admin/elections', data);
    return response.data;
  },

  // Update election (admin only)
  update: async (id: number, data: Partial<CreateElectionRequest>): Promise<Election> => {
    const response = await apiClient.put(`/admin/elections/${id}`, data);
    return response.data;
  },

  // Delete election (admin only)
  delete: async (id: number): Promise<void> => {
    await apiClient.delete(`/admin/elections/${id}`);
  },
};
