<template>
  <header class="app-navbar">
    <div class="navbar-left">
      <button class="hamburger" @click="uiStore.toggleSidebar()" aria-label="Toggle sidebar">
        ☰
      </button>
      <Breadcrumbs />
    </div>

    <div class="navbar-right">
      <div class="user-menu" v-if="authStore.isAuthenticated">
        <button class="user-trigger" @click="menuOpen = !menuOpen">
          <span class="user-avatar">{{ initials }}</span>
          <span class="user-name">{{ displayName }}</span>
          <span class="dropdown-arrow">▾</span>
        </button>
        <Transition name="dropdown">
          <div v-if="menuOpen" class="dropdown-menu" @click="menuOpen = false">
            <div class="dropdown-header">
              <strong>{{ displayName }}</strong>
              <small>{{ authStore.currentUser?.role }}</small>
            </div>
            <div class="dropdown-divider" />
            <router-link to="/admin/profile" class="dropdown-item">👤 Profile</router-link>
            <button class="dropdown-item" @click="handleLogout">🚪 Logout</button>
          </div>
        </Transition>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';
import { useUiStore } from '@/stores/uiStore';
import Breadcrumbs from './Breadcrumbs.vue';

const authStore = useAuthStore();
const uiStore = useUiStore();
const router = useRouter();

const menuOpen = ref(false);

const displayName = computed(() => {
  const user = authStore.currentUser;
  if (!user) return '';
  if (user.fullName) return user.fullName;
  if (user.firstName && user.lastName) return `${user.firstName} ${user.lastName}`;
  return user.username;
});

const initials = computed(() => {
  const name = displayName.value;
  if (!name) return '?';
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
});

async function handleLogout() {
  await authStore.logout();
  router.push('/admin/login');
}
</script>

<style scoped>
.app-navbar {
  height: var(--navbar-height, 60px);
  background: var(--color-surface, #ffffff);
  border-bottom: 1px solid var(--color-border, #e2e8f0);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 1.5rem;
  position: sticky;
  top: 0;
  z-index: 100;
}

.navbar-left {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.hamburger {
  background: none;
  border: none;
  font-size: 1.25rem;
  cursor: pointer;
  padding: 0.35rem 0.5rem;
  border-radius: 6px;
  color: var(--color-text-muted, #718096);
  transition: all 0.15s;
}
.hamburger:hover {
  background: rgba(0, 0, 0, 0.05);
  color: var(--color-text, #1a202c);
}

.navbar-right {
  display: flex;
  align-items: center;
}

.user-menu {
  position: relative;
}

.user-trigger {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.35rem 0.5rem;
  border-radius: 6px;
  transition: background 0.15s;
}
.user-trigger:hover {
  background: rgba(0, 0, 0, 0.05);
}

.user-avatar {
  width: 2rem;
  height: 2rem;
  border-radius: 50%;
  background: var(--color-primary, #667eea);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  font-weight: 600;
}

.user-name {
  font-size: 0.9rem;
  color: var(--color-text, #1a202c);
  font-weight: 500;
}

.dropdown-arrow {
  font-size: 0.75rem;
  color: var(--color-text-muted, #718096);
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 0.5rem;
  background: var(--color-surface, #ffffff);
  border: 1px solid var(--color-border, #e2e8f0);
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  min-width: 200px;
  overflow: hidden;
  z-index: 200;
}

.dropdown-header {
  padding: 0.75rem 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
}
.dropdown-header strong {
  font-size: 0.9rem;
  color: var(--color-text, #1a202c);
}
.dropdown-header small {
  font-size: 0.75rem;
  color: var(--color-text-muted, #718096);
  text-transform: uppercase;
}

.dropdown-divider {
  height: 1px;
  background: var(--color-border, #e2e8f0);
}

.dropdown-item {
  display: block;
  width: 100%;
  padding: 0.6rem 1rem;
  background: none;
  border: none;
  text-align: left;
  font-size: 0.9rem;
  color: var(--color-text, #1a202c);
  cursor: pointer;
  text-decoration: none;
  transition: background 0.15s;
}
.dropdown-item:hover {
  background: rgba(0, 0, 0, 0.04);
}

/* Transitions */
.dropdown-enter-active,
.dropdown-leave-active {
  transition: all 0.15s ease;
}
.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}
</style>
