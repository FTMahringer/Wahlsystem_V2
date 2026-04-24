import apiClient from "./axios";
import type { StudentToken, TokenDistribution } from "@/types";

export const tokenApi = {
  // Get my voting tokens (student only)
  getMyTokens: async (): Promise<StudentToken[]> => {
    const response = await apiClient.get("/student/tokens");
    return response.data;
  },

  // Get token distribution for an election and class (teacher/admin)
  getTokenDistribution: async (
    electionId: number,
    schoolClassId: number,
  ): Promise<TokenDistribution> => {
    const response = await apiClient.get(
      `/teacher/elections/${electionId}/tokens`,
      { params: { schoolClassId } },
    );
    return response.data;
  },

  // Generate tokens for all students in a class for an election
  generateTokens: async (
    electionId: number,
    schoolClassId: number,
  ): Promise<TokenDistribution> => {
    const response = await apiClient.post(
      `/teacher/elections/${electionId}/tokens/generate`,
      null,
      { params: { schoolClassId } },
    );
    return response.data;
  },
};
