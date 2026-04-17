<template>
  <div class="voter-election">
    <div class="election-container">
      <div v-if="loading" class="loading-state">
        <div class="spinner" />
        <p>{{ t('voter.loadingElection') }}</p>
      </div>

      <div v-else-if="error" class="error-state">
        <p>{{ error }}</p>
        <button class="btn" @click="loadData">{{ t('common.retry') }}</button>
      </div>

      <template v-else-if="election">
        <div class="election-header">
          <h1>{{ election.title }}</h1>
          <p class="type-badge">{{ electionType.label }}</p>
        </div>
        <p v-if="election.description" class="election-desc">{{ election.description }}</p>
        <p class="instruction">{{ instructionText }}</p>

        <div v-if="election.type === 'SINGLE_CHOICE' || election.type === 'BINARY_CHOICE'" class="candidates-list">
          <div
            v-for="candidate in candidates"
            :key="candidate.id"
            class="candidate-card"
            :class="{ selected: selectedCandidateId === candidate.id }"
            @click="selectedCandidateId = candidate.id"
          >
            <div class="candidate-check">
              <div class="radio" :class="{ checked: selectedCandidateId === candidate.id }" />
            </div>
            <div class="candidate-info">
              <h3>{{ candidate.firstName }} {{ candidate.lastName }}</h3>
              <p v-if="candidate.className" class="class-name">{{ candidate.className }}</p>
              <p v-if="candidate.description" class="description">{{ candidate.description }}</p>
            </div>
          </div>
        </div>

        <template v-else-if="election.type === 'APPROVAL_VOTING' || election.type === 'LIMITED_VOTE'">
          <div class="selection-counter">
            {{ t('voter.selectedCount', { count: selectedCandidateIds.length }) }}
            <template v-if="election.type === 'LIMITED_VOTE'">
              / {{ selectionLimit }}
            </template>
          </div>

          <div class="candidates-list">
            <div
              v-for="candidate in candidates"
              :key="candidate.id"
              class="candidate-card"
              :class="{ selected: selectedCandidateIds.includes(candidate.id) }"
              @click="toggleCandidate(candidate.id)"
            >
              <div class="candidate-check">
                <div class="checkbox" :class="{ checked: selectedCandidateIds.includes(candidate.id) }" />
              </div>
              <div class="candidate-info">
                <h3>{{ candidate.firstName }} {{ candidate.lastName }}</h3>
                <p v-if="candidate.className" class="class-name">{{ candidate.className }}</p>
                <p v-if="candidate.description" class="description">{{ candidate.description }}</p>
              </div>
            </div>
          </div>
        </template>

        <template v-else-if="election.type === 'BORDA_COUNT'">
          <div class="ranking-help">
            {{ t('voter.rankHelp') }}
          </div>

          <div class="ranking-list">
            <div
              v-for="(candidate, index) in rankedCandidates"
              :key="candidate.id"
              class="ranking-item"
            >
              <div class="rank-badge">{{ index + 1 }}</div>
              <div class="candidate-info">
                <h3>{{ candidate.firstName }} {{ candidate.lastName }}</h3>
                <p v-if="candidate.className" class="class-name">{{ candidate.className }}</p>
                <p v-if="candidate.description" class="description">{{ candidate.description }}</p>
              </div>
              <div class="rank-actions">
                <button
                  type="button"
                  class="move-btn"
                  :disabled="index === 0"
                  @click="moveCandidate(index, -1)"
                >
                  ↑
                </button>
                <button
                  type="button"
                  class="move-btn"
                  :disabled="index === rankedCandidates.length - 1"
                  @click="moveCandidate(index, 1)"
                >
                  ↓
                </button>
              </div>
            </div>
          </div>
        </template>

        <button class="vote-button" :disabled="!canContinue" @click="goToConfirm">
          {{ t('voter.continueToConfirm') }}
        </button>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { candidateApi, electionApi } from "@/api";
import { useLocale } from "@/composables/useLocale";
import { getElectionTypeDefinition, type Candidate, type Election } from "@/types";

interface StoredVoteBallot {
  electionId: number;
  electionTitle: string;
  electionType: Election["type"];
  candidateId?: number;
  candidateIds?: number[];
  rankedCandidateIds?: number[];
  summary: string[];
}

const route = useRoute();
const router = useRouter();
const electionId = Number(route.params.id);
const { t } = useLocale();

