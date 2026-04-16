<template>
  <BaseCard :title="title" padding="none">
    <div class="table-wrap">
      <table v-if="rows.length > 0">
        <thead>
          <tr>
            <th v-for="col in columns" :key="col.key">{{ col.label }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, i) in rows" :key="i">
            <td v-for="col in columns" :key="col.key">{{ row[col.key] ?? '—' }}</td>
          </tr>
        </tbody>
      </table>
      <div v-else class="empty-table">
        {{ emptyText || 'No data available' }}
      </div>
    </div>
  </BaseCard>
</template>

<script setup lang="ts">
import BaseCard from '@/components/common/BaseCard.vue';

defineProps<{
  title: string;
  columns: { key: string; label: string }[];
  rows: Record<string, any>[];
  emptyText?: string;
}>();
</script>

<style scoped>
.table-wrap {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 0.75rem 1rem;
  text-align: left;
  border-bottom: 1px solid var(--color-border, #e2e8f0);
  font-size: 0.9rem;
}

th {
  background: #f8fafc;
  font-weight: 600;
  color: var(--color-text-muted, #718096);
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}

td {
  color: var(--color-text, #1a202c);
}

tbody tr:hover {
  background: rgba(102, 126, 234, 0.04);
}

.empty-table {
  padding: 2rem;
  text-align: center;
  color: var(--color-text-muted, #718096);
}
</style>
