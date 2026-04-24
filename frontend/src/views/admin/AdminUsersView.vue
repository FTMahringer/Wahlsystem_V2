<template>
  <div class="admin-users">
    <div class="header">
      <div>
        <h1>{{ t("adminUsers.title") }}</h1>
        <p class="subtitle">{{ t("adminUsers.subtitle") }}</p>
      </div>
      <BaseButton @click="openWizard"
        >+ {{ t("adminUsers.addUsers") }}</BaseButton
      >
    </div>

    <div class="summary-grid">
      <div class="summary-card">
        <strong>{{ users.length }}</strong
        ><span>{{ t("common.total") }}</span>
      </div>
      <div class="summary-card">
        <strong>{{ studentCount }}</strong
        ><span>{{ t("adminUsers.students") }}</span>
      </div>
      <div class="summary-card">
        <strong>{{ teacherCount }}</strong
        ><span>{{ t("adminUsers.teachers") }}</span>
      </div>
      <div class="summary-card">
        <strong>{{ activeCount }}</strong
        ><span>{{ t("common.active") }}</span>
      </div>
    </div>

    <div class="toolbar">
      <div class="filter-group">
        <button
          v-for="option in roleFilters"
          :key="option.value"
          class="filter-btn"
          :class="{ active: roleFilter === option.value }"
          @click="setRoleFilter(option.value)"
        >
          {{ option.label }}
        </button>
      </div>
      <div class="toolbar-actions">
        <select v-model="activeFilter" class="status-select">
          <option value="ALL">{{ t("adminUsers.allStatuses") }}</option>
          <option value="ACTIVE">{{ t("adminUsers.activeOnly") }}</option>
          <option value="INACTIVE">{{ t("adminUsers.inactiveOnly") }}</option>
        </select>
        <input
          v-model="search"
          type="search"
          class="search-input"
          :placeholder="t('adminUsers.searchPlaceholder')"
          @keyup.enter="loadUsers"
        />
        <BaseButton variant="secondary" @click="loadUsers">{{
          t("common.refresh")
        }}</BaseButton>
        <BaseButton variant="secondary" @click="openExportModal">
          📥 {{ t("adminUsers.export") }}
        </BaseButton>
      </div>
    </div>

    <div v-if="loading" class="loading-state">
      {{ t("adminUsers.loading") }}
    </div>
    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <BaseButton @click="loadUsers">{{ t("common.retry") }}</BaseButton>
    </div>
    <BaseEmptyState
      v-else-if="users.length === 0"
      :title="t('adminUsers.emptyTitle')"
      :message="t('adminUsers.emptyMessage')"
      icon="👥"
    />
    <div v-else class="users-table">
      <table>
        <thead>
          <tr>
            <th>{{ t("common.name") }}</th>
            <th>{{ t("common.role") }}</th>
            <th>{{ t("common.username") }}</th>
            <th>{{ t("common.email") }}</th>
            <th>{{ t("common.group") }}</th>
            <th>{{ t("common.status") }}</th>
            <th>{{ t("common.created") }}</th>
            <th>{{ t("common.actions") }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in users" :key="user.id">
            <td>
              <div class="name-cell">
                <strong>{{ displayName(user) }}</strong
                ><small v-if="user.role === 'STUDENT' && user.studentId"
                  >ID: {{ user.studentId }}</small
                ><small v-else-if="user.role === 'TEACHER' && user.employeeId"
                  >ID: {{ user.employeeId }}</small
                >
              </div>
            </td>
            <td>
              <span class="role-badge" :class="user.role.toLowerCase()">{{
                t(`roles.${user.role}`)
              }}</span>
            </td>
            <td>{{ user.username }}</td>
            <td>{{ user.email }}</td>
            <td>{{ describeGroup(user) }}</td>
            <td>
              <span class="status-badge" :class="{ inactive: !user.active }">{{
                user.active ? t("common.active") : t("common.inactive")
              }}</span>
            </td>
            <td>{{ formatDate(user.createdAt) }}</td>
            <td>
              <div class="actions-cell">
                <BaseButton
                  size="sm"
                  variant="ghost"
                  :loading="togglingUserId === user.id"
                  @click="toggleActive(user)"
                  >{{
                    user.active
                      ? t("adminUsers.deactivate")
                      : t("adminUsers.activate")
                  }}</BaseButton
                ><BaseButton
                  v-if="canEdit(user)"
                  size="sm"
                  variant="ghost"
                  @click="openEdit(user)"
                  >✏️</BaseButton
                >
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <BaseDialog
      :open="wizardOpen"
      :title="t('adminUsers.onboardingTitle')"
      size="lg"
      @update:open="handleDialogState"
    >
      <WizardShell>
        <template #header>
          <div class="wizard-header-copy">
            <div>
              <h2>{{ currentStep?.title }}</h2>
              <p v-if="currentStep?.description">
                {{ currentStep.description }}
              </p>
            </div>
            <span class="step-counter">{{
              t("wizard.stepCounter", {
                current: currentStepIndex + 1,
                total: wizardSteps.length,
              })
            }}</span>
          </div>
        </template>
        <template #nav>
          <WizardStepNav
            :steps="wizardSteps"
            :current-step-id="currentStepId"
            :completed-step-ids="completedStepIds"
            @select="selectStep"
          />
        </template>
        <WizardStepPanel :active="currentStepId === 'mode'">
          <div class="wizard-card-grid">
            <button
              v-for="mode in importModes"
              :key="mode.value"
              type="button"
              class="mode-card"
              :class="{ active: importMode === mode.value }"
              @click="importMode = mode.value"
            >
              <strong>{{ mode.label }}</strong>
              <p>{{ mode.description }}</p>
            </button>
          </div>
        </WizardStepPanel>
        <WizardStepPanel :active="currentStepId === 'role'">
          <div class="wizard-card-grid">
            <button
              v-for="role in managedRoles"
              :key="role.value"
              type="button"
              class="mode-card"
              :class="{
                active: onboardingRole === role.value,
                disabled: role.value === 'STUDENT' && !hasSchoolClasses,
              }"
              :disabled="role.value === 'STUDENT' && !hasSchoolClasses"
              @click="
                role.value === 'STUDENT' && !hasSchoolClasses
                  ? null
                  : (onboardingRole = role.value)
              "
            >
              <strong>{{ role.label }}</strong>
              <p>{{ role.description }}</p>
              <div
                v-if="role.value === 'STUDENT' && !hasSchoolClasses"
                class="role-disabled-hint"
              >
                <span class="hint-icon">⚠️</span>
                <span>{{ t("adminUsers.studentRoleDisabled") }}</span>
                <BaseButton
                  size="sm"
                  variant="ghost"
                  @click.stop="router.push('/admin/classes')"
                >
                  {{ t("adminUsers.createClassFirst") }}
                </BaseButton>
              </div>
            </button>
          </div>
        </WizardStepPanel>
        <WizardStepPanel :active="currentStepId === 'details'">
          <div v-if="importMode === 'single'" class="single-form">
            <div class="form-grid">
              <div class="form-group">
                <label>{{ t("common.username") }} *</label
                ><input v-model="singleForm.username" type="text" />
              </div>
              <div class="form-group">
                <label>{{ t("common.email") }} *</label
                ><input v-model="singleForm.email" type="email" />
              </div>
              <div class="form-group">
                <label>{{ t("common.password") }} *</label
                ><input v-model="singleForm.password" type="text" />
              </div>
              <div class="form-group">
                <label>{{ t("common.firstName") }} *</label
                ><input v-model="singleForm.firstName" type="text" />
              </div>
              <div class="form-group">
                <label>{{ t("common.lastName") }} *</label
                ><input v-model="singleForm.lastName" type="text" />
              </div>
              <template v-if="onboardingRole === 'STUDENT'">
                <div class="form-group">
                  <label>{{ t("adminUsers.studentId") }} *</label
                  ><input v-model="singleForm.studentId" type="text" />
                </div>
                <div class="form-group">
                  <label>{{ t("common.class") }} *</label
                  ><input v-model="singleForm.className" type="text" />
                </div>
                <div class="form-group">
                  <label>{{ t("adminUsers.grade") }}</label
                  ><input
                    v-model.number="singleForm.gradeLevel"
                    type="number"
                    min="1"
                  />
                </div>
              </template>
              <template v-else>
                <div class="form-group">
                  <label>{{ t("adminUsers.employeeId") }} *</label
                  ><input v-model="singleForm.employeeId" type="text" />
                </div>
                <div class="form-group">
                  <label>{{ t("common.department") }}</label
                  ><input v-model="singleForm.department" type="text" />
                </div>
                <div class="form-group full-width">
                  <label>{{ t("common.subjects") }}</label
                  ><input v-model="singleForm.subjects" type="text" />
                </div>
              </template>
            </div>
          </div>
          <div v-else class="bulk-import">
            <div class="import-toolbar">
              <div class="import-hint">
                <strong>{{
                  importMode === "csv"
                    ? t("adminUsers.csvImport")
                    : t("adminUsers.bulkPaste")
                }}</strong>
                <p>{{ importHint }}</p>
              </div>
              <label v-if="importMode === 'csv'" class="file-input"
                ><input
                  type="file"
                  accept=".csv,text/csv,.txt"
                  @change="handleCsvUpload"
                />{{ t("adminUsers.chooseFile") }}</label
              >
            </div>
            <textarea
              v-model="importText"
              rows="12"
              class="import-textarea"
              :placeholder="importPlaceholder"
            />
            <div class="preview-note">
              {{ t("adminUsers.parsedRows") }}
              <strong>{{ parsedImport.users.length }}</strong
              ><span v-if="parsedImport.errors.length > 0" class="field-error">
                •
                {{
                  t("adminUsers.issuesNeedFixing", {
                    count: parsedImport.errors.length,
                  })
                }}</span
              >
            </div>
            <span v-if="errors.importText" class="field-error">{{
              errors.importText
            }}</span>
          </div>
        </WizardStepPanel>
        <WizardStepPanel :active="currentStepId === 'review'">
          <div class="review-grid">
            <div class="review-card">
              <h3>{{ t("adminUsers.importMode") }}</h3>
              <p>{{ currentImportMode.label }}</p>
            </div>
            <div class="review-card">
              <h3>{{ t("adminUsers.role") }}</h3>
              <p>{{ t(`roles.${onboardingRole}`) }}</p>
            </div>
            <div class="review-card">
              <h3>{{ t("adminUsers.entries") }}</h3>
              <p>{{ reviewUsers.length }}</p>
            </div>
            <div class="review-card">
              <h3>{{ t("adminUsers.expectedResult") }}</h3>
              <p>
                {{
                  t("adminUsers.createExpectedResult", {
                    count: reviewUsers.length,
                    role:
                      onboardingRole === "STUDENT"
                        ? t("adminUsers.studentsPlural")
                        : t("adminUsers.teachersPlural"),
                  })
                }}
              </p>
            </div>
          </div>
          <div class="review-list-card">
            <h3>{{ t("adminUsers.preview") }}</h3>
            <table class="preview-table">
              <thead>
                <tr>
                  <th>{{ t("common.username") }}</th>
                  <th>{{ t("common.name") }}</th>
                  <th>{{ t("common.email") }}</th>
                  <th>
                    {{
                      onboardingRole === "STUDENT"
                        ? t("common.class")
                        : t("common.department")
                    }}
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="user in reviewUsers.slice(0, 8)"
                  :key="`${user.username}-${user.email}`"
                >
                  <td>{{ user.username }}</td>
                  <td>{{ user.firstName }} {{ user.lastName }}</td>
                  <td>{{ user.email }}</td>
                  <td>
                    {{
                      onboardingRole === "STUDENT"
                        ? user.className || "-"
                        : user.department || "-"
                    }}
                  </td>
                </tr>
              </tbody>
            </table>
            <p v-if="reviewUsers.length > 8" class="preview-more">
              {{ t("adminUsers.firstEntriesShown") }}
            </p>
          </div>
        </WizardStepPanel>
        <template #actions>
          <WizardActions
            :is-first-step="isFirstStep"
            :is-last-step="isLastStep"
            :submitting="submitting"
            :submit-label="t('adminUsers.createUsers')"
            @back="goToPreviousStep"
            @next="goToNextStepWithValidation"
            @submit="submitWizard"
          >
            <template #secondary
              ><BaseButton
                variant="ghost"
                :disabled="submitting"
                @click="closeWizard"
                >{{ t("common.cancel") }}</BaseButton
              ></template
            >
          </WizardActions>
        </template>
      </WizardShell>
    </BaseDialog>

    <BaseDialog
      :open="editOpen"
      :title="t('adminUsers.editTitle')"
      size="lg"
      @update:open="editOpen = $event"
    >
      <div v-if="editUser" class="edit-form">
        <div class="form-grid">
          <div class="form-group">
            <label>{{ t("common.username") }}</label
            ><input v-model="editForm.username" type="text" />
          </div>
          <div class="form-group">
            <label>{{ t("common.email") }}</label
            ><input v-model="editForm.email" type="email" />
          </div>
          <div class="form-group">
            <label>{{ t("common.firstName") }}</label
            ><input v-model="editForm.firstName" type="text" />
          </div>
          <div class="form-group">
            <label>{{ t("common.lastName") }}</label
            ><input v-model="editForm.lastName" type="text" />
          </div>
          <template v-if="editUser.role === 'STUDENT'">
            <div class="form-group">
              <label>{{ t("adminUsers.studentId") }}</label
              ><input v-model="editForm.studentId" type="text" />
            </div>
            <div class="form-group">
              <label>{{ t("common.class") }}</label
              ><input v-model="editForm.className" type="text" />
            </div>
            <div class="form-group">
              <label>{{ t("adminUsers.grade") }}</label
              ><input
                v-model.number="editForm.gradeLevel"
                type="number"
                min="1"
              />
            </div>
            <div class="form-group">
              <label>{{ t("adminUsers.canVote") }}</label
              ><select v-model="editForm.canVote">
                <option :value="true">{{ t("common.yes") }}</option>
                <option :value="false">{{ t("common.no") }}</option>
              </select>
            </div>
          </template>
          <template v-else-if="editUser.role === 'TEACHER'">
            <div class="form-group">
              <label>{{ t("adminUsers.employeeId") }}</label
              ><input v-model="editForm.employeeId" type="text" />
            </div>
            <div class="form-group">
              <label>{{ t("common.department") }}</label
              ><input v-model="editForm.department" type="text" />
            </div>
            <div class="form-group full-width">
              <label>{{ t("common.subjects") }}</label
              ><input v-model="editForm.subjects" type="text" />
            </div>
          </template>
          <template v-else-if="editUser.role === 'ADMIN'">
            <div class="form-group">
              <label>{{ t("adminUsers.adminLevel") }}</label
              ><input
                v-model.number="editForm.adminLevel"
                type="number"
                min="1"
              />
            </div>
            <div class="form-group">
              <label>{{ t("common.department") }}</label
              ><input v-model="editForm.department" type="text" />
            </div>
          </template>
        </div>
        <div class="edit-actions">
          <BaseButton
            variant="secondary"
            :disabled="editSubmitting"
            @click="editOpen = false"
            >{{ t("common.cancel") }}</BaseButton
          >
          <BaseButton :loading="editSubmitting" @click="submitEdit">{{
            t("common.save")
          }}</BaseButton>
        </div>
      </div>
    </BaseDialog>

    <!-- Export Modal -->
    <BaseDialog
      :open="exportModalOpen"
      :title="t('adminUsers.exportTitle')"
      size="lg"
      @update:open="exportModalOpen = $event"
    >
      <div class="export-modal">
        <!-- Role Selection -->
        <div class="export-section">
          <h3>{{ t("adminUsers.exportRoleLabel") }}</h3>
          <div class="export-options">
            <label class="export-option">
              <input v-model="exportRole" type="radio" value="STUDENT" />
              <span>{{ t("roles.STUDENT") }}</span>
            </label>
            <label class="export-option">
              <input v-model="exportRole" type="radio" value="TEACHER" />
              <span>{{ t("roles.TEACHER") }}</span>
            </label>
            <label class="export-option">
              <input v-model="exportRole" type="radio" value="BOTH" />
              <span>{{ t("adminUsers.exportBoth") }}</span>
            </label>
          </div>
        </div>

        <!-- Field Selection -->
        <div class="export-section">
          <h3>{{ t("adminUsers.exportFieldsLabel") }}</h3>
          <div class="field-selector">
            <div class="available-fields">
              <h4>{{ t("adminUsers.availableFields") }}</h4>
              <div class="field-list">
                <div
                  v-for="field in availableExportFields"
                  :key="field.key"
                  class="field-item"
                  @click="addExportField(field)"
                >
                  {{ field.label }} →
                </div>
              </div>
            </div>
            <div class="selected-fields">
              <h4>{{ t("adminUsers.selectedFields") }}</h4>
              <div class="field-list">
                <div
                  v-for="field in selectedExportFields"
                  :key="field.key"
                  class="field-item selected"
                  @click="removeExportField(field)"
                >
                  ← {{ field.label }}
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="export-actions">
          <BaseButton variant="secondary" @click="exportModalOpen = false">
            {{ t("common.cancel") }}
          </BaseButton>
          <BaseButton
            :disabled="selectedExportFields.length === 0"
            @click="performExport"
          >
            📥 {{ t("adminUsers.exportDownload") }}
          </BaseButton>
        </div>
      </div>
    </BaseDialog>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from "vue";
