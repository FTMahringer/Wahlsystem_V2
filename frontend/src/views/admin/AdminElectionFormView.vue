<template>
  <div class="election-form-view">
    <div class="page-header">
      <h1>{{ isEdit ? "Edit Election" : "Create Election" }}</h1>
      <p class="page-subtitle">
        Configure the election in guided steps so the rules, candidates, and schedule stay in sync.
      </p>
    </div>

    <div v-if="loadingElection" class="loading">Loading election...</div>

    <WizardShell v-else>
      <template #header>
        <div class="wizard-header-copy">
          <div>
            <h2>{{ currentStep?.title }}</h2>
            <p v-if="currentStep?.description">{{ currentStep.description }}</p>
          </div>
          <span class="step-counter">
            Step {{ currentStepIndex + 1 }} / {{ steps.length }}
          </span>
        </div>
      </template>

      <template #nav>
        <WizardStepNav
          :steps="steps"
          :current-step-id="currentStepId"
          :completed-step-ids="completedStepIds"
          @select="handleStepSelect"
        />
      </template>

      <WizardStepPanel :active="currentStepId === 'basics'">
        <div class="form-grid">
          <div class="form-group">
            <label for="title">Title *</label>
            <input
              id="title"
              v-model="form.title"
              type="text"
              placeholder="Election title"
              :disabled="submitting"
            />
            <span v-if="errors.title" class="field-error">{{ errors.title }}</span>
          </div>

          <div class="form-group full-width">
            <label for="description">Description</label>
            <textarea
              id="description"
              v-model="form.description"
              rows="5"
              placeholder="Describe the election..."
              :disabled="submitting"
            />
          </div>
        </div>
      </WizardStepPanel>

      <WizardStepPanel :active="currentStepId === 'type'">
        <div class="type-grid">
          <button
            v-for="option in electionTypeOptions"
            :key="option"
            type="button"
            class="type-card"
            :class="{ active: form.type === option }"
            @click="selectElectionType(option)"
          >
            <div class="type-card-header">
              <strong>{{ getElectionTypeDefinition(option).label }}</strong>
              <span class="type-card-badge">
                {{ getElectionTypeDefinition(option).resultMetricLabel }}
              </span>
            </div>
            <p>{{ getElectionTypeDefinition(option).description }}</p>
            <small>{{ getElectionTypeDefinition(option).helperText }}</small>
          </button>
        </div>

        <div class="type-config">
          <div v-if="selectedType.requiresMaxSelections" class="form-group compact">
            <label for="maxSelections">Maximum selections *</label>
            <input
              id="maxSelections"
              v-model.number="form.maxSelections"
              type="number"
              min="1"
              placeholder="e.g. 2"
              :disabled="submitting"
            />
            <span v-if="errors.maxSelections" class="field-error">
              {{ errors.maxSelections }}
            </span>
          </div>

          <div class="type-hints">
            <p v-if="form.type === 'BINARY_CHOICE'">
              Binary choice elections must contain exactly two candidates.
            </p>
            <p v-else-if="form.type === 'BORDA_COUNT'">
              Voters will rank all candidates and results are counted as points.
            </p>
            <p v-else-if="form.type === 'APPROVAL_VOTING'">
              Voters can approve any number of candidates.
            </p>
            <p v-else-if="form.type === 'LIMITED_VOTE'">
              Voters can choose up to the configured number of candidates.
            </p>
            <p v-else>
              Voters choose exactly one candidate.
            </p>
          </div>
        </div>
      </WizardStepPanel>

      <WizardStepPanel :active="currentStepId === 'candidates'">
        <div class="candidate-step-header">
          <div>
            <h3>Candidates</h3>
            <p>
              Add the people or options that should appear on the ballot.
            </p>
          </div>
          <BaseButton variant="secondary" @click="addCandidate">
            + Add Candidate
          </BaseButton>
        </div>

        <div v-if="candidateDrafts.length === 0" class="candidate-empty">
          No candidates yet. Add at least two to continue.
        </div>

        <div v-else class="candidate-drafts">
          <div
            v-for="(candidate, index) in candidateDrafts"
            :key="candidate.tempId"
            class="candidate-draft"
          >
            <div class="candidate-draft-header">
              <strong>Candidate {{ index + 1 }}</strong>
              <BaseButton
                variant="ghost"
                size="sm"
                :disabled="submitting"
                @click="removeCandidate(candidate.tempId)"
              >
                Remove
              </BaseButton>
            </div>

            <div class="form-grid">
              <div class="form-group">
                <label>First Name *</label>
                <input v-model="candidate.firstName" type="text" :disabled="submitting" />
              </div>
              <div class="form-group">
                <label>Last Name *</label>
                <input v-model="candidate.lastName" type="text" :disabled="submitting" />
              </div>
              <div class="form-group">
                <label>Class</label>
                <input
                  v-model="candidate.className"
                  type="text"
                  placeholder="e.g. 10A"
                  :disabled="submitting"
                />
              </div>
              <div class="form-group full-width">
                <label>Description</label>
                <textarea
                  v-model="candidate.description"
                  rows="3"
                  placeholder="Short description..."
                  :disabled="submitting"
                />
              </div>
            </div>
          </div>
        </div>

        <span v-if="errors.candidates" class="field-error">{{ errors.candidates }}</span>
      </WizardStepPanel>

      <WizardStepPanel :active="currentStepId === 'schedule'">
        <div class="form-grid schedule-grid">
          <div class="form-group">
            <label for="startAt">Start Date</label>
            <input
              id="startAt"
              v-model="form.startAt"
              type="datetime-local"
              :disabled="submitting"
            />
          </div>

          <div class="form-group">
            <label for="endAt">End Date</label>
            <input
              id="endAt"
              v-model="form.endAt"
              type="datetime-local"
              :disabled="submitting"
            />
            <span v-if="errors.endAt" class="field-error">{{ errors.endAt }}</span>
          </div>
        </div>

        <div class="schedule-note">
          <p>
            Saving as draft keeps the election hidden. Publishing sets the status automatically:
            future dates become <strong>planned</strong>, otherwise the election becomes
            <strong>active</strong>.
          </p>
        </div>
      </WizardStepPanel>

      <WizardStepPanel :active="currentStepId === 'review'">
        <div class="review-grid">
          <div class="review-card">
            <h3>Basics</h3>
            <dl>
              <div>
                <dt>Title</dt>
                <dd>{{ form.title || "—" }}</dd>
              </div>
              <div>
                <dt>Description</dt>
                <dd>{{ form.description || "—" }}</dd>
              </div>
            </dl>
          </div>

          <div class="review-card">
            <h3>Election Type</h3>
            <dl>
              <div>
                <dt>Type</dt>
                <dd>{{ selectedType.label }}</dd>
              </div>
              <div v-if="form.type === 'LIMITED_VOTE'">
                <dt>Selection limit</dt>
                <dd>{{ form.maxSelections }}</dd>
              </div>
              <div>
                <dt>Result metric</dt>
                <dd>{{ selectedType.resultMetricLabel }}</dd>
              </div>
            </dl>
          </div>

          <div class="review-card">
            <h3>Candidates</h3>
            <ul class="review-list">
              <li v-for="candidate in candidateDrafts" :key="candidate.tempId">
                {{ candidate.firstName }} {{ candidate.lastName }}
                <small v-if="candidate.className">({{ candidate.className }})</small>
              </li>
            </ul>
          </div>

          <div class="review-card">
            <h3>Schedule</h3>
            <dl>
              <div>
                <dt>Start</dt>
                <dd>{{ formatDateTime(form.startAt) }}</dd>
              </div>
              <div>
                <dt>End</dt>
                <dd>{{ formatDateTime(form.endAt) }}</dd>
              </div>
              <div>
                <dt>Publish outcome</dt>
                <dd>{{ publishOutcomeLabel }}</dd>
              </div>
            </dl>
          </div>
        </div>
      </WizardStepPanel>

      <template #actions>
        <WizardActions
          :is-first-step="isFirstStep"
          :is-last-step="isLastStep"
          :submitting="submitting"
          :submit-label="isEdit ? 'Save and Publish' : 'Create and Publish'"
          @back="goToPreviousStep"
          @next="goToNextStepWithValidation"
          @submit="handleSubmit('publish')"
        >
          <template v-if="isLastStep" #secondary>
            <BaseButton
              variant="secondary"
              :disabled="submitting"
              @click="handleSubmit('draft')"
            >
              {{ isEdit ? "Save Draft" : "Create Draft" }}
            </BaseButton>
            <BaseButton variant="ghost" :disabled="submitting" @click="router.push('/admin/elections')">
              Cancel
            </BaseButton>
          </template>
        </WizardActions>
      </template>
    </WizardShell>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { candidateApi } from "@/api";
