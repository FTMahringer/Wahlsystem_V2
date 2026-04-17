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

    <!-- Inactivity warning overlay -->
    <Transition name="fade">
      <div v-if="showWarning" class="inactivity-overlay" @click="resetTimer">
        <div class="inactivity-dialog">
          <span class="inactivity-icon">⏱️</span>
          <h3>{{ t('shell.inactivityTitle') }}</h3>
          <p>{{ t('shell.inactivityMessage', { seconds: countdownSecs }) }}</p>
          <button class="stay-btn" @click="resetTimer">{{ t('shell.stayLoggedIn') }}</button>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import { useUiStore } from '@/stores/uiStore';
import { useAuthStore } from '@/stores/authStore';
import { useLocale } from '@/composables/useLocale';
import AppSidebar from '@/components/navigation/AppSidebar.vue';
import AppNavbar from '@/components/navigation/AppNavbar.vue';
import GlobalToastLayer from '@/components/ui/GlobalToastLayer.vue';
import GlobalConfirmDialog from '@/components/ui/GlobalConfirmDialog.vue';

const uiStore = useUiStore();
const authStore = useAuthStore();
const router = useRouter();
const { t } = useLocale();

const IDLE_MS = 30 * 60 * 1000;       // 30 minutes until logout
const WARN_MS = IDLE_MS - 60 * 1000;  // warn 60 seconds before

const showWarning = ref(false);
const countdownSecs = ref(60);

let idleTimer: ReturnType<typeof setTimeout> | null = null;
let warnTimer: ReturnType<typeof setTimeout> | null = null;
let countdownInterval: ReturnType<typeof setInterval> | null = null;

const ACTIVITY_EVENTS = ['mousemove', 'mousedown', 'keydown', 'scroll', 'touchstart', 'click'];

function resetTimer() {
  showWarning.value = false;
  countdownSecs.value = 60;
  clearTimeout(idleTimer!);
  clearTimeout(warnTimer!);
  clearInterval(countdownInterval!);

  warnTimer = setTimeout(showWarningDialog, WARN_MS);
  idleTimer = setTimeout(handleIdle, IDLE_MS);
}

function showWarningDialog() {
  showWarning.value = true;
  countdownSecs.value = 60;
  countdownInterval = setInterval(() => {
    countdownSecs.value--;
    if (countdownSecs.value <= 0) clearInterval(countdownInterval!);
  }, 1000);
}

async function handleIdle() {
  showWarning.value = false;
  await authStore.logout();
  router.push('/');
}

onMounted(() => {
  ACTIVITY_EVENTS.forEach(e => window.addEventListener(e, resetTimer, { passive: true }));
  resetTimer();
});

onUnmounted(() => {
  ACTIVITY_EVENTS.forEach(e => window.removeEventListener(e, resetTimer));
  clearTimeout(idleTimer!);
  clearTimeout(warnTimer!);
  clearInterval(countdownInterval!);
});
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

/* Inactivity warning */
.inactivity-overlay {
  position: fixed;
  inset: 0;
  background: var(--color-overlay);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.inactivity-dialog {
  background: var(--color-surface);
  border-radius: 12px;
  padding: 2rem 2.5rem;
  text-align: center;
  max-width: 360px;
  width: 90%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.inactivity-icon {
  font-size: 2.5rem;
  display: block;
  margin-bottom: 0.75rem;
}

.inactivity-dialog h3 {
  margin: 0 0 0.5rem;
  font-size: 1.25rem;
  color: var(--color-text);
}

.inactivity-dialog p {
  color: var(--color-text-muted);
  font-size: 0.95rem;
  margin: 0 0 1.5rem;
}

.stay-btn {
  background: var(--color-primary, #667eea);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 0.75rem 2rem;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s;
}

.stay-btn:hover {
  background: var(--color-primary-hover, #5a67d8);
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.25s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