import { userApi, schoolClassApi } from "@/api";
import { useRouter } from "vue-router";
import BaseButton from "@/components/common/BaseButton.vue";
import BaseDialog from "@/components/common/BaseDialog.vue";
import BaseEmptyState from "@/components/common/BaseEmptyState.vue";
import WizardActions from "@/components/common/wizard/WizardActions.vue";
import WizardShell from "@/components/common/wizard/WizardShell.vue";
import WizardStepNav from "@/components/common/wizard/WizardStepNav.vue";
import WizardStepPanel from "@/components/common/wizard/WizardStepPanel.vue";
import { useLocale } from "@/composables/useLocale";
import { useWizard, type WizardStepDefinition } from "@/composables/useWizard";
import { toIntlLocale } from "@/locales";
import { useUiStore } from "@/stores/uiStore";
import type {
  ManagedUserFilters,
  RegisterRequest,
  SchoolClass,
  User,
  UserUpdateRequest,
} from "@/types";

type ManagedRole = "STUDENT" | "TEACHER";
type ImportMode = "single" | "bulk" | "csv";
type RoleFilter = "ALL" | ManagedRole;
type ActiveFilter = "ALL" | "ACTIVE" | "INACTIVE";

const uiStore = useUiStore();
const router = useRouter();
const { t, language } = useLocale();
const localeCode = computed(() => toIntlLocale(language.value));