import BaseButton from "@/components/common/BaseButton.vue";
import WizardActions from "@/components/common/wizard/WizardActions.vue";
import WizardShell from "@/components/common/wizard/WizardShell.vue";
import WizardStepNav from "@/components/common/wizard/WizardStepNav.vue";
import WizardStepPanel from "@/components/common/wizard/WizardStepPanel.vue";
import { useWizard, type WizardStepDefinition } from "@/composables/useWizard";
import { useElectionStore } from "@/stores/electionStore";
import { useUiStore } from "@/stores/uiStore";
import {
  getElectionTypeDefinition,
  type CreateCandidateRequest,
  type CreateElectionRequest,
  type ElectionType,
  type ElectionStatus,
  type Candidate,
} from "@/types";

interface CandidateDraft {
  tempId: string;
  id?: number;
  firstName: string;
  lastName: string;
  className: string;
  description: string;
}

const route = useRoute();
const router = useRouter();
const electionStore = useElectionStore();
const uiStore = useUiStore();

const isEdit = computed(() => !!route.params.id);
const loadingElection = ref(false);
const submitting = ref(false);

const steps = ref<WizardStepDefinition[]>([
  {
    id: "basics",
    title: "Basics",
    description: "Set the election title and the voter-facing description.",
  },
  {
    id: "type",
    title: "Election Type",
    description: "Choose the ballot style and type-specific rules.",
  },
  {
    id: "candidates",
    title: "Candidates",
    description: "Add the ballot entries and keep them in the right order.",
  },
  {
    id: "schedule",
    title: "Schedule",
    description: "Define when the election starts, ends, and becomes visible.",
  },
  {
    id: "review",
    title: "Review",
    description: "Check the configuration before saving the election.",
  },
]);

