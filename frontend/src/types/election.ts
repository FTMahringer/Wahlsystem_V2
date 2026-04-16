export type ElectionStatus = 'DRAFT' | 'PLANNED' | 'ACTIVE' | 'ENDED' | 'ARCHIVED';
export type ElectionType = 'SINGLE_CHOICE' | 'MULTIPLE_CHOICE';

export interface Election {
  id: number;
  title: string;
  description: string;
  type: ElectionType;
  status: ElectionStatus;
  startAt: string | null;
  endAt: string | null;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateElectionRequest {
  title: string;
  description: string;
  type: ElectionType;
  startAt: string | null;
  endAt: string | null;
}
