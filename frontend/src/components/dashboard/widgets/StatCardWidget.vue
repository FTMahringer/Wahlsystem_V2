<template>
  <div class="stat-card" :style="color ? { borderTopColor: color } : {}">
    <p class="stat-title">{{ title }}</p>
    <p class="stat-value">{{ value }}</p>
    <p v-if="subtitle" class="stat-subtitle">
      <span v-if="trend === 'up'" class="trend up">↑</span>
      <span v-else-if="trend === 'down'" class="trend down">↓</span>
      <span v-else-if="trend === 'neutral'" class="trend neutral">→</span>
      {{ subtitle }}
    </p>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  title: string;
  value: string | number;
  subtitle?: string;
  trend?: 'up' | 'down' | 'neutral';
  color?: string;
}>();
</script>

<style scoped>
.stat-card {
  background: var(--color-surface, #ffffff);
  border-radius: 8px;
  padding: 1.25rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  border-top: 3px solid var(--color-primary, #667eea);
}

.stat-title {
  margin: 0 0 0.5rem 0;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-text-muted, #718096);
  font-weight: 600;
}

.stat-value {
  margin: 0;
  font-size: 2rem;
  font-weight: 700;
  color: var(--color-text, #1a202c);
}

.stat-subtitle {
  margin: 0.5rem 0 0 0;
  font-size: 0.85rem;
  color: var(--color-text-muted, #718096);
}

.trend {
  font-weight: 600;
}
.trend.up { color: var(--color-success, #38a169); }
.trend.down { color: var(--color-danger, #e53e3e); }
.trend.neutral { color: var(--color-text-muted, #718096); }
</style>
