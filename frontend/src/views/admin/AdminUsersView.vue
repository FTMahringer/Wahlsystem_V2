<template>
  <div class="admin-users">
    <div class="header">
      <div>
        <h1>Users</h1>
        <p class="subtitle">
          Manage students and teachers, then onboard new users through the shared wizard flow.
        </p>
      </div>
      <BaseButton @click="openWizard">➕ Add Users</BaseButton>
    </div>

    <div class="summary-grid">
      <div class="summary-card">
        <strong>{{ users.length }}</strong>
        <span>Total</span>
      </div>
      <div class="summary-card">
        <strong>{{ users.filter((user) => user.role === 'STUDENT').length }}</strong>
        <span>Students</span>
      </div>
      <div class="summary-card">
        <strong>{{ users.filter((user) => user.role === 'TEACHER').length }}</strong>
        <span>Teachers</span>
      </div>
      <div class="summary-card">
        <strong>{{ users.filter((user) => user.active).length }}</strong>
        <span>Active</span>
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
          <option value="ALL">All statuses</option>
          <option value="ACTIVE">Active only</option>
          <option value="INACTIVE">Inactive only</option>
        </select>

        <input
          v-model="search"
          type="search"
          class="search-input"
          placeholder="Search by name, username, or email"
          @keyup.enter="loadUsers"
        />

        <BaseButton variant="secondary" @click="loadUsers">Refresh</BaseButton>
      </div>
    </div>

    <div v-if="loading" class="loading-state">Loading users...</div>

    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <BaseButton @click="loadUsers">Retry</BaseButton>
    </div>

    <BaseEmptyState
      v-else-if="users.length === 0"
      title="No users found"
      message="Create the first students or teachers with the onboarding wizard."
      icon="👥"
    />

    <div v-else class="users-table">
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Role</th>
            <th>Username</th>
            <th>Email</th>
            <th>Group</th>
            <th>Status</th>
            <th>Created</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in users" :key="user.id">
            <td>
              <div class="name-cell">
                <strong>{{ user.fullName || `${user.firstName || ''} ${user.lastName || ''}`.trim() || user.username }}</strong>
                <small v-if="user.role === 'STUDENT' && user.studentId">ID: {{ user.studentId }}</small>
                <small v-else-if="user.role === 'TEACHER' && user.employeeId">ID: {{ user.employeeId }}</small>
              </div>
            </td>
            <td>
              <span class="role-badge" :class="user.role.toLowerCase()">
                {{ user.role }}
              </span>
            </td>
            <td>{{ user.username }}</td>
            <td>{{ user.email }}</td>
            <td>{{ describeGroup(user) }}</td>
            <td>
              <span class="status-badge" :class="{ inactive: !user.active }">
                {{ user.active ? "Active" : "Inactive" }}
              </span>
            </td>
            <td>{{ formatDate(user.createdAt) }}</td>
            <td>
              <BaseButton
                size="sm"
                variant="ghost"
                :loading="togglingUserId === user.id"
                @click="toggleActive(user)"
              >
                {{ user.active ? "Deactivate" : "Activate" }}
              </BaseButton>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <BaseDialog
      :open="wizardOpen"
      title="User onboarding wizard"
      size="lg"
      @update:open="handleDialogState"
    >
      <WizardShell>
        <template #header>
          <div class="wizard-header-copy">
            <div>
              <h2>{{ currentStep?.title }}</h2>
              <p v-if="currentStep?.description">{{ currentStep.description }}</p>
            </div>
            <span class="step-counter">
              Step {{ currentStepIndex + 1 }} / {{ wizardSteps.length }}
            </span>
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
              :class="{ active: onboardingRole === role.value }"
              @click="onboardingRole = role.value"
            >
              <strong>{{ role.label }}</strong>
              <p>{{ role.description }}</p>
            </button>
          </div>
        </WizardStepPanel>

        <WizardStepPanel :active="currentStepId === 'details'">
          <div v-if="importMode === 'single'" class="single-form">
            <div class="form-grid">
              <div class="form-group">
                <label>Username *</label>
                <input v-model="singleForm.username" type="text" />
              </div>
              <div class="form-group">
                <label>Email *</label>
                <input v-model="singleForm.email" type="email" />
              </div>
              <div class="form-group">
                <label>Password *</label>
                <input v-model="singleForm.password" type="text" />
              </div>
              <div class="form-group">
                <label>First Name *</label>
                <input v-model="singleForm.firstName" type="text" />
              </div>
              <div class="form-group">
                <label>Last Name *</label>
                <input v-model="singleForm.lastName" type="text" />
              </div>

              <template v-if="onboardingRole === 'STUDENT'">
                <div class="form-group">
                  <label>Student ID *</label>
                  <input v-model="singleForm.studentId" type="text" />
                </div>
                <div class="form-group">
                  <label>Class *</label>
                  <input v-model="singleForm.className" type="text" placeholder="e.g. 10A" />
                </div>
                <div class="form-group">
                  <label>Grade</label>
                  <input v-model.number="singleForm.gradeLevel" type="number" min="1" />
                </div>
              </template>

              <template v-else>
                <div class="form-group">
                  <label>Employee ID *</label>
                  <input v-model="singleForm.employeeId" type="text" />
                </div>
                <div class="form-group">
                  <label>Department</label>
                  <input v-model="singleForm.department" type="text" />
                </div>
                <div class="form-group full-width">
                  <label>Subjects</label>
                  <input v-model="singleForm.subjects" type="text" placeholder="Math, Physics" />
                </div>
              </template>
            </div>
          </div>

          <div v-else class="bulk-import">
            <div class="import-toolbar">
              <div class="import-hint">
                <strong>{{ importMode === 'csv' ? 'CSV import' : 'Bulk paste' }}</strong>
                <p>{{ importHint }}</p>
              </div>
              <label v-if="importMode === 'csv'" class="file-input">
                <input type="file" accept=".csv,text/csv,.txt" @change="handleCsvUpload" />
                Choose file
              </label>
            </div>

            <textarea
              v-model="importText"
              rows="12"
              class="import-textarea"
              :placeholder="importPlaceholder"
            />

            <div class="preview-note">
              Parsed rows: <strong>{{ parsedImport.users.length }}</strong>
              <span v-if="parsedImport.errors.length > 0" class="field-error">
                • {{ parsedImport.errors.length }} issue(s) need to be fixed
              </span>
            </div>

            <span v-if="errors.importText" class="field-error">{{ errors.importText }}</span>
          </div>
        </WizardStepPanel>

        <WizardStepPanel :active="currentStepId === 'review'">
          <div class="review-grid">
            <div class="review-card">
              <h3>Import mode</h3>
              <p>{{ currentImportMode.label }}</p>
            </div>
            <div class="review-card">
              <h3>Role</h3>
              <p>{{ onboardingRole }}</p>
            </div>
            <div class="review-card">
              <h3>Entries</h3>
              <p>{{ reviewUsers.length }}</p>
            </div>
            <div class="review-card">
              <h3>Expected result</h3>
              <p>Create {{ reviewUsers.length }} {{ onboardingRole === 'STUDENT' ? 'student(s)' : 'teacher(s)' }}</p>
            </div>
          </div>

          <div class="review-list-card">
            <h3>Preview</h3>
            <table class="preview-table">
              <thead>
                <tr>
                  <th>Username</th>
                  <th>Name</th>
                  <th>Email</th>
                  <th>{{ onboardingRole === 'STUDENT' ? 'Class' : 'Department' }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="user in reviewUsers.slice(0, 8)" :key="`${user.username}-${user.email}`">
                  <td>{{ user.username }}</td>
                  <td>{{ user.firstName }} {{ user.lastName }}</td>
                  <td>{{ user.email }}</td>
                  <td>{{ onboardingRole === 'STUDENT' ? user.className || '—' : user.department || '—' }}</td>
                </tr>
              </tbody>
            </table>
            <p v-if="reviewUsers.length > 8" class="preview-more">
              Showing the first 8 entries.
            </p>
          </div>
        </WizardStepPanel>

        <template #actions>
          <WizardActions
            :is-first-step="isFirstStep"
            :is-last-step="isLastStep"
            :submitting="submitting"
            submit-label="Create users"
            @back="goToPreviousStep"
            @next="goToNextStepWithValidation"
            @submit="submitWizard"
          >
            <template #secondary>
              <BaseButton variant="ghost" :disabled="submitting" @click="closeWizard">
                Cancel
              </BaseButton>
            </template>
          </WizardActions>
        </template>
      </WizardShell>
    </BaseDialog>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from "vue";
import {
  userApi,
} from "@/api";
import BaseButton from "@/components/common/BaseButton.vue";
import BaseDialog from "@/components/common/BaseDialog.vue";
import BaseEmptyState from "@/components/common/BaseEmptyState.vue";
import WizardActions from "@/components/common/wizard/WizardActions.vue";
import WizardShell from "@/components/common/wizard/WizardShell.vue";
import WizardStepNav from "@/components/common/wizard/WizardStepNav.vue";
import WizardStepPanel from "@/components/common/wizard/WizardStepPanel.vue";
import { useWizard, type WizardStepDefinition } from "@/composables/useWizard";
import { useUiStore } from "@/stores/uiStore";
import type { ManagedUserFilters, RegisterRequest, User } from "@/types";

type ManagedRole = "STUDENT" | "TEACHER";
type ImportMode = "single" | "bulk" | "csv";
type RoleFilter = "ALL" | ManagedRole;
type ActiveFilter = "ALL" | "ACTIVE" | "INACTIVE";

const uiStore = useUiStore();

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

const roleFilters = [
  { label: "All", value: "ALL" as const },
  { label: "Students", value: "STUDENT" as const },
  { label: "Teachers", value: "TEACHER" as const },
];

const importModes = [
  {
    value: "single" as const,
    label: "Single create",
    description: "Create one user with a guided form.",
  },
  {
    value: "bulk" as const,
    label: "Bulk paste",
    description: "Paste multiple rows at once from a spreadsheet or text list.",
  },
  {
    value: "csv" as const,
    label: "CSV import",
    description: "Upload a CSV file and preview the imported users before saving.",
  },
];

const managedRoles = [
  {
    value: "STUDENT" as const,
    label: "Students",
    description: "Ideal for class-based election access and voter targeting.",
  },
  {
    value: "TEACHER" as const,
    label: "Teachers",
    description: "Create staff accounts that can manage elections and groups.",
  },
];

const wizardSteps = ref<WizardStepDefinition[]>([
  {
    id: "mode",
    title: "Import mode",
    description: "Choose how the users should be created.",
  },
  {
    id: "role",
    title: "Role",
    description: "Select whether you are onboarding students or teachers.",
  },
  {
    id: "details",
    title: "Details",
    description: "Enter the user information or paste/import the rows.",
  },
  {
    id: "review",
    title: "Review",
    description: "Check the preview before the users are created.",
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
    targetIndex <= currentIndex || completedStepIds.value.includes(wizardSteps.value[targetIndex].id),
});

const currentImportMode = computed(
  () => importModes.find((mode) => mode.value === importMode.value) ?? importModes[0],
);

const importHint = computed(() =>
  onboardingRole.value === "STUDENT"
    ? "Use the order: username, email, password, firstName, lastName, studentId, className, gradeLevel"
    : "Use the order: username, email, password, firstName, lastName, employeeId, department, subjects",
);

const importPlaceholder = computed(() =>
  onboardingRole.value === "STUDENT"
    ? "username,email,password,firstName,lastName,studentId,className,gradeLevel\njdoe,jdoe@example.com,secret123,Jane,Doe,S-001,10A,10"
    : "username,email,password,firstName,lastName,employeeId,department,subjects\ntsmith,tsmith@example.com,secret123,Tom,Smith,T-015,Science,Math;Physics",
);

const parsedImport = computed(() => parseImportedUsers(importText.value, onboardingRole.value));

const reviewUsers = computed<RegisterRequest[]>(() =>
  importMode.value === "single" ? [buildSingleUserRequest()] : parsedImport.value.users,
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

function openWizard() {
  resetWizard();
  wizardOpen.value = true;
}

function closeWizard() {
  wizardOpen.value = false;
}

function handleDialogState(open: boolean) {
  wizardOpen.value = open;
  if (!open) {
    resetWizard();
  }
}

function setRoleFilter(value: RoleFilter) {
  roleFilter.value = value;
  loadUsers();
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
    error.value = err.response?.data?.message || "Failed to load users.";
  } finally {
    loading.value = false;
  }
}

function describeGroup(user: User): string {
  if (user.role === "STUDENT") {
    const className = user.className || "—";
    return user.gradeLevel ? `${className} • Grade ${user.gradeLevel}` : className;
  }

  if (user.role === "TEACHER") {
    return user.department || "—";
  }

  return "—";
}

function formatDate(value?: string): string {
  return value ? new Date(value).toLocaleDateString("de-DE") : "—";
}

async function toggleActive(user: User) {
  togglingUserId.value = user.id;
  try {
    const updated = await userApi.updateActiveState(user.id, { active: !user.active });
    const index = users.value.findIndex((entry) => entry.id === user.id);
    if (index !== -1) {
      users.value[index] = updated;
    }
    uiStore.showToast({
      type: "success",
      message: `${updated.fullName || updated.username} is now ${updated.active ? "active" : "inactive"}.`,
    });
  } catch (err: any) {
    uiStore.showToast({
      type: "error",
      message: err.response?.data?.message || "Failed to update the user state.",
    });
  } finally {
    togglingUserId.value = null;
  }
}

function clearErrors(...keys: string[]) {
  for (const key of keys) {
    delete errors[key];
  }
}

function validateModeStep(): boolean {
  return true;
}

function validateRoleStep(): boolean {
  return onboardingRole.value === "STUDENT" || onboardingRole.value === "TEACHER";
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
    errors.single = "Complete the required user fields before continuing.";
    return false;
  }

  if (onboardingRole.value === "STUDENT" && (!request.studentId || !request.className)) {
    errors.single = "Student onboarding requires a student ID and a class.";
    return false;
  }

  if (onboardingRole.value === "TEACHER" && !request.employeeId) {
    errors.single = "Teacher onboarding requires an employee ID.";
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

function parseImportedUsers(text: string, role: ManagedRole): { users: RegisterRequest[]; errors: string[] } {
  const trimmed = text.trim();
  if (!trimmed) {
    return { users: [], errors: [] };
  }

  const lines = trimmed
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);

  if (lines.length === 0) {
    return { users: [], errors: [] };
  }

  const delimiter = detectDelimiter(lines[0]);
  const lowerHeader = lines[0].toLowerCase();
  const skipHeader = lowerHeader.includes("username") && lowerHeader.includes("email");
  const dataLines = skipHeader ? lines.slice(1) : lines;

  const users: RegisterRequest[] = [];
  const importErrors: string[] = [];

  dataLines.forEach((line, index) => {
    const columns = line.split(delimiter).map((column) => column.trim());
    const rowNumber = skipHeader ? index + 2 : index + 1;

    if (role === "STUDENT") {
      if (columns.length < 7) {
        importErrors.push(`Row ${rowNumber} must contain at least 7 columns.`);
        return;
      }

      const [username, email, password, firstName, lastName, studentId, className, gradeLevel] = columns;
      if (!username || !email || !password || !firstName || !lastName || !studentId || !className) {
        importErrors.push(`Row ${rowNumber} is missing a required student field.`);
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
      importErrors.push(`Row ${rowNumber} must contain at least 6 columns.`);
      return;
    }

    const [username, email, password, firstName, lastName, employeeId, department, subjects] = columns;
    if (!username || !email || !password || !firstName || !lastName || !employeeId) {
      importErrors.push(`Row ${rowNumber} is missing a required teacher field.`);
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

  if (importMode.value === "single") {
    return validateSingleForm();
  }

  if (!importText.value.trim()) {
    errors.importText = "Paste or upload at least one row before continuing.";
    return false;
  }

  if (parsedImport.value.errors.length > 0 || parsedImport.value.users.length === 0) {
    errors.importText = parsedImport.value.errors[0] || "No valid import rows were found.";
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
  if (targetIndex === -1) {
    return;
  }

  if (targetIndex > currentStepIndex.value && !validateStep()) {
    uiStore.showToast({ type: "error", message: "Complete the current step before moving on." });
    return;
  }

  if (targetIndex > currentStepIndex.value) {
    markStepComplete();
  }

  goToStep(stepId);
}

function goToNextStepWithValidation() {
  if (!validateStep()) {
    uiStore.showToast({ type: "error", message: "Please fix the highlighted issues first." });
    return;
  }

  markStepComplete();
  goToNextStep();
}

async function handleCsvUpload(event: Event) {
  const input = event.target as HTMLInputElement;
  const file = input.files?.[0];
  if (!file) {
    return;
  }

  importText.value = await file.text();
}

async function submitWizard() {
  const allStepsValid = wizardSteps.value.every((step) => validateStep(step.id));
  if (!allStepsValid) {
    uiStore.showToast({ type: "error", message: "Complete the wizard before submitting." });
    return;
  }

  const payload = reviewUsers.value;
  submitting.value = true;

  try {
    if (importMode.value === "single") {
      if (onboardingRole.value === "STUDENT") {
        await userApi.createStudent(payload[0]);
      } else {
        await userApi.createTeacher(payload[0]);
      }
    } else if (onboardingRole.value === "STUDENT") {
      await userApi.createStudentsBatch(payload);
    } else {
      await userApi.createTeachersBatch(payload);
    }

    await loadUsers();
    closeWizard();
    uiStore.showToast({
      type: "success",
      message:
        payload.length === 1
          ? `${onboardingRole.value === "STUDENT" ? "Student" : "Teacher"} created successfully.`
          : `${payload.length} users imported successfully.`,
    });
  } catch (err: any) {
    uiStore.showToast({
      type: "error",
      message: err.response?.data?.message || "Failed to create the users.",
    });
  } finally {
    submitting.value = false;
  }
}

onMounted(() => {
  uiStore.setBreadcrumbs([
    { label: "Dashboard", route: "/admin/dashboard" },
    { label: "Users" },
  ]);
  uiStore.setPageTitle("Users");
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
.import-textarea {
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

.mode-card p {
  margin: 0.4rem 0 0 0;
  color: var(--color-text-muted, #718096);
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
