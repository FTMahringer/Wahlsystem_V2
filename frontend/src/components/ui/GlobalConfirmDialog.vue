<template>
  <BaseDialog
    v-if="uiStore.confirmDialog"
    :open="uiStore.confirmDialog.open"
    :title="uiStore.confirmDialog.title"
    size="sm"
    @update:open="handleClose"
  >
    <p class="confirm-message">{{ uiStore.confirmDialog.message }}</p>

    <template #footer>
      <BaseButton variant="secondary" @click="handleCancel">{{ t('dialogs.cancel') }}</BaseButton>
      <BaseButton variant="danger" @click="handleConfirm">{{ t('dialogs.confirm') }}</BaseButton>
    </template>
  </BaseDialog>
</template>

<script setup lang="ts">
import { useUiStore } from '@/stores/uiStore';
import { useLocale } from '@/composables/useLocale';
import BaseDialog from '@/components/common/BaseDialog.vue';
import BaseButton from '@/components/common/BaseButton.vue';

const uiStore = useUiStore();
const { t } = useLocale();

function handleConfirm() {
  uiStore.confirmDialog?.onConfirm();
  uiStore.closeConfirm();
}

function handleCancel() {
  uiStore.confirmDialog?.onCancel?.();
  uiStore.closeConfirm();
}

function handleClose() {
  uiStore.confirmDialog?.onCancel?.();
  uiStore.closeConfirm();
}
</script>

<style scoped>
.confirm-message {
  margin: 0;
  color: var(--color-text-muted, #718096);
  font-size: 0.95rem;
  line-height: 1.5;
}
</style>
