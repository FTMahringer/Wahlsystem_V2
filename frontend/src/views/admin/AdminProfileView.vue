<template>
  <div class="admin-profile">
    <h1>Profile</h1>

    <div v-if="user" class="profile-card">
      <div class="avatar">{{ initials }}</div>

      <div class="profile-fields">
        <div class="field">
          <label>Username</label>
          <span>{{ user.username }}</span>
        </div>
        <div class="field">
          <label>Email</label>
          <span>{{ user.email }}</span>
        </div>
        <div class="field">
          <label>Role</label>
          <span class="role-badge">{{ user.role }}</span>
        </div>
        <div v-if="user.firstName || user.lastName" class="field">
          <label>Name</label>
          <span>{{ user.firstName }} {{ user.lastName }}</span>
        </div>
        <div v-if="user.department" class="field">
          <label>Department</label>
          <span>{{ user.department }}</span>
        </div>
        <div v-if="user.createdAt" class="field">
          <label>Member Since</label>
          <span>{{ new Date(user.createdAt).toLocaleDateString('de-DE') }}</span>
        </div>
      </div>

      <div class="profile-actions">
        <BaseButton variant="danger" @click="handleLogout">🚪 Logout</BaseButton>
      </div>
    </div>

    <div v-else class="loading">Loading profile...</div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';
import { useUiStore } from '@/stores/uiStore';
import BaseButton from '@/components/common/BaseButton.vue';

const authStore = useAuthStore();
const uiStore = useUiStore();
const router = useRouter();

const user = computed(() => authStore.currentUser);

const initials = computed(() => {
  const u = user.value;
  if (!u) return '?';
  if (u.firstName && u.lastName) return (u.firstName[0] + u.lastName[0]).toUpperCase();
  return u.username.slice(0, 2).toUpperCase();
});

async function handleLogout() {
  await authStore.logout();
  router.push('/admin/login');
}

onMounted(() => {
  uiStore.setBreadcrumbs([
    { label: 'Dashboard', route: '/admin/dashboard' },
    { label: 'Profile' },
  ]);
  uiStore.setPageTitle('Profile');
});
</script>

<style scoped>
.admin-profile h1 {
  margin-bottom: 1.5rem;
  color: var(--color-text);
}

.profile-card {
  background: var(--color-surface);
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
  padding: 2rem;
  max-width: 500px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
}

.avatar {
  width: 4rem;
  height: 4rem;
  border-radius: 50%;
  background: var(--color-primary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  font-weight: 700;
}

.profile-fields {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.field {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--color-border);
}

.field label {
  font-weight: 500;
  color: var(--color-text-muted);
  font-size: 0.9rem;
}

.field span {
  color: var(--color-text);
  font-size: 0.95rem;
}

.role-badge {
  background: var(--color-primary);
  color: white !important;
  padding: 0.15rem 0.6rem;
  border-radius: 12px;
  font-size: 0.8rem !important;
  font-weight: 600;
  text-transform: uppercase;
}

.profile-actions {
  padding-top: 0.5rem;
}

.loading {
  text-align: center;
  padding: 2rem;
  color: var(--color-text-muted);
}
</style>
