<template>
  <div class="index-page">
    <header class="header">
      <div class="header-content">
        <h1>Wahlsystem</h1>
        <nav class="nav">
          <router-link to="/">Home</router-link>
          <router-link v-if="!isAuthenticated" to="/login">Login</router-link>
          <router-link v-if="isAdminOrTeacher" to="/admin/dashboard">Dashboard</router-link>
          <router-link v-if="isStudent" to="/vote/login">Vote</router-link>
          <button v-if="isAuthenticated" class="logout-btn" @click="handleLogout">Logout</button>
        </nav>
      </div>
    </header>

    <main class="main-content">
      <!-- Active Elections -->
      <section class="section">
        <h2>Active Elections</h2>
        <div v-if="loadingActive" class="loading">Loading...</div>
        <div v-else-if="activeElections.length === 0" class="empty">No active elections at the moment.</div>
        <div v-else class="election-grid">
          <div v-for="election in activeElections" :key="election.id" class="election-card active">
            <div class="card-header">
              <h3>{{ election.title }}</h3>
              <span class="badge active">Active</span>
            </div>
            <p class="description">{{ election.description || 'No description available.' }}</p>
            <div class="meta">
              <span v-if="election.endAt">Ends: {{ formatDate(election.endAt) }}</span>
              <span v-else>No end date</span>
            </div>
            <router-link v-if="isStudent" :to="`/vote/election/${election.id}`" class="action-link">
              Vote Now
            </router-link>
          </div>
        </div>
      </section>

      <!-- Upcoming Elections -->
      <section class="section">
        <h2>Upcoming Elections</h2>
        <div v-if="loadingAll" class="loading">Loading...</div>
        <div v-else-if="upcomingElections.length === 0" class="empty">No upcoming elections.</div>
        <div v-else class="election-grid">
          <div v-for="election in upcomingElections" :key="election.id" class="election-card planned">
            <div class="card-header">
              <h3>{{ election.title }}</h3>
              <span class="badge planned">{{ election.status }}</span>
            </div>
            <p class="description">{{ election.description || 'No description available.' }}</p>
            <div class="meta">
              <span v-if="election.startAt">Starts: {{ formatDate(election.startAt) }}</span>
              <span v-else>No start date</span>
            </div>
          </div>
        </div>
      </section>

      <!-- Previous Results -->
      <section class="section">
        <h2>Previous Election Results</h2>
        <div v-if="loadingEnded" class="loading">Loading...</div>
        <div v-else-if="endedElections.length === 0" class="empty">No ended elections yet.</div>
        <div v-else class="results-list">
          <div v-for="election in endedElections" :key="election.id" class="result-card">
            <div class="result-header" @click="toggleResult(election.id)">
              <h3>{{ election.title }}</h3>
              <span class="toggle">{{ expandedResults[election.id] ? '▲' : '▼' }}</span>
            </div>
            <div v-if="expandedResults[election.id]" class="result-body">
              <div v-if="resultLoading[election.id]" class="loading">Loading results...</div>
              <div v-else-if="results[election.id]" class="result-details">
                <p class="total-votes">
                  Total {{ results[election.id].resultMetricLabel }}:
                  {{ results[election.id].totalVotes }}
                </p>
                <div class="winners" v-if="results[election.id].winners.length > 0">
                  <h4>🏆 Winner{{ results[election.id].winners.length > 1 ? 's' : '' }}</h4>
                  <div class="winner-tags">
                      <span v-for="winner in results[election.id].winners" :key="winner.candidateId" class="winner-tag">
                        {{ winner.firstName }} {{ winner.lastName }}
                      <small>
                        ({{ winner.voteCount }} {{ results[election.id].resultMetricLabel }},
                        {{ winner.percentage.toFixed(1) }}%)
                      </small>
                      </span>
                  </div>
                </div>
                <div class="all-results">
                  <h4>All Results</h4>
                  <div v-for="r in results[election.id].results" :key="r.candidateId" class="result-bar">
                    <div class="bar-label">
                      <span>{{ r.firstName }} {{ r.lastName }}</span>
                      <span>
                        {{ r.voteCount }} {{ results[election.id].resultMetricLabel }}
                        ({{ r.percentage.toFixed(1) }}%)
                      </span>
                    </div>
                    <div class="bar-track">
                      <div class="bar-fill" :style="{ width: r.percentage + '%' }" :class="{ winner: r.winner }"></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>

    <footer class="footer">
      <p>&copy; {{ new Date().getFullYear() }} Wahlsystem</p>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { electionApi } from '@/api';
import { useAuthStore } from '@/stores/authStore';
import { useRole } from '@/composables/useRole';
import type { Election, ElectionResult } from '@/types';

const router = useRouter();
const authStore = useAuthStore();
const { isAuthenticated, isAdminOrTeacher, isStudent } = useRole();

const allElections = ref<Election[]>([]);
const activeElections = ref<Election[]>([]);
const endedElections = ref<Election[]>([]);
const results = ref<Record<number, ElectionResult>>({});
const expandedResults = ref<Record<number, boolean>>({});
const resultLoading = ref<Record<number, boolean>>({});

const loadingAll = ref(false);
const loadingActive = ref(false);
const loadingEnded = ref(false);

