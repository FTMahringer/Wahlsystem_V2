import apiClient from "./axios";
import type { AuditLog } from "@/types";

export const auditLogApi = {
  getRecentLogs: async (limit: number = 100): Promise<AuditLog[]> => {
    const response = await apiClient.get("/admin/audit", {
      params: { limit },
    });
    return response.data;
  },

  searchLogs: async (query: string, limit: number = 100): Promise<AuditLog[]> => {
    const response = await apiClient.get("/admin/audit/search", {
      params: { query, limit },
    });
    return response.data;
  },

  getLogsInRange: async (
    start: string,
    end: string,
    limit: number = 100,
  ): Promise<AuditLog[]> => {
    const response = await apiClient.get("/admin/audit/range", {
      params: { start, end, limit },
    });
    return response.data;
  },
};
