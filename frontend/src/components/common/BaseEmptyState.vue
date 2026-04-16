<template>
  <div class="empty-state">
    <div v-if="icon" class="empty-icon">{{ icon }}</div>
    <div v-else class="empty-icon">📭</div>
    <h3>{{ title }}</h3>
    <p>{{ message }}</p>
    <router-link v-if="action?.route" :to="action.route" class="empty-action">
      {{ action.label }}
    </router-link>
    <button v-else-if="action" class="empty-action" @click="$emit('action')">
      {{ action.label }}
    </button>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  title: string;
  message: string;
  icon?: string;
  action?: { label: string; route?: string };
}>();

defineEmits<{
  action: [];
}>();
</script>

<style scoped>
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 2rem;
  text-align: center;
}

.empty-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
  opacity: 0.7;
}

.empty-state h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.1rem;
  color: var(--color-text, #1a202c);
}

.empty-state p {
  margin: 0 0 1.5rem 0;
  color: var(--color-text-muted, #718096);
  font-size: 0.95rem;
  max-width: 360px;
}

.empty-action {
  display: inline-block;
  padding: 0.5rem 1.25rem;
  background: var(--color-primary, #667eea);
  color: white;
  text-decoration: none;
  border: none;
  border-radius: 6px;
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.15s;
}

.empty-action:hover {
  background: var(--color-primary-hover, #5a67d8);
}
</style>