const upcomingElections = computed(() => {
  return allElections.value.filter(e => e.status !== 'ACTIVE' && e.status !== 'ENDED');
});

function formatDate(dateStr: string | null): string {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleString('de-DE');
}

async function loadData() {
  loadingAll.value = true;
  loadingActive.value = true;
  loadingEnded.value = true;

  try {
    const [all, active, ended] = await Promise.all([
      electionApi.getAll(),
      electionApi.getActive(),
      electionApi.getEnded(),
    ]);
    allElections.value = all;
    activeElections.value = active;
    endedElections.value = ended;
  } catch (err) {
    console.error('Failed to load elections', err);
  } finally {
    loadingAll.value = false;
    loadingActive.value = false;
    loadingEnded.value = false;
  }
}

async function toggleResult(electionId: number) {
  if (expandedResults.value[electionId]) {
    expandedResults.value[electionId] = false;
    return;
  }
  expandedResults.value[electionId] = true;

  if (results.value[electionId]) return;

  resultLoading.value[electionId] = true;
  try {
    const result = await electionApi.getResults(electionId);
    results.value[electionId] = result;
  } catch (err) {
    console.error('Failed to load results', err);
  } finally {
    resultLoading.value[electionId] = false;
  }
}

async function handleLogout() {
  await authStore.logout();
  router.push('/');
}

onMounted(() => {
  loadData();
});
</script>

<style scoped>
.index-page {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f5f7fa;
}

.header {
  background: white;
  border-bottom: 1px solid #e0e0e0;
  padding: 1rem 2rem;
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header h1 {
  margin: 0;
  font-size: 1.5rem;
  color: #333;
}

.nav {
  display: flex;
  gap: 1.5rem;
  align-items: center;
}

.nav a {
  color: #667eea;
  text-decoration: none;
  font-weight: 500;
}

.nav a:hover {
  text-decoration: underline;
}

.logout-btn {
  background: transparent;
  border: 1px solid #667eea;
  color: #667eea;
  padding: 0.4rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
}

.logout-btn:hover {
  background: #667eea;
  color: white;
}

.main-content {
  flex: 1;
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
  padding: 2rem;
  display: flex;
  flex-direction: column;
  gap: 2.5rem;
}

.section h2 {
  margin-bottom: 1rem;
  color: #333;
  font-size: 1.4rem;
}

.loading, .empty {
  padding: 1.5rem;
  text-align: center;
  color: #666;
  background: white;
  border-radius: 8px;
}

.election-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1rem;
}

.election-card {
  background: white;
  border-radius: 10px;
  padding: 1.25rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  border-left: 4px solid #ccc;
}

.election-card.active {
  border-left-color: #22c55e;
}

.election-card.planned {
  border-left-color: #f59e0b;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0.75rem;
}

.card-header h3 {
  margin: 0;
  font-size: 1.1rem;
  color: #333;
}

.badge {
  font-size: 0.7rem;
  font-weight: 600;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  text-transform: uppercase;
}

.badge.active {
  background: #dcfce7;
  color: #166534;
}

.badge.planned {
  background: #fef3c7;
  color: #92400e;
}

.description {
  color: #555;
  font-size: 0.95rem;
  margin-bottom: 0.75rem;
  line-height: 1.4;
}

.meta {
  font-size: 0.85rem;
  color: #888;
  margin-bottom: 0.75rem;
}

.action-link {
  display: inline-block;
  background: #667eea;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  text-decoration: none;
  font-size: 0.9rem;
  font-weight: 500;
}

.action-link:hover {
  background: #5a67d8;
}

.results-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.result-card {
  background: white;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  overflow: hidden;
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.25rem;
  cursor: pointer;
  background: #fafafa;
}

.result-header h3 {
  margin: 0;
  font-size: 1.05rem;
  color: #333;
}

.toggle {
  color: #888;
}

.result-body {
  padding: 1rem 1.25rem;
}

.total-votes {
  font-weight: 500;
  color: #555;
  margin-bottom: 1rem;
}

.winners {
  margin-bottom: 1.25rem;
}

.winners h4 {
  margin: 0 0 0.5rem 0;
  color: #333;
}

.winner-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.winner-tag {
  background: #fef3c7;
  color: #92400e;
  padding: 0.4rem 0.75rem;
  border-radius: 6px;
  font-weight: 500;
  font-size: 0.9rem;
}

.winner-tag small {
  font-weight: 400;
  color: #b45309;
}

.all-results h4 {
  margin: 0 0 0.75rem 0;
  color: #333;
}

.result-bar {
  margin-bottom: 0.75rem;
}

.bar-label {
  display: flex;
  justify-content: space-between;
  font-size: 0.9rem;
  color: #555;
  margin-bottom: 0.25rem;
}

.bar-track {
  height: 10px;
  background: #e5e7eb;
  border-radius: 5px;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  background: #667eea;
  border-radius: 5px;
  transition: width 0.3s ease;
}

.bar-fill.winner {
  background: #f59e0b;
}

.footer {
  text-align: center;
  padding: 1.5rem;
  color: #888;
  font-size: 0.9rem;
  background: white;
  border-top: 1px solid #e0e0e0;
}
</style>
