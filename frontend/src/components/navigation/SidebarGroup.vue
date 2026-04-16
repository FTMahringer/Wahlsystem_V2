<template>
  <div class="sidebar-group">
    <div v-if="item.dividerBefore" class="group-divider" />
    <button
      class="group-header"
      :class="{ collapsed, active: hasActiveChild }"
      @click="toggle"
      :title="collapsed ? item.label : undefined"
    >
      <span class="group-icon">{{ item.icon || '📁' }}</span>
      <template v-if="!collapsed">
        <span class="group-label">{{ item.label }}</span>
        <span class="group-arrow" :class="{ open: isOpen }">▸</span>
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

const props = defineProps<{
  item: DashNavItem;
  collapsed: boolean;
}>();

const route = useRoute();
const { hasAnyRole } = useRole();

const isOpen = ref(false);

const visibleChildren = computed(() => {
  if (!props.item.children) return [];
  return props.item.children.filter(child => {
    if (child.hidden) return false;
    if (child.roles && child.roles.length > 0) {
      return hasAnyRole(child.roles as any);
    }
    return true;
  });
});

const hasActiveChild = computed(() => {
  if (!props.item.children) return false;
  return props.item.children.some(child => {
    if (!child.route) return false;
    const childPath = child.route.split('?')[0];
    return route.path === childPath;
  });
});

watch(hasActiveChild, (active) => {
  if (active) isOpen.value = true;
}, { immediate: true });

function toggle() {
  if (props.collapsed) return;
  isOpen.value = !isOpen.value;
}
</script>

<style scoped>
.group-divider {
  height: 1px;
  background: var(--color-border, #e2e8f0);
  margin: 0.5rem 0;
}

.group-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  width: 100%;
  padding: 0.6rem 1rem;
  background: none;
  border: none;
  border-radius: 6px;
  color: var(--color-text-muted, #718096);
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.15s ease;
  text-align: left;
}

.group-header.collapsed {
  justify-content: center;
  padding: 0.6rem;
}

.group-header:hover {
  background: rgba(102, 126, 234, 0.08);
  color: var(--color-primary, #667eea);
}

.group-header.active {
  color: var(--color-primary, #667eea);
}

.group-icon {
  flex-shrink: 0;
  width: 1.25rem;
  text-align: center;
  font-size: 1rem;
}

.group-label {
  flex: 1;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.group-arrow {
  font-size: 0.75rem;
  transition: transform 0.2s ease;
  flex-shrink: 0;
}
.group-arrow.open {
  transform: rotate(90deg);
}

.group-children {
  padding-left: 1rem;
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
  max-height: 500px;
}
</style>
