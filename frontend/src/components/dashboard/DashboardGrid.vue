<template>
  <div class="dashboard-grid">
    <div
      v-for="widget in widgets"
      :key="widget.id"
      class="grid-item"
      :class="[`size-${widget.size || 'sm'}`]"
    >
      <slot :name="widget.id" :widget="widget" />
    </div>
  </div>
</template>

<script setup lang="ts">
import type { DashboardWidgetConfig } from '@/types';

defineProps<{
  widgets: DashboardWidgetConfig[];
}>();
</script>

<style scoped>
.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.5rem;
}

.grid-item.size-sm {
  grid-column: span 1;
}

.grid-item.size-md {
  grid-column: span 2;
}

.grid-item.size-lg {
  grid-column: span 4;
}

@media (max-width: 1024px) {
  .dashboard-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .grid-item.size-lg {
    grid-column: span 2;
  }
}

@media (max-width: 640px) {
  .dashboard-grid {
    grid-template-columns: 1fr;
  }
  .grid-item.size-sm,
  .grid-item.size-md,
  .grid-item.size-lg {
    grid-column: span 1;
  }
}
</style>
