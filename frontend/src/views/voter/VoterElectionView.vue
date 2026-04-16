<template>
  <div class="voter-election">
    <div class="election-container">
      <h1>Election</h1>
      <p>Select a candidate to vote for:</p>
      
      <div class="candidates-list">
        <div
          v-for="candidate in candidates"
          :key="candidate.id"
          class="candidate-card"
          :class="{ selected: selectedCandidate === candidate.id }"
          @click="selectedCandidate = candidate.id"
        >
          <h3>{{ candidate.firstName }} {{ candidate.lastName }}</h3>
          <p v-if="candidate.className" class="class-name">{{ candidate.className }}</p>
          <p v-if="candidate.description" class="description">{{ candidate.description }}</p>
        </div>
      </div>
      
      <button
        class="vote-button"
        :disabled="!selectedCandidate"
        @click="submitVote"
      >
        Submit Vote
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const selectedCandidate = ref<number | null>(null);

const candidates = ref([
  { id: 1, firstName: 'John', lastName: 'Doe', className: '10A', description: 'Candidate 1' },
  { id: 2, firstName: 'Jane', lastName: 'Smith', className: '10B', description: 'Candidate 2' },
  { id: 3, firstName: 'Bob', lastName: 'Johnson', className: '10A', description: 'Candidate 3' },
]);

function submitVote() {
  // TODO: Implement vote submission
  router.push('/vote/result');
}
</script>

<style scoped>
.voter-election {
  min-height: 100vh;
  padding: 2rem;
  background: #f5f5f5;
}

.election-container {
  max-width: 800px;
  margin: 0 auto;
}

.election-container h1 {
  color: #333;
  margin-bottom: 1rem;
}

.candidates-list {
  margin: 2rem 0;
}

.candidate-card {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 1rem;
  cursor: pointer;
  border: 2px solid transparent;
  transition: all 0.2s;
}

.candidate-card:hover {
  border-color: #667eea;
}

.candidate-card.selected {
  border-color: #667eea;
  background: #f0f4ff;
}

.candidate-card h3 {
  margin: 0 0 0.5rem 0;
  color: #333;
}

.class-name {
  color: #667eea;
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
}

.vote-button {
  width: 100%;
  padding: 1rem;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1.1rem;
  cursor: pointer;
}

.vote-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>
