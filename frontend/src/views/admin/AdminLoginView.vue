<template>
  <div class="admin-login">
    <div class="login-card">
      <div class="login-header">
        <span class="login-icon">🗳️</span>
        <h1>Admin Login</h1>
        <p>Sign in to manage elections</p>
      </div>

      <form @submit.prevent="handleLogin" class="login-form" autocomplete="on">
        <div class="form-group">
          <label for="username">Username</label>
          <input
            id="username"
            v-model="credentials.username"
            type="text"
            placeholder="Enter username"
            autocomplete="username"
            required
            :disabled="authStore.loading || blocked"
          />
        </div>

        <div class="form-group">
          <label for="password">Password</label>
          <div class="password-wrapper">
            <input
              id="password"
              v-model="credentials.password"
              :type="showPassword ? 'text' : 'password'"
              placeholder="Enter password"
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
          {{ authStore.loading ? 'Signing in...' : 'Sign In' }}
        </button>
      </form>

      <div v-if="isDevMode" class="dev-tools">
        <p class="dev-tools__title">Dev tools</p>
        <button
          type="button"
          class="dev-btn"
          :disabled="authStore.loading"
          @click="handleDevLogin"
        >
          Sign in as admin
        </button>
        <button
          type="button"
          class="dev-btn dev-btn--secondary"
          :disabled="authStore.loading"
          @click="handleDevResetAdmin"
        >
          Reset admin to admin / admin123
        </button>
      </div>

      <div class="login-footer">
        <router-link to="/">← Back to Home</router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';

const authStore = useAuthStore();
const router = useRouter();

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
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 1rem;
}

.login-card {
  background: white;
  padding: 2.5rem;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 400px;
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
  margin: 0 0 0.25rem 0;
  color: var(--color-text, #1a202c);
  font-size: 1.5rem;
}

.login-header p {
  margin: 0;
  color: var(--color-text-muted, #718096);
  font-size: 0.9rem;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.form-group label {
  font-weight: 500;
  color: #555;
  font-size: 0.9rem;
}

.form-group input {
  padding: 0.75rem 1rem;
  border: 1.5px solid var(--color-border, #e2e8f0);
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.2s;
  width: 100%;
  box-sizing: border-box;
}

.form-group input:focus {
  outline: none;
  border-color: var(--color-primary, #667eea);
}

.form-group input:disabled {
  background: #f5f5f5;
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
  color: #888;
  display: flex;
  align-items: center;
  user-select: none;
}

.toggle-password:hover {
  color: #555;
}

.error-message {
  color: var(--color-danger, #e53e3e);
  font-size: 0.9rem;
  text-align: center;
  padding: 0.5rem;
  background: #fff5f5;
  border-radius: 6px;
  border: 1px solid #fed7d7;
}

.login-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  width: 100%;
  padding: 0.875rem;
  background: var(--color-primary, #667eea);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s;
}

.login-btn:hover:not(:disabled) {
  background: var(--color-primary-hover, #5a67d8);
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
  border-top: 1px solid var(--color-border, #e2e8f0);
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.dev-tools__title {
  margin: 0;
  text-align: center;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text-muted, #718096);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.dev-btn {
  width: 100%;
  padding: 0.75rem;
  border-radius: 8px;
  border: 1px solid var(--color-primary, #667eea);
  background: #eef2ff;
  color: var(--color-primary, #667eea);
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s, color 0.2s, border-color 0.2s;
}

.dev-btn:hover:not(:disabled) {
  background: #e0e7ff;
}

.dev-btn--secondary {
  border-color: #94a3b8;
  background: #f8fafc;
  color: #475569;
}

.dev-btn--secondary:hover:not(:disabled) {
  background: #f1f5f9;
}

.login-footer {
  margin-top: 1.5rem;
  text-align: center;
  padding-top: 1.25rem;
  border-top: 1px solid var(--color-border, #e2e8f0);
}

.login-footer a {
  color: var(--color-primary, #667eea);
  text-decoration: none;
  font-size: 0.9rem;
}

.login-footer a:hover {
  text-decoration: underline;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
