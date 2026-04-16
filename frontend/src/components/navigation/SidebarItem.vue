<template>
  <router-link
    v-if="item.route"
    :to="item.route"
    class="sidebar-item"
    :class="{ active: isActive, collapsed }"
    :title="collapsed ? item.label : undefined"
  >
    <span class="item-icon-wrap" :style="{ background: iconColor }">{{ item.icon || '○' }}</span>
    <span v-if="!collapsed" class="item-label">{{ item.label }}</span>
    <span v-if="!collapsed && item.badge != null" class="item-badge">{{ item.badge }}</span>
  </router-link>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import type { DashNavItem } from '@/types';

const ICON_COLORS: Record<string, string> = {
  dashboard:       'rgba(99,102,241,0.25)',
  elections:       'rgba(59,130,246,0.25)',
  'elections-active': 'rgba(16,185,129,0.25)',
  'elections-all': 'rgba(59,130,246,0.25)',
  'elections-create': 'rgba(139,92,246,0.25)',
  candidates:      'rgba(139,92,246,0.25)',
  voters:          'rgba(20,184,166,0.25)',
  results:         'rgba(34,197,94,0.25)',
  audit:           'rgba(245,158,11,0.25)',
  settings:        'rgba(100,116,139,0.25)',
  profile:         'rgba(244,63,94,0.25)',
};

const props = defineProps<{ item: DashNavItem; collapsed: boolean }>();
const route = useRoute();

const isActive = computed(() => {
  if (!props.item.route) return false;
  return route.path === props.item.route.split('?')[0];
});

const iconColor = computed(() => ICON_COLORS[props.item.id] ?? 'rgba(255,255,255,0.1)');
</script>

<style scoped>
.sidebar-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.45rem 0.6rem;
  color: #8892b0;
  text-decoration: none;
  border-radius: 8px;
  transition: background 0.15s, color 0.15s;
  font-size: 0.875rem;
  font-weight: 500;
  position: relative;
  white-space: nowrap;
}

.sidebar-item.collapsed {
  justify-content: center;
  padding: 0.5rem;
}

.sidebar-item:hover {
  background: rgba(255, 255, 255, 0.06);
  color: #ccd6f6;
}

.sidebar-item.active {
  background: rgba(102, 126, 234, 0.18);
  color: #fff;
}

.sidebar-item.active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 20%;
  height: 60%;
  width: 3px;
  border-radius: 0 3px 3px 0;
  background: #667eea;
}

.item-icon-wrap {
  flex-shrink: 0;
  width: 32px;
  height: 32px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.95rem;
  transition: background 0.15s;
}

.item-label {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
}

.item-badge {
  background: #667eea;
  color: white;
  font-size: 0.68rem;
  font-weight: 700;
  padding: 0.1rem 0.4rem;
  border-radius: 10px;
}
</style>

