<template>
  <router-link
    v-if="item.route"
    :to="item.route"
    class="sidebar-item"
    :class="{ active: isActive, collapsed }"
    :title="collapsed ? item.label : undefined"
  >
    <span v-if="item.dividerBefore" class="divider" />
    <span class="item-icon">{{ item.icon || '○' }}</span>
    <span v-if="!collapsed" class="item-label">{{ item.label }}</span>
    <span v-if="!collapsed && item.badge != null" class="item-badge">{{ item.badge }}</span>
  </router-link>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import type { DashNavItem } from '@/types';

const props = defineProps<{
  item: DashNavItem;
  collapsed: boolean;
}>();

const route = useRoute();

const isActive = computed(() => {
  if (!props.item.route) return false;
  const itemPath = props.item.route.split('?')[0];
  return route.path === itemPath;
});
</script>

<style scoped>
.divider {
  display: block;
  height: 1px;
  background: var(--color-border, #e2e8f0);
  margin: 0.5rem 0;
}

.sidebar-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.6rem 1rem;
  color: var(--color-text-muted, #718096);
  text-decoration: none;
  border-radius: 6px;
  transition: all 0.15s ease;
  font-size: 0.9rem;
  margin: 1px 0;
}

.sidebar-item.collapsed {
  justify-content: center;
  padding: 0.6rem;
}

.sidebar-item:hover {
  background: rgba(102, 126, 234, 0.08);
  color: var(--color-primary, #667eea);
}

.sidebar-item.active {
  background: rgba(102, 126, 234, 0.12);
  color: var(--color-primary, #667eea);
  font-weight: 600;
}

.item-icon {
  flex-shrink: 0;
  width: 1.25rem;
  text-align: center;
  font-size: 1rem;
}

.item-label {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.item-badge {
  background: var(--color-primary, #667eea);
  color: white;
  font-size: 0.7rem;
  font-weight: 600;
  padding: 0.1rem 0.45rem;
  border-radius: 10px;
  min-width: 1.25rem;
  text-align: center;
}
</style>
