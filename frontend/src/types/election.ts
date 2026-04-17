export type ElectionStatus =
  | "DRAFT"
  | "PLANNED"
  | "ACTIVE"
  | "ENDED"
  | "ARCHIVED";

export type ElectionType =
  | "SINGLE_CHOICE"
  | "BINARY_CHOICE"
  | "APPROVAL_VOTING"
  | "LIMITED_VOTE"
  | "BORDA_COUNT";

export interface ElectionTypeDefinition {
  label: string;
  shortLabel: string;
  description: string;
  ballotMode: "single" | "multiple" | "ranking";
  resultMetricLabel: string;
  helperText: string;
  requiresMaxSelections?: boolean;
}

export const electionTypeDefinitions: Record<ElectionType, ElectionTypeDefinition> = {
  SINGLE_CHOICE: {
    label: "Single Choice",
    shortLabel: "Single",
    description: "Each voter selects exactly one candidate.",
    ballotMode: "single",
    resultMetricLabel: "votes",
    helperText: "Choose one candidate.",
  },
  BINARY_CHOICE: {
    label: "Binary Choice",
    shortLabel: "Binary",
    description: "A simple election between exactly two choices.",
    ballotMode: "single",
    resultMetricLabel: "votes",
    helperText: "Choose one of the two options.",
  },
  APPROVAL_VOTING: {
    label: "Approval Voting",
    shortLabel: "Approval",
    description: "Voters can approve any number of acceptable candidates.",
    ballotMode: "multiple",
    resultMetricLabel: "votes",
    helperText: "Select every candidate you approve of.",
  },
  LIMITED_VOTE: {
    label: "Limited Vote",
    shortLabel: "Limited",
    description: "Voters may select up to a configured number of candidates.",
    ballotMode: "multiple",
    resultMetricLabel: "votes",
    helperText: "Select up to the configured number of candidates.",
    requiresMaxSelections: true,
  },
  BORDA_COUNT: {
    label: "Borda Count",
    shortLabel: "Borda",
    description: "Voters rank candidates, and higher ranks receive more points.",
    ballotMode: "ranking",
    resultMetricLabel: "points",
    helperText: "Rank all candidates from most preferred to least preferred.",
  },
};

export function getElectionTypeDefinition(type: ElectionType): ElectionTypeDefinition {
  return electionTypeDefinitions[type];
}

export interface Election {
  id: number;
  title: string;
  description: string;
  type: ElectionType;
  status: ElectionStatus;
  startAt: string | null;
  endAt: string | null;
  maxSelections: number | null;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateElectionRequest {
  title: string;
  description: string;
  type: ElectionType;
  status?: ElectionStatus;
  startAt: string | null;
  endAt: string | null;
  maxSelections: number | null;
}
