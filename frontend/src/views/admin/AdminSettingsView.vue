<template>
  <div class="admin-settings">
    <h1>Settings</h1>

    <AlertWidget
      type="info"
      title="System Settings"
      message="System settings will be available in a future update."
    />

    <BaseEmptyState
      title="Coming Soon"
      message="Configuration options for the election system are planned."
      icon="⚙️"
    />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';
import { useUiStore } from '@/stores/uiStore';
import AlertWidget from '@/components/dashboard/widgets/AlertWidget.vue';
import BaseEmptyState from '@/components/common/BaseEmptyState.vue';

const uiStore = useUiStore();

onMounted(() => {
  uiStore.setBreadcrumbs([
    { label: 'Dashboard', route: '/admin/dashboard' },
    { label: 'Settings' },
  ]);
  uiStore.setPageTitle('Settings');
});
</script>

<style scoped>
.admin-settings h1 {
  margin-bottom: 1.5rem;
  color: var(--color-text);
}
</style>
