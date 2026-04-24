import type { ElectionStatus, ElectionType } from "./election";

export interface StudentToken {
  id: number;
  token: string;
  used: boolean;
  usedAt: string | null;
  createdAt: string;
  electionId: number;
  electionTitle: string;
  electionType: ElectionType;
  electionStatus: ElectionStatus;
  electionEndAt: string | null;
}

export interface TokenDistribution {
  electionId: number;
  electionTitle: string;
  schoolClassId: number;
  schoolClassName: string;
  entries: TokenDistributionEntry[];
}

export interface TokenDistributionEntry {
  studentId: number;
  studentName: string;
  studentUsername: string;
  token: string;
  used: boolean;
}
