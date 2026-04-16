<template>
  <div class="admin-users">
    <div class="header">
      <h1>Users</h1>
      <BaseButton @click="uiStore.showToast({ type: 'info', message: 'User creation coming soon.' })">
        ➕ Create User
      </BaseButton>
    </div>

    <div class="info-note">
      <AlertWidget
        type="info"
        title="User Management"
        message="Full user management features are coming soon. For now, users can register via the public registration page."
      />
    </div>

    <BaseEmptyState
      title="Coming Soon"
      message="User management will be available in a future update."
      icon="👥"
    />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';
import { useUiStore } from '@/stores/uiStore';
import BaseButton from '@/components/common/BaseButton.vue';
import BaseEmptyState from '@/components/common/BaseEmptyState.vue';
import AlertWidget from '@/components/dashboard/widgets/AlertWidget.vue';

const uiStore = useUiStore();

onMounted(() => {
  uiStore.setBreadcrumbs([
    { label: 'Dashboard', route: '/admin/dashboard' },
    { label: 'Users' },
  ]);
  uiStore.setPageTitle('Users');
});
</script>

<style scoped>
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.header h1 { margin: 0; color: var(--color-text); }

.info-note { margin-bottom: 1.5rem; }
</style>
