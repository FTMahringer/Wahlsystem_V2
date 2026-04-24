<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <h1>{{ t("app.name") }}</h1>
        <p class="subtitle">{{ t("auth.signInToAccount") }}</p>
      </div>

      <form @submit.prevent="handleLogin" class="login-form">
        <div class="form-group">
          <label for="username">{{ t("auth.username") }}</label>
          <input
            id="username"
            v-model="credentials.username"
            type="text"
            required
            :disabled="authStore.loading"
            :placeholder="t('auth.usernamePlaceholder')"
          />
        </div>

        <div class="form-group">
          <label for="password">{{ t("auth.password") }}</label>
          <input
            id="password"
            v-model="credentials.password"
            type="password"
            required
            :disabled="authStore.loading"
            :placeholder="t('auth.passwordPlaceholder')"
          />
        </div>

        <div v-if="authStore.error" class="error-message">
          {{ authStore.error }}
        </div>

        <button
          type="submit"
          class="login-button"
          :disabled="authStore.loading || !isFormValid"
        >
          <span v-if="authStore.loading">{{ t("auth.signingIn") }}</span>
          <span v-else>{{ t("auth.signIn") }}</span>
        </button>
      </form>

      <div class="login-footer">
        <p class="voter-link">
          <router-link to="/">{{ t("common.backToHome") }}</router-link>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, computed } from "vue";
import { useRouter } from "vue-router";
import { useLocale } from "@/composables/useLocale";
import { useAuthStore } from "@/stores/authStore";

const authStore = useAuthStore();
const router = useRouter();
const { t } = useLocale();

const credentials = reactive({
  username: "",
  password: "",
});

const isFormValid = computed(() => {
  return credentials.username.length >= 3 && credentials.password.length >= 6;
});

async function handleLogin() {
  const success = await authStore.login(credentials);
  if (success) {
    const user = authStore.currentUser;
    if (user?.role === "ADMIN") {
      router.push("/admin/dashboard");
    } else if (user?.role === "TEACHER") {
      router.push("/teacher/dashboard");
    } else if (user?.role === "STUDENT") {
      router.push("/student/dashboard");
    } else {
      router.push("/");
    }
  }
}
</script>

<style scoped>
.login-container {
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

.login-header h1 {
  margin: 0 0 0.5rem 0;
  color: #333;
  font-size: 1.75rem;
}

.subtitle {
  color: #666;
  margin: 0;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  font-weight: 500;
  color: #555;
  font-size: 0.9rem;
}

.form-group input {
  padding: 0.75rem 1rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.2s;
}

.form-group input:focus {
  outline: none;
  border-color: #667eea;
}

.form-group input:disabled {
  background: #f5f5f5;
  cursor: not-allowed;
}

.error-message {
  color: #e74c3c;
  font-size: 0.9rem;
  text-align: center;
}

.login-button {
  padding: 0.875rem;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s;
}

.login-button:hover:not(:disabled) {
  background: #5a67d8;
}

.login-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.login-footer {
  margin-top: 1.5rem;
  text-align: center;
  color: #666;
  font-size: 0.9rem;
}

.login-footer a {
  color: #667eea;
  text-decoration: none;
  font-weight: 500;
}

.login-footer a:hover {
  text-decoration: underline;
}

.voter-link {
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px solid #eee;
}
</style>
