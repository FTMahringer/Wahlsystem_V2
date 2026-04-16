<template>
  <aside class="app-sidebar" :class="{ collapsed: uiStore.sidebarCollapsed }">
    <div class="sidebar-logo">
      <span class="logo-icon">🗳️</span>
      <span v-if="!uiStore.sidebarCollapsed" class="logo-text">Wahlsystem</span>
    </div>

    <nav class="sidebar-nav">
      <template v-for="item in visibleItems" :key="item.id">
        <SidebarGroup
          v-if="item.children && item.children.length > 0"
          :item="item"
          :collapsed="uiStore.sidebarCollapsed"
        />
        <SidebarItem
          v-else
          :item="item"
          :collapsed="uiStore.sidebarCollapsed"
        />
      </template>
    </nav>
  </aside>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useUiStore } from '@/stores/uiStore';
import { useRole } from '@/composables/useRole';
import type { DashNavItem } from '@/types';
import SidebarItem from './SidebarItem.vue';
import SidebarGroup from './SidebarGroup.vue';

const uiStore = useUiStore();
const { hasAnyRole } = useRole();

const navItems: DashNavItem[] = [
  {
    id: 'dashboard',
    label: 'Dashboard',
    icon: '📊',
    route: '/admin/dashboard',
  },
  {
    id: 'elections',
    label: 'Elections',
    icon: '🗳️',
    children: [
      { id: 'elections-active', label: 'Active Elections', icon: '▶', route: '/admin/elections?status=ACTIVE' },
      { id: 'elections-all', label: 'All Elections', icon: '📋', route: '/admin/elections' },
      { id: 'elections-create', label: 'Create Election', icon: '➕', route: '/admin/elections/create' },
    ],
  },
  {
    id: 'candidates',
    label: 'Candidates',
    icon: '👤',
    route: '/admin/candidates',
  },
  {
    id: 'voters',
    label: 'Voters',
    icon: '👥',
    route: '/admin/voters',
    dividerBefore: true,
  },
  {
    id: 'results',
    label: 'Results',
    icon: '📈',
    route: '/admin/results',
  },
  {
    id: 'audit',
    label: 'Audit Logs',
    icon: '📝',
    route: '/admin/audit',
    roles: ['ADMIN'],
  },
  {
    id: 'settings',
    label: 'Settings',
    icon: '⚙️',
    route: '/admin/settings',
    roles: ['ADMIN'],
    dividerBefore: true,
  },
  {
    id: 'profile',
    label: 'Profile',
    icon: '👤',
    route: '/admin/profile',
  },
];

const visibleItems = computed(() => {
  return navItems.filter(item => {
    if (item.hidden) return false;
    if (item.roles && item.roles.length > 0) {
      return hasAnyRole(item.roles as any);
    }
    return true;
  });
});
</script>

<style scoped>
.app-sidebar {
  width: var(--sidebar-width, 240px);
  height: 100vh;
  background: var(--color-surface, #ffffff);
  border-right: 1px solid var(--color-border, #e2e8f0);
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  overflow-x: hidden;
  transition: width 0.2s ease;
  position: sticky;
  top: 0;
}

.app-sidebar.collapsed {
  width: 60px;
}

.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1.25rem 1rem;
  border-bottom: 1px solid var(--color-border, #e2e8f0);
  white-space: nowrap;
}

.logo-icon {
  font-size: 1.5rem;
  flex-shrink: 0;
}

.logo-text {
  font-weight: 700;
  font-size: 1.1rem;
  color: var(--color-text, #1a202c);
}

.sidebar-nav {
  flex: 1;
  padding: 0.75rem 0.5rem;
  display: flex;
  flex-direction: column;
}
</style>
