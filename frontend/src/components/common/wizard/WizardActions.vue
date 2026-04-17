<template>
  <div class="wizard-actions-row">
    <BaseButton variant="secondary" :disabled="isFirstStep || submitting" @click="$emit('back')">
      {{ resolvedBackLabel }}
    </BaseButton>

    <div class="wizard-actions-right">
      <slot name="secondary" />

      <BaseButton
        v-if="!isLastStep"
        :disabled="nextDisabled || submitting"
        @click="$emit('next')"
      >
        {{ resolvedNextLabel }}
      </BaseButton>

      <BaseButton
        v-else
        :loading="submitting"
        :disabled="submitDisabled"
        @click="$emit('submit')"
      >
        {{ resolvedSubmitLabel }}
      </BaseButton>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useLocale } from '@/composables/useLocale';
import BaseButton from "@/components/common/BaseButton.vue";

const props = withDefaults(
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
  },
);

defineEmits<{
  back: [];
  next: [];
  submit: [];
}>();

const { t } = useLocale();

const resolvedBackLabel = computed(() => props.backLabel ?? t('wizard.back'));
const resolvedNextLabel = computed(() => props.nextLabel ?? t('wizard.next'));
const resolvedSubmitLabel = computed(() => props.submitLabel ?? t('wizard.save'));
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
