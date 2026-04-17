<template>
  <div class="admin-dashboard">
    <h1>{{ t('adminDashboard.title') }}</h1>

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
      <BaseButton @click="loadData">{{ t('common.retry') }}</BaseButton>
    </div>

    <template v-else>
      <!-- Stats row -->
      <DashboardGrid :widgets="statWidgets">
        <template #stat-active>
          <StatCardWidget
            :title="t('adminDashboard.statActiveTitle')"
            :value="electionStore.activeElections.length"
            :subtitle="t('adminDashboard.statActiveSubtitle')"
            trend="neutral"
            color="#38a169"
          />
        </template>
        <template #stat-draft>
          <StatCardWidget
            :title="t('adminDashboard.statDraftTitle')"
            :value="electionStore.draftElections.length"
            :subtitle="t('adminDashboard.statDraftSubtitle')"
            trend="neutral"
            color="#d69e2e"
          />
        </template>
        <template #stat-total>
          <StatCardWidget
            :title="t('adminDashboard.statTotalTitle')"
            :value="electionStore.elections.length"
            :subtitle="t('adminDashboard.statTotalSubtitle')"
            trend="neutral"
          />
        </template>
        <template #stat-ended>
          <StatCardWidget
            :title="t('adminDashboard.statEndedTitle')"
            :value="electionStore.endedElections.length"
            :subtitle="t('adminDashboard.statEndedSubtitle')"
            trend="neutral"
            color="#e53e3e"
          />
        </template>
      </DashboardGrid>

      <!-- Quick Actions -->
      <div class="section">
        <QuickActionWidget
          :title="t('adminDashboard.quickActions')"
          :actions="quickActions"
        />
      </div>

      <!-- Recent Elections -->
      <div class="section">
        <TableWidget
          :title="t('adminDashboard.recentElections')"
          :columns="recentColumns"
          :rows="recentRows"
          :empty-text="t('adminDashboard.noElectionsYet')"
        />
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { onMounted, computed } from 'vue';
import { useLocale } from '@/composables/useLocale';
import { toIntlLocale } from '@/locales';
import { useUiStore } from '@/stores/uiStore';
import { useElectionStore } from '@/stores/electionStore';
import { getElectionStatusLabel, getElectionTypeDefinition, type DashboardWidgetConfig } from '@/types';
import DashboardGrid from '@/components/dashboard/DashboardGrid.vue';
import StatCardWidget from '@/components/dashboard/widgets/StatCardWidget.vue';
import TableWidget from '@/components/dashboard/widgets/TableWidget.vue';
import QuickActionWidget from '@/components/dashboard/widgets/QuickActionWidget.vue';
import BaseButton from '@/components/common/BaseButton.vue';

const uiStore = useUiStore();
const electionStore = useElectionStore();
const { t, language } = useLocale();

const localeCode = computed(() => toIntlLocale(language.value));

const statWidgets = computed<DashboardWidgetConfig[]>(() => [
  { id: 'stat-active', type: 'stat', title: t('common.active'), size: 'sm' },
  { id: 'stat-draft', type: 'stat', title: t('electionStatus.DRAFT'), size: 'sm' },
  { id: 'stat-total', type: 'stat', title: t('common.total'), size: 'sm' },
  { id: 'stat-ended', type: 'stat', title: t('electionStatus.ENDED'), size: 'sm' },
]);

const quickActions = computed(() => [
  { label: t('adminDashboard.actionCreateElection'), icon: '➕', route: '/admin/elections/create' },
  { label: t('adminDashboard.actionAllElections'), icon: '📋', route: '/admin/elections' },
  { label: t('adminDashboard.actionViewProfile'), icon: '👤', route: '/admin/profile' },
]);

const recentColumns = computed(() => [
  { key: 'title', label: t('common.title') },
  { key: 'status', label: t('common.status') },
  { key: 'type', label: t('common.type') },
  { key: 'createdAt', label: t('common.created') },
]);

const recentRows = computed(() => {
  return [...electionStore.elections]
    .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
    .slice(0, 5)
    .map(e => ({
      title: e.title,
      status: getElectionStatusLabel(e.status, t),
      type: getElectionTypeDefinition(e.type, t).label,
      createdAt: new Date(e.createdAt).toLocaleDateString(localeCode.value),
    }));
});

async function loadData() {
  await electionStore.fetchAll();
}

onMounted(() => {
  uiStore.setBreadcrumbs([{ label: t('nav.dashboard') }]);
  uiStore.setPageTitle(t('adminDashboard.title'));
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
