# Initialize Vue.js Frontend for Wahlsystem
# This script creates a complete Vue 3 + TypeScript + Vite project structure with JWT Auth

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR
$FRONTEND_DIR = Join-Path $PROJECT_ROOT "frontend"
$TEMPLATE_DIR = Join-Path $SCRIPT_DIR "templates/frontend"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Initializing Wahlsystem Frontend" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if frontend is already initialized
if ((Test-Path "$FRONTEND_DIR/package.json") -and (Test-Path "$FRONTEND_DIR/src")) {
    Write-Host "Frontend already initialized (package.json and src/ found)." -ForegroundColor Yellow
    Write-Host "Skipping initialization."
    exit 0
}

Write-Host "Creating frontend directory structure..." -ForegroundColor Green

# Create directory structure
$dirs = @(
    "src/api",
    "src/assets",
    "src/components/common",
    "src/components/admin",
    "src/components/voter",
    "src/components/auth",
    "src/composables",
    "src/layouts",
    "src/router",
    "src/stores",
    "src/types",
    "src/utils",
    "src/views/admin",
    "src/views/voter",
    "src/views/auth"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path (Join-Path $FRONTEND_DIR $dir) | Out-Null
}

# Copy template files
Write-Host "Creating configuration files..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/package.json" "$FRONTEND_DIR/package.json" -Force
Copy-Item "$TEMPLATE_DIR/vite.config.ts" "$FRONTEND_DIR/vite.config.ts" -Force
Copy-Item "$TEMPLATE_DIR/tsconfig.json" "$FRONTEND_DIR/tsconfig.json" -Force
Copy-Item "$TEMPLATE_DIR/tsconfig.node.json" "$FRONTEND_DIR/tsconfig.node.json" -Force
Copy-Item "$TEMPLATE_DIR/index.html" "$FRONTEND_DIR/index.html" -Force
Copy-Item "$TEMPLATE_DIR/App.vue" "$FRONTEND_DIR/src/App.vue" -Force
Copy-Item "$TEMPLATE_DIR/main.ts" "$FRONTEND_DIR/src/main.ts" -Force
Copy-Item "$TEMPLATE_DIR/router.ts" "$FRONTEND_DIR/src/router/index.ts" -Force
Copy-Item "$TEMPLATE_DIR/env.d.ts" "$FRONTEND_DIR/src/env.d.ts" -Force

# Create .env files
Write-Host "Creating environment files..." -ForegroundColor Green

$envDev = @'
VITE_API_BASE_URL=http://localhost:8080/api/v1
VITE_APP_NAME=Wahlsystem
VITE_APP_ENV=development
'@
$envDev | Set-Content "$FRONTEND_DIR/.env.development" -Encoding UTF8

$envProd = @'
VITE_API_BASE_URL=/api/v1
VITE_APP_NAME=Wahlsystem
VITE_APP_ENV=production
'@
$envProd | Set-Content "$FRONTEND_DIR/.env.production" -Encoding UTF8

# Copy types from templates
Write-Host "Creating TypeScript types..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/src/types/auth.ts" "$FRONTEND_DIR/src/types/auth.ts" -Force
Copy-Item "$TEMPLATE_DIR/src/types/election.ts" "$FRONTEND_DIR/src/types/election.ts" -Force
Copy-Item "$TEMPLATE_DIR/src/types/candidate.ts" "$FRONTEND_DIR/src/types/candidate.ts" -Force
Copy-Item "$TEMPLATE_DIR/src/types/vote.ts" "$FRONTEND_DIR/src/types/vote.ts" -Force
Copy-Item "$TEMPLATE_DIR/src/types/index.ts" "$FRONTEND_DIR/src/types/index.ts" -Force