const election = ref<Election | null>(null);
const candidates = ref<Candidate[]>([]);
const selectedCandidateId = ref<number | null>(null);
const selectedCandidateIds = ref<number[]>([]);
const rankedCandidateIds = ref<number[]>([]);
const loading = ref(false);
const error = ref<string | null>(null);

const electionType = computed(() =>
  election.value ? getElectionTypeDefinition(election.value.type, t) : getElectionTypeDefinition("SINGLE_CHOICE", t),
);

const selectionLimit = computed(() => election.value?.maxSelections ?? 1);

const instructionText = computed(() => {
  if (!election.value) {
    return "";
  }

  if (election.value.type === "LIMITED_VOTE") {
    return t('voter.limitedVoteInstruction', { count: selectionLimit.value });
  }

  return electionType.value.helperText;
});

const rankedCandidates = computed(() =>
  rankedCandidateIds.value
    .map((candidateId) => candidates.value.find((candidate) => candidate.id === candidateId))
    .filter((candidate): candidate is Candidate => Boolean(candidate)),
);

const canContinue = computed(() => {
  if (!election.value) {
    return false;
  }

  switch (election.value.type) {
    case "SINGLE_CHOICE":
    case "BINARY_CHOICE":
      return selectedCandidateId.value !== null;
    case "APPROVAL_VOTING":
      return selectedCandidateIds.value.length > 0;
    case "LIMITED_VOTE":
      return (
        selectedCandidateIds.value.length > 0 &&
        selectedCandidateIds.value.length <= selectionLimit.value
      );
    case "BORDA_COUNT":
      return rankedCandidateIds.value.length === candidates.value.length;
    default:
      return false;
  }
});

function toggleCandidate(candidateId: number) {
  if (!election.value) {
    return;
  }

  const alreadySelected = selectedCandidateIds.value.includes(candidateId);
  if (alreadySelected) {
    selectedCandidateIds.value = selectedCandidateIds.value.filter((id) => id !== candidateId);
    return;
  }

  if (
    election.value.type === "LIMITED_VOTE" &&
    selectedCandidateIds.value.length >= selectionLimit.value
  ) {
    return;
  }

  selectedCandidateIds.value = [...selectedCandidateIds.value, candidateId];
}

function moveCandidate(index: number, offset: number) {
  const nextIndex = index + offset;
  if (nextIndex < 0 || nextIndex >= rankedCandidateIds.value.length) {
    return;
  }

  const updated = [...rankedCandidateIds.value];
  const [movedCandidateId] = updated.splice(index, 1);
  updated.splice(nextIndex, 0, movedCandidateId);
  rankedCandidateIds.value = updated;
}

function buildBallot(): StoredVoteBallot | null {
  if (!election.value) {
    return null;
  }

  const summary: string[] = [];
  const ballot: StoredVoteBallot = {
    electionId,
    electionTitle: election.value.title,
    electionType: election.value.type,
    summary,
  };

  switch (election.value.type) {
    case "SINGLE_CHOICE":
    case "BINARY_CHOICE": {
      const selectedCandidate = candidates.value.find(
        (candidate) => candidate.id === selectedCandidateId.value,
      );
      if (!selectedCandidate) {
        return null;
      }
      ballot.candidateId = selectedCandidate.id;
      summary.push(`${selectedCandidate.firstName} ${selectedCandidate.lastName}`);
      break;
    }
    case "APPROVAL_VOTING":
    case "LIMITED_VOTE": {
      ballot.candidateIds = [...selectedCandidateIds.value];
      summary.push(
        ...selectedCandidateIds.value
          .map((candidateId) => candidates.value.find((candidate) => candidate.id === candidateId))
          .filter((candidate): candidate is Candidate => Boolean(candidate))
          .map((candidate) => `${candidate.firstName} ${candidate.lastName}`),
      );
      break;
    }
    case "BORDA_COUNT": {
      ballot.rankedCandidateIds = [...rankedCandidateIds.value];
      summary.push(
        ...rankedCandidates.value.map(
          (candidate, index) => `${index + 1}. ${candidate.firstName} ${candidate.lastName}`,
        ),
      );
      break;
    }
  }

  return ballot;
}

function goToConfirm() {
  const ballot = buildBallot();
  if (!ballot) {
    return;
  }

  sessionStorage.setItem("vote_ballot", JSON.stringify(ballot));
  router.push("/vote/confirm");
}