const schoolClasses = ref<SchoolClass[]>([]);
const hasSchoolClasses = computed(() => schoolClasses.value.length > 0);

const users = ref<User[]>([]);
const loading = ref(false);
const error = ref<string | null>(null);
const togglingUserId = ref<number | null>(null);

const roleFilter = ref<RoleFilter>("ALL");
const activeFilter = ref<ActiveFilter>("ALL");
const search = ref("");

const wizardOpen = ref(false);
const submitting = ref(false);
const importMode = ref<ImportMode>("single");
const onboardingRole = ref<ManagedRole>("STUDENT");
const importText = ref("");
const errors = reactive<Record<string, string>>({});

const singleForm = reactive({
  username: "",
  email: "",
  password: "",
  firstName: "",
  lastName: "",
  studentId: "",
  className: "",
  gradeLevel: null as number | null,
  employeeId: "",
  department: "",
  subjects: "",
});

const editOpen = ref(false);
const editSubmitting = ref(false);
const editUser = ref<User | null>(null);

// Export
const exportModalOpen = ref(false);
const exportRole = ref<"STUDENT" | "TEACHER" | "BOTH">("STUDENT");
const selectedExportFields = ref<{ key: string; label: string }[]>([
  { key: "username", label: "Benutzername" },
  { key: "email", label: "E-Mail" },
  { key: "firstName", label: "Vorname" },
  { key: "lastName", label: "Nachname" },
  { key: "role", label: "Rolle" },
]);
const availableExportFields = computed(() => {
  const all = [
    { key: "id", label: "ID" },
    { key: "username", label: "Benutzername" },
    { key: "email", label: "E-Mail" },
    { key: "firstName", label: "Vorname" },
    { key: "lastName", label: "Nachname" },
    { key: "fullName", label: "Vollständiger Name" },
    { key: "role", label: "Rolle" },
    { key: "active", label: "Aktiv" },
    { key: "createdAt", label: "Erstellt am" },
    { key: "lastLoginAt", label: "Letzter Login" },
    { key: "studentId", label: "Schüler-ID" },
    { key: "className", label: "Klasse" },
    { key: "gradeLevel", label: "Schulstufe" },
    { key: "employeeId", label: "Personalnummer" },
    { key: "department", label: "Abteilung" },
    { key: "subjects", label: "Fächer" },
  ];
  const selectedKeys = selectedExportFields.value.map((f) => f.key);
  return all.filter((f) => !selectedKeys.includes(f.key));
});

