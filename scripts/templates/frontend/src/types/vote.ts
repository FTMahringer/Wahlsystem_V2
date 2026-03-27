export interface Vote {
  id: number;
  electionId: number;
  candidateId: number;
  timestamp: string;
}

export interface CastVoteRequest {
  electionId: number;
  candidateId: number;
  token: string;
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