const {
  currentStep,
  currentStepId,
  currentStepIndex,
  completedStepIds,
  isFirstStep,
  isLastStep,
  goToStep,
  goToNextStep,
  goToPreviousStep,
  markStepComplete,
} = useWizard(steps, {
  canNavigateToStep: (_step, targetIndex, currentIndex) =>
    targetIndex <= currentIndex || completedStepIds.value.includes(steps.value[targetIndex].id),
});

const electionTypeOptions: ElectionType[] = [
  "SINGLE_CHOICE",
  "BINARY_CHOICE",
  "APPROVAL_VOTING",
  "LIMITED_VOTE",
  "BORDA_COUNT",
];

const form = reactive({
  title: "",
  description: "",
  type: "SINGLE_CHOICE" as ElectionType,
  startAt: "",
  endAt: "",
  maxSelections: null as number | null,
});

const errors = reactive<Record<string, string>>({});
const candidateDrafts = ref<CandidateDraft[]>([]);
const originalCandidates = ref<Candidate[]>([]);

const selectedType = computed(() => getElectionTypeDefinition(form.type));
const publishOutcomeLabel = computed(() => {
  const publishStatus = derivePublishStatus();
  switch (publishStatus) {
    case "PLANNED":
      return "Planned";
    case "ENDED":
      return "Ended";
    default:
      return "Active";
  }
});

function createTempId(): string {
  return `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`;
}

function createEmptyCandidateDraft(): CandidateDraft {
  return {
    tempId: createTempId(),
    firstName: "",
    lastName: "",
    className: "",
    description: "",
  };
}

function selectElectionType(type: ElectionType) {
  form.type = type;
  if (type !== "LIMITED_VOTE") {
    form.maxSelections = null;
  } else if (form.maxSelections === null) {
    form.maxSelections = 2;
  }
}

function addCandidate() {
  candidateDrafts.value.push(createEmptyCandidateDraft());
}

function removeCandidate(tempId: string) {
  candidateDrafts.value = candidateDrafts.value.filter((candidate) => candidate.tempId !== tempId);
}

function clearStepErrors(keys: string[]) {
  for (const key of keys) {
    delete errors[key];
  }
}

function validateBasicsStep(): boolean {
  clearStepErrors(["title"]);

  if (!form.title.trim()) {
    errors.title = "Title is required.";
    return false;
  }

  return true;
}

function validateTypeStep(): boolean {
  clearStepErrors(["maxSelections"]);

  if (form.type === "LIMITED_VOTE") {
    if (!form.maxSelections || form.maxSelections < 1) {
      errors.maxSelections = "Set a selection limit of at least 1.";
      return false;
    }
  }

  return true;
}

function validateCandidatesStep(): boolean {
  clearStepErrors(["candidates"]);

  if (candidateDrafts.value.length < 2) {
    errors.candidates = "Add at least two candidates.";
    return false;
  }

  if (form.type === "BINARY_CHOICE" && candidateDrafts.value.length !== 2) {
    errors.candidates = "Binary choice elections require exactly two candidates.";
    return false;
  }

  if (
    form.type === "LIMITED_VOTE" &&
    form.maxSelections !== null &&
    form.maxSelections >= candidateDrafts.value.length
  ) {
    errors.candidates = "The selection limit must be lower than the number of candidates.";
    return false;
  }

  const hasInvalidCandidate = candidateDrafts.value.some(
    (candidate) =>
      !candidate.firstName.trim() ||
      !candidate.lastName.trim(),
  );

  if (hasInvalidCandidate) {
    errors.candidates = "Each candidate needs a first and last name.";
    return false;
  }

  return true;
}