const editForm = reactive({
  username: "",
  email: "",
  firstName: "",
  lastName: "",
  studentId: "",
  className: "",
  gradeLevel: null as number | null,
  canVote: true,
  employeeId: "",
  department: "",
  subjects: "",
  adminLevel: 1,
});

const studentCount = computed(
  () => users.value.filter((u) => u.role === "STUDENT").length,
);
const teacherCount = computed(
  () => users.value.filter((u) => u.role === "TEACHER").length,
);
const activeCount = computed(() => users.value.filter((u) => u.active).length);

const roleFilters = computed(() => [
  { label: t("adminElections.filters.ALL"), value: "ALL" as const },
  { label: t("adminUsers.students"), value: "STUDENT" as const },
  { label: t("adminUsers.teachers"), value: "TEACHER" as const },
]);

const importModes = computed(() => [
  {
    value: "single" as const,
    label: t("adminUsers.importModeOptions.single.label"),
    description: t("adminUsers.importModeOptions.single.description"),
  },
  {
    value: "bulk" as const,
    label: t("adminUsers.importModeOptions.bulk.label"),
    description: t("adminUsers.importModeOptions.bulk.description"),
  },
  {
    value: "csv" as const,
    label: t("adminUsers.importModeOptions.csv.label"),
    description: t("adminUsers.importModeOptions.csv.description"),
  },
]);

