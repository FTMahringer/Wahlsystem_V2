import { translate, type TranslateFunction } from '@/locales';

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

const electionTypeDefinitions = {
  SINGLE_CHOICE: {
    ballotMode: "single",
  },
  BINARY_CHOICE: {
    ballotMode: "single",
  },
  APPROVAL_VOTING: {
    ballotMode: "multiple",
  },
  LIMITED_VOTE: {
    ballotMode: "multiple",
    requiresMaxSelections: true,
  },
  BORDA_COUNT: {
    ballotMode: "ranking",
  },
} as const;

export function getElectionTypeDefinition(
  type: ElectionType,
  t: TranslateFunction = translate,
): ElectionTypeDefinition {
  const definition = electionTypeDefinitions[type];

  return {
    ...definition,
    label: t(`electionTypes.${type}.label`),
    shortLabel: t(`electionTypes.${type}.shortLabel`),
    description: t(`electionTypes.${type}.description`),
    resultMetricLabel: t(`electionTypes.${type}.resultMetricLabel`),
    helperText: t(`electionTypes.${type}.helperText`),
  };
}

export function getElectionStatusLabel(
  status: ElectionStatus,
  t: TranslateFunction = translate,
) {
  return t(`electionStatus.${status}`);
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
