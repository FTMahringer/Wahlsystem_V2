<template>
  <div class="teacher-dashboard">
    <h1>{{ t("teacherDashboard.title") }}</h1>

    <div v-if="electionStore.loading" class="skeleton-grid">
      <div v-for="i in 3" :key="i" class="skeleton-card">
        <div class="skeleton-line narrow" />
        <div class="skeleton-line wide" />
      </div>
    </div>

    <div v-else-if="electionStore.error" class="error-state">
      <p>{{ electionStore.error }}</p>
      <BaseButton @click="loadData">{{ t("common.retry") }}</BaseButton>
    </div>

    <template v-else>
      <DashboardGrid :widgets="statWidgets">
        <template #stat-active
          ><StatCardWidget
            :title="t('teacherDashboard.statActiveTitle')"
            :value="myActiveElections.length"
            :subtitle="t('teacherDashboard.statActiveSubtitle')"
            trend="neutral"
            color="#38a169"
        /></template>
        <template #stat-draft
          ><StatCardWidget
            :title="t('teacherDashboard.statDraftTitle')"
            :value="myDraftElections.length"
            :subtitle="t('teacherDashboard.statDraftSubtitle')"
            trend="neutral"
            color="#d69e2e"
        /></template>
        <template #stat-total
          ><StatCardWidget
            :title="t('teacherDashboard.statTotalTitle')"
            :value="myElections.length"
            :subtitle="t('teacherDashboard.statTotalSubtitle')"
            trend="neutral"
        /></template>
        <template #stat-classes
          ><StatCardWidget
            :title="t('teacherDashboard.statClassesTitle')"
            :value="myClasses.length"
            :subtitle="t('teacherDashboard.statClassesSubtitle')"
            trend="neutral"
            color="#667eea"
        /></template>
      </DashboardGrid>

      <div class="section">
        <QuickActionWidget
          :title="t('teacherDashboard.quickActions')"
          :actions="quickActions"
        />
      </div>

      <div v-if="myClasses.length > 0" class="section">
        <h2>{{ t("teacherDashboard.myClasses") }}</h2>
        <div class="classes-grid">
          <div v-for="cls in myClasses" :key="cls.id" class="class-card">
            <h3>{{ cls.name }}</h3>
            <p v-if="cls.gradeLevel">
              {{ t("adminUsers.grade") }}: {{ cls.gradeLevel }}
            </p>
            <p>
              {{
                t("teacherDashboard.studentsCount", {
                  count: cls.students?.length || 0,
                })
              }}
            </p>
          </div>
        </div>
      </div>

      <div class="section">
        <TableWidget
          :title="t('teacherDashboard.myElections')"
          :columns="recentColumns"
          :rows="recentRows"
          :empty-text="t('teacherDashboard.noElectionsYet')"
        />
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { onMounted, computed } from "vue";
import { useLocale } from "@/composables/useLocale";
import { toIntlLocale } from "@/locales";
import { useUiStore } from "@/stores/uiStore";
import { useElectionStore } from "@/stores/electionStore";
import { useAuthStore } from "@/stores/authStore";
import {
  getElectionStatusLabel,
  getElectionTypeDefinition,
  type DashboardWidgetConfig,
} from "@/types";
import DashboardGrid from "@/components/dashboard/DashboardGrid.vue";
import StatCardWidget from "@/components/dashboard/widgets/StatCardWidget.vue";
import TableWidget from "@/components/dashboard/widgets/TableWidget.vue";
import QuickActionWidget from "@/components/dashboard/widgets/QuickActionWidget.vue";
import BaseButton from "@/components/common/BaseButton.vue";
import { schoolClassApi } from "@/api";
import { ref } from "vue";
import type { SchoolClass } from "@/types";

const uiStore = useUiStore();
const electionStore = useElectionStore();
const authStore = useAuthStore();
const { t, language } = useLocale();
const localeCode = computed(() => toIntlLocale(language.value));

const myClasses = ref<SchoolClass[]>([]);

const myElections = computed(() => {
  const username = authStore.user?.username;
  if (!username) return [];
  return electionStore.elections.filter((e) => e.createdBy === username);
});

const myActiveElections = computed(() =>
  myElections.value.filter((e) => e.status === "ACTIVE"),
);
const myDraftElections = computed(() =>
  myElections.value.filter((e) => e.status === "DRAFT"),
);

const statWidgets = computed<DashboardWidgetConfig[]>(() => [
  { id: "stat-active", type: "stat", title: t("common.active"), size: "sm" },
  {
    id: "stat-draft",
    type: "stat",
    title: t("electionStatus.DRAFT"),
    size: "sm",
  },
  { id: "stat-total", type: "stat", title: t("common.total"), size: "sm" },
  { id: "stat-classes", type: "stat", title: t("nav.classes"), size: "sm" },
]);

const canCreateElections = computed(() => {
  return authStore.user?.canCreateElections !== false;
});

const tokenMode = import.meta.env.VITE_TOKEN_MODE || "ui";

const quickActions = computed(() => {
  const actions = [
    {
      label: t("teacherDashboard.actionAllElections"),
      icon: "📋",
      route: "/admin/elections",
    },
    {
      label: t("teacherDashboard.actionViewProfile"),
      icon: "👤",
      route: "/admin/profile",
    },
  ];
  if (canCreateElections.value) {
    actions.unshift({
      label: t("teacherDashboard.actionCreateElection"),
      icon: "➕",
      route: "/admin/elections/create",
    });
  }
  if (tokenMode === "paper") {
    actions.push({
      label: t("teacherDashboard.actionDistributeTokens"),
      icon: "🎫",
      route: "/teacher/tokens",
    });
  }
  return actions;
});

const recentColumns = computed(() => [
  { key: "title", label: t("common.title") },
  { key: "status", label: t("common.status") },
  { key: "type", label: t("common.type") },
  { key: "createdAt", label: t("common.created") },
]);

const recentRows = computed(() => {
  return [...myElections.value]
    .sort(
      (a, b) =>
        new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
    )
    .slice(0, 5)
    .map((e) => ({
      title: e.title,
      status: getElectionStatusLabel(e.status, t),
      type: getElectionTypeDefinition(e.type, t).label,
      createdAt: new Date(e.createdAt).toLocaleDateString(localeCode.value),
    }));
});

async function loadData() {
  await electionStore.fetchAll();
  try {
    myClasses.value = await schoolClassApi.getMyClasses();
  } catch (e) {
    console.error("Failed to load classes", e);
  }
}

onMounted(() => {
  uiStore.setBreadcrumbs([{ label: t("nav.dashboard") }]);
  uiStore.setPageTitle(t("teacherDashboard.title"));
  loadData();
});
</script>

<style scoped>
.teacher-dashboard h1 {
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
.error-state p {
  margin-bottom: 1rem;
}
.skeleton-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1.5rem;
}
.skeleton-card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}
.skeleton-line {
  height: 1rem;
  background: linear-gradient(90deg, #e2e8f0 25%, #edf2f7 50%, #e2e8f0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 4px;
  margin-bottom: 0.75rem;
}
.skeleton-line.wide {
  width: 100%;
  height: 2rem;
}
.skeleton-line.narrow {
  width: 60%;
}
@keyframes shimmer {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}
.classes-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1rem;
}
.class-card {
  background: white;
  border-radius: 10px;
  padding: 1rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  border-left: 4px solid #667eea;
}
.class-card h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.05rem;
}
.class-card p {
  margin: 0;
  color: #718096;
  font-size: 0.9rem;
}
</style>
