<template>
  <div class="admin-elections">
    <div class="header">
      <h1>{{ t('adminElections.title') }}</h1>
      <BaseButton @click="router.push('/admin/elections/create')">➕ {{ t('adminElections.createElection') }}</BaseButton>
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
      <BaseButton @click="electionStore.fetchAll()">{{ t('common.retry') }}</BaseButton>
    </div>

    <!-- Empty -->
    <BaseEmptyState
      v-else-if="filteredElections.length === 0"
      :title="t('adminElections.noElectionsTitle')"
      :message="t('adminElections.noElectionsMessage')"
      icon="🗳️"
      :action="{ label: t('adminElections.createElection'), route: '/admin/elections/create' }"
    />

    <!-- Elections Table -->
    <div v-else class="elections-table">
      <table>
        <thead>
          <tr>
            <th>{{ t('common.title') }}</th>
            <th>{{ t('common.type') }}</th>
            <th>{{ t('common.status') }}</th>
            <th>{{ t('common.start') }}</th>
            <th>{{ t('common.end') }}</th>
            <th>{{ t('common.actions') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="election in filteredElections" :key="election.id">
            <td class="title-cell">{{ election.title }}</td>
              <td>{{ getElectionTypeDefinition(election.type, t).label }}</td>
            <td>
              <span class="status-badge" :class="statusClass(election.status)">
                {{ getElectionStatusLabel(election.status, t) }}
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
import { useLocale } from '@/composables/useLocale';
import { toIntlLocale } from '@/locales';
import { useElectionStore } from '@/stores/electionStore';
import { useUiStore } from '@/stores/uiStore';
import type { Election, ElectionStatus } from '@/types';
import { getElectionStatusLabel, getElectionTypeDefinition } from '@/types';
import BaseButton from '@/components/common/BaseButton.vue';
import BaseEmptyState from '@/components/common/BaseEmptyState.vue';

const router = useRouter();
const electionStore = useElectionStore();
const uiStore = useUiStore();
const { t, language } = useLocale();

const activeFilter = ref<string>('ALL');
const localeCode = computed(() => toIntlLocale(language.value));

const filters = computed(() => [
  { label: t('adminElections.filters.ALL'), value: 'ALL' },
  { label: t('adminElections.filters.DRAFT'), value: 'DRAFT' },
  { label: t('adminElections.filters.ACTIVE'), value: 'ACTIVE' },
  { label: t('adminElections.filters.ENDED'), value: 'ENDED' },
  { label: t('adminElections.filters.ARCHIVED'), value: 'ARCHIVED' },
]);

const filteredElections = computed(() => {
  if (activeFilter.value === 'ALL') return electionStore.elections;
  return electionStore.elections.filter(e => e.status === activeFilter.value);
});

function statusClass(status: ElectionStatus): string {
  return `status-${status.toLowerCase()}`;
}

function formatDate(date: string | null): string {
  if (!date) return t('common.notAvailable');
  return new Date(date).toLocaleDateString(localeCode.value);
}

function confirmDelete(election: Election) {
  uiStore.openConfirm({
    title: t('adminElections.deleteTitle'),
    message: t('adminElections.deleteMessage', { title: election.title }),
    onConfirm: async () => {
      const success = await electionStore.deleteElection(election.id);
      if (success) {
        uiStore.showToast({ type: 'success', message: t('adminElections.deletedSuccess') });
      } else {
        uiStore.showToast({ type: 'error', message: electionStore.error || t('adminElections.deleteFailed') });
      }
    },
  });
}

onMounted(() => {
  uiStore.setBreadcrumbs([
    { label: t('nav.dashboard'), route: '/admin/dashboard' },
    { label: t('nav.elections') },
  ]);
  uiStore.setPageTitle(t('adminElections.title'));
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
