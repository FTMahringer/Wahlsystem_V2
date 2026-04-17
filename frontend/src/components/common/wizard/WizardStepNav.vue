<template>
  <ol class="wizard-step-nav">
    <li v-for="(step, index) in steps" :key="step.id" class="wizard-step-item">
      <button
        type="button"
        class="wizard-step-button"
        :class="{
          active: step.id === currentStepId,
          complete: completedStepIds.includes(step.id),
        }"
        @click="$emit('select', step.id)"
      >
        <span class="wizard-step-index">
          {{ completedStepIds.includes(step.id) ? "✓" : index + 1 }}
        </span>
        <span class="wizard-step-copy">
          <span class="wizard-step-title">{{ step.title }}</span>
          <span v-if="step.description" class="wizard-step-description">
            {{ step.description }}
          </span>
        </span>
      </button>
    </li>
  </ol>
</template>

<script setup lang="ts">
import type { WizardStepDefinition } from "@/composables/useWizard";

defineProps<{
  steps: WizardStepDefinition[];
  currentStepId: string;
  completedStepIds: string[];
}>();

defineEmits<{
  select: [stepId: string];
}>();
</script>

<style scoped>
.wizard-step-nav {
  list-style: none;
  margin: 0;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.wizard-step-item {
  margin: 0;
}

.wizard-step-button {
  width: 100%;
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  text-align: left;
  background: transparent;
  border: 1px solid transparent;
  border-radius: 12px;
  padding: 0.75rem;
  cursor: pointer;
  transition: all 0.15s ease;
}

.wizard-step-button:hover {
  border-color: var(--color-primary, #667eea);
  background: rgba(102, 126, 234, 0.05);
}

.wizard-step-button.active {
  border-color: var(--color-primary, #667eea);
  background: rgba(102, 126, 234, 0.08);
}

.wizard-step-button.complete .wizard-step-index {
  background: #48bb78;
  border-color: #48bb78;
  color: white;
}

.wizard-step-index {
  width: 1.8rem;
  height: 1.8rem;
  flex-shrink: 0;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  border: 1px solid var(--color-border, #cbd5e0);
  background: white;
  color: var(--color-text, #1a202c);
  font-size: 0.85rem;
  font-weight: 700;
}

.wizard-step-copy {
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
}

.wizard-step-title {
  color: var(--color-text, #1a202c);
  font-weight: 600;
  font-size: 0.95rem;
}

.wizard-step-description {
  color: var(--color-text-muted, #718096);
  font-size: 0.8rem;
  line-height: 1.35;
}
</style>
