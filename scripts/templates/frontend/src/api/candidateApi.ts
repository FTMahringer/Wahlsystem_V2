import apiClient from './axios';
import type { Candidate, CreateCandidateRequest } from '@/types';

export const candidateApi = {
  // Get candidates by election
  getByElection: async (electionId: number): Promise<Candidate[]> => {
    const response = await apiClient.get(`/elections/${electionId}/candidates`);
    return response.data;
  },

  // Create candidate (admin only)
  create: async (data: CreateCandidateRequest): Promise<Candidate> => {
    const response = await apiClient.post('/admin/candidates', data);
    return response.data;
  },

  // Update candidate (admin only)
  update: async (id: number, data: Partial<CreateCandidateRequest>): Promise<Candidate> => {
    const response = await apiClient.put(`/admin/candidates/${id}`, data);
    return response.data;
  },

  // Delete candidate (admin only)
  delete: async (id: number): Promise<void> => {
    await apiClient.delete(`/admin/candidates/${id}`);
  },
};