function validateScheduleStep(): boolean {
  clearStepErrors(["endAt"]);

  if (form.startAt && form.endAt && new Date(form.endAt) <= new Date(form.startAt)) {
    errors.endAt = "End date must be after the start date.";
    return false;
  }

  return true;
}

function validateStep(stepId = currentStepId.value): boolean {
  switch (stepId) {
    case "basics":
      return validateBasicsStep();
    case "type":
      return validateTypeStep();
    case "candidates":
      return validateCandidatesStep();
    case "schedule":
    case "review":
      return validateScheduleStep();
    default:
      return true;
  }
}

function handleStepSelect(stepId: string) {
  const targetIndex = steps.value.findIndex((step) => step.id === stepId);
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
    uiStore.showToast({ type: "error", message: "Please fix the highlighted fields first." });
    return;
  }

  markStepComplete();
  goToNextStep();
}

function derivePublishStatus(): ElectionStatus {
  if (form.endAt && new Date(form.endAt) <= new Date()) {
    return "ENDED";
  }

  if (form.startAt && new Date(form.startAt) > new Date()) {
    return "PLANNED";
  }

  return "ACTIVE";
}

function buildElectionPayload(status: ElectionStatus): CreateElectionRequest {
  return {
    title: form.title.trim(),
    description: form.description.trim(),
    type: form.type,
    status,
    startAt: form.startAt ? new Date(form.startAt).toISOString() : null,
    endAt: form.endAt ? new Date(form.endAt).toISOString() : null,
    maxSelections: form.type === "LIMITED_VOTE" ? form.maxSelections : null,
  };
}

async function syncCandidates(electionId: number) {
  const retainedIds = new Set<number>();

  for (const [index, draft] of candidateDrafts.value.entries()) {
    const payload: CreateCandidateRequest = {
      electionId,
      firstName: draft.firstName.trim(),
      lastName: draft.lastName.trim(),
      className: draft.className.trim() || undefined,
      description: draft.description.trim() || undefined,
      sortOrder: index,
    };

    if (draft.id) {
      retainedIds.add(draft.id);
      await candidateApi.update(draft.id, payload);
    } else {
      const created = await candidateApi.create(payload);
      draft.id = created.id;
    }
  }

  const candidatesToDelete = originalCandidates.value.filter(
    (candidate) => !retainedIds.has(candidate.id),
  );

  await Promise.all(candidatesToDelete.map((candidate) => candidateApi.delete(candidate.id)));
  originalCandidates.value = await candidateApi.getByElection(electionId);
}

async function handleSubmit(mode: "draft" | "publish") {
  const allStepsValid = steps.value.every((step) => validateStep(step.id));
  if (!allStepsValid) {
    uiStore.showToast({ type: "error", message: "Please complete all steps before saving." });
    return;
  }

  submitting.value = true;

  try {
    const payload = buildElectionPayload(mode === "draft" ? "DRAFT" : derivePublishStatus());
    const result = isEdit.value
      ? await electionStore.update(Number(route.params.id), payload)
      : await electionStore.create(payload);

    if (!result) {
      throw new Error(electionStore.error || "Failed to save election.");
    }

    await syncCandidates(result.id);
    uiStore.showToast({
      type: "success",
      message: isEdit.value
        ? "Election updated successfully."
        : "Election created successfully.",
    });
    router.push("/admin/elections");
  } catch (error: any) {
    uiStore.showToast({
      type: "error",
      message: error?.response?.data?.message || error?.message || "Failed to save election.",
    });
  } finally {
    submitting.value = false;
  }
}

function formatDateTime(value: string): string {
  if (!value) {
    return "—";
  }
  return new Date(value).toLocaleString("de-DE");
}

function mapCandidateToDraft(candidate: Candidate): CandidateDraft {
  return {
    tempId: createTempId(),
    id: candidate.id,
    firstName: candidate.firstName,
    lastName: candidate.lastName,
    className: candidate.className || "",
    description: candidate.description || "",
  };
}

