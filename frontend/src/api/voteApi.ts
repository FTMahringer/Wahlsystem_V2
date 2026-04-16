import apiClient from './axios';
import type { CastVoteRequest, ElectionResults } from '@/types';

export const voteApi = {
  // Cast a vote
  castVote: async (data: CastVoteRequest): Promise<void> => {
    await apiClient.post('/votes', data);
  },

  // Get election results (admin only)
  getResults: async (electionId: number): Promise<ElectionResults> => {
    const response = await apiClient.get(`/admin/elections/${electionId}/results`);
    return response.data;
  },
};
