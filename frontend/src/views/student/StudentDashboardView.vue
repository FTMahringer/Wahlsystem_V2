<template>
  <div class="student-dashboard">
    <header class="student-header">
      <h1>{{ t("studentDashboard.title") }}</h1>
      <p>{{ t("studentDashboard.subtitle") }}</p>
    </header>

    <div v-if="loading" class="loading-state">{{ t("common.loading") }}</div>
    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <BaseButton @click="loadData">{{ t("common.retry") }}</BaseButton>
    </div>

    <template v-else>
      <!-- My Tokens Section (only in UI mode) -->
      <section v-if="tokenMode === 'ui' && myTokens.length > 0" class="section">
        <h2>{{ t("studentDashboard.myTokens") }}</h2>
        <div class="token-grid">
          <div
            v-for="token in myTokens"
            :key="token.id"
            class="token-card"
            :class="{ used: token.used }"
          >
            <div class="token-header">
              <h3>{{ token.electionTitle }}</h3>
              <span v-if="token.used" class="badge used">{{
                t("studentDashboard.tokenUsed")
              }}</span>
              <span v-else class="badge unused">{{
                t("studentDashboard.tokenUnused")
              }}</span>
            </div>
            <div class="token-value">
              <code>{{ token.token }}</code>
              <button
                v-if="!token.used"
                class="copy-btn"
                :title="t('studentDashboard.copyToken')"
                @click="copyToken(token.token)"
              >
                📋
              </button>
            </div>
            <p v-if="token.electionEndAt" class="token-meta">
              {{
                t("studentDashboard.tokenExpires", {
                  date: formatDate(token.electionEndAt),
                })
              }}
            </p>
          </div>
        </div>
      </section>

      <!-- Active Elections -->
      <section v-if="activeElections.length > 0" class="section">
        <h2>{{ t("studentDashboard.activeElections") }}</h2>
        <div class="election-grid">
          <div
            v-for="election in activeElections"
            :key="election.id"
            class="election-card"
          >
            <div class="card-header">
              <h3>{{ election.title }}</h3>
              <span class="badge active">{{ t("common.active") }}</span>
            </div>
            <p class="description">
              {{ election.description || t("index.noDescription") }}
            </p>
            <div class="meta">
              <span v-if="election.endAt">{{
                t("index.ends", { date: formatDate(election.endAt) })
              }}</span>
              <span v-else>{{ t("index.noEndDate") }}</span>
            </div>
            <button class="vote-btn" @click="goToVote(election.id)">
              {{ t("index.voteNow") }}
            </button>
          </div>
        </div>
      </section>

      <!-- Upcoming Elections -->
      <section v-if="upcomingElections.length > 0" class="section">
        <h2>{{ t("studentDashboard.upcomingElections") }}</h2>
        <div class="election-grid">
          <div
            v-for="election in upcomingElections"
            :key="election.id"
            class="election-card planned"
          >
            <div class="card-header">
              <h3>{{ election.title }}</h3>
              <span class="badge planned">{{
                getElectionStatusLabel(election.status, t)
              }}</span>
            </div>
            <p class="description">
              {{ election.description || t("index.noDescription") }}
            </p>
            <div class="meta">
              <span v-if="election.startAt">{{
                t("index.starts", { date: formatDate(election.startAt) })
              }}</span>
              <span v-else>{{ t("index.noStartDate") }}</span>
            </div>
          </div>
        </div>
      </section>

      <BaseEmptyState
        v-if="
          activeElections.length === 0 &&
          upcomingElections.length === 0 &&
          myTokens.length === 0
        "
        :title="t('studentDashboard.noElections')"
        :message="t('studentDashboard.noElectionsMessage')"
        icon="🗳️"
      />
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { electionApi, tokenApi } from "@/api";
import BaseButton from "@/components/common/BaseButton.vue";
import BaseEmptyState from "@/components/common/BaseEmptyState.vue";
import { useLocale } from "@/composables/useLocale";
import { toIntlLocale } from "@/locales";
import {
  getElectionStatusLabel,
  type Election,
  type StudentToken,
} from "@/types";

const router = useRouter();
const { t, language } = useLocale();
const localeCode = computed(() => toIntlLocale(language.value));

const allElections = ref<Election[]>([]);
const myTokens = ref<StudentToken[]>([]);
const loading = ref(false);
const error = ref<string | null>(null);

const tokenMode = import.meta.env.VITE_TOKEN_MODE || "ui";

const activeElections = computed(() =>
  allElections.value.filter((e) => e.status === "ACTIVE"),
);
const upcomingElections = computed(() =>
  allElections.value.filter((e) => e.status === "PLANNED"),
);

function formatDate(dateStr: string | null): string {
  if (!dateStr) return "-";
  return new Date(dateStr).toLocaleString(localeCode.value);
}

function goToVote(electionId: number) {
  router.push(`/student/vote/election/${electionId}`);
}

async function copyToken(token: string) {
  try {
    await navigator.clipboard.writeText(token);
    // Could show toast here
  } catch {
    // Fallback: select text manually
  }
}

async function loadData() {
  loading.value = true;
  error.value = null;
  try {
    const [elections, tokens] = await Promise.all([
      electionApi.getAll(),
      tokenMode === "ui"
        ? tokenApi.getMyTokens().catch(() => [] as StudentToken[])
        : Promise.resolve([] as StudentToken[]),
    ]);
    allElections.value = elections;
    myTokens.value = tokens;
  } catch (err: any) {
    error.value = err.response?.data?.message || t("voter.loadElectionFailed");
  } finally {
    loading.value = false;
  }
}

onMounted(loadData);
</script>

<style scoped>
.student-dashboard {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.student-header {
  margin-bottom: 2rem;
}
.student-header h1 {
  margin: 0 0 0.5rem 0;
  color: #1a202c;
}
.student-header p {
  margin: 0;
  color: #718096;
}
.section {
  margin-bottom: 2.5rem;
}
.section h2 {
  margin-bottom: 1rem;
  color: #333;
  font-size: 1.4rem;
}
.loading-state,
.error-state {
  padding: 2rem;
  text-align: center;
}
.error-state {
  color: #e53e3e;
}

/* Token grid */
.token-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1rem;
}
.token-card {
  background: white;
  border-radius: 10px;
  padding: 1.25rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  border-left: 4px solid #22c55e;
}
.token-card.used {
  border-left-color: #9ca3af;
  opacity: 0.85;
}
.token-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0.75rem;
}
.token-header h3 {
  margin: 0;
  font-size: 1rem;
  color: #333;
}
.token-value {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}
.token-value code {
  background: #f3f4f6;
  padding: 0.5rem 0.75rem;
  border-radius: 6px;
  font-family: monospace;
  font-size: 1.1rem;
  letter-spacing: 0.05em;
  color: #1a202c;
  flex: 1;
}
.copy-btn {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 1.1rem;
  padding: 0.25rem;
  border-radius: 4px;
}
.copy-btn:hover {
  background: #f3f4f6;
}
.token-meta {
  font-size: 0.8rem;
  color: #888;
  margin: 0;
}

/* Election grid */
.election-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1rem;
}
.election-card {
  background: white;
  border-radius: 10px;
  padding: 1.25rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
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
.badge.used {
  background: #e5e7eb;
  color: #6b7280;
}
.badge.unused {
  background: #dcfce7;
  color: #166534;
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
.vote-btn {
  display: inline-block;
  background: #667eea;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  border: none;
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s;
}
.vote-btn:hover {
  background: #5a67d8;
}
</style>
