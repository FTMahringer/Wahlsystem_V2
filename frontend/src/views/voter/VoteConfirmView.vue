<template>
  <div class="vote-confirm">
    <div class="confirm-card">
      <div class="icon">✅</div>
      <h1>Confirm Your Vote</h1>

      <div class="vote-details">
        <div class="detail-row">
          <span class="label">Election</span>
          <span class="value">{{ electionTitle }}</span>
        </div>
        <div class="detail-row">
          <span class="label">Candidate</span>
          <span class="value">{{ candidateName }}</span>
        </div>
      </div>

      <p class="warning">⚠️ This action cannot be undone. Your vote is final.</p>

      <div v-if="errorMsg" class="error-msg">{{ errorMsg }}</div>

      <div class="actions">
        <button class="btn btn-secondary" :disabled="submitting" @click="goBack">
          ← Go Back
        </button>
        <button class="btn btn-primary" :disabled="submitting" @click="submitVote">
          {{ submitting ? 'Submitting...' : '🗳️ Submit Vote' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { voteApi } from '@/api';

const router = useRouter();
const submitting = ref(false);
const errorMsg = ref('');

const electionTitle = ref('');
const candidateName = ref('');
const candidateId = ref(0);
const electionId = ref(0);
const voterToken = ref('');

function goBack() {
  router.back();
}

async function submitVote() {
  if (!candidateId.value || !electionId.value || !voterToken.value) {
    errorMsg.value = 'Missing vote data. Please go back and try again.';
    return;
  }

  submitting.value = true;
  errorMsg.value = '';

  try {
    await voteApi.castVote({
      electionId: electionId.value,
      candidateId: candidateId.value,
      token: voterToken.value,
    });
    // Clear vote session data
    sessionStorage.removeItem('vote_candidate_id');
    sessionStorage.removeItem('vote_candidate_name');
    sessionStorage.removeItem('vote_election_id');
    sessionStorage.removeItem('vote_election_title');
    router.push('/vote/success');
  } catch (err: any) {
    errorMsg.value = err.response?.data?.message || 'Failed to submit vote. Please try again.';
  } finally {
    submitting.value = false;
  }
}

onMounted(() => {
  candidateId.value = Number(sessionStorage.getItem('vote_candidate_id') || 0);
  candidateName.value = sessionStorage.getItem('vote_candidate_name') || '';
  electionId.value = Number(sessionStorage.getItem('vote_election_id') || 0);
  electionTitle.value = sessionStorage.getItem('vote_election_title') || '';
  voterToken.value = sessionStorage.getItem('voter_token') || '';

  if (!candidateId.value || !electionId.value) {
    router.replace('/vote/login');
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
  max-width: 480px;
  width: 100%;
}

.icon { font-size: 3rem; margin-bottom: 0.5rem; }

.confirm-card h1 {
  margin: 0 0 1.5rem 0;
  color: #1a202c;
  font-size: 1.5rem;
}

.vote-details {
  background: #f7fafc;
  border-radius: 10px;
  padding: 1.25rem;
  margin-bottom: 1.25rem;
  text-align: left;
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
