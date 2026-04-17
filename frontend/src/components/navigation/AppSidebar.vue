<template>
  <aside class="app-sidebar" :class="{ collapsed: uiStore.sidebarCollapsed }">

    <!-- Logo -->
    <div class="sidebar-logo">
      <div class="logo-icon-wrap">🗳️</div>
      <span v-if="!uiStore.sidebarCollapsed" class="logo-text">{{ t('app.name') }}</span>
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
import { useLocale } from '@/composables/useLocale';
import { useRole } from '@/composables/useRole';
import type { DashNavItem } from '@/types';
import SidebarItem from './SidebarItem.vue';
import SidebarGroup from './SidebarGroup.vue';

const uiStore = useUiStore();
const { hasAnyRole } = useRole();
const { t } = useLocale();

const BOTTOM_IDS = new Set(['settings', 'profile']);

const allNavItems = computed<DashNavItem[]>(() => [
  {
    id: 'dashboard',
    label: t('nav.dashboard'),
    icon: '📊',
    route: '/admin/dashboard',
  },
  {
    id: 'elections',
    label: t('nav.elections'),
    icon: '🗳️',
    children: [
      { id: 'elections-active', label: t('nav.activeElections'), icon: '▶', route: '/admin/elections?status=ACTIVE' },
      { id: 'elections-all', label: t('nav.allElections'), icon: '📋', route: '/admin/elections' },
      { id: 'elections-create', label: t('nav.createElection'), icon: '➕', route: '/admin/elections/create' },
    ],
  },
  {
    id: 'candidates',
    label: t('nav.candidates'),
    icon: '👤',
    route: '/admin/candidates',
  },
  {
    id: 'voters',
    label: t('nav.voters'),
    icon: '👥',
    route: '/admin/voters',
  },
  {
    id: 'results',
    label: t('nav.results'),
    icon: '📈',
    route: '/admin/results',
  },
  {
    id: 'audit',
    label: t('nav.audit'),
    icon: '🔍',
    route: '/admin/audit',
    roles: ['ADMIN'],
  },
  {
    id: 'settings',
    label: t('nav.settings'),
    icon: '⚙️',
    route: '/admin/settings',
    roles: ['ADMIN'],
  },
  {
    id: 'profile',
    label: t('nav.profile'),
    icon: '👤',
    route: '/admin/profile',
  },
]);

function isVisible(item: DashNavItem) {
  if (item.hidden) return false;
  if (item.roles?.length) return hasAnyRole(item.roles as any);
  return true;
}

const mainItems = computed(() => allNavItems.value.filter(i => !BOTTOM_IDS.has(i.id) && isVisible(i)));
const bottomItems = computed(() => allNavItems.value.filter(i => BOTTOM_IDS.has(i.id) && isVisible(i)));
</script>

<style scoped>
.app-sidebar {
  width: var(--sidebar-width, 240px);
  height: 100vh;
  background: var(--color-sidebar-bg);
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
  color: var(--color-sidebar-text);
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