const managedRoles = computed(() => [
  {
    value: "STUDENT" as const,
    label: t("adminUsers.managedRoles.STUDENT.label"),
    description: t("adminUsers.managedRoles.STUDENT.description"),
  },
  {
    value: "TEACHER" as const,
    label: t("adminUsers.managedRoles.TEACHER.label"),
    description: t("adminUsers.managedRoles.TEACHER.description"),
  },
]);

const wizardSteps = computed<WizardStepDefinition[]>(() => [
  {
    id: "mode",
    title: t("adminUsers.wizardSteps.mode.title"),
    description: t("adminUsers.wizardSteps.mode.description"),
  },
  {
    id: "role",
    title: t("adminUsers.wizardSteps.role.title"),
    description: t("adminUsers.wizardSteps.role.description"),
  },
  {
    id: "details",
    title: t("adminUsers.wizardSteps.details.title"),
    description: t("adminUsers.wizardSteps.details.description"),
  },
  {
    id: "review",
    title: t("adminUsers.wizardSteps.review.title"),
    description: t("adminUsers.wizardSteps.review.description"),
  },
]);

const {
  currentStep,
  currentStepId,
  currentStepIndex,
  completedStepIds,
  isFirstStep,
  isLastStep,
  goToNextStep,
  goToPreviousStep,
  goToStep,
  markStepComplete,
  resetCompletedSteps,
} = useWizard(wizardSteps, {
  canNavigateToStep: (_step, targetIndex, currentIndex) =>
    targetIndex <= currentIndex ||
    completedStepIds.value.includes(wizardSteps.value[targetIndex].id),
});

const currentImportMode = computed(
  () =>
    importModes.value.find((mode) => mode.value === importMode.value) ??
    importModes.value[0],
);
const importHint = computed(() =>
  t(`adminUsers.importHints.${onboardingRole.value}`),
);
const importPlaceholder = computed(() =>
  t(`adminUsers.importPlaceholders.${onboardingRole.value}`),
);
const parsedImport = computed(() =>
  parseImportedUsers(importText.value, onboardingRole.value),
);
const reviewUsers = computed<RegisterRequest[]>(() =>
  importMode.value === "single"
    ? [buildSingleUserRequest()]
    : parsedImport.value.users,
);

function defaultPassword(): string {
  return "changeme123";
}

function resetSingleForm() {
  singleForm.username = "";
  singleForm.email = "";
  singleForm.password = defaultPassword();
  singleForm.firstName = "";
  singleForm.lastName = "";
  singleForm.studentId = "";
  singleForm.className = "";
  singleForm.gradeLevel = null;
  singleForm.employeeId = "";
  singleForm.department = "";
  singleForm.subjects = "";
}

function resetWizard() {
  importMode.value = "single";
  onboardingRole.value = "STUDENT";
  importText.value = "";
  resetSingleForm();
  resetCompletedSteps();
  goToStep("mode", true);
  Object.keys(errors).forEach((key) => delete errors[key]);
}

async function openWizard() {
  resetWizard();
  await loadSchoolClasses();
  wizardOpen.value = true;
}
async function loadSchoolClasses() {
  try {
    schoolClasses.value = await schoolClassApi.getAll();
  } catch {
    schoolClasses.value = [];
  }
}
function closeWizard() {
  wizardOpen.value = false;
}
function handleDialogState(open: boolean) {
  wizardOpen.value = open;
  if (!open) resetWizard();
}
function setRoleFilter(value: RoleFilter) {
  roleFilter.value = value;
  loadUsers();
}

