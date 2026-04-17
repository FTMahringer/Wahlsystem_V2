export interface Vote {
  id: number;
  electionId: number;
  candidateId: number;
  timestamp: string;
}

export interface CastVoteRequest {
  electionId: number;
  token: string;
  candidateId?: number;
  candidateIds?: number[];
  rankedCandidateIds?: number[];
}

export interface VoteResult {
  candidateId: number;
  candidateName: string;
  voteCount: number;
  percentage: number;
}

export interface ElectionResults {
  electionId: number;
  totalVotes: number;
  results: VoteResult[];
}

export interface ElectionResultCandidate {
  candidateId: number;
  firstName: string;
  lastName: string;
  className: string;
  description: string;
  voteCount: number;
  percentage: number;
  winner: boolean;
}

export interface ElectionResult {
  electionId: number;
  electionTitle: string;
  endedAt: string;
  totalVotes: number;
  resultMetricLabel: string;
  results: ElectionResultCandidate[];
  winners: ElectionResultCandidate[];
}
