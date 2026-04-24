<template>
  <div class="admin-audit">
    <header class="page-header">
      <h1>{{ t("audit.title") }}</h1>
      <p>{{ t("audit.subtitle") }}</p>
    </header>

    <!-- Filters -->
    <div class="filters-bar">
      <input
        v-model="searchQuery"
        type="search"
        class="search-input"
        :placeholder="t('audit.searchPlaceholder')"
        @keyup.enter="loadLogs"
      />
      <input v-model="dateFrom" type="datetime-local" class="date-input" />
      <input v-model="dateTo" type="datetime-local" class="date-input" />
      <BaseButton variant="secondary" @click="loadLogs">{{ t("common.refresh") }}</BaseButton>
    </div>

    <div v-if="loading" class="loading-state">{{ t("common.loading") }}</div>
    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <BaseButton @click="loadLogs">{{ t("common.retry") }}</BaseButton>
    </div>

    <div v-else-if="logs.length === 0" class="empty-state">
      <p>{{ t("audit.noLogs") }}</p>
    </div>

    <div v-else class="logs-table-wrapper">
      <table class="logs-table">
        <thead>
          <tr>
            <th>{{ t("audit.timestamp") }}</th>
            <th>{{ t("audit.action") }}</th>
            <th>{{ t("audit.actor") }}</th>
            <th>{{ t("audit.role") }}</th>
            <th>{{ t("audit.resource") }}</th>
            <th>{{ t("audit.details") }}</th>
            <th>{{ t("audit.status") }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="log in logs" :key="log.id" :class="{ error: log.success === false }">
            <td class="timestamp">{{ formatDate(log.timestamp) }}</td>
            <td>
              <span class="action-badge" :class="actionClass(log.action)">{{ log.action }}</span>
            </td>
            <td>{{ log.actorUsername || "—" }}</td>
            <td>{{ log.actorRole || "—" }}</td>
            <td>
              <span v-if="log.resourceType && log.resourceId">
                {{ log.resourceType }} #{{ log.resourceId }}
              </span>
              <span v-else>—</span>
            </td>
            <td class="details-cell">{{ log.details || "—" }}</td>
            <td>
              <span v-if="log.success === true" class="status-success">✓</span>
              <span v-else-if="log.success === false" class="status-error">✗</span>
              <span v-else>—</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { auditLogApi } from "@/api";
import BaseButton from "@/components/common/BaseButton.vue";
import { useLocale } from "@/composables/useLocale";
import { useUiStore } from "@/stores/uiStore";
import type { AuditLog } from "@/types";

const { t } = useLocale();
const uiStore = useUiStore();

const logs = ref<AuditLog[]>([]);
const loading = ref(false);
const error = ref<string | null>(null);
const searchQuery = ref("");
const dateFrom = ref("");
const dateTo = ref("");

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleString("de-DE");
}

function actionClass(action: string): string {
  if (action.includes("LOGIN")) return "login";
  if (action.includes("VOTE")) return "vote";
  if (action.includes("USER")) return "user";
  if (action.includes("CREATE") || action.includes("REGISTER")) return "create";
  if (action.includes("DELETE")) return "delete";
  if (action.includes("UPDATE")) return "update";
  return "default";
}

async function loadLogs() {
  loading.value = true;
  error.value = null;
  try {
    if (searchQuery.value.trim()) {
      logs.value = await auditLogApi.searchLogs(searchQuery.value, 200);
    } else if (dateFrom.value && dateTo.value) {
      logs.value = await auditLogApi.getLogsInRange(
        new Date(dateFrom.value).toISOString(),
        new Date(dateTo.value).toISOString(),
        200
      );
    } else {
      logs.value = await auditLogApi.getRecentLogs(200);
    }
  } catch (err: any) {
    error.value = err.response?.data?.message || t("audit.loadFailed");
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  uiStore.setBreadcrumbs([{ label: t("nav.audit") }]);
  uiStore.setPageTitle(t("audit.title"));
  loadLogs();
});
</script>

<style scoped>
.admin-audit {
  max-width: 1400px;
}
.page-header {
  margin-bottom: 1.5rem;
}
.page-header h1 {
  margin: 0 0 0.25rem 0;
}
.page-header p {
  margin: 0;
  color: #718096;
}
.filters-bar {
  display: flex;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
  align-items: center;
}
.search-input {
  flex: 1;
  min-width: 200px;
  padding: 0.6rem 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 0.95rem;
}
.date-input {
  padding: 0.6rem 0.75rem;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 0.95rem;
}
.loading-state,
.error-state,
.empty-state {
  padding: 2rem;
  text-align: center;
  color: #718096;
}
.error-state {
  color: #e53e3e;
}
.logs-table-wrapper {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  overflow: hidden;
}
.logs-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}
.logs-table th,
.logs-table td {
  padding: 0.75rem 1rem;
  text-align: left;
  border-bottom: 1px solid #f1f5f9;
}
.logs-table th {
  background: #f8fafc;
  font-weight: 600;
  color: #4a5568;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}
.logs-table tr:hover {
  background: #f8fafc;
}
.logs-table tr.error {
  background: #fef2f2;
}
.timestamp {
  font-family: monospace;
  font-size: 0.85rem;
  color: #64748b;
  white-space: nowrap;
}
.action-badge {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  text-transform: uppercase;
}
.action-badge.login {
  background: #dbeafe;
  color: #1e40af;
}
.action-badge.vote {
  background: #dcfce7;
  color: #166534;
}
.action-badge.user {
  background: #fef3c7;
  color: #92400e;
}
.action-badge.create {
  background: #d1fae5;
  color: #065f46;
}
.action-badge.delete {
  background: #fee2e2;
  color: #991b1b;
}
.action-badge.update {
  background: #e0e7ff;
  color: #3730a3;
}
.action-badge.default {
  background: #f3f4f6;
  color: #4b5563;
}
.details-cell {
  max-width: 300px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.status-success {
  color: #22c55e;
  font-weight: 700;
}
.status-error {
  color: #ef4444;
  font-weight: 700;
}
</style>
