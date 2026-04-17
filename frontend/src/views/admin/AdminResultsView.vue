<template>
  <div class="admin-results">
    <h1>{{ t('adminResults.title') }}</h1>
    <p v-if="election" class="election-name">{{ election.title }}</p>

    <!-- Loading -->
    <div v-if="loading" class="loading">{{ t('adminResults.loading') }}</div>

    <!-- Error -->
    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <BaseButton @click="loadData">{{ t('common.retry') }}</BaseButton>
    </div>

    <!-- No results yet -->
    <BaseEmptyState
      v-else-if="!results"
      :title="t('adminResults.emptyTitle')"
      :message="t('adminResults.emptyMessage')"
      icon="📊"
    />

    <!-- Results display -->
    <template v-else>
      <div class="total-votes">
        <strong>{{ t('adminResults.totalMetric', { metric: results.resultMetricLabel }) }}</strong> {{ results.totalVotes }}
      </div>

      <!-- Winners -->
      <div v-if="results.winners && results.winners.length > 0" class="winners-section">
        <h2>🏆 {{ results.winners.length > 1 ? t('adminResults.winners') : t('adminResults.winner') }}</h2>
        <div class="winner-cards">
            <div v-for="w in results.winners" :key="w.candidateId" class="winner-card">
              <div class="winner-name">{{ w.firstName }} {{ w.lastName }}</div>
              <div class="winner-stats">
              {{ w.voteCount }} {{ results.resultMetricLabel }} ({{ w.percentage.toFixed(1) }}%)
              </div>
            </div>
          </div>
      </div>

      <!-- All results -->
      <div class="all-results">
        <h2>{{ t('adminResults.allResults') }}</h2>
          <div v-for="r in results.results" :key="r.candidateId" class="result-row">
          <div class="result-info">
            <span class="result-name">{{ r.firstName }} {{ r.lastName }}</span>
            <span class="result-count">
              {{ r.voteCount }} {{ results.resultMetricLabel }} ({{ r.percentage.toFixed(1) }}%)
            </span>
          </div>
          <div class="result-bar-track">
            <div
              class="result-bar-fill"
              :style="{ width: r.percentage + '%' }"
              :class="{ winner: r.winner }"
            />
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { electionApi } from '@/api';
import { useLocale } from '@/composables/useLocale';
import { useUiStore } from '@/stores/uiStore';
import type { Election, ElectionResult } from '@/types';
import BaseButton from '@/components/common/BaseButton.vue';
import BaseEmptyState from '@/components/common/BaseEmptyState.vue';

const route = useRoute();
const uiStore = useUiStore();
const electionId = Number(route.params.id);
const { t } = useLocale();

const election = ref<Election | null>(null);
const results = ref<ElectionResult | null>(null);
const loading = ref(false);
const error = ref<string | null>(null);

async function loadData() {
  loading.value = true;
  error.value = null;
  try {
    election.value = await electionApi.getById(electionId);
    results.value = await electionApi.getResults(electionId);
  } catch (err: any) {
    if (err.response?.status === 400 || err.response?.status === 404) {
      // Election not ended yet or no results
      try { election.value = await electionApi.getById(electionId); } catch {}
      results.value = null;
    } else {
        error.value = err.response?.data?.message || t('adminResults.loadFailed');
    }
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  uiStore.setBreadcrumbs([
    { label: t('nav.dashboard'), route: '/admin/dashboard' },
    { label: t('nav.elections'), route: '/admin/elections' },
    { label: t('nav.results') },
  ]);
  uiStore.setPageTitle(t('adminResults.title'));
  loadData();
});
</script>

<style scoped>
.admin-results h1 { margin: 0 0 0.25rem 0; color: var(--color-text); }
.election-name { color: var(--color-text-muted); font-size: 0.9rem; margin: 0 0 1.5rem 0; }
.loading { text-align: center; padding: 2rem; color: var(--color-text-muted); }
.error-state { text-align: center; padding: 2rem; color: var(--color-danger); }
.error-state p { margin-bottom: 1rem; }

.total-votes {
  background: var(--color-surface);
  padding: 1rem 1.25rem;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
  margin-bottom: 1.5rem;
  font-size: 1.1rem;
}

.winners-section { margin-bottom: 1.5rem; }
.winners-section h2 { margin-bottom: 1rem; font-size: 1.1rem; }

.winner-cards { display: flex; gap: 1rem; flex-wrap: wrap; }
.winner-card {
  background: #fffff0;
  border: 2px solid #f6e05e;
  border-radius: 8px;
  padding: 1rem 1.5rem;
}
.winner-name { font-weight: 600; font-size: 1.1rem; color: var(--color-text); }
.winner-stats { color: var(--color-text-muted); font-size: 0.9rem; margin-top: 0.25rem; }

.all-results h2 { margin-bottom: 1rem; font-size: 1.1rem; }

.result-row { margin-bottom: 1rem; }
.result-info { display: flex; justify-content: space-between; margin-bottom: 0.35rem; font-size: 0.9rem; }
.result-name { font-weight: 500; color: var(--color-text); }
.result-count { color: var(--color-text-muted); }

.result-bar-track {
  height: 10px;
  background: var(--color-border);
  border-radius: 5px;
  overflow: hidden;
}
.result-bar-fill {
  height: 100%;
  background: var(--color-primary);
  border-radius: 5px;
  transition: width 0.4s ease;
}
.result-bar-fill.winner { background: #f6ad55; }
</style>