function openExportModal() {
  exportModalOpen.value = true;
}
function addExportField(field: { key: string; label: string }) {
  selectedExportFields.value.push(field);
}
function removeExportField(field: { key: string; label: string }) {
  selectedExportFields.value = selectedExportFields.value.filter(
    (f) => f.key !== field.key,
  );
}
function performExport() {
  const roleFilter = exportRole.value === "BOTH" ? undefined : exportRole.value;
  const filtered = users.value.filter((u) => {
    if (!roleFilter) return u.role !== "ADMIN";
    return u.role === roleFilter;
  });

  const headers = selectedExportFields.value.map((f) => f.label).join(";");
  const rows = filtered.map((user) =>
    selectedExportFields.value
      .map((field) => {
        const value = (user as any)[field.key];
        if (value === null || value === undefined) return "";
        if (typeof value === "boolean") return value ? "Ja" : "Nein";
        return String(value).replace(/"/g, '""');
      })
      .join(";"),
  );

  const csv = [headers, ...rows].join("\n");
  const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = `users_export_${new Date().toISOString().slice(0, 10)}.csv`;
  link.click();
  URL.revokeObjectURL(link.href);
  exportModalOpen.value = false;
}

function buildFilters(): ManagedUserFilters {
  return {
    role: roleFilter.value === "ALL" ? undefined : roleFilter.value,
    active:
      activeFilter.value === "ALL"
        ? undefined
        : activeFilter.value === "ACTIVE",
    search: search.value.trim() || undefined,
  };
}

async function loadUsers() {
  loading.value = true;
  error.value = null;
  try {
    users.value = await userApi.getAll(buildFilters());
  } catch (err: any) {
    error.value = err.response?.data?.message || t("adminUsers.loadFailed");
  } finally {
    loading.value = false;
  }
}

function displayName(user: User): string {
  return (
    user.fullName ||
    `${user.firstName || ""} ${user.lastName || ""}`.trim() ||
    user.username
  );
}

function describeGroup(user: User): string {
  if (user.role === "STUDENT") {
    const className = user.className || "-";
    return user.gradeLevel
      ? `${className} • Stufe ${user.gradeLevel}`
      : className;
  }
  if (user.role === "TEACHER") return user.department || "-";
  return "-";
}

function formatDate(value?: string): string {
  return value ? new Date(value).toLocaleDateString(localeCode.value) : "-";
}

function canEdit(user: User): boolean {
  return user.role !== "ADMIN";
}

function openEdit(user: User) {
  editUser.value = user;
  editForm.username = user.username;
  editForm.email = user.email;
  editForm.firstName = user.firstName || "";
  editForm.lastName = user.lastName || "";
  editForm.studentId = user.studentId || "";
  editForm.className = user.className || "";
  editForm.gradeLevel = user.gradeLevel ?? null;
  editForm.canVote = user.canVote ?? true;
  editForm.employeeId = user.employeeId || "";
  editForm.department = user.department || "";
  editForm.subjects = user.subjects || "";
  editForm.adminLevel = user.adminLevel ?? 1;
  editOpen.value = true;
}

async function submitEdit() {
  if (!editUser.value) return;
  editSubmitting.value = true;
  try {
    const payload: UserUpdateRequest = {
      username: editForm.username.trim(),
      email: editForm.email.trim(),
      firstName: editForm.firstName.trim(),
      lastName: editForm.lastName.trim(),
    };
    if (editUser.value.role === "STUDENT") {
      payload.studentId = editForm.studentId.trim();
      payload.className = editForm.className.trim();
      payload.gradeLevel = editForm.gradeLevel ?? undefined;
      payload.canVote = editForm.canVote;
    } else if (editUser.value.role === "TEACHER") {
      payload.employeeId = editForm.employeeId.trim();
      payload.departmentTeacher = editForm.department.trim();
      payload.subjects = editForm.subjects.trim();
    } else if (editUser.value.role === "ADMIN") {
      payload.adminLevel = editForm.adminLevel;
      payload.department = editForm.department.trim();
    }
    const updated = await userApi.updateUser(editUser.value.id, payload);
    const index = users.value.findIndex((u) => u.id === updated.id);
    if (index !== -1) users.value[index] = updated;
    editOpen.value = false;
    uiStore.showToast({
      type: "success",
      message: t("adminUsers.updatedSuccess", { name: displayName(updated) }),
    });
  } catch (err: any) {
    uiStore.showToast({
      type: "error",
      message: err.response?.data?.message || t("adminUsers.updateFailed"),
    });
  } finally {
    editSubmitting.value = false;
  }
}

async function toggleActive(user: User) {
  togglingUserId.value = user.id;
  try {
    const updated = await userApi.updateActiveState(user.id, {
      active: !user.active,
    });
    const index = users.value.findIndex((entry) => entry.id === user.id);
    if (index !== -1) users.value[index] = updated;
    uiStore.showToast({
      type: "success",
      message: t("adminUsers.activeStateToast", {
        name: updated.fullName || updated.username,
        state: updated.active ? t("common.active") : t("common.inactive"),
      }),
    });
  } catch (err: any) {
    uiStore.showToast({
      type: "error",
      message: err.response?.data?.message || t("adminUsers.updateStateFailed"),
    });
  } finally {
    togglingUserId.value = null;
  }
}

function clearErrors(...keys: string[]) {
  for (const key of keys) delete errors[key];
}
function validateModeStep(): boolean {
  return true;
}
function validateRoleStep(): boolean {
  return (
    onboardingRole.value === "STUDENT" || onboardingRole.value === "TEACHER"
  );
}

function buildSingleUserRequest(): RegisterRequest {
  const base: RegisterRequest = {
    username: singleForm.username.trim(),
    email: singleForm.email.trim(),
    password: singleForm.password.trim(),
    firstName: singleForm.firstName.trim(),
    lastName: singleForm.lastName.trim(),
    role: onboardingRole.value,
  };
  if (onboardingRole.value === "STUDENT") {
    base.studentId = singleForm.studentId.trim();
    base.className = singleForm.className.trim();
    base.gradeLevel = singleForm.gradeLevel ?? undefined;
  } else {
    base.employeeId = singleForm.employeeId.trim();
    base.department = singleForm.department.trim() || undefined;
    base.subjects = singleForm.subjects.trim() || undefined;
  }
  return base;
}

function validateSingleForm(): boolean {
  clearErrors("single");
  const request = buildSingleUserRequest();
  if (
    !request.username ||
    !request.email ||
    !request.password ||
    !request.firstName ||
    !request.lastName
  ) {
    errors.single = t("adminUsers.completeRequiredFields");
    return false;
  }
  if (
    onboardingRole.value === "STUDENT" &&
    (!request.studentId || !request.className)
  ) {
    errors.single = t("adminUsers.studentRequiresIdClass");
    return false;
  }
  if (onboardingRole.value === "TEACHER" && !request.employeeId) {
    errors.single = t("adminUsers.teacherRequiresId");
    return false;
  }
  return true;
}

function detectDelimiter(line: string): string {
  const candidates = [",", ";", "\t"];
  let bestDelimiter = ",";
  let bestScore = -1;
  for (const delimiter of candidates) {
    const score = line.split(delimiter).length;
    if (score > bestScore) {
      bestDelimiter = delimiter;
      bestScore = score;
    }
  }
  return bestDelimiter;
}

function parseImportedUsers(
  text: string,
  role: ManagedRole,
): { users: RegisterRequest[]; errors: string[] } {
  const trimmed = text.trim();
  if (!trimmed) return { users: [], errors: [] };
  const lines = trimmed
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);
  if (lines.length === 0) return { users: [], errors: [] };
  const delimiter = detectDelimiter(lines[0]);
  const lowerHeader = lines[0].toLowerCase();
  const skipHeader =
    lowerHeader.includes("username") && lowerHeader.includes("email");
  const dataLines = skipHeader ? lines.slice(1) : lines;
  const users: RegisterRequest[] = [];
  const importErrors: string[] = [];
  dataLines.forEach((line, index) => {
    const columns = line.split(delimiter).map((column) => column.trim());
    const rowNumber = skipHeader ? index + 2 : index + 1;
    if (role === "STUDENT") {
      if (columns.length < 7) {
        importErrors.push(
          t("adminUsers.rowMinimumStudent", { row: rowNumber }),
        );
        return;
      }
      const [
        username,
        email,
        password,
        firstName,
        lastName,
        studentId,
        className,
        gradeLevel,
      ] = columns;
      if (
        !username ||
        !email ||
        !password ||
        !firstName ||
        !lastName ||
        !studentId ||
        !className
      ) {
        importErrors.push(
          t("adminUsers.rowMissingStudent", { row: rowNumber }),
        );
        return;
      }
      users.push({
        username,
        email,
        password,
        firstName,
        lastName,
        role: "STUDENT",
        studentId,
        className,
        gradeLevel: gradeLevel ? Number(gradeLevel) : undefined,
      });
      return;
    }
    if (columns.length < 6) {
      importErrors.push(t("adminUsers.rowMinimumTeacher", { row: rowNumber }));
      return;
    }
    const [
      username,
      email,
      password,
      firstName,
      lastName,
      employeeId,
      department,
      subjects,
    ] = columns;
    if (
      !username ||
      !email ||
      !password ||
      !firstName ||
      !lastName ||
      !employeeId
    ) {
      importErrors.push(t("adminUsers.rowMissingTeacher", { row: rowNumber }));
      return;
    }
    users.push({
      username,
      email,
      password,
      firstName,
      lastName,
      role: "TEACHER",
      employeeId,
      department: department || undefined,
      subjects: subjects || undefined,
    });
  });
  return { users, errors: importErrors };
}

