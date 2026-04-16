<template>
  <div class="voter-election">
    <div class="election-container">
      <!-- Loading -->
      <div v-if="loading" class="loading-state">
        <div class="spinner" />
        <p>Loading election...</p>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="error-state">
        <p>{{ error }}</p>
        <button class="btn" @click="loadData">Retry</button>
      </div>

      <!-- Election -->
      <template v-else-if="election">
        <h1>{{ election.title }}</h1>
        <p v-if="election.description" class="election-desc">{{ election.description }}</p>
        <p class="instruction">Select a candidate to vote for:</p>

        <div class="candidates-list">
          <div
            v-for="candidate in candidates"
            :key="candidate.id"
            class="candidate-card"
            :class="{ selected: selectedCandidate === candidate.id }"
            @click="selectedCandidate = candidate.id"
          >
            <div class="candidate-check">
              <div class="radio" :class="{ checked: selectedCandidate === candidate.id }" />
            </div>
            <div class="candidate-info">
              <h3>{{ candidate.firstName }} {{ candidate.lastName }}</h3>
              <p v-if="candidate.className" class="class-name">{{ candidate.className }}</p>
              <p v-if="candidate.description" class="description">{{ candidate.description }}</p>
            </div>
          </div>
        </div>

        <button
          class="vote-button"
          :disabled="selectedCandidate === null"
          @click="goToConfirm"
        >
          Continue to Confirm
        </button>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { electionApi, candidateApi } from '@/api';
import type { Election, Candidate } from '@/types';

const route = useRoute();
const router = useRouter();
const electionId = Number(route.params.id);

const election = ref<Election | null>(null);
const candidates = ref<Candidate[]>([]);
const selectedCandidate = ref<number | null>(null);
const loading = ref(false);
const error = ref<string | null>(null);

function goToConfirm() {
  if (selectedCandidate.value === null) return;
  const candidate = candidates.value.find(c => c.id === selectedCandidate.value);
  // Store selection in sessionStorage for the confirm page
  sessionStorage.setItem('vote_candidate_id', String(selectedCandidate.value));
  sessionStorage.setItem('vote_candidate_name', candidate ? `${candidate.firstName} ${candidate.lastName}` : '');
  sessionStorage.setItem('vote_election_id', String(electionId));
  sessionStorage.setItem('vote_election_title', election.value?.title || '');
  router.push('/vote/confirm');
}

async function loadData() {
  loading.value = true;
  error.value = null;
  try {
    const [el, cands] = await Promise.all([
      electionApi.getById(electionId),
      candidateApi.getByElection(electionId),
    ]);
    election.value = el;
    candidates.value = cands;
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to load election.';
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
  max-width: 700px;
  margin: 0 auto;
}

.election-container h1 {
  color: #1a202c;
  margin-bottom: 0.5rem;
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

.candidates-list { margin-bottom: 1.5rem; }

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

.radio {
  width: 1.25rem;
  height: 1.25rem;
  border: 2px solid #cbd5e0;
  border-radius: 50%;
  transition: all 0.2s;
  position: relative;
}

.radio.checked {
  border-color: #667eea;
}

.radio.checked::after {
  content: '';
  position: absolute;
  top: 3px;
  left: 3px;
  width: 10px;
  height: 10px;
  background: #667eea;
  border-radius: 50%;
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
</style>
