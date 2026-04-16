<template>
  <div class="admin-dashboard">
    <h1>Dashboard</h1>

    <!-- Loading skeleton -->
    <div v-if="electionStore.loading" class="skeleton-grid">
      <div v-for="i in 3" :key="i" class="skeleton-card">
        <div class="skeleton-line narrow" />
        <div class="skeleton-line wide" />
      </div>
    </div>

    <!-- Error state -->
    <div v-else-if="electionStore.error" class="error-state">
      <p>{{ electionStore.error }}</p>
      <BaseButton @click="loadData">Retry</BaseButton>
    </div>

    <template v-else>
      <!-- Stats row -->
      <DashboardGrid :widgets="statWidgets">
        <template #stat-active>
          <StatCardWidget
            title="Active Elections"
            :value="electionStore.activeElections.length"
            subtitle="Currently running"
            trend="neutral"
            color="#38a169"
          />
        </template>
        <template #stat-draft>
          <StatCardWidget
            title="Draft Elections"
            :value="electionStore.draftElections.length"
            subtitle="In preparation"
            trend="neutral"
            color="#d69e2e"
          />
        </template>
        <template #stat-total>
          <StatCardWidget
            title="Total Elections"
            :value="electionStore.elections.length"
            subtitle="All time"
            trend="neutral"
          />
        </template>
        <template #stat-ended>
          <StatCardWidget
            title="Ended Elections"
            :value="electionStore.endedElections.length"
            subtitle="Completed"
            trend="neutral"
            color="#e53e3e"
          />
        </template>
      </DashboardGrid>

      <!-- Quick Actions -->
      <div class="section">
        <QuickActionWidget
          title="Quick Actions"
          :actions="quickActions"
        />
      </div>

      <!-- Recent Elections -->
      <div class="section">
        <TableWidget
          title="Recent Elections"
          :columns="recentColumns"
          :rows="recentRows"
          empty-text="No elections created yet"
        />
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { onMounted, computed } from 'vue';
import { useUiStore } from '@/stores/uiStore';
import { useElectionStore } from '@/stores/electionStore';
import type { DashboardWidgetConfig } from '@/types';
import DashboardGrid from '@/components/dashboard/DashboardGrid.vue';
import StatCardWidget from '@/components/dashboard/widgets/StatCardWidget.vue';
import TableWidget from '@/components/dashboard/widgets/TableWidget.vue';
import QuickActionWidget from '@/components/dashboard/widgets/QuickActionWidget.vue';
import BaseButton from '@/components/common/BaseButton.vue';

const uiStore = useUiStore();
const electionStore = useElectionStore();

const statWidgets: DashboardWidgetConfig[] = [
  { id: 'stat-active', type: 'stat', title: 'Active', size: 'sm' },
  { id: 'stat-draft', type: 'stat', title: 'Draft', size: 'sm' },
  { id: 'stat-total', type: 'stat', title: 'Total', size: 'sm' },
  { id: 'stat-ended', type: 'stat', title: 'Ended', size: 'sm' },
];

const quickActions = [
  { label: 'Create Election', icon: '➕', route: '/admin/elections/create' },
  { label: 'All Elections', icon: '📋', route: '/admin/elections' },
  { label: 'View Profile', icon: '👤', route: '/admin/profile' },
];

const recentColumns = [
  { key: 'title', label: 'Title' },
  { key: 'status', label: 'Status' },
  { key: 'type', label: 'Type' },
  { key: 'createdAt', label: 'Created' },
];

const recentRows = computed(() => {
  return [...electionStore.elections]
    .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
    .slice(0, 5)
    .map(e => ({
      title: e.title,
      status: e.status,
      type: e.type.replace('_', ' '),
      createdAt: new Date(e.createdAt).toLocaleDateString('de-DE'),
    }));
});

async function loadData() {
  await electionStore.fetchAll();
}

onMounted(() => {
  uiStore.setBreadcrumbs([{ label: 'Dashboard' }]);
  uiStore.setPageTitle('Dashboard');
  loadData();
});
</script>

<style scoped>
.admin-dashboard h1 {
  margin-bottom: 1.5rem;
  color: var(--color-text, #1a202c);
}

.section {
  margin-top: 1.5rem;
}

.error-state {
  text-align: center;
  padding: 2rem;
  color: var(--color-danger, #e53e3e);
}
.error-state p { margin-bottom: 1rem; }

.skeleton-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1.5rem;
}

.skeleton-card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}

.skeleton-line {
  height: 1rem;
  background: linear-gradient(90deg, #e2e8f0 25%, #edf2f7 50%, #e2e8f0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 4px;
  margin-bottom: 0.75rem;
}
.skeleton-line.wide { width: 100%; height: 2rem; }
.skeleton-line.narrow { width: 60%; }

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
</style>
