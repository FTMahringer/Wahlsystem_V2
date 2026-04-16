<template>
  <BaseCard :title="config.title" :padding="loading ? 'md' : 'md'">
    <div v-if="loading" class="widget-skeleton">
      <div class="skeleton-line wide" />
      <div class="skeleton-line" />
      <div class="skeleton-line narrow" />
    </div>
    <slot v-else />
  </BaseCard>
</template>

<script setup lang="ts">
import BaseCard from '@/components/common/BaseCard.vue';
import type { DashboardWidgetConfig } from '@/types';

defineProps<{
  config: DashboardWidgetConfig;
  loading?: boolean;
}>();
</script>

<style scoped>
.widget-skeleton {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.skeleton-line {
  height: 1rem;
  background: linear-gradient(90deg, #e2e8f0 25%, #edf2f7 50%, #e2e8f0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 4px;
  width: 80%;
}

.skeleton-line.wide { width: 100%; height: 2rem; }
.skeleton-line.narrow { width: 50%; }

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
</style>