# Copy API layer from templates
Write-Host "Creating API layer..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/src/api/axios.ts" "$FRONTEND_DIR/src/api/axios.ts" -Force
Copy-Item "$TEMPLATE_DIR/src/api/authApi.ts" "$FRONTEND_DIR/src/api/authApi.ts" -Force
Copy-Item "$TEMPLATE_DIR/src/api/electionApi.ts" "$FRONTEND_DIR/src/api/electionApi.ts" -Force
Copy-Item "$TEMPLATE_DIR/src/api/candidateApi.ts" "$FRONTEND_DIR/src/api/candidateApi.ts" -Force
Copy-Item "$TEMPLATE_DIR/src/api/voteApi.ts" "$FRONTEND_DIR/src/api/voteApi.ts" -Force
Copy-Item "$TEMPLATE_DIR/src/api/index.ts" "$FRONTEND_DIR/src/api/index.ts" -Force

# Copy stores from templates
Write-Host "Creating Pinia stores..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/src/stores/authStore.ts" "$FRONTEND_DIR/src/stores/authStore.ts" -Force

# Create additional stores
$electionStoreTs = @'
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { electionApi, candidateApi, voteApi } from '@/api';
import type { Election, Candidate, CreateElectionRequest, ElectionResults } from '@/types';

export const useElectionStore = defineStore('election', () => {
  // State
  const elections = ref<Election[]>([]);
  const currentElection = ref<Election | null>(null);
  const candidates = ref<Candidate[]>([]);
  const results = ref<ElectionResults | null>(null);
  const loading = ref(false);
  const error = ref<string | null>(null);

  // Getters
  const activeElections = computed(() => 
    elections.value.filter(e => e.status === 'ACTIVE')
  );

  const draftElections = computed(() => 
    elections.value.filter(e => e.status === 'DRAFT')
  );

  // Actions
  async function fetchElections() {
    loading.value = true;
    error.value = null;
    try {
      elections.value = await electionApi.getAll();
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to load elections';
    } finally {
      loading.value = false;
    }
  }

  async function fetchElection(id: number) {
    loading.value = true;
    error.value = null;
    try {
      currentElection.value = await electionApi.getById(id);
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to load election';
    } finally {
      loading.value = false;
    }
  }

  async function fetchCandidates(electionId: number) {
    loading.value = true;
    error.value = null;
    try {
      candidates.value = await candidateApi.getByElection(electionId);
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to load candidates';
    } finally {
      loading.value = false;
    }
  }

  async function createElection(data: CreateElectionRequest) {
    loading.value = true;
    error.value = null;
    try {
      const election = await electionApi.create(data);
      elections.value.push(election);
      return election;
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to create election';
      return null;
    } finally {
      loading.value = false;
    }
  }

  async function fetchResults(electionId: number) {
    loading.value = true;
    error.value = null;
    try {
      results.value = await voteApi.getResults(electionId);
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Failed to load results';
    } finally {
      loading.value = false;
    }
  }

  return {
    elections,
    currentElection,
    candidates,
    results,
    loading,
    error,
    activeElections,
    draftElections,
    fetchElections,
    fetchElection,
    fetchCandidates,
    createElection,
    fetchResults,
  };
});
'@
$electionStoreTs | Set-Content "$FRONTEND_DIR/src/stores/electionStore.ts" -Encoding UTF8

$uiStoreTs = @'
import { defineStore } from 'pinia';
import { ref } from 'vue';

export interface Notification {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  message: string;
}

export const useUiStore = defineStore('ui', () => {
  // State
  const notifications = ref<Notification[]>([]);
  const isLoading = ref(false);

  // Actions
  function showNotification(type: Notification['type'], message: string) {
    const id = Date.now().toString();
    notifications.value.push({ id, type, message });
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
      removeNotification(id);
    }, 5000);
  }

  function removeNotification(id: string) {
    const index = notifications.value.findIndex(n => n.id === id);
    if (index > -1) {
      notifications.value.splice(index, 1);
    }
  }

  function setLoading(loading: boolean) {
    isLoading.value = loading;
  }

  return {
    notifications,
    isLoading,
    showNotification,
    removeNotification,
    setLoading,
  };
});
'@
$uiStoreTs | Set-Content "$FRONTEND_DIR/src/stores/uiStore.ts" -Encoding UTF8

