<template>
  <div class="voter-login">
    <div class="login-card">
      <div class="logo">🗳️</div>
      <h1>{{ t('app.name') }}</h1>
      <p>{{ t('voter.loginTitle') }}</p>

      <div v-if="errorMsg" class="error-msg">{{ errorMsg }}</div>

      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <input
            v-model="token"
            type="text"
            :placeholder="t('voter.tokenPlaceholder')"
            required
            :disabled="loading"
            autocomplete="off"
          />
        </div>

        <button type="submit" :disabled="!token.trim() || loading">
          {{ loading ? t('voter.verifying') : t('voter.continue') }}
        </button>
      </form>

      <div class="admin-link">
        <router-link to="/admin/login">{{ t('voter.adminLogin') }}</router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { authApi } from '@/api';
import { useLocale } from '@/composables/useLocale';

const token = ref('');
const loading = ref(false);
const errorMsg = ref('');
const router = useRouter();
const { t } = useLocale();

async function handleLogin() {
  if (!token.value.trim()) return;
  loading.value = true;
  errorMsg.value = '';

  try {
    const result = await authApi.tokenLogin({ token: token.value.trim() });
    // Store voter token in sessionStorage for the voting flow
    sessionStorage.setItem('voter_token', token.value.trim());
    sessionStorage.setItem('voter_election_id', String(result.electionId));
    router.push(`/vote/election/${result.electionId}`);
  } catch (err: any) {
    errorMsg.value = err.response?.data?.message || t('voter.invalidToken');
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped>
.voter-login {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.login-card {
  background: white;
  padding: 3rem;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  text-align: center;
  max-width: 420px;
  width: 100%;
}

.logo { font-size: 3rem; margin-bottom: 0.5rem; }

.login-card h1 {
  margin-bottom: 0.5rem;
  color: #1a202c;
}

.login-card p {
  color: #718096;
  margin-bottom: 2rem;
}

.error-msg {
  background: #fed7d7;
  color: #9b2c2c;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  font-size: 0.9rem;
  margin-bottom: 1.25rem;
}

.form-group { margin-bottom: 1.5rem; }

input {
  width: 100%;
  padding: 1rem;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  font-size: 1.1rem;
  text-align: center;
  letter-spacing: 0.1em;
  font-family: monospace;
  transition: border-color 0.2s;
}

input:focus {
  outline: none;
  border-color: #667eea;
}

button {
  width: 100%;
  padding: 1rem;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

button:hover:not(:disabled) { background: #5a67d8; }
button:disabled { opacity: 0.6; cursor: not-allowed; }

.admin-link {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid #e2e8f0;
}

.admin-link a {
  color: #667eea;
  text-decoration: none;
  font-size: 0.9rem;
}

.admin-link a:hover { text-decoration: underline; }
</style>
