<template>
  <div class="admin-login">
    <div class="login-topbar">
      <router-link to="/" class="home-link">{{ t('common.backToHome') }}</router-link>
      <AppPreferencesControls />
    </div>

    <div class="login-card">
      <div class="login-header">
        <span class="login-icon">🗳️</span>
        <h1>{{ t('auth.adminLoginTitle') }}</h1>
        <p>{{ t('auth.adminLoginSubtitle') }}</p>
      </div>

      <form @submit.prevent="handleLogin" class="login-form" autocomplete="on">
        <div class="form-group">
          <label for="username">{{ t('auth.username') }}</label>
          <input
            id="username"
            v-model="credentials.username"
            type="text"
            :placeholder="t('auth.usernamePlaceholder')"
            autocomplete="username"
            required
            :disabled="authStore.loading || blocked"
          />
        </div>

        <div class="form-group">
          <label for="password">{{ t('auth.password') }}</label>
          <div class="password-wrapper">
            <input
              id="password"
              v-model="credentials.password"
              :type="showPassword ? 'text' : 'password'"
              :placeholder="t('auth.passwordPlaceholder')"
              autocomplete="current-password"
              required
              :disabled="authStore.loading || blocked"
            />
            <button
              type="button"
              class="toggle-password"
              @click="showPassword = !showPassword"
              :aria-label="showPassword ? 'Hide password' : 'Show password'"
              tabindex="-1"
            >
              <span v-if="showPassword">🙈</span>
              <span v-else>👁️</span>
            </button>
          </div>
        </div>

        <div v-if="authStore.error" class="error-message">
          {{ authStore.error }}
        </div>

        <button
          type="submit"
          class="login-btn"
          :disabled="authStore.loading || !isValid || blocked"
        >
          <span v-if="authStore.loading" class="spinner" />
          {{ authStore.loading ? t('auth.signingIn') : t('auth.signIn') }}
        </button>
      </form>

      <div v-if="isDevMode" class="dev-tools">
        <p class="dev-tools__title">{{ t('auth.devTools') }}</p>
        <button
          type="button"
          class="dev-btn"
          :disabled="authStore.loading"
          @click="handleDevLogin"
        >
          {{ t('auth.devSignInAdmin') }}
        </button>
        <button
          type="button"
          class="dev-btn dev-btn--secondary"
          :disabled="authStore.loading"
          @click="handleDevResetAdmin"
        >
          {{ t('auth.devResetAdmin') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { useRouter } from 'vue-router';
import AppPreferencesControls from '@/components/common/AppPreferencesControls.vue';
import { useLocale } from '@/composables/useLocale';
import { useAuthStore } from '@/stores/authStore';

const authStore = useAuthStore();
const router = useRouter();
const { t } = useLocale();

const credentials = reactive({ username: '', password: '' });
const showPassword = ref(false);
const blocked = ref(false);
const isDevMode = import.meta.env.DEV;

const isValid = computed(() =>
  credentials.username.length >= 1 && credentials.password.length >= 1
);

onMounted(() => {
  if (authStore.isAuthenticated && authStore.isAdminOrTeacher) {
    router.replace('/admin/dashboard');
  }
  authStore.error = null;
});

async function handleLogin() {
  if (blocked.value) return;
  const success = await authStore.login(credentials);
  if (success) {
    router.push('/admin/dashboard');
  } else if (authStore.error?.includes('seconds')) {
    blocked.value = true;
    setTimeout(() => {
      blocked.value = false;
      authStore.error = null;
    }, 15 * 60 * 1000);
  }
}

async function handleDevLogin() {
  const success = await authStore.devLogin('admin');
  if (success) {
    router.push('/admin/dashboard');
  }
}

async function handleDevResetAdmin() {
  const success = await authStore.devResetAdmin();
  if (success) {
    router.push('/admin/dashboard');
  }
}
</script>

<style scoped>
.admin-login {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, var(--color-primary) 0%, #764ba2 100%);
  padding: 1rem;
}

.login-topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  margin-bottom: 2rem;
}

.home-link {
  color: white;
  text-decoration: none;
  font-weight: 600;
}

.login-card {
  width: 100%;
  max-width: 420px;
  margin: auto;
  background: var(--color-surface);
  color: var(--color-text);
  padding: 2.5rem;
  border-radius: 16px;
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.28);
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.login-header {
  text-align: center;
  margin-bottom: 2rem;
}

.login-icon {
  font-size: 2.5rem;
  display: block;
  margin-bottom: 0.5rem;
}

.login-header h1 {
  margin: 0 0 0.25rem;
  color: var(--color-text);
  font-size: 1.5rem;
}

.login-header p {
  margin: 0;
  color: var(--color-text-muted);
  font-size: 0.95rem;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.45rem;
}

.form-group label {
  font-weight: 500;
  color: var(--color-text);
  font-size: 0.9rem;
}

.form-group input {
  padding: 0.8rem 1rem;
  border: 1px solid var(--color-border);
  border-radius: 10px;
  font-size: 1rem;
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
  width: 100%;
  background: var(--color-surface);
  color: var(--color-text);
}

.form-group input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.18);
}

.form-group input:disabled {
  opacity: 0.7;
}

.password-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.password-wrapper input {
  padding-right: 2.75rem;
}

.toggle-password {
  position: absolute;
  right: 0.75rem;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0;
  font-size: 1.1rem;
  line-height: 1;
  color: var(--color-text-muted);
  display: flex;
  align-items: center;
}

.error-message {
  color: var(--color-danger);
  font-size: 0.9rem;
  text-align: center;
  padding: 0.75rem;
  background: rgba(229, 62, 62, 0.12);
  border-radius: 8px;
  border: 1px solid rgba(229, 62, 62, 0.22);
}

.login-btn,
.dev-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  width: 100%;
  padding: 0.875rem;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.15s ease, background 0.2s ease, border-color 0.2s ease;
}

.login-btn {
  background: var(--color-primary);
  color: white;
}

.login-btn:hover:not(:disabled),
.dev-btn:hover:not(:disabled) {
  transform: translateY(-1px);
}

.login-btn:hover:not(:disabled) {
  background: var(--color-primary-hover);
}

.login-btn:disabled,
.dev-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.spinner {
  display: inline-block;
  width: 1em;
  height: 1em;
  border: 2px solid currentColor;
  border-right-color: transparent;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

.dev-tools {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid var(--color-border);
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.dev-tools__title {
  margin: 0;
  text-align: center;
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.dev-btn {
  background: var(--color-surface-muted);
  color: var(--color-text);
  border: 1px solid var(--color-border);
}

.dev-btn--secondary {
  background: transparent;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

@media (max-width: 720px) {
  .admin-login {
    padding: 0.75rem;
  }

  .login-topbar {
    flex-direction: column;
    align-items: stretch;
  }

  .login-card {
    padding: 1.5rem;
  }
}
</style>
