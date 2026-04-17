<template>
  <Teleport to="body">
    <Transition name="dialog">
      <div v-if="open" class="dialog-overlay" @click.self="handleBackdrop">
        <div class="dialog-box" :class="[`size-${size}`]" @keydown.escape="handleEscape">
          <div class="dialog-header">
            <h2>{{ title }}</h2>
            <button class="close-btn" @click="$emit('update:open', false)" :aria-label="t('dialogs.close')">&times;</button>
          </div>
          <div class="dialog-body">
            <slot />
          </div>
          <div v-if="$slots.footer" class="dialog-footer">
            <slot name="footer" />
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { watch } from 'vue';
import { useLocale } from '@/composables/useLocale';

const props = withDefaults(defineProps<{
  open: boolean;
  title: string;
  size?: 'sm' | 'md' | 'lg';
}>(), {
  size: 'md',
});

const emit = defineEmits<{
  'update:open': [value: boolean];
}>();

const { t } = useLocale();

function handleBackdrop() {
  emit('update:open', false);
}

function handleEscape() {
  emit('update:open', false);
}

watch(() => props.open, (val) => {
  if (val) {
    document.body.style.overflow = 'hidden';
    setTimeout(() => {
      const box = document.querySelector('.dialog-box') as HTMLElement;
      box?.focus();
    }, 50);
  } else {
    document.body.style.overflow = '';
  }
});
</script>

<style scoped>
.dialog-overlay {
  position: fixed;
  inset: 0;
  z-index: 1000;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.dialog-box {
  background: var(--color-surface, #ffffff);
  border-radius: 12px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  outline: none;
}

.size-sm { max-width: 400px; }
.size-md { max-width: 560px; }
.size-lg { max-width: 720px; }

.dialog-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 1.5rem;
  border-bottom: 1px solid var(--color-border, #e2e8f0);
}

.dialog-header h2 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--color-text, #1a202c);
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  line-height: 1;
  color: var(--color-text-muted, #718096);
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 4px;
}

.close-btn:hover {
  background: rgba(0, 0, 0, 0.05);
  color: var(--color-text, #1a202c);
}

.dialog-body {
  padding: 1.5rem;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  padding: 1rem 1.5rem;
  border-top: 1px solid var(--color-border, #e2e8f0);
}

/* Transitions */
.dialog-enter-active,
.dialog-leave-active {
  transition: opacity 0.2s ease;
}
.dialog-enter-active .dialog-box,
.dialog-leave-active .dialog-box {
  transition: transform 0.2s ease;
}
.dialog-enter-from,
.dialog-leave-to {
  opacity: 0;
}
.dialog-enter-from .dialog-box {
  transform: scale(0.95) translateY(-10px);
}
.dialog-leave-to .dialog-box {
  transform: scale(0.95) translateY(-10px);
}
</style>
