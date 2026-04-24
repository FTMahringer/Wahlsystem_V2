<template>
  <div class="election-form-view">
    <div class="page-header">
      <h1>
        {{
          isEdit
            ? t("adminElectionForm.editTitle")
            : t("adminElectionForm.createTitle")
        }}
      </h1>
      <p class="page-subtitle">
        {{ t("adminElectionForm.subtitle") }}
      </p>
    </div>

    <div v-if="loadingElection" class="loading">
      {{ t("adminElectionForm.loading") }}
    </div>

    <WizardShell v-else>
      <template #header>
        <div class="wizard-header-copy">
          <div>
            <h2>{{ currentStep?.title }}</h2>
            <p v-if="currentStep?.description">{{ currentStep.description }}</p>
          </div>
          <span class="step-counter">
            {{
              t("wizard.stepCounter", {
                current: currentStepIndex + 1,
                total: steps.length,
              })
            }}
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
            <label for="title">{{ t("common.title") }} *</label>
            <input
              id="title"
              v-model="form.title"
              type="text"
              :placeholder="t('adminElectionForm.electionTitlePlaceholder')"
              :disabled="submitting"
            />
            <span v-if="errors.title" class="field-error">{{
              errors.title
            }}</span>
          </div>

          <div class="form-group full-width">
            <label for="description">{{ t("common.description") }}</label>
            <textarea
              id="description"
              v-model="form.description"
              rows="5"
              :placeholder="
                t('adminElectionForm.electionDescriptionPlaceholder')
              "
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
              <strong>{{ getElectionTypeDefinition(option, t).label }}</strong>
              <span class="type-card-badge">
                {{ getElectionTypeDefinition(option, t).resultMetricLabel }}
              </span>
            </div>
            <p>{{ getElectionTypeDefinition(option, t).description }}</p>
            <small>{{ getElectionTypeDefinition(option, t).helperText }}</small>
          </button>
        </div>

        <div class="type-config">
          <div
            v-if="selectedType.requiresMaxSelections"
            class="form-group compact"
          >
            <label for="maxSelections"
              >{{ t("adminElectionForm.selectionLimit") }} *</label
            >
            <input
              id="maxSelections"
              v-model.number="form.maxSelections"
              type="number"
              min="1"
              :placeholder="t('adminElectionForm.maxSelectionsPlaceholder')"
              :disabled="submitting"
            />
            <span v-if="errors.maxSelections" class="field-error">
              {{ errors.maxSelections }}
            </span>
          </div>

          <div class="type-hints">
            <p v-if="form.type === 'BINARY_CHOICE'">
              {{ t("adminElectionForm.binaryHint") }}
            </p>
            <p v-else-if="form.type === 'BORDA_COUNT'">
              {{ t("adminElectionForm.bordaHint") }}
            </p>
            <p v-else-if="form.type === 'APPROVAL_VOTING'">
              {{ t("adminElectionForm.approvalHint") }}
            </p>
            <p v-else-if="form.type === 'LIMITED_VOTE'">
              {{ t("adminElectionForm.limitedHint") }}
            </p>
            <p v-else>
              {{ t("adminElectionForm.singleHint") }}
            </p>
          </div>
        </div>
      </WizardStepPanel>

      <WizardStepPanel :active="currentStepId === 'candidates'">
        <div class="candidate-step-header">
          <div>
            <h3>{{ t("adminElectionForm.candidatesTitle") }}</h3>
            <p>
              {{ t("adminElectionForm.candidatesIntro") }}
            </p>
          </div>
          <BaseButton variant="secondary" @click="addCandidate">
            + {{ t("adminElectionForm.addCandidate") }}
          </BaseButton>
        </div>

        <div v-if="candidateDrafts.length === 0" class="candidate-empty">
          {{ t("adminElectionForm.noCandidates") }}
        </div>

        <div v-else class="candidate-drafts">
          <div
            v-for="(candidate, index) in candidateDrafts"
            :key="candidate.tempId"
            class="candidate-draft"
          >
            <div class="candidate-draft-header">
              <strong>{{
                t("adminElectionForm.candidateNumber", { number: index + 1 })
              }}</strong>
              <BaseButton
                variant="ghost"
                size="sm"
                :disabled="submitting"
                @click="removeCandidate(candidate.tempId)"
              >
                {{ t("common.remove") }}
              </BaseButton>
            </div>

            <div class="form-grid">
              <div class="form-group">
                <label>{{ t("common.firstName") }} *</label>
                <input
                  v-model="candidate.firstName"
                  type="text"
                  :disabled="submitting"
                />
              </div>
              <div class="form-group">
                <label>{{ t("common.lastName") }} *</label>
                <input
                  v-model="candidate.lastName"
                  type="text"
                  :disabled="submitting"
                />
              </div>
              <div class="form-group">
                <label>{{ t("common.class") }}</label>
                <input
                  v-model="candidate.className"
                  type="text"
                  :placeholder="t('adminElectionForm.classPlaceholder')"
                  :disabled="submitting"
                />
              </div>
              <div class="form-group full-width">
                <label>{{ t("common.description") }}</label>
                <textarea
                  v-model="candidate.description"
                  rows="3"
                  :placeholder="
                    t('adminElectionForm.shortDescriptionPlaceholder')
                  "
                  :disabled="submitting"
                />
              </div>
            </div>
          </div>
        </div>

        <span v-if="errors.candidates" class="field-error">{{
          errors.candidates
        }}</span>
      </WizardStepPanel>

      <WizardStepPanel :active="currentStepId === 'schedule'">
        <div class="form-grid schedule-grid">
          <div class="form-group">
            <label for="startAt">{{ t("common.start") }}</label>
            <input
              id="startAt"
              v-model="form.startAt"
              type="datetime-local"
              :disabled="submitting"
            />
          </div>

          <div class="form-group">
            <label for="endAt">{{ t("common.end") }}</label>
            <input
              id="endAt"
              v-model="form.endAt"
              type="datetime-local"
              :disabled="submitting"
            />
            <span v-if="errors.endAt" class="field-error">{{
              errors.endAt
            }}</span>
          </div>
        </div>

        <div class="schedule-note">
          <p>
            {{ t("adminElectionForm.scheduleNote") }}
          </p>
        </div>
      </WizardStepPanel>

      <WizardStepPanel :active="currentStepId === 'classScope'">
        <div class="form-grid">
          <div class="form-group full-width">
            <label>{{ t("adminElectionForm.classScope") }}</label>
            <p class="hint">
              {{ t("adminElectionForm.classScopeDescription") }}
            </p>
            <select v-model="form.schoolClassId" :disabled="submitting">
              <option :value="undefined">
                {{ t("adminElectionForm.noClass") }}
              </option>
              <option
                v-for="cls in schoolClasses"
                :key="cls.id"
                :value="cls.id"
              >
                {{ cls.name }} {{ cls.gradeLevel ? `(${cls.gradeLevel})` : "" }}
              </option>
            </select>
          </div>
        </div>
      </WizardStepPanel>

      <WizardStepPanel :active="currentStepId === 'review'">
        <div class="review-grid">
          <div class="review-card">
            <h3>{{ t("adminElectionForm.basicsTitle") }}</h3>
            <dl>
              <div>
                <dt>{{ t("common.title") }}</dt>
                <dd>{{ form.title || t("common.notAvailable") }}</dd>
              </div>
              <div>
                <dt>{{ t("common.description") }}</dt>
                <dd>{{ form.description || t("common.notAvailable") }}</dd>
              </div>
            </dl>
          </div>

          <div class="review-card">
            <h3>{{ t("adminElectionForm.typeTitle") }}</h3>
            <dl>
              <div>
                <dt>{{ t("common.type") }}</dt>
                <dd>{{ selectedType.label }}</dd>
              </div>
              <div v-if="form.type === 'LIMITED_VOTE'">
                <dt>{{ t("adminElectionForm.selectionLimit") }}</dt>
                <dd>{{ form.maxSelections }}</dd>
              </div>
              <div>
                <dt>{{ t("adminElectionForm.resultMetric") }}</dt>
                <dd>{{ selectedType.resultMetricLabel }}</dd>
              </div>
            </dl>
          </div>

          <div class="review-card">
            <h3>{{ t("adminElectionForm.candidatesTitle") }}</h3>
            <ul class="review-list">
              <li v-for="candidate in candidateDrafts" :key="candidate.tempId">
                {{ candidate.firstName }} {{ candidate.lastName }}
                <small v-if="candidate.className"
                  >({{ candidate.className }})</small
                >
              </li>
            </ul>
          </div>

          <div class="review-card">
            <h3>{{ t("adminElectionForm.scheduleTitle") }}</h3>
            <dl>
              <div>
                <dt>{{ t("common.start") }}</dt>
                <dd>{{ formatDateTime(form.startAt) }}</dd>
              </div>
              <div>
                <dt>{{ t("common.end") }}</dt>
                <dd>{{ formatDateTime(form.endAt) }}</dd>
              </div>
              <div>
                <dt>{{ t("adminElectionForm.publishOutcome") }}</dt>
                <dd>{{ publishOutcomeLabel }}</dd>
              </div>
            </dl>
          </div>

          <div class="review-card full-width">
            <h3>{{ t("adminElectionForm.classScope") }}</h3>
            <dl>
              <div>
                <dt>{{ t("common.class") }}</dt>
                <dd>{{ selectedClassName }}</dd>
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
          :submit-label="
            isEdit
              ? t('adminElectionForm.saveAndPublish')
              : t('adminElectionForm.createAndPublish')
          "
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
              {{
                isEdit
                  ? t("adminElectionForm.saveDraft")
                  : t("adminElectionForm.createDraft")
              }}
            </BaseButton>
            <BaseButton
              variant="ghost"
              :disabled="submitting"
              @click="router.push('/admin/elections')"
            >
              {{ t("common.cancel") }}
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
import { candidateApi, schoolClassApi } from "@/api";
import BaseButton from "@/components/common/BaseButton.vue";
import WizardActions from "@/components/common/wizard/WizardActions.vue";
import WizardShell from "@/components/common/wizard/WizardShell.vue";
import WizardStepNav from "@/components/common/wizard/WizardStepNav.vue";
import WizardStepPanel from "@/components/common/wizard/WizardStepPanel.vue";
import { useLocale } from "@/composables/useLocale";
import { useWizard, type WizardStepDefinition } from "@/composables/useWizard";
import { toIntlLocale } from "@/locales";
import { useElectionStore } from "@/stores/electionStore";
import { useUiStore } from "@/stores/uiStore";
import {
  getElectionTypeDefinition,
  type CreateCandidateRequest,
  type CreateElectionRequest,
  type ElectionType,
  type ElectionStatus,
  type Candidate,
  type SchoolClass,
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
const { t, language } = useLocale();
const localeCode = computed(() => toIntlLocale(language.value));

const isEdit = computed(() => !!route.params.id);
const loadingElection = ref(false);
const submitting = ref(false);

const schoolClasses = ref<SchoolClass[]>([]);

const steps = computed<WizardStepDefinition[]>(() => [
  {
    id: "basics",
    title: t("adminElectionForm.basicsTitle"),
    description: t("adminElectionForm.basicsDescription"),
  },
  {
    id: "type",
    title: t("adminElectionForm.typeTitle"),
    description: t("adminElectionForm.typeDescription"),
  },
  {
    id: "candidates",
    title: t("adminElectionForm.candidatesTitle"),
    description: t("adminElectionForm.candidatesDescription"),
  },
  {
    id: "schedule",
    title: t("adminElectionForm.scheduleTitle"),
    description: t("adminElectionForm.scheduleDescription"),
  },
  {
    id: "classScope",
    title: t("adminElectionForm.classScope"),
    description: t("adminElectionForm.classScopeDescription"),
  },
  {
    id: "review",
    title: t("adminElectionForm.reviewTitle"),
    description: t("adminElectionForm.reviewDescription"),
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
    targetIndex <= currentIndex ||
    completedStepIds.value.includes(steps.value[targetIndex].id),
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
  schoolClassId: undefined as number | undefined,
});

const errors = reactive<Record<string, string>>({});
const candidateDrafts = ref<CandidateDraft[]>([]);
const originalCandidates = ref<Candidate[]>([]);

const selectedType = computed(() => getElectionTypeDefinition(form.type, t));
const selectedClassName = computed(() => {
  if (!form.schoolClassId) return t("adminElectionForm.noClass");
  const cls = schoolClasses.value.find((c) => c.id === form.schoolClassId);
  return cls?.name || t("common.notAvailable");
});

const publishOutcomeLabel = computed(() => {
  const publishStatus = derivePublishStatus();
  switch (publishStatus) {
    case "PLANNED":
      return t("adminElectionForm.publishStatus.PLANNED");
    case "ENDED":
      return t("adminElectionForm.publishStatus.ENDED");
    default:
      return t("adminElectionForm.publishStatus.ACTIVE");
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
  candidateDrafts.value = candidateDrafts.value.filter(
    (candidate) => candidate.tempId !== tempId,
  );
}

function clearStepErrors(keys: string[]) {
  for (const key of keys) {
    delete errors[key];
  }
}

function validateBasicsStep(): boolean {
  clearStepErrors(["title"]);

  if (!form.title.trim()) {
    errors.title = t("adminElectionForm.titleRequired");
    return false;
  }

  return true;
}

function validateTypeStep(): boolean {
  clearStepErrors(["maxSelections"]);

  if (form.type === "LIMITED_VOTE") {
    if (!form.maxSelections || form.maxSelections < 1) {
      errors.maxSelections = t("adminElectionForm.minSelectionLimit");
      return false;
    }
  }

  return true;
}

function validateCandidatesStep(): boolean {
  clearStepErrors(["candidates"]);

  if (candidateDrafts.value.length < 2) {
    errors.candidates = t("adminElectionForm.minCandidates");
    return false;
  }

  if (form.type === "BINARY_CHOICE" && candidateDrafts.value.length !== 2) {
    errors.candidates = t("adminElectionForm.binaryNeedsTwo");
    return false;
  }

  if (
    form.type === "LIMITED_VOTE" &&
    form.maxSelections !== null &&
    form.maxSelections >= candidateDrafts.value.length
  ) {
    errors.candidates = t("adminElectionForm.selectionLimitLower");
    return false;
  }

  const hasInvalidCandidate = candidateDrafts.value.some(
    (candidate) => !candidate.firstName.trim() || !candidate.lastName.trim(),
  );

  if (hasInvalidCandidate) {
    errors.candidates = t("adminElectionForm.candidateNeedsName");
    return false;
  }

  return true;
}

function validateScheduleStep(): boolean {
  clearStepErrors(["endAt"]);

  if (
    form.startAt &&
    form.endAt &&
    new Date(form.endAt) <= new Date(form.startAt)
  ) {
    errors.endAt = t("adminElectionForm.endAfterStart");
    return false;
  }

  return true;
}

function validateClassScopeStep(): boolean {
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
      return validateScheduleStep();
    case "classScope":
      return validateClassScopeStep();
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
    uiStore.showToast({
      type: "error",
      message: t("wizard.completeCurrentStep"),
    });
    return;
  }

  if (targetIndex > currentStepIndex.value) {
    markStepComplete();
  }

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
    schoolClassId: form.schoolClassId,
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

  await Promise.all(
    candidatesToDelete.map((candidate) => candidateApi.delete(candidate.id)),
  );
  originalCandidates.value = await candidateApi.getByElection(electionId);
}

async function handleSubmit(mode: "draft" | "publish") {
  const allStepsValid = steps.value.every((step) => validateStep(step.id));
  if (!allStepsValid) {
    uiStore.showToast({ type: "error", message: t("wizard.completeWizard") });
    return;
  }

  submitting.value = true;

  try {
    const payload = buildElectionPayload(
      mode === "draft" ? "DRAFT" : derivePublishStatus(),
    );
    const result = isEdit.value
      ? await electionStore.update(Number(route.params.id), payload)
      : await electionStore.create(payload);

    if (!result) {
      throw new Error(electionStore.error || t("adminElectionForm.saveFailed"));
    }

    await syncCandidates(result.id);
    uiStore.showToast({
      type: "success",
      message: isEdit.value
        ? t("adminElectionForm.updatedSuccess")
        : t("adminElectionForm.createdSuccess"),
    });
    router.push("/admin/elections");
  } catch (error: any) {
    uiStore.showToast({
      type: "error",
      message:
        error?.response?.data?.message ||
        error?.message ||
        t("adminElectionForm.saveFailed"),
    });
  } finally {
    submitting.value = false;
  }
}

function formatDateTime(value: string): string {
  if (!value) {
    return t("common.notAvailable");
  }
  return new Date(value).toLocaleString(localeCode.value);
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
    { label: t("nav.dashboard"), route: "/admin/dashboard" },
    { label: t("nav.elections"), route: "/admin/elections" },
    {
      label: isEdit.value
        ? t("adminElectionForm.editBreadcrumb")
        : t("adminElectionForm.createBreadcrumb"),
    },
  ]);
  uiStore.setPageTitle(
    isEdit.value
      ? t("adminElectionForm.editTitle")
      : t("adminElectionForm.createTitle"),
  );

  try {
    schoolClasses.value = await schoolClassApi.getAll();
  } catch (e) {
    console.error("Failed to load school classes", e);
  }

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
      form.schoolClassId = election.schoolClassId ?? undefined;
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
.form-group textarea,
.form-group select {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1.5px solid var(--color-border, #e2e8f0);
  border-radius: 10px;
  font-size: 1rem;
  font-family: inherit;
}
.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
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
.review-card.full-width {
  grid-column: 1 / -1;
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
.hint {
  color: var(--color-text-muted, #718096);
  font-size: 0.9rem;
  margin: 0 0 0.5rem 0;
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
