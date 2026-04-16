<template>
  <div class="admin-layout" :class="{ 'sidebar-collapsed': uiStore.sidebarCollapsed }">
    <AppSidebar />
    <div class="admin-main">
      <AppNavbar />
      <main class="admin-content">
        <router-view />
      </main>
    </div>
    <GlobalToastLayer />
    <GlobalConfirmDialog />
  </div>
</template>

<script setup lang="ts">
import { useUiStore } from '@/stores/uiStore';
import AppSidebar from '@/components/navigation/AppSidebar.vue';
import AppNavbar from '@/components/navigation/AppNavbar.vue';
import GlobalToastLayer from '@/components/ui/GlobalToastLayer.vue';
import GlobalConfirmDialog from '@/components/ui/GlobalConfirmDialog.vue';

const uiStore = useUiStore();
</script>

<style scoped>
.admin-layout {
  display: flex;
  min-height: 100vh;
  background: var(--color-bg, #f8fafc);
}

.admin-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.admin-content {
  flex: 1;
  padding: 1.5rem 2rem;
  overflow-y: auto;
}
</style>
