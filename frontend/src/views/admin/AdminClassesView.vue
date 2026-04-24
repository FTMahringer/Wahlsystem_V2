<template>
  <div class="admin-classes">
    <div class="header">
      <div>
        <h1>{{ t("adminClasses.title") }}</h1>
        <p class="subtitle">{{ t("adminClasses.subtitle") }}</p>
      </div>
      <BaseButton @click="openCreate"
        >+ {{ t("adminClasses.createClass") }}</BaseButton
      >
    </div>

    <div v-if="loading" class="loading-state">{{ t("common.loading") }}</div>
    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <BaseButton @click="loadClasses">{{ t("common.retry") }}</BaseButton>
    </div>
    <div v-else class="classes-layout">
      <div class="classes-list">
        <div
          v-for="cls in classes"
          :key="cls.id"
          class="class-card"
          :class="{ active: selectedClass?.id === cls.id }"
          @click="selectClass(cls)"
        >
          <div class="class-card-header">
            <strong>{{ cls.name }}</strong>
            <span v-if="cls.gradeLevel" class="grade-badge">{{
              cls.gradeLevel
            }}</span>
          </div>
          <div class="class-card-meta">
            <span v-if="cls.classTeacher"
              >👨‍🏫 {{ cls.classTeacher.fullName }}</span
            >
            <span v-else class="no-teacher">{{
              t("adminClasses.noTeacher")
            }}</span>
            <span>👤 {{ cls.students?.length || 0 }}</span>
          </div>
        </div>
      </div>
      <div v-if="selectedClass" class="class-detail">
        <div class="detail-header">
          <h2>{{ selectedClass.name }}</h2>
          <div class="detail-actions">
            <BaseButton
              size="sm"
              variant="ghost"
              @click="openEdit(selectedClass)"
              >✏️</BaseButton
            >
            <BaseButton
              size="sm"
              variant="ghost"
              @click="confirmDelete(selectedClass)"
              >🗑️</BaseButton
            >
          </div>
        </div>
        <div class="detail-info">
          <div v-if="selectedClass.gradeLevel" class="info-row">
            <span class="info-label">{{ t("adminUsers.grade") }}</span
            ><span>{{ selectedClass.gradeLevel }}</span>
          </div>
          <div v-if="selectedClass.room" class="info-row">
            <span class="info-label">{{ t("adminClasses.room") }}</span
            ><span>{{ selectedClass.room }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">{{ t("adminClasses.classTeacher") }}</span
            ><span>{{
              selectedClass.classTeacher?.fullName ||
              t("adminClasses.noTeacher")
            }}</span>
          </div>
        </div>
        <div class="detail-section">
          <h3>{{ t("adminClasses.teachers") }}</h3>
          <div v-if="selectedClass.classTeacher" class="person-chip">
            <span>{{ selectedClass.classTeacher.fullName }}</span>
            <small>{{ selectedClass.classTeacher.employeeId }}</small>
          </div>
          <div v-else class="empty-section">
            {{ t("adminClasses.noTeacher") }}
          </div>
        </div>
        <div class="detail-section">
          <h3>
            {{ t("adminClasses.students") }} ({{
              selectedClass.students?.length || 0
            }})
          </h3>
          <div
            v-if="selectedClass.students && selectedClass.students.length > 0"
            class="students-grid"
          >
            <div
              v-for="student in selectedClass.students"
              :key="student.id"
              class="person-chip"
            >
              <span>{{ student.fullName }}</span>
              <small>{{ student.studentId }}</small>
            </div>
          </div>
          <div v-else class="empty-section">
            {{ t("adminClasses.noStudents") }}
          </div>
        </div>
      </div>
      <BaseEmptyState
        v-else
        class="class-detail empty"
        :title="t('adminClasses.selectClass')"
        message=""
        icon="🏫"
      />
    </div>

    <BaseDialog
      :open="dialogOpen"
      :title="
        isEdit ? t('adminClasses.editTitle') : t('adminClasses.createTitle')
      "
      size="md"
      @update:open="dialogOpen = $event"
    >
      <div class="form-grid">
        <div class="form-group">
          <label>{{ t("common.name") }} *</label
          ><input v-model="form.name" type="text" />
        </div>
        <div class="form-group">
          <label>{{ t("adminUsers.grade") }}</label
          ><input v-model.number="form.gradeLevel" type="number" min="1" />
        </div>
        <div class="form-group">
          <label>{{ t("adminClasses.room") }}</label
          ><input v-model="form.room" type="text" />
        </div>
        <div class="form-group full-width">
          <label>{{ t("adminClasses.classTeacher") }}</label>
          <select v-model="form.classTeacherId">
            <option :value="undefined">{{ t("common.none") }}</option>
            <option
              v-for="teacher in teachers"
              :key="teacher.id"
              :value="teacher.id"
            >
              {{ teacher.fullName || teacher.username }} ({{
                teacher.employeeId
              }})
            </option>
          </select>
        </div>
      </div>
      <div class="dialog-actions">
        <BaseButton
          variant="secondary"
          :disabled="submitting"
          @click="dialogOpen = false"
          >{{ t("common.cancel") }}</BaseButton
        >
        <BaseButton :loading="submitting" @click="submitForm">{{
          isEdit ? t("common.save") : t("common.create")
        }}</BaseButton>
      </div>
    </BaseDialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from "vue";
import { schoolClassApi, userApi } from "@/api";
import BaseButton from "@/components/common/BaseButton.vue";
import BaseDialog from "@/components/common/BaseDialog.vue";
import BaseEmptyState from "@/components/common/BaseEmptyState.vue";
import { useLocale } from "@/composables/useLocale";
import { useUiStore } from "@/stores/uiStore";
import type { SchoolClass, SchoolClassUpsertRequest, User } from "@/types";

const uiStore = useUiStore();
const { t } = useLocale();

const classes = ref<SchoolClass[]>([]);
const teachers = ref<User[]>([]);
const loading = ref(false);
const error = ref<string | null>(null);
const selectedClass = ref<SchoolClass | null>(null);

const dialogOpen = ref(false);
const isEdit = ref(false);
const submitting = ref(false);
const editingId = ref<number | null>(null);

const form = reactive({
  name: "",
  gradeLevel: null as number | null,
  room: "",
  classTeacherId: undefined as number | undefined,
});

async function loadClasses() {
  loading.value = true;
  error.value = null;
  try {
    const [classesData, teachersData] = await Promise.all([
      schoolClassApi.getAll(),
      userApi.getAll({ role: "TEACHER" }),
    ]);
    classes.value = classesData;
    teachers.value = teachersData;
    if (selectedClass.value) {
      const updated = classesData.find((c) => c.id === selectedClass.value!.id);
      if (updated) selectedClass.value = updated;
    }
  } catch (err: any) {
    error.value = err.response?.data?.message || t("adminClasses.loadFailed");
  } finally {
    loading.value = false;
  }
}

function selectClass(cls: SchoolClass) {
  selectedClass.value = cls;
}

function openCreate() {
  isEdit.value = false;
  editingId.value = null;
  form.name = "";
  form.gradeLevel = null;
  form.room = "";
  form.classTeacherId = undefined;
  dialogOpen.value = true;
}

function openEdit(cls: SchoolClass) {
  isEdit.value = true;
  editingId.value = cls.id;
  form.name = cls.name;
  form.gradeLevel = cls.gradeLevel;
  form.room = cls.room || "";
  form.classTeacherId = cls.classTeacher?.id;
  dialogOpen.value = true;
}

function confirmDelete(cls: SchoolClass) {
  uiStore.openConfirm({
    title: t("adminClasses.deleteTitle"),
    message: t("adminClasses.deleteMessage", { name: cls.name }),
    onConfirm: async () => {
      try {
        await schoolClassApi.delete(cls.id);
        if (selectedClass.value?.id === cls.id) selectedClass.value = null;
        await loadClasses();
        uiStore.showToast({
          type: "success",
          message: t("adminClasses.deletedSuccess"),
        });
      } catch (err: any) {
        uiStore.showToast({
          type: "error",
          message:
            err.response?.data?.message || t("adminClasses.deleteFailed"),
        });
      }
    },
  });
}

async function submitForm() {
  if (!form.name.trim()) {
    uiStore.showToast({
      type: "error",
      message: t("adminClasses.nameRequired"),
    });
    return;
  }
  submitting.value = true;
  try {
    const payload: SchoolClassUpsertRequest = {
      name: form.name.trim(),
      gradeLevel: form.gradeLevel ?? undefined,
      room: form.room.trim() || undefined,
      classTeacherId: form.classTeacherId,
    };
    if (isEdit.value && editingId.value) {
      await schoolClassApi.update(editingId.value, payload);
      uiStore.showToast({
        type: "success",
        message: t("adminClasses.updatedSuccess"),
      });
    } else {
      await schoolClassApi.create(payload);
      uiStore.showToast({
        type: "success",
        message: t("adminClasses.createdSuccess"),
      });
    }
    dialogOpen.value = false;
    await loadClasses();
  } catch (err: any) {
    uiStore.showToast({
      type: "error",
      message: err.response?.data?.message || t("adminClasses.saveFailed"),
    });
  } finally {
    submitting.value = false;
  }
}

onMounted(() => {
  uiStore.setBreadcrumbs([
    { label: t("nav.dashboard"), route: "/admin/dashboard" },
    { label: t("nav.classes") },
  ]);
  uiStore.setPageTitle(t("adminClasses.title"));
  loadClasses();
});
</script>

<style scoped>
.admin-classes {
  max-width: 1200px;
}
.header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1.5rem;
}
.header h1 {
  margin: 0 0 0.3rem 0;
}
.subtitle {
  margin: 0;
  color: var(--color-text-muted, #718096);
}
.loading-state,
.error-state {
  padding: 2rem;
  text-align: center;
}
.error-state {
  color: var(--color-danger, #e53e3e);
}
.classes-layout {
  display: grid;
  grid-template-columns: 320px 1fr;
  gap: 1.5rem;
  min-height: 500px;
}
.classes-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.class-card {
  background: var(--color-surface, #ffffff);
  border-radius: 12px;
  padding: 1rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  cursor: pointer;
  border: 2px solid transparent;
  transition: all 0.15s;
}
.class-card:hover {
  border-color: var(--color-primary, #667eea);
}
.class-card.active {
  border-color: var(--color-primary, #667eea);
  background: #f0f4ff;
}
.class-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}
.class-card-header strong {
  font-size: 1.05rem;
  color: var(--color-text, #1a202c);
}
.grade-badge {
  background: #e2e8f0;
  color: #4a5568;
  padding: 0.15rem 0.5rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 600;
}
.class-card-meta {
  display: flex;
  justify-content: space-between;
  font-size: 0.85rem;
  color: var(--color-text-muted, #718096);
}
.no-teacher {
  color: #a0aec0;
  font-style: italic;
}
.class-detail {
  background: var(--color-surface, #ffffff);
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}
.class-detail.empty {
  display: flex;
  align-items: center;
  justify-content: center;
}
.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.25rem;
}
.detail-header h2 {
  margin: 0;
}
.detail-actions {
  display: flex;
  gap: 0.25rem;
}
.detail-info {
  background: #f8fafc;
  border-radius: 10px;
  padding: 1rem;
  margin-bottom: 1.5rem;
}
.info-row {
  display: flex;
  justify-content: space-between;
  padding: 0.4rem 0;
  border-bottom: 1px solid #e2e8f0;
}
.info-row:last-child {
  border-bottom: none;
}
.info-label {
  color: var(--color-text-muted, #718096);
  font-size: 0.9rem;
}
.detail-section {
  margin-bottom: 1.5rem;
}
.detail-section h3 {
  margin: 0 0 0.75rem 0;
  font-size: 1rem;
  color: var(--color-text, #1a202c);
}
.students-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}
.person-chip {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: #edf2f7;
  padding: 0.4rem 0.75rem;
  border-radius: 8px;
  font-size: 0.9rem;
}
.person-chip small {
  color: #718096;
  font-size: 0.75rem;
}
.empty-section {
  color: #a0aec0;
  font-size: 0.9rem;
  font-style: italic;
}
.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1rem;
}
.full-width {
  grid-column: 1 / -1;
}
.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}
.form-group label {
  font-weight: 600;
  color: #4a5568;
  font-size: 0.9rem;
}
.form-group input,
.form-group select {
  border: 1.5px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  padding: 0.7rem 0.9rem;
  font-size: 0.95rem;
  font-family: inherit;
}
.dialog-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  margin-top: 1.5rem;
}
@media (max-width: 768px) {
  .classes-layout {
    grid-template-columns: 1fr;
  }
}
</style>