function validateDetailsStep(): boolean {
  clearErrors("single", "importText");
  if (importMode.value === "single") return validateSingleForm();
  if (!importText.value.trim()) {
    errors.importText = t("adminUsers.pasteOrUpload");
    return false;
  }
  if (
    parsedImport.value.errors.length > 0 ||
    parsedImport.value.users.length === 0
  ) {
    errors.importText =
      parsedImport.value.errors[0] || t("adminUsers.noValidRows");
    return false;
  }
  return true;
}

function validateStep(stepId = currentStepId.value): boolean {
  switch (stepId) {
    case "mode":
      return validateModeStep();
    case "role":
      return validateRoleStep();
    case "details":
    case "review":
      return validateDetailsStep();
    default:
      return true;
  }
}

function selectStep(stepId: string) {
  const targetIndex = wizardSteps.value.findIndex((step) => step.id === stepId);
  if (targetIndex === -1) return;
  if (targetIndex > currentStepIndex.value && !validateStep()) {
    uiStore.showToast({
      type: "error",
      message: t("wizard.completeCurrentStep"),
    });
    return;
  }
  if (targetIndex > currentStepIndex.value) markStepComplete();
  goToStep(stepId);
}

function goToNextStepWithValidation() {
  if (!validateStep()) {
    uiStore.showToast({
      type: "error",
      message: t("wizard.fixHighlightedIssues"),
    });
    return;
  }
  markStepComplete();
  goToNextStep();
}

async function handleCsvUpload(event: Event) {
  const input = event.target as HTMLInputElement;
  const file = input.files?.[0];
  if (!file) return;
  importText.value = await file.text();
}

async function submitWizard() {
  const allStepsValid = wizardSteps.value.every((step) =>
    validateStep(step.id),
  );
  if (!allStepsValid) {
    uiStore.showToast({ type: "error", message: t("wizard.completeWizard") });
    return;
  }
  const payload = reviewUsers.value;
  submitting.value = true;
  try {
    if (importMode.value === "single") {
      if (onboardingRole.value === "STUDENT")
        await userApi.createStudent(payload[0]);
      else await userApi.createTeacher(payload[0]);
    } else if (onboardingRole.value === "STUDENT")
      await userApi.createStudentsBatch(payload);
    else await userApi.createTeachersBatch(payload);
    await loadUsers();
    closeWizard();
    uiStore.showToast({
      type: "success",
      message:
        payload.length === 1
          ? t("adminUsers.singleCreated", {
              role:
                onboardingRole.value === "STUDENT"
                  ? t("roles.STUDENT")
                  : t("roles.TEACHER"),
            })
          : t("adminUsers.importedSuccess", { count: payload.length }),
    });
  } catch (err: any) {
    uiStore.showToast({
      type: "error",
      message: err.response?.data?.message || t("adminUsers.createFailed"),
    });
  } finally {
    submitting.value = false;
  }
}

onMounted(() => {
  uiStore.setBreadcrumbs([
    { label: t("nav.dashboard"), route: "/admin/dashboard" },
    { label: t("nav.users") },
  ]);
  uiStore.setPageTitle(t("adminUsers.title"));
  resetSingleForm();
  loadUsers();
});
</script>

