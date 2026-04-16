<template>
  <button
    class="base-button"
    :class="[`variant-${variant}`, `size-${size}`, { loading: loading }]"
    :disabled="disabled || loading"
    :type="(type as any) || 'button'"
    @click="$emit('click', $event)"
  >
    <span v-if="loading" class="spinner" />
    <slot />
  </button>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  disabled?: boolean;
  type?: string;
}>(), {
  variant: 'primary',
  size: 'md',
  loading: false,
  disabled: false,
});

defineEmits<{
  click: [event: MouseEvent];
}>();
</script>

<style scoped>
.base-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  border: none;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.15s ease;
  white-space: nowrap;
}

.base-button:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

/* Sizes */
.size-sm { padding: 0.375rem 0.75rem; font-size: 0.8rem; }
.size-md { padding: 0.5rem 1rem; font-size: 0.9rem; }
.size-lg { padding: 0.75rem 1.5rem; font-size: 1rem; }

/* Variants */
.variant-primary {
  background: var(--color-primary, #667eea);
  color: white;
}
.variant-primary:hover:not(:disabled) {
  background: var(--color-primary-hover, #5a67d8);
}

.variant-secondary {
  background: var(--color-border, #e2e8f0);
  color: var(--color-text, #1a202c);
}
.variant-secondary:hover:not(:disabled) {
  background: #cbd5e1;
}

.variant-danger {
  background: var(--color-danger, #e53e3e);
  color: white;
}
.variant-danger:hover:not(:disabled) {
  background: #c53030;
}

.variant-ghost {
  background: transparent;
  color: var(--color-text, #1a202c);
}
.variant-ghost:hover:not(:disabled) {
  background: rgba(0, 0, 0, 0.05);
}

/* Spinner */
.spinner {
  display: inline-block;
  width: 1em;
  height: 1em;
  border: 2px solid currentColor;
  border-right-color: transparent;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
