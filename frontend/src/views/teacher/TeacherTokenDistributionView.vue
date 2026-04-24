<template>
  <div class="token-distribution">
    <header class="page-header">
      <h1>{{ t("teacherTokens.title") }}</h1>
      <p>{{ t("teacherTokens.subtitle") }}</p>
    </header>

    <!-- Class & Election Selection -->
    <div class="selection-bar">
      <div class="field">
        <label>{{ t("teacherTokens.selectClass") }}</label>
        <select v-model="selectedClassId" @change="onSelectionChange">
          <option :value="null">{{ t("teacherTokens.chooseClass") }}</option>
          <option v-for="cls in myClasses" :key="cls.id" :value="cls.id">
            {{ cls.name }}
          </option>
        </select>
      </div>
      <div class="field">
        <label>{{ t("teacherTokens.selectElection") }}</label>
        <select v-model="selectedElectionId" @change="onSelectionChange">
          <option :value="null">{{ t("teacherTokens.chooseElection") }}</option>
          <option
            v-for="election in myElections"
            :key="election.id"
            :value="election.id"
          >
            {{ election.title }}
          </option>
        </select>
      </div>
      <BaseButton
        :disabled="!canGenerate"
        :loading="generating"
        @click="generateTokens"
      >
        {{ t("teacherTokens.generateTokens") }}
      </BaseButton>
    </div>

    <!-- Token Table -->
    <div v-if="loading" class="loading-state">{{ t("common.loading") }}</div>

    <template v-else-if="distribution">
      <div class="distribution-header">
        <h2>
          {{ distribution.electionTitle }} — {{ distribution.schoolClassName }}
        </h2>
        <BaseButton variant="secondary" size="sm" @click="printTable">
          🖨️ {{ t("teacherTokens.print") }}
        </BaseButton>
      </div>

      <div class="table-wrapper">
        <table class="token-table">
          <thead>
            <tr>
              <th>#</th>
              <th>{{ t("common.name") }}</th>
              <th>{{ t("common.username") }}</th>
              <th>{{ t("teacherTokens.token") }}</th>
              <th>{{ t("common.status") }}</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(entry, index) in distribution.entries"
              :key="entry.studentId"
              :class="{ used: entry.used }"
            >
              <td>{{ index + 1 }}</td>
              <td>{{ entry.studentName }}</td>
              <td>{{ entry.studentUsername }}</td>
              <td>
                <code class="token-code">{{ entry.token }}</code>
              </td>
              <td>
                <span v-if="entry.used" class="status-badge used">{{
                  t("teacherTokens.used")
                }}</span>
                <span v-else class="status-badge unused">{{
                  t("teacherTokens.unused")
                }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-if="distribution.entries.length === 0" class="empty-state">
        <p>{{ t("teacherTokens.noStudents") }}</p>
      </div>
    </template>

    <BaseEmptyState
      v-else-if="!loading && selectedClassId && selectedElectionId"
      :title="t('teacherTokens.noTokens')"
      :message="t('teacherTokens.generateHint')"
      icon="🎫"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { tokenApi, electionApi, schoolClassApi } from "@/api";
import BaseButton from "@/components/common/BaseButton.vue";
import BaseEmptyState from "@/components/common/BaseEmptyState.vue";
import { useLocale } from "@/composables/useLocale";
import type { Election, SchoolClass, TokenDistribution } from "@/types";

const { t } = useLocale();

const myClasses = ref<SchoolClass[]>([]);
const myElections = ref<Election[]>([]);
const selectedClassId = ref<number | null>(null);
const selectedElectionId = ref<number | null>(null);
const distribution = ref<TokenDistribution | null>(null);
const loading = ref(false);
const generating = ref(false);

const canGenerate = computed(
  () => selectedClassId.value !== null && selectedElectionId.value !== null,
);

async function loadClassesAndElections() {
  try {
    const [classes, elections] = await Promise.all([
      schoolClassApi.getAll(),
      electionApi.getAll(),
    ]);
    myClasses.value = classes;
    myElections.value = elections;
  } catch {
    // handle error
  }
}

async function onSelectionChange() {
  if (!selectedClassId.value || !selectedElectionId.value) {
    distribution.value = null;
    return;
  }
  await loadDistribution();
}

async function loadDistribution() {
  if (!selectedClassId.value || !selectedElectionId.value) return;
  loading.value = true;
  try {
    distribution.value = await tokenApi.getTokenDistribution(
      selectedElectionId.value,
      selectedClassId.value,
    );
  } catch {
    distribution.value = null;
  } finally {
    loading.value = false;
  }
}

async function generateTokens() {
  if (!selectedClassId.value || !selectedElectionId.value) return;
  generating.value = true;
  try {
    distribution.value = await tokenApi.generateTokens(
      selectedElectionId.value,
      selectedClassId.value,
    );
  } finally {
    generating.value = false;
  }
}

function printTable() {
  window.print();
}

onMounted(loadClassesAndElections);
</script>

<style scoped>
.token-distribution {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.page-header {
  margin-bottom: 2rem;
}
.page-header h1 {
  margin: 0 0 0.5rem 0;
  color: #1a202c;
}
.page-header p {
  margin: 0;
  color: #718096;
}
.selection-bar {
  display: flex;
  gap: 1rem;
  align-items: flex-end;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}
.field {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  min-width: 220px;
}
.field label {
  font-size: 0.85rem;
  font-weight: 500;
  color: #4a5568;
}
.field select {
  padding: 0.6rem 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 0.95rem;
  background: white;
}
.loading-state {
  padding: 2rem;
  text-align: center;
  color: #718096;
}
.distribution-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}
.distribution-header h2 {
  margin: 0;
  font-size: 1.2rem;
  color: #1a202c;
}
.table-wrapper {
  background: white;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  overflow: hidden;
}
.token-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.95rem;
}
.token-table th,
.token-table td {
  padding: 0.875rem 1rem;
  text-align: left;
  border-bottom: 1px solid #f1f5f9;
}
.token-table th {
  background: #f8fafc;
  font-weight: 600;
  color: #4a5568;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}
.token-table tr:hover {
  background: #f8fafc;
}
.token-table tr.used {
  opacity: 0.7;
  background: #f9fafb;
}
.token-code {
  background: #f3f4f6;
  padding: 0.35rem 0.6rem;
  border-radius: 4px;
  font-family: monospace;
  font-size: 0.9rem;
  letter-spacing: 0.03em;
}
.status-badge {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  text-transform: uppercase;
}
.status-badge.used {
  background: #e5e7eb;
  color: #6b7280;
}
.status-badge.unused {
  background: #dcfce7;
  color: #166534;
}
.empty-state {
  padding: 2rem;
  text-align: center;
  color: #718096;
}

@media print {
  .selection-bar,
  .distribution-header button {
    display: none !important;
  }
  .token-distribution {
    padding: 0;
  }
  .table-wrapper {
    box-shadow: none;
  }
}
</style>