<style scoped>
.admin-users {
  max-width: 1300px;
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
  color: var(--color-text, #1a202c);
}
.subtitle {
  margin: 0;
  color: var(--color-text-muted, #718096);
}
.summary-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 1rem;
  margin-bottom: 1.5rem;
}
.summary-card {
  background: var(--color-surface, #ffffff);
  border-radius: 12px;
  padding: 1rem 1.2rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}
.summary-card strong {
  font-size: 1.5rem;
  color: var(--color-text, #1a202c);
}
.summary-card span {
  color: var(--color-text-muted, #718096);
}
.toolbar {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  margin-bottom: 1rem;
}
.filter-group,
.toolbar-actions {
  display: flex;
  gap: 0.75rem;
  align-items: center;
  flex-wrap: wrap;
}
.filter-btn {
  padding: 0.45rem 0.9rem;
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 999px;
  background: white;
  cursor: pointer;
}
.filter-btn.active {
  background: var(--color-primary, #667eea);
  border-color: var(--color-primary, #667eea);
  color: white;
}
.status-select,
.search-input,
.form-group input,
.form-group textarea,
.import-textarea,
.form-group select {
  border: 1.5px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  padding: 0.7rem 0.9rem;
  font-size: 0.95rem;
  font-family: inherit;
}
.search-input {
  min-width: 280px;
}
.users-table {
  background: var(--color-surface, #ffffff);
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}
table {
  width: 100%;
  border-collapse: collapse;
}
th,
td {
  padding: 0.9rem 1rem;
  border-bottom: 1px solid var(--color-border, #e2e8f0);
  text-align: left;
  font-size: 0.92rem;
}
th {
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--color-text-muted, #718096);
  background: #f8fafc;
}
.name-cell {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}
.name-cell small {
  color: var(--color-text-muted, #718096);
}
.role-badge,
.status-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.65rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 700;
}
.role-badge.student {
  background: #ebf8ff;
  color: #2b6cb0;
}
.role-badge.teacher {
  background: #faf5ff;
  color: #6b46c1;
}
.role-badge.admin {
  background: #fef3c7;
  color: #92400e;
}
.status-badge {
  background: #c6f6d5;
  color: #276749;
}
.status-badge.inactive {
  background: #fed7d7;
  color: #9b2c2c;
}
.loading-state,
.error-state {
  padding: 2rem;
  text-align: center;
}
.error-state {
  color: var(--color-danger, #e53e3e);
}
.actions-cell {
  display: flex;
  gap: 0.25rem;
}
.wizard-header-copy {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  align-items: flex-start;
}
.wizard-header-copy h2 {
  margin: 0 0 0.35rem 0;
}
.wizard-header-copy p {
  margin: 0;
  color: var(--color-text-muted, #718096);
}
.step-counter {
  color: var(--color-text-muted, #718096);
  font-size: 0.85rem;
  font-weight: 600;
}
.wizard-card-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1rem;
}
.mode-card {
  text-align: left;
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 14px;
  background: white;
  padding: 1rem;
  cursor: pointer;
}
.mode-card.active {
  border-color: var(--color-primary, #667eea);
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.12);
}
.mode-card.disabled {
  opacity: 0.6;
  cursor: not-allowed;
  background: #f9fafb;
}
.mode-card.disabled strong,
.mode-card.disabled p {
  color: #9ca3af;
}
.mode-card p {
  margin: 0.4rem 0 0 0;
  color: var(--color-text-muted, #718096);
}
.role-disabled-hint {
  margin-top: 0.75rem;
  padding: 0.5rem;
  background: #fef3c7;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
  font-size: 0.85rem;
  color: #92400e;
}
.hint-icon {
  font-size: 1rem;
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
}
.import-toolbar {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  align-items: flex-start;
  margin-bottom: 1rem;
}
.import-hint p {
  margin: 0.35rem 0 0 0;
  color: var(--color-text-muted, #718096);
}
.file-input {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  padding: 0.7rem 1rem;
  cursor: pointer;
}
.file-input input {
  display: none;
}
.import-textarea {
  width: 100%;
  min-height: 280px;
  resize: vertical;
}
.preview-note,
.field-error,
.single-form .field-error {
  display: block;
  margin-top: 0.6rem;
}
.field-error {
  color: var(--color-danger, #e53e3e);
  font-size: 0.82rem;
}
.review-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}
.review-card,
.review-list-card {
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 14px;
  padding: 1rem;
}
.review-card h3,
.review-list-card h3 {
  margin: 0 0 0.6rem 0;
}
.review-card p,
.preview-more {
  margin: 0;
  color: var(--color-text-muted, #718096);
}
.preview-table {
  width: 100%;
  border-collapse: collapse;
}
.preview-table th,
.preview-table td {
  padding: 0.7rem 0.8rem;
}
.edit-form {
  padding: 0.5rem;
}
.edit-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  margin-top: 1.5rem;
}

/* Export Modal Styles */
.export-modal {
  padding: 0.5rem;
}
.export-section {
  margin-bottom: 1.5rem;
}
.export-section h3 {
  margin: 0 0 0.75rem 0;
  font-size: 1rem;
  color: #1a202c;
}
.export-options {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}
.export-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  background: #f8fafc;
  border-radius: 8px;
  cursor: pointer;
  border: 2px solid transparent;
  transition: all 0.2s;
}
.export-option:hover {
  border-color: #667eea;
}
.export-option input {
  cursor: pointer;
}
.field-selector {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}
.available-fields,
.selected-fields {
  background: #f8fafc;
  border-radius: 10px;
  padding: 1rem;
  border: 1px solid #e2e8f0;
}
.available-fields h4,
.selected-fields h4 {
  margin: 0 0 0.75rem 0;
  font-size: 0.85rem;
  color: #4a5568;
  text-transform: uppercase;
}
.field-list {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  max-height: 250px;
  overflow-y: auto;
}
.field-item {
  padding: 0.5rem 0.75rem;
  background: white;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.15s;
  border: 1px solid #e2e8f0;
}
.field-item:hover {
  background: #edf2f7;
  border-color: #667eea;
}
.field-item.selected {
  background: #e0e7ff;
  border-color: #667eea;
  color: #3730a3;
}
.export-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid #e2e8f0;
}
@media (max-width: 980px) {
  .summary-grid,
  .review-grid,
  .wizard-card-grid,
  .form-grid {
    grid-template-columns: 1fr;
  }
  .toolbar,
  .import-toolbar,
  .wizard-header-copy,
  .header {
    flex-direction: column;
  }
  .search-input {
    min-width: 0;
    width: 100%;
  }
}
</style>
