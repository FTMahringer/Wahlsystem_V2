<template>
  <div class="wizard-actions-row">
    <BaseButton variant="secondary" :disabled="isFirstStep || submitting" @click="$emit('back')">
      {{ backLabel }}
    </BaseButton>

    <div class="wizard-actions-right">
      <slot name="secondary" />

      <BaseButton
        v-if="!isLastStep"
        :disabled="nextDisabled || submitting"
        @click="$emit('next')"
      >
        {{ nextLabel }}
      </BaseButton>

      <BaseButton
        v-else
        :loading="submitting"
        :disabled="submitDisabled"
        @click="$emit('submit')"
      >
        {{ submitLabel }}
      </BaseButton>
    </div>
  </div>
</template>

<script setup lang="ts">
import BaseButton from "@/components/common/BaseButton.vue";

withDefaults(
  defineProps<{
    isFirstStep: boolean;
    isLastStep: boolean;
    nextDisabled?: boolean;
    submitDisabled?: boolean;
    submitting?: boolean;
    backLabel?: string;
    nextLabel?: string;
    submitLabel?: string;
  }>(),
  {
    nextDisabled: false,
    submitDisabled: false,
    submitting: false,
    backLabel: "Back",
    nextLabel: "Next",
    submitLabel: "Save",
  },
);

defineEmits<{
  back: [];
  next: [];
  submit: [];
}>();
</script>

<style scoped>
.wizard-actions-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.wizard-actions-right {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 0.75rem;
  flex-wrap: wrap;
}
</style>
