<template>
  <nav class="breadcrumbs" v-if="uiStore.breadcrumbs.length > 0">
    <template v-for="(crumb, index) in uiStore.breadcrumbs" :key="index">
      <span v-if="index > 0" class="separator">/</span>
      <router-link
        v-if="crumb.route && index < uiStore.breadcrumbs.length - 1"
        :to="crumb.route"
        class="crumb-link"
      >
        {{ crumb.label }}
      </router-link>
      <span v-else class="crumb-current">{{ crumb.label }}</span>
    </template>
  </nav>
</template>

<script setup lang="ts">
import { useUiStore } from '@/stores/uiStore';

const uiStore = useUiStore();
</script>

<style scoped>
.breadcrumbs {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
}

.separator {
  color: var(--color-text-muted, #718096);
}

.crumb-link {
  color: var(--color-primary, #667eea);
  text-decoration: none;
}

.crumb-link:hover {
  text-decoration: underline;
}

.crumb-current {
  color: var(--color-text, #1a202c);
  font-weight: 500;
}
</style>