$storesIndexTs = @'
export * from './authStore';
export * from './electionStore';
export * from './uiStore';
'@
$storesIndexTs | Set-Content "$FRONTEND_DIR/src/stores/index.ts" -Encoding UTF8

# Copy auth views from templates
Write-Host "Creating auth views..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/src/views/auth/LoginView.vue" "$FRONTEND_DIR/src/views/auth/LoginView.vue" -Force
Copy-Item "$TEMPLATE_DIR/src/views/auth/RegisterView.vue" "$FRONTEND_DIR/src/views/auth/RegisterView.vue" -Force

# Create layouts
Write-Host "Creating layouts..." -ForegroundColor Green

$voterLayout = @'
<template>
  <div class="voter-layout">
    <main class="voter-main">
      <router-view />
    </main>
  </div>
</template>

<style scoped>
.voter-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.voter-main {
  flex: 1;
  display: flex;
  flex-direction: column;
}
</style>
'@
$voterLayout | Set-Content "$FRONTEND_DIR/src/layouts/VoterLayout.vue" -Encoding UTF8

$adminLayout = @'
<template>
  <div class="admin-layout">
    <header class="admin-header">
      <h1>Wahlsystem Admin</h1>
      <nav>
        <router-link to="/admin/dashboard">Dashboard</router-link>
        <router-link to="/admin/elections">Elections</router-link>
        <button @click="logout">Logout</button>
      </nav>
    </header>
    <main class="admin-main">
      <router-view />
    </main>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '@/stores';
import { useRouter } from 'vue-router';

const authStore = useAuthStore();
const router = useRouter();

async function logout() {
  await authStore.logout();
  router.push('/login');
}
</script>

