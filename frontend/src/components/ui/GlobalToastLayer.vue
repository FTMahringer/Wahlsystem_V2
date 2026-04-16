<template>
  <Teleport to="body">
    <TransitionGroup name="toast" tag="div" class="toast-layer">
      <div
        v-for="toast in uiStore.toasts"
        :key="toast.id"
        class="toast"
        :class="[`toast-${toast.type}`]"
      >
        <span class="toast-icon">{{ iconForType(toast.type) }}</span>
        <span class="toast-message">{{ toast.message }}</span>
        <button class="toast-close" @click="uiStore.dismissToast(toast.id)">&times;</button>
      </div>
    </TransitionGroup>
  </Teleport>
</template>

<script setup lang="ts">
import { useUiStore } from '@/stores/uiStore';

const uiStore = useUiStore();

function iconForType(type: string): string {
  switch (type) {
    case 'success': return '✓';
    case 'error': return '✕';
    case 'warning': return '⚠';
    case 'info': return 'ℹ';
    default: return 'ℹ';
  }
}
</script>

<style scoped>
.toast-layer {
  position: fixed;
  bottom: 1.5rem;
  right: 1.5rem;
  z-index: 2000;
  display: flex;
  flex-direction: column-reverse;
  gap: 0.75rem;
  pointer-events: none;
}

.toast {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.875rem 1.25rem;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  min-width: 300px;
  max-width: 420px;
  pointer-events: auto;
  color: white;
  font-size: 0.9rem;
}

.toast-success { background: #38a169; }
.toast-error { background: #e53e3e; }
.toast-warning { background: #d69e2e; color: #1a202c; }
.toast-info { background: #3182ce; }

.toast-icon {
  font-weight: bold;
  font-size: 1.1rem;
  flex-shrink: 0;
}

.toast-message {
  flex: 1;
}

.toast-close {
  background: none;
  border: none;
  color: inherit;
  font-size: 1.25rem;
  cursor: pointer;
  opacity: 0.7;
  padding: 0;
  line-height: 1;
  flex-shrink: 0;
}
.toast-close:hover { opacity: 1; }

/* Transitions */
.toast-enter-active { transition: all 0.3s ease; }
.toast-leave-active { transition: all 0.2s ease; }
.toast-enter-from { opacity: 0; transform: translateX(60px); }
.toast-leave-to { opacity: 0; transform: translateX(60px); }
</style>
