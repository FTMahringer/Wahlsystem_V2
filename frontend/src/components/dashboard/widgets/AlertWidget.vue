<template>
  <div class="alert-widget" :class="[`alert-${type}`]">
    <span class="alert-icon">{{ iconForType }}</span>
    <div class="alert-content">
      <strong v-if="title">{{ title }}</strong>
      <p>{{ message }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
  title?: string;
  message: string;
  type: 'info' | 'warning' | 'error';
}>();

const iconForType = computed(() => {
  switch (props.type) {
    case 'info': return 'ℹ️';
    case 'warning': return '⚠️';
    case 'error': return '❌';
    default: return 'ℹ️';
  }
});
</script>

<style scoped>
.alert-widget {
  display: flex;
  gap: 0.75rem;
  padding: 1rem 1.25rem;
  border-radius: 8px;
  border-left: 4px solid;
}

.alert-info {
  background: #ebf8ff;
  border-left-color: #3182ce;
}
.alert-warning {
  background: #fffff0;
  border-left-color: #d69e2e;
}
.alert-error {
  background: #fff5f5;
  border-left-color: #e53e3e;
}

.alert-icon {
  flex-shrink: 0;
  font-size: 1.1rem;
}

.alert-content strong {
  display: block;
  margin-bottom: 0.25rem;
  font-size: 0.9rem;
  color: var(--color-text, #1a202c);
}

.alert-content p {
  margin: 0;
  font-size: 0.85rem;
  color: var(--color-text-muted, #718096);
  line-height: 1.5;
}
</style>
