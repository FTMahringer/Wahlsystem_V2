<template>
  <div class="base-card" :class="[`padding-${padding}`]">
    <div v-if="title" class="base-card-header">
      <h3>{{ title }}</h3>
      <slot name="header-actions" />
    </div>
    <div class="base-card-body">
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  title?: string;
  padding?: 'none' | 'sm' | 'md' | 'lg';
}>(), {
  padding: 'md',
});
</script>

<style scoped>
.base-card {
  background: var(--color-surface, #ffffff);
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08), 0 1px 2px rgba(0, 0, 0, 0.06);
  overflow: hidden;
}

.base-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.25rem;
  border-bottom: 1px solid var(--color-border, #e2e8f0);
}

.base-card-header h3 {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
  color: var(--color-text, #1a202c);
}

.padding-none .base-card-body { padding: 0; }
.padding-sm .base-card-body { padding: 0.75rem; }
.padding-md .base-card-body { padding: 1.25rem; }
.padding-lg .base-card-body { padding: 2rem; }
</style>