async function loadData() {
  loading.value = true;
  error.value = null;
  try {
    const [loadedElection, loadedCandidates] = await Promise.all([
      electionApi.getById(electionId),
      candidateApi.getByElection(electionId),
    ]);
    election.value = loadedElection;
    candidates.value = loadedCandidates;
    rankedCandidateIds.value = loadedCandidates.map((candidate) => candidate.id);

    if (loadedElection.type === "BINARY_CHOICE" && loadedCandidates.length !== 2) {
      error.value = t('voter.binaryChoiceRequiresTwo');
    }
  } catch (err: any) {
    error.value = err.response?.data?.message || t('voter.loadElectionFailed');
  } finally {
    loading.value = false;
  }
}

onMounted(loadData);
</script>

<style scoped>
.voter-election {
  min-height: 100vh;
  padding: 2rem;
}

.election-container {
  max-width: 760px;
  margin: 0 auto;
}

.election-header {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  align-items: center;
  margin-bottom: 0.5rem;
}

.election-container h1 {
  color: #1a202c;
  margin: 0;
}

.type-badge {
  margin: 0;
  padding: 0.35rem 0.8rem;
  border-radius: 999px;
  background: #edf2f7;
  color: #4a5568;
  font-size: 0.8rem;
  font-weight: 700;
  text-transform: uppercase;
}

.election-desc {
  color: #718096;
  margin-bottom: 0.5rem;
}

.instruction {
  color: #4a5568;
  font-weight: 500;
  margin-bottom: 1.5rem;
}

.selection-counter,
.ranking-help {
  margin-bottom: 1rem;
  color: #4a5568;
  font-weight: 600;
}

.loading-state, .error-state {
  text-align: center;
  padding: 3rem;
}

.spinner {
  width: 2.5rem;
  height: 2.5rem;
  border: 3px solid #e2e8f0;
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin { to { transform: rotate(360deg); } }

.error-state { color: #e53e3e; }
.error-state p { margin-bottom: 1rem; }

.btn {
  padding: 0.5rem 1rem;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}

.candidates-list {
  margin-bottom: 1.5rem;
}

.candidate-card {
  background: white;
  padding: 1.25rem 1.5rem;
  border-radius: 12px;
  margin-bottom: 0.75rem;
  cursor: pointer;
  border: 2px solid transparent;
  transition: all 0.2s;
  display: flex;
  gap: 1rem;
  align-items: flex-start;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
}

.candidate-card:hover { border-color: #667eea; }

.candidate-card.selected {
  border-color: #667eea;
  background: #f0f4ff;
}

.candidate-check { padding-top: 0.25rem; flex-shrink: 0; }

.radio,
.checkbox {
  width: 1.25rem;
  height: 1.25rem;
  border: 2px solid #cbd5e0;
  transition: all 0.2s;
  position: relative;
}

.radio {
  border-radius: 50%;
}

.checkbox {
  border-radius: 6px;
}

.radio.checked,
.checkbox.checked {
  border-color: #667eea;
  background: #667eea;
}

.radio.checked::after {
  content: "";
  position: absolute;
  top: 3px;
  left: 3px;
  width: 10px;
  height: 10px;
  background: white;
  border-radius: 50%;
}

.checkbox.checked::after {
  content: "✓";
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 0.85rem;
  font-weight: 700;
}

.candidate-info h3 {
  margin: 0 0 0.25rem 0;
  color: #1a202c;
  font-size: 1.05rem;
}

.class-name {
  color: #667eea;
  font-size: 0.85rem;
  margin: 0 0 0.25rem 0;
  font-weight: 500;
}

.description {
  color: #718096;
  font-size: 0.9rem;
  margin: 0;
}

.ranking-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.ranking-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: white;
  border-radius: 12px;
  padding: 1rem 1.25rem;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
}

.rank-badge {
  width: 2rem;
  height: 2rem;
  border-radius: 999px;
  background: #667eea;
  color: white;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  flex-shrink: 0;
}

.rank-actions {
  margin-left: auto;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.move-btn {
  width: 2rem;
  height: 2rem;
  border-radius: 8px;
  border: 1px solid #cbd5e0;
  background: white;
  cursor: pointer;
}

.move-btn:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.vote-button {
  width: 100%;
  padding: 1rem;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.vote-button:hover:not(:disabled) { background: #5a67d8; }
.vote-button:disabled { opacity: 0.5; cursor: not-allowed; }

@media (max-width: 700px) {
  .election-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .ranking-item {
    align-items: flex-start;
  }
}
</style>
