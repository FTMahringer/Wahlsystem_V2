<template>
  <div class="teacher-my-class">
    <header class="page-header">
      <h1>{{ t("teacherMyClass.title") }}</h1>
      <p>{{ t("teacherMyClass.subtitle") }}</p>
    </header>

    <div v-if="loading" class="loading-state">{{ t("common.loading") }}</div>
    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <BaseButton @click="loadData">{{ t("common.retry") }}</BaseButton>
    </div>

    <template v-else-if="myClass">
      <div class="class-info-card">
        <h2>{{ myClass.name }}</h2>
        <div class="class-meta">
          <span v-if="myClass.gradeLevel"
            >{{ t("adminUsers.grade") }}: {{ myClass.gradeLevel }}</span
          >
          <span v-if="myClass.room"
            >{{ t("teacherMyClass.room") }}: {{ myClass.room }}</span
          >
          <span
            >{{ t("teacherMyClass.studentCount") }}:
            {{ myClass.students?.length || 0 }}</span
          >
        </div>
      </div>

      <div class="students-section">
        <h3>{{ t("teacherMyClass.students") }}</h3>
        <div v-if="!myClass.students || myClass.students.length === 0" class="empty">
          <p>{{ t("teacherMyClass.noStudents") }}</p>
        </div>
        <table v-else class="students-table">
          <thead>
            <tr>
              <th>#</th>
              <th>{{ t("common.name") }}</th>
              <th>{{ t("common.username") }}</th>
              <th>{{ t("adminUsers.studentId") }}</th>
              <th>{{ t("adminUsers.canVote") }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(student, index) in myClass.students" :key="student.id">
              <td>{{ index + 1 }}</td>
              <td>{{ student.fullName }}</td>
              <td>{{ student.username }}</td>
              <td>{{ student.studentId || "—" }}</td>
              <td>
                <span
                  class="vote-badge"
                  :class="student.canVote ? 'can' : 'cannot'"
                >
                  {{ student.canVote ? t("common.yes") : t("common.no") }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>

    <BaseEmptyState
      v-else
      :title="t('teacherMyClass.noClass')"
      :message="t('teacherMyClass.noClassMessage')"
      icon="🏫"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { schoolClassApi } from "@/api";
import BaseButton from "@/components/common/BaseButton.vue";
import BaseEmptyState from "@/components/common/BaseEmptyState.vue";
import { useLocale } from "@/composables/useLocale";
import { useUiStore } from "@/stores/uiStore";
import type { SchoolClass } from "@/types";

const { t } = useLocale();
const uiStore = useUiStore();

const myClass = ref<SchoolClass | null>(null);
const loading = ref(false);
const error = ref<string | null>(null);

async function loadData() {
  loading.value = true;
  error.value = null;
  try {
    const classes = await schoolClassApi.getMyClasses();
    myClass.value = classes.length > 0 ? classes[0] : null;
  } catch (err: any) {
    error.value = err.response?.data?.message || t("teacherMyClass.loadFailed");
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  uiStore.setBreadcrumbs([{ label: t("nav.myClass") }]);
  uiStore.setPageTitle(t("teacherMyClass.title"));
  loadData();
});
</script>

<style scoped>
.teacher-my-class {
  max-width: 1000px;
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
.loading-state,
.error-state {
  padding: 2rem;
  text-align: center;
}
.error-state {
  color: #e53e3e;
}
.class-info-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  margin-bottom: 1.5rem;
  border-left: 4px solid #667eea;
}
.class-info-card h2 {
  margin: 0 0 0.5rem 0;
  color: #1a202c;
}
.class-meta {
  display: flex;
  gap: 1.5rem;
  color: #718096;
  font-size: 0.9rem;
}
.students-section h3 {
  margin-bottom: 0.75rem;
  color: #333;
}
.students-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}
.students-table th,
.students-table td {
  padding: 0.875rem 1rem;
  text-align: left;
  border-bottom: 1px solid #f1f5f9;
}
.students-table th {
  background: #f8fafc;
  font-weight: 600;
  color: #4a5568;
  font-size: 0.8rem;
  text-transform: uppercase;
}
.students-table tr:hover {
  background: #f8fafc;
}
.vote-badge {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
}
.vote-badge.can {
  background: #dcfce7;
  color: #166534;
}
.vote-badge.cannot {
  background: #fee2e2;
  color: #991b1b;
}
.empty {
  padding: 2rem;
  text-align: center;
  color: #718096;
}
</style>
