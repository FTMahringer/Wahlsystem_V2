export interface Candidate {
  id: number;
  firstName: string;
  lastName: string;
  className: string | null;
  description: string | null;
  sortOrder: number;
  active: boolean;
  electionId: number;
}

export interface CreateCandidateRequest {
  firstName: string;
  lastName: string;
  className?: string;
  description?: string;
  sortOrder?: number;
  electionId: number;
}
