<template>
  <BaseCard :title="title">
    <div class="actions-grid">
      <template v-for="action in actions" :key="action.label">
        <router-link
          v-if="action.route"
          :to="action.route"
          class="action-btn"
        >
          <span v-if="action.icon" class="action-icon">{{ action.icon }}</span>
          {{ action.label }}
        </router-link>
        <button
          v-else
          class="action-btn"
          @click="action.action?.()"
        >
          <span v-if="action.icon" class="action-icon">{{ action.icon }}</span>
          {{ action.label }}
        </button>
      </template>
    </div>
  </BaseCard>
</template>

<script setup lang="ts">
import BaseCard from '@/components/common/BaseCard.vue';

defineProps<{
  title: string;
  actions: { label: string; icon?: string; route?: string; action?: () => void }[];
}>();
</script>

<style scoped>
.actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 0.75rem;
}

.action-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  padding: 1rem;
  background: var(--color-bg, #f8fafc);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 8px;
  text-decoration: none;
  color: var(--color-text, #1a202c);
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.15s;
}

.action-btn:hover {
  background: rgba(102, 126, 234, 0.08);
  border-color: var(--color-primary, #667eea);
  color: var(--color-primary, #667eea);
}

.action-icon {
  font-size: 1.5rem;
}
</style>