onMounted(async () => {
  uiStore.setBreadcrumbs([
    { label: "Dashboard", route: "/admin/dashboard" },
    { label: "Elections", route: "/admin/elections" },
    { label: isEdit.value ? "Edit" : "Create" },
  ]);
  uiStore.setPageTitle(isEdit.value ? "Edit Election" : "Create Election");

  if (!isEdit.value) {
    addCandidate();
    addCandidate();
    return;
  }

  loadingElection.value = true;
  try {
    const [election, candidates] = await Promise.all([
      electionStore.fetchById(Number(route.params.id)),
      candidateApi.getByElection(Number(route.params.id)),
    ]);

    if (election) {
      form.title = election.title;
      form.description = election.description;
      form.type = election.type;
      form.startAt = election.startAt ? election.startAt.slice(0, 16) : "";
      form.endAt = election.endAt ? election.endAt.slice(0, 16) : "";
      form.maxSelections = election.maxSelections;
    }

    originalCandidates.value = candidates;
    candidateDrafts.value = candidates.map(mapCandidateToDraft);
    if (candidateDrafts.value.length === 0) {
      addCandidate();
      addCandidate();
    }
  } finally {
    loadingElection.value = false;
  }
});
</script>

<style scoped>
.election-form-view {
  max-width: 1200px;
}

.page-header {
  margin-bottom: 1.5rem;
}

.page-header h1 {
  margin: 0 0 0.35rem 0;
  color: var(--color-text, #1a202c);
}

.page-subtitle {
  margin: 0;
  color: var(--color-text-muted, #718096);
}

.wizard-header-copy {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  align-items: flex-start;
}

.wizard-header-copy h2 {
  margin: 0 0 0.35rem 0;
  color: var(--color-text, #1a202c);
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

.loading {
  padding: 2rem;
  text-align: center;
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
  font-size: 0.9rem;
  color: #4a5568;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1.5px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  font-size: 1rem;
  font-family: inherit;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--color-primary, #667eea);
}

.field-error {
  color: var(--color-danger, #e53e3e);
  font-size: 0.82rem;
}

.type-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1rem;
}

.type-card {
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 14px;
  background: white;
  padding: 1rem;
  text-align: left;
  cursor: pointer;
  transition: all 0.15s ease;
}

.type-card:hover,
.type-card.active {
  border-color: var(--color-primary, #667eea);
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.12);
}

.type-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
}

.type-card p {
  margin: 0 0 0.5rem 0;
  color: var(--color-text, #1a202c);
}

.type-card small,
.type-card-badge {
  color: var(--color-text-muted, #718096);
}

.type-card-badge {
  text-transform: uppercase;
  font-size: 0.72rem;
  font-weight: 700;
}

.type-config {
  margin-top: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.compact {
  max-width: 260px;
}

.type-hints {
  padding: 1rem;
  background: #f8fafc;
  border-radius: 12px;
  color: var(--color-text-muted, #718096);
}

.type-hints p {
  margin: 0;
}

.candidate-step-header {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.candidate-step-header h3 {
  margin: 0 0 0.25rem 0;
}

.candidate-step-header p {
  margin: 0;
  color: var(--color-text-muted, #718096);
}

.candidate-empty {
  padding: 1rem;
  border: 1px dashed var(--color-border, #cbd5e0);
  border-radius: 12px;
  color: var(--color-text-muted, #718096);
}

.candidate-drafts {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.candidate-draft {
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 14px;
  padding: 1rem;
}

.candidate-draft-header {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  align-items: center;
  margin-bottom: 1rem;
}

.schedule-grid {
  align-items: start;
}

.schedule-note {
  margin-top: 1rem;
  padding: 1rem;
  border-radius: 12px;
  background: #f8fafc;
  color: var(--color-text-muted, #718096);
}

.schedule-note p {
  margin: 0;
}

.review-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1rem;
}

.review-card {
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 14px;
  padding: 1rem;
}

.review-card h3 {
  margin: 0 0 0.75rem 0;
}

.review-card dl,
.review-list {
  margin: 0;
}

.review-card dl div {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  padding: 0.4rem 0;
  border-bottom: 1px solid #edf2f7;
}

.review-card dl div:last-child {
  border-bottom: none;
}

.review-card dt {
  color: var(--color-text-muted, #718096);
}

.review-card dd {
  margin: 0;
  color: var(--color-text, #1a202c);
  font-weight: 600;
  text-align: right;
}

.review-list {
  padding-left: 1.1rem;
}

.review-list li + li {
  margin-top: 0.35rem;
}

@media (max-width: 900px) {
  .form-grid,
  .type-grid,
  .review-grid {
    grid-template-columns: 1fr;
  }

  .wizard-header-copy,
  .candidate-step-header {
    flex-direction: column;
  }
}
</style>
