<template>
  <div class="vote-success">
    <div class="success-card">
      <div class="icon">🎉</div>
      <h1>{{ t('voter.successTitle') }}</h1>
      <p>{{ t('voter.successMessage') }}</p>
      <p class="sub-text">{{ t('voter.successThanks') }}</p>

      <button class="btn" @click="finish">{{ t('common.done') }}</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router';
import { useLocale } from '@/composables/useLocale';

const router = useRouter();
const { t } = useLocale();

function finish() {
  // Clear all voter session data
  sessionStorage.removeItem('voter_token');
  sessionStorage.removeItem('voter_election_id');
  sessionStorage.removeItem('vote_candidate_id');
  sessionStorage.removeItem('vote_candidate_name');
  sessionStorage.removeItem('vote_election_id');
  sessionStorage.removeItem('vote_election_title');
  sessionStorage.removeItem('vote_ballot');
  sessionStorage.removeItem('vote_summary');
  router.push('/vote/login');
}
</script>

<style scoped>
.vote-success {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.success-card {
  background: white;
  padding: 3rem;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0,0,0,0.15);
  text-align: center;
  max-width: 440px;
  width: 100%;
}

.icon { font-size: 4rem; margin-bottom: 0.5rem; }

.success-card h1 {
  margin: 0 0 0.75rem 0;
  color: #276749;
  font-size: 1.75rem;
}

.success-card p {
  color: #4a5568;
  margin: 0 0 0.5rem 0;
  font-size: 1.05rem;
}

.sub-text {
  color: #718096 !important;
  font-size: 0.9rem !important;
  margin-bottom: 2rem !important;
}

.btn {
  padding: 0.875rem 2.5rem;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.btn:hover { background: #5a67d8; }
</style>
