<template>
  <aside class="app-sidebar" :class="{ collapsed: uiStore.sidebarCollapsed }">

    <!-- Logo -->
    <div class="sidebar-logo">
      <div class="logo-icon-wrap">🗳️</div>
      <span v-if="!uiStore.sidebarCollapsed" class="logo-text">Wahlsystem</span>
    </div>

    <!-- Main nav -->
    <nav class="sidebar-nav">
      <template v-for="item in mainItems" :key="item.id">
        <SidebarGroup
          v-if="item.children?.length"
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

    <!-- Bottom: settings + profile -->
    <div class="sidebar-bottom">
      <div class="bottom-divider" />
      <template v-for="item in bottomItems" :key="item.id">
        <SidebarItem :item="item" :collapsed="uiStore.sidebarCollapsed" />
      </template>
    </div>

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

const BOTTOM_IDS = new Set(['settings', 'profile']);

const allNavItems: DashNavItem[] = [
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
      { id: 'elections-all',    label: 'All Elections',    icon: '📋', route: '/admin/elections' },
      { id: 'elections-create', label: 'Create Election',  icon: '➕', route: '/admin/elections/create' },
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
    icon: '🔍',
    route: '/admin/audit',
    roles: ['ADMIN'],
  },
  {
    id: 'settings',
    label: 'Settings',
    icon: '⚙️',
    route: '/admin/settings',
    roles: ['ADMIN'],
  },
  {
    id: 'profile',
    label: 'Profile',
    icon: '👤',
    route: '/admin/profile',
  },
];

function isVisible(item: DashNavItem) {
  if (item.hidden) return false;
  if (item.roles?.length) return hasAnyRole(item.roles as any);
  return true;
}

const mainItems   = computed(() => allNavItems.filter(i => !BOTTOM_IDS.has(i.id) && isVisible(i)));
const bottomItems = computed(() => allNavItems.filter(i =>  BOTTOM_IDS.has(i.id) && isVisible(i)));
</script>

<style scoped>
.app-sidebar {
  width: var(--sidebar-width, 240px);
  height: 100vh;
  background: #131525;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  transition: width 0.25s ease;
  position: sticky;
  top: 0;
  flex-shrink: 0;
}

.app-sidebar.collapsed {
  width: 64px;
}

/* ─── Logo ─── */
.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1.25rem 1rem 1rem;
  white-space: nowrap;
  flex-shrink: 0;
}

.logo-icon-wrap {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.1rem;
  flex-shrink: 0;
}

.logo-text {
  font-weight: 700;
  font-size: 1.05rem;
  color: #fff;
  letter-spacing: 0.01em;
}

/* ─── Main nav ─── */
.sidebar-nav {
  flex: 1;
  padding: 0.5rem 0.6rem;
  overflow-y: auto;
  overflow-x: hidden;
  display: flex;
  flex-direction: column;
  gap: 2px;
  scrollbar-width: none;
}
.sidebar-nav::-webkit-scrollbar { display: none; }

/* ─── Bottom section ─── */
.sidebar-bottom {
  flex-shrink: 0;
  padding: 0 0.6rem 0.75rem;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.bottom-divider {
  height: 1px;
  background: rgba(255, 255, 255, 0.08);
  margin: 0 0.4rem 0.5rem;
}
</style>

