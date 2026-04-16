<template>
  <div class="sidebar-group">
    <button
      class="group-header"
      :class="{ collapsed, active: hasActiveChild }"
      @click="toggle"
      :title="collapsed ? item.label : undefined"
    >
      <span class="group-icon-wrap">{{ item.icon || '📁' }}</span>
      <template v-if="!collapsed">
        <span class="group-label">{{ item.label }}</span>
        <span class="group-arrow" :class="{ open: isOpen }">
          <svg width="12" height="12" viewBox="0 0 12 12" fill="currentColor">
            <path d="M4.5 2L8.5 6L4.5 10" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
          </svg>
        </span>
      </template>
    </button>

    <Transition name="expand">
      <div v-if="isOpen && !collapsed" class="group-children">
        <SidebarItem
          v-for="child in visibleChildren"
          :key="child.id"
          :item="child"
          :collapsed="collapsed"
        />
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import { useRoute } from 'vue-router';
import { useRole } from '@/composables/useRole';
import type { DashNavItem } from '@/types';
import SidebarItem from './SidebarItem.vue';

const props = defineProps<{ item: DashNavItem; collapsed: boolean }>();

const route = useRoute();
const { hasAnyRole } = useRole();
const isOpen = ref(false);

const visibleChildren = computed(() => {
  if (!props.item.children) return [];
  return props.item.children.filter(child => {
    if (child.hidden) return false;
    if (child.roles?.length) return hasAnyRole(child.roles as any);
    return true;
  });
});

const hasActiveChild = computed(() =>
  props.item.children?.some(c => c.route && route.path === c.route.split('?')[0]) ?? false
);

watch(hasActiveChild, active => { if (active) isOpen.value = true; }, { immediate: true });

function toggle() {
  if (!props.collapsed) isOpen.value = !isOpen.value;
}
</script>

<style scoped>
.group-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  width: 100%;
  padding: 0.45rem 0.6rem;
  background: none;
  border: none;
  border-radius: 8px;
  color: #8892b0;
  cursor: pointer;
  font-size: 0.875rem;
  font-weight: 500;
  transition: background 0.15s, color 0.15s;
  text-align: left;
  white-space: nowrap;
}

.group-header.collapsed {
  justify-content: center;
  padding: 0.5rem;
}

.group-header:hover {
  background: rgba(255, 255, 255, 0.06);
  color: #ccd6f6;
}

.group-header.active {
  color: #ccd6f6;
}

.group-icon-wrap {
  flex-shrink: 0;
  width: 32px;
  height: 32px;
  border-radius: 8px;
  background: rgba(59, 130, 246, 0.22);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.95rem;
}

.group-label {
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
}

.group-arrow {
  flex-shrink: 0;
  color: #4a5568;
  transition: transform 0.2s ease;
  display: flex;
  align-items: center;
}
.group-arrow.open {
  transform: rotate(90deg);
}

/* Children indented */
.group-children {
  padding-left: 0.5rem;
  display: flex;
  flex-direction: column;
  gap: 2px;
  margin-top: 2px;
}

/* Expand transition */
.expand-enter-active,
.expand-leave-active {
  transition: all 0.2s ease;
  overflow: hidden;
}
.expand-enter-from,
.expand-leave-to {
  opacity: 0;
  max-height: 0;
}
.expand-enter-to,
.expand-leave-from {
  opacity: 1;
  max-height: 300px;
}
</style>

