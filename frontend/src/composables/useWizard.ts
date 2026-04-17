import { computed, ref, type Ref } from "vue";

export interface WizardStepDefinition {
  id: string;
  title: string;
  description?: string;
  optional?: boolean;
}

interface UseWizardOptions {
  initialStepId?: string;
  canNavigateToStep?: (targetStep: WizardStepDefinition, targetIndex: number, currentIndex: number) => boolean;
}

export function useWizard(
  steps: Ref<WizardStepDefinition[]>,
  options: UseWizardOptions = {},
) {
  const fallbackStepId = steps.value[0]?.id ?? "";
  const currentStepId = ref(options.initialStepId ?? fallbackStepId);
  const completedStepIds = ref<string[]>([]);

  const currentStepIndex = computed(() =>
    Math.max(
      steps.value.findIndex((step) => step.id === currentStepId.value),
      0,
    ),
  );

  const currentStep = computed(
    () => steps.value[currentStepIndex.value] ?? steps.value[0],
  );

  const isFirstStep = computed(() => currentStepIndex.value === 0);
  const isLastStep = computed(
    () => currentStepIndex.value === steps.value.length - 1,
  );

  function goToStep(stepId: string, force = false): boolean {
    const targetIndex = steps.value.findIndex((step) => step.id === stepId);
    if (targetIndex === -1) {
      return false;
    }

    const targetStep = steps.value[targetIndex];
    const canNavigate = options.canNavigateToStep?.(
      targetStep,
      targetIndex,
      currentStepIndex.value,
    );

    if (!force && canNavigate === false) {
      return false;
    }

    currentStepId.value = stepId;
    return true;
  }

  function goToNextStep(): boolean {
    const nextStep = steps.value[currentStepIndex.value + 1];
    if (!nextStep) {
      return false;
    }

    return goToStep(nextStep.id, true);
  }

  function goToPreviousStep(): boolean {
    const previousStep = steps.value[currentStepIndex.value - 1];
    if (!previousStep) {
      return false;
    }

    return goToStep(previousStep.id, true);
  }

  function markStepComplete(stepId = currentStepId.value) {
    if (!completedStepIds.value.includes(stepId)) {
      completedStepIds.value = [...completedStepIds.value, stepId];
    }
  }

  function resetCompletedSteps(stepIds?: string[]) {
    completedStepIds.value = stepIds ? [...stepIds] : [];
  }

  return {
    currentStepId,
    currentStepIndex,
    currentStep,
    completedStepIds,
    isFirstStep,
    isLastStep,
    goToStep,
    goToNextStep,
    goToPreviousStep,
    markStepComplete,
    resetCompletedSteps,
  };
}