<style scoped>
.admin-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.admin-header {
  background: #2c3e50;
  color: white;
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.admin-header nav {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.admin-header a {
  color: white;
  text-decoration: none;
}

.admin-header a:hover {
  text-decoration: underline;
}

.admin-main {
  flex: 1;
  padding: 2rem;
  background: #f5f5f5;
}
</style>
'@
$adminLayout | Set-Content "$FRONTEND_DIR/src/layouts/AdminLayout.vue" -Encoding UTF8

# Create default views
Write-Host "Creating default views..." -ForegroundColor Green

# Voter Login View
$voterLoginView = @'
<template>
  <div class="voter-login">
    <div class="login-card">
      <h1>Wahlsystem</h1>
      <p>Enter your voting token to participate</p>
      
      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <input
            v-model="token"
            type="text"
            placeholder="Enter your token"
            required
            :disabled="authStore.loading"
          />
        </div>
        
        <button type="submit" :disabled="authStore.loading || !token">
          {{ authStore.loading ? 'Loading...' : 'Continue' }}
        </button>
      </form>
      
      <p v-if="authStore.error" class="error">{{ authStore.error }}</p>
      
      <div class="admin-link">
        <router-link to="/login">Admin Login</router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores';

const token = ref('');
const authStore = useAuthStore();
const router = useRouter();

async function handleLogin() {
  router.push('/vote/election/1');
}
</script>

<style scoped>
.voter-login {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 1rem;
}

.login-card {
  background: white;
  padding: 3rem;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  text-align: center;
  max-width: 400px;
  width: 100%;
}

.login-card h1 {
  margin-bottom: 0.5rem;
  color: #333;
}

.login-card p {
  color: #666;
  margin-bottom: 2rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

input {
  width: 100%;
  padding: 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.2s;
}

input:focus {
  outline: none;
  border-color: #667eea;
}

button {
  width: 100%;
  padding: 1rem;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.2s;
}

button:hover:not(:disabled) {
  background: #5a67d8;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error {
  color: #e74c3c;
  margin-top: 1rem;
}

.admin-link {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid #eee;
}

.admin-link a {
  color: #667eea;
  text-decoration: none;
}

.admin-link a:hover {
  text-decoration: underline;
}
</style>
'@
$voterLoginView | Set-Content "$FRONTEND_DIR/src/views/voter/VoterLoginView.vue" -Encoding UTF8

# Admin Dashboard View
$adminDashboardView = @'
<template>
  <div class="admin-dashboard">
    <h1>Dashboard</h1>
    
    <div class="welcome-message">
      <h2>Welcome, {{ authStore.currentUser?.fullName || authStore.currentUser?.username }}!</h2>
      <p>You are logged in as <strong>{{ authStore.currentUser?.role }}</strong></p>
    </div>
    
    <div class="stats-grid">
      <div class="stat-card">
        <h3>Active Elections</h3>
        <p class="stat-value">{{ electionStore.activeElections.length }}</p>
      </div>
      
      <div class="stat-card">
        <h3>Draft Elections</h3>
        <p class="stat-value">{{ electionStore.draftElections.length }}</p>
      </div>
      
      <div class="stat-card">
        <h3>Total Elections</h3>
        <p class="stat-value">{{ electionStore.elections.length }}</p>
      </div>
    </div>
    
    <div class="quick-actions">
      <h2>Quick Actions</h2>
      <router-link to="/admin/elections/create" class="action-button">
        Create New Election
      </router-link>
      <router-link to="/admin/elections" class="action-button secondary">
        View All Elections
      </router-link>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';
import { useAuthStore, useElectionStore } from '@/stores';

const authStore = useAuthStore();
const electionStore = useElectionStore();

onMounted(() => {
  electionStore.fetchElections();
});
</script>

<style scoped>
.admin-dashboard h1 {
  margin-bottom: 1rem;
  color: #333;
}

.welcome-message {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 2rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.welcome-message h2 {
  margin: 0 0 0.5rem 0;
  color: #333;
}

.welcome-message p {
  margin: 0;
  color: #666;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.stat-card h3 {
  margin: 0 0 1rem 0;
  color: #666;
  font-size: 0.9rem;
  text-transform: uppercase;
}

.stat-value {
  font-size: 2.5rem;
  font-weight: bold;
  color: #667eea;
  margin: 0;
}

.quick-actions {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.quick-actions h2 {
  margin-bottom: 1.5rem;
  color: #333;
}

.action-button {
  display: inline-block;
  padding: 0.75rem 1.5rem;
  background: #667eea;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  margin-right: 1rem;
  margin-bottom: 0.5rem;
}

.action-button:hover {
  background: #5a67d8;
}

.action-button.secondary {
  background: #6c757d;
}

.action-button.secondary:hover {
  background: #5a6268;
}
</style>
'@
$adminDashboardView | Set-Content "$FRONTEND_DIR/src/views/admin/AdminDashboardView.vue" -Encoding UTF8

# Admin Elections View
$adminElectionsView = @'
<template>
  <div class="admin-elections">
    <div class="header">
      <h1>Elections</h1>
      <router-link to="/admin/elections/create" class="create-button">
        Create Election
      </router-link>
    </div>
    
    <div v-if="electionStore.loading" class="loading">
      Loading elections...
    </div>
    
    <div v-else-if="electionStore.error" class="error">
      {{ electionStore.error }}
    </div>
    
    <div v-else class="elections-table">
      <table>
        <thead>
          <tr>
            <th>Title</th>
            <th>Type</th>
            <th>Status</th>
            <th>Start Date</th>
            <th>End Date</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="election in electionStore.elections" :key="election.id">
            <td>{{ election.title }}</td>
            <td>{{ election.type }}</td>
            <td>
              <span :class="['status-badge', election.status.toLowerCase()]">
                {{ election.status }}
              </span>
            </td>
            <td>{{ formatDate(election.startAt) }}</td>
            <td>{{ formatDate(election.endAt) }}</td>
            <td>
              <button class="action-btn" @click="editElection(election.id)">
                Edit
              </button>
              <button class="action-btn" @click="viewResults(election.id)">
                Results
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useElectionStore } from '@/stores';

const electionStore = useElectionStore();
const router = useRouter();

onMounted(() => {
  electionStore.fetchElections();
});

function formatDate(date: string | null): string {
  if (!date) return '-';
  return new Date(date).toLocaleDateString();
}

function editElection(id: number) {
  router.push(`/admin/elections/${id}/edit`);
}

function viewResults(id: number) {
  router.push(`/admin/elections/${id}/results`);
}
</script>

<style scoped>
.admin-elections {
  max-width: 1200px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.header h1 {
  margin: 0;
  color: #333;
}

.create-button {
  padding: 0.75rem 1.5rem;
  background: #667eea;
  color: white;
  text-decoration: none;
  border-radius: 4px;
}

.create-button:hover {
  background: #5a67d8;
}

.elections-table {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid #eee;
}

th {
  background: #f8f9fa;
  font-weight: 600;
  color: #555;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 500;
}

.status-badge.draft {
  background: #e9ecef;
  color: #495057;
}

.status-badge.active {
  background: #d4edda;
  color: #155724;
}

.status-badge.ended {
  background: #f8d7da;
  color: #721c24;
}

.status-badge.planned {
  background: #fff3cd;
  color: #856404;
}

.status-badge.archived {
  background: #e2e3e5;
  color: #383d41;
}

.action-btn {
  padding: 0.5rem 1rem;
  background: transparent;
  border: 1px solid #667eea;
  color: #667eea;
  border-radius: 4px;
  cursor: pointer;
  margin-right: 0.5rem;
}

.action-btn:hover {
  background: #667eea;
  color: white;
}

.loading, .error {
  text-align: center;
  padding: 3rem;
  color: #666;
}

.error {
  color: #e74c3c;
}
</style>
'@
$adminElectionsView | Set-Content "$FRONTEND_DIR/src/views/admin/AdminElectionsView.vue" -Encoding UTF8

# Create placeholder views
Write-Host "Creating placeholder views..." -ForegroundColor Green

$placeholderContent = @'
<template>
  <div class="placeholder-view">
    <h1>Coming Soon</h1>
    <p>This feature is under development.</p>
    <router-link to="/admin/elections">Back to Elections</router-link>
  </div>
</template>

<style scoped>
.placeholder-view {
  text-align: center;
  padding: 3rem;
}

.placeholder-view h1 {
  color: #333;
  margin-bottom: 1rem;
}

.placeholder-view p {
  color: #666;
  margin-bottom: 2rem;
}

.placeholder-view a {
  color: #667eea;
  text-decoration: none;
}

.placeholder-view a:hover {
  text-decoration: underline;
}
</style>
'@

$placeholderContent | Set-Content "$FRONTEND_DIR/src/views/admin/AdminElectionCreateView.vue" -Encoding UTF8
$placeholderContent | Set-Content "$FRONTEND_DIR/src/views/admin/AdminElectionEditView.vue" -Encoding UTF8
$placeholderContent | Set-Content "$FRONTEND_DIR/src/views/admin/AdminElectionResultsView.vue" -Encoding UTF8

# Voter Election View
$voterElectionView = @'
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
'@
$voterElectionView | Set-Content "$FRONTEND_DIR/src/views/voter/VoterElectionView.vue" -Encoding UTF8

# Voter Result View
$voterResultView = @'
<template>
  <div class="voter-result">
    <div class="result-card">
      <h1>Thank You!</h1>
      <p>Your vote has been successfully recorded.</p>
      <button @click="goHome">Return to Home</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router';

const router = useRouter();

function goHome() {
  router.push('/vote/login');
}
</script>

<style scoped>
.voter-result {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 1rem;
}

.result-card {
  background: white;
  padding: 3rem;
  border-radius: 12px;
  text-align: center;
  max-width: 400px;
}

.result-card h1 {
  color: #27ae60;
  margin-bottom: 1rem;
}

.result-card p {
  color: #666;
  margin-bottom: 2rem;
}

button {
  padding: 1rem 2rem;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}

button:hover {
  background: #5a67d8;
}
</style>
'@
$voterResultView | Set-Content "$FRONTEND_DIR/src/views/voter/VoterResultView.vue" -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Frontend initialization complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Project structure created at: $FRONTEND_DIR"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. cd frontend"
Write-Host "  2. npm install"
Write-Host "  3. npm run dev"
Write-Host ""
