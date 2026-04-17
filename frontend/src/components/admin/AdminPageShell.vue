<template>
  <section class="page-shell">
    <header class="page-shell__header">
      <div>
        <h1 class="page-shell__title">{{ title }}</h1>
        <p v-if="description" class="page-shell__description">{{ description }}</p>
      </div>
      <div v-if="$slots.actions" class="page-shell__actions">
        <slot name="actions" />
      </div>
    </header>
    <div class="page-shell__body">
      <slot />
    </div>
  </section>
</template>

<script setup lang="ts">
defineProps<{
  title: string;
  description?: string;
}>();
</script>

<style scoped>
.page-shell {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.page-shell__header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.page-shell__title {
  margin: 0;
  color: var(--color-text);
}

.page-shell__description {
  margin: 0.35rem 0 0;
  color: var(--color-text-muted);
  max-width: 680px;
}

.page-shell__actions {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}
</style>
