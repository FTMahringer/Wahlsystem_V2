<template>
  <div class="admin-elections">
    <div class="header">
      <h1>Elections</h1>
      <BaseButton @click="router.push('/admin/elections/create')">➕ Create Election</BaseButton>
    </div>

    <!-- Status filters -->
    <div class="filters">
      <button
        v-for="f in filters"
        :key="f.value"
        class="filter-btn"
        :class="{ active: activeFilter === f.value }"
        @click="activeFilter = f.value"
      >
        {{ f.label }}
      </button>
    </div>

    <!-- Loading -->
    <div v-if="electionStore.loading" class="loading-skeleton">
      <div v-for="i in 4" :key="i" class="skeleton-row" />
    </div>

    <!-- Error -->
    <div v-else-if="electionStore.error" class="error-state">
      <p>{{ electionStore.error }}</p>
      <BaseButton @click="electionStore.fetchAll()">Retry</BaseButton>
    </div>

    <!-- Empty -->
    <BaseEmptyState
      v-else-if="filteredElections.length === 0"
      title="No elections found"
      message="Create your first election to get started."
      icon="🗳️"
      :action="{ label: 'Create Election', route: '/admin/elections/create' }"
    />

    <!-- Elections Table -->
    <div v-else class="elections-table">
      <table>
        <thead>
          <tr>
            <th>Title</th>
            <th>Type</th>
            <th>Status</th>
            <th>Start</th>
            <th>End</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="election in filteredElections" :key="election.id">
            <td class="title-cell">{{ election.title }}</td>
            <td>{{ election.type.replace('_', ' ') }}</td>
            <td>
              <span class="status-badge" :class="statusClass(election.status)">
                {{ election.status }}
              </span>
            </td>
            <td>{{ formatDate(election.startAt) }}</td>
            <td>{{ formatDate(election.endAt) }}</td>
            <td class="actions-cell">
              <BaseButton size="sm" variant="ghost" @click="router.push(`/admin/elections/${election.id}/edit`)">✏️</BaseButton>
              <BaseButton size="sm" variant="ghost" @click="router.push(`/admin/elections/${election.id}/candidates`)">👤</BaseButton>
              <BaseButton size="sm" variant="ghost" @click="router.push(`/admin/elections/${election.id}/results`)">📊</BaseButton>
              <BaseButton size="sm" variant="ghost" @click="confirmDelete(election)">🗑️</BaseButton>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useElectionStore } from '@/stores/electionStore';
import { useUiStore } from '@/stores/uiStore';
import type { Election, ElectionStatus } from '@/types';
import BaseButton from '@/components/common/BaseButton.vue';
import BaseEmptyState from '@/components/common/BaseEmptyState.vue';

const router = useRouter();
const electionStore = useElectionStore();
const uiStore = useUiStore();

const activeFilter = ref<string>('ALL');

const filters = [
  { label: 'All', value: 'ALL' },
  { label: 'Draft', value: 'DRAFT' },
  { label: 'Active', value: 'ACTIVE' },
  { label: 'Ended', value: 'ENDED' },
  { label: 'Archived', value: 'ARCHIVED' },
];

const filteredElections = computed(() => {
  if (activeFilter.value === 'ALL') return electionStore.elections;
  return electionStore.elections.filter(e => e.status === activeFilter.value);
});

function statusClass(status: ElectionStatus): string {
  return `status-${status.toLowerCase()}`;
}

function formatDate(date: string | null): string {
  if (!date) return '—';
  return new Date(date).toLocaleDateString('de-DE');
}

function confirmDelete(election: Election) {
  uiStore.openConfirm({
    title: 'Delete Election',
    message: `Are you sure you want to delete "${election.title}"? This action cannot be undone.`,
    onConfirm: async () => {
      const success = await electionStore.deleteElection(election.id);
      if (success) {
        uiStore.showToast({ type: 'success', message: 'Election deleted successfully.' });
      } else {
        uiStore.showToast({ type: 'error', message: electionStore.error || 'Failed to delete.' });
      }
    },
  });
}

onMounted(() => {
  uiStore.setBreadcrumbs([
    { label: 'Dashboard', route: '/admin/dashboard' },
    { label: 'Elections' },
  ]);
  uiStore.setPageTitle('Elections');
  electionStore.fetchAll();
});
</script>

<style scoped>
.admin-elections {
  max-width: 1200px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.header h1 {
  margin: 0;
  color: var(--color-text, #1a202c);
}

.filters {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
}

.filter-btn {
  padding: 0.4rem 1rem;
  border: 1px solid var(--color-border, #e2e8f0);
  background: var(--color-surface, #ffffff);
  border-radius: 20px;
  cursor: pointer;
  font-size: 0.85rem;
  color: var(--color-text-muted, #718096);
  transition: all 0.15s;
}

.filter-btn:hover {
  border-color: var(--color-primary, #667eea);
  color: var(--color-primary, #667eea);
}

.filter-btn.active {
  background: var(--color-primary, #667eea);
  border-color: var(--color-primary, #667eea);
  color: white;
}

.elections-table {
  background: var(--color-surface, #ffffff);
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 0.875rem 1rem;
  text-align: left;
  border-bottom: 1px solid var(--color-border, #e2e8f0);
  font-size: 0.9rem;
}

th {
  background: #f8fafc;
  font-weight: 600;
  color: var(--color-text-muted, #718096);
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}

.title-cell { font-weight: 500; }

.actions-cell {
  display: flex;
  gap: 0.25rem;
}

.status-badge {
  display: inline-block;
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.status-draft { background: #e2e8f0; color: #4a5568; }
.status-planned { background: #fefcbf; color: #975a16; }
.status-active { background: #c6f6d5; color: #276749; }
.status-ended { background: #fed7d7; color: #9b2c2c; }
.status-archived { background: #e2e8f0; color: #718096; }

.error-state {
  text-align: center;
  padding: 2rem;
  color: var(--color-danger, #e53e3e);
}
.error-state p { margin-bottom: 1rem; }

.loading-skeleton {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.skeleton-row {
  height: 3rem;
  background: linear-gradient(90deg, #e2e8f0 25%, #edf2f7 50%, #e2e8f0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 6px;
}

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
</style>
