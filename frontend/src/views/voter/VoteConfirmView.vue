<template>
  <div class="vote-confirm">
    <div class="confirm-card">
      <div class="icon">✅</div>
      <h1>{{ t('voter.confirmTitle') }}</h1>

      <div v-if="ballot" class="vote-details">
        <div class="detail-row">
          <span class="label">{{ t('voter.election') }}</span>
          <span class="value">{{ ballot.electionTitle }}</span>
        </div>
        <div class="detail-row">
          <span class="label">{{ t('voter.selectionType') }}</span>
          <span class="value">{{ getElectionTypeDefinition(ballot.electionType, t).label }}</span>
        </div>
      </div>

      <div v-if="ballot" class="selection-summary">
        <h2>{{ t('voter.yourSelection') }}</h2>
        <ul>
          <li v-for="item in ballot.summary" :key="item">{{ item }}</li>
        </ul>
      </div>

      <p class="warning">⚠️ {{ t('voter.finalWarning') }}</p>

      <div v-if="errorMsg" class="error-msg">{{ errorMsg }}</div>

      <div class="actions">
        <button class="btn btn-secondary" :disabled="submitting" @click="goBack">
          ← {{ t('voter.goBack') }}
        </button>
        <button class="btn btn-primary" :disabled="submitting || !ballot" @click="submitVote">
          {{ submitting ? t('voter.submittingVote') : `🗳️ ${t('voter.submitVote')}` }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from "vue";
import { useRouter } from "vue-router";
import { voteApi } from "@/api";
import { useLocale } from "@/composables/useLocale";
import { getElectionTypeDefinition, type Election } from "@/types";

interface StoredVoteBallot {
  electionId: number;
  electionTitle: string;
  electionType: Election["type"];
  candidateId?: number;
  candidateIds?: number[];
  rankedCandidateIds?: number[];
  summary: string[];
}

const router = useRouter();
const submitting = ref(false);
const errorMsg = ref("");
const ballot = ref<StoredVoteBallot | null>(null);
const voterToken = ref("");
const { t } = useLocale();

function goBack() {
  router.back();
}

async function submitVote() {
  if (!ballot.value || !voterToken.value) {
    errorMsg.value = t('voter.missingVoteData');
    return;
  }

  submitting.value = true;
  errorMsg.value = "";

  try {
    await voteApi.castVote({
      electionId: ballot.value.electionId,
      token: voterToken.value,
      candidateId: ballot.value.candidateId,
      candidateIds: ballot.value.candidateIds,
      rankedCandidateIds: ballot.value.rankedCandidateIds,
    });
    sessionStorage.removeItem("vote_ballot");
    router.push("/vote/success");
  } catch (err: any) {
    errorMsg.value = err.response?.data?.message || t('voter.submitVoteFailed');
  } finally {
    submitting.value = false;
  }
}

onMounted(() => {
  const rawBallot = sessionStorage.getItem("vote_ballot");
  voterToken.value = sessionStorage.getItem("voter_token") || "";

  if (!rawBallot || !voterToken.value) {
    router.replace("/vote/login");
    return;
  }

  try {
    ballot.value = JSON.parse(rawBallot) as StoredVoteBallot;
  } catch {
    router.replace("/vote/login");
  }
});
</script>

<style scoped>
.vote-confirm {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.confirm-card {
  background: white;
  padding: 2.5rem;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0,0,0,0.15);
  text-align: center;
  max-width: 560px;
  width: 100%;
}

.icon { font-size: 3rem; margin-bottom: 0.5rem; }

.confirm-card h1 {
  margin: 0 0 1.5rem 0;
  color: #1a202c;
  font-size: 1.5rem;
}

.vote-details,
.selection-summary {
  background: #f7fafc;
  border-radius: 10px;
  padding: 1.25rem;
  margin-bottom: 1.25rem;
  text-align: left;
}

.selection-summary h2 {
  margin: 0 0 0.75rem 0;
  font-size: 1rem;
  color: #1a202c;
}

.selection-summary ul {
  margin: 0;
  padding-left: 1.1rem;
}

.selection-summary li + li {
  margin-top: 0.35rem;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem 0;
}

.detail-row + .detail-row {
  border-top: 1px solid #e2e8f0;
}

.label {
  color: #718096;
  font-size: 0.9rem;
}

.value {
  font-weight: 600;
  color: #1a202c;
}

.warning {
  color: #975a16;
  background: #fffff0;
  border: 1px solid #fefcbf;
  border-radius: 8px;
  padding: 0.75rem;
  font-size: 0.9rem;
  margin-bottom: 1.25rem;
}

.error-msg {
  background: #fed7d7;
  color: #9b2c2c;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  font-size: 0.9rem;
  margin-bottom: 1.25rem;
}

.actions {
  display: flex;
  gap: 0.75rem;
}

.btn {
  flex: 1;
  padding: 0.875rem;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn:disabled { opacity: 0.6; cursor: not-allowed; }

.btn-secondary {
  background: #e2e8f0;
  color: #4a5568;
}

.btn-secondary:hover:not(:disabled) { background: #cbd5e0; }

.btn-primary {
  background: #667eea;
  color: white;
}

.btn-primary:hover:not(:disabled) { background: #5a67d8; }
</style>
