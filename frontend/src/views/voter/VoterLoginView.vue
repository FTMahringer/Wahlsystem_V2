<template>
  <div class="voter-login">
    <div class="login-card">
      <h1>Wahlsystem</h1>
      <p>Enter your voting token to participate</p>

      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <input
            v-model="token"
            type="text"
            placeholder="Enter your token"
            required
          />
        </div>

        <button type="submit" :disabled="!token">Continue</button>
      </form>

      <div class="admin-link">
        <router-link to="/login">Login with Account</router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";

const token = ref("");
const router = useRouter();

async function handleLogin() {
  // Placeholder for token-based voter login
  router.push("/vote/election/1");
}
</script>

<style scoped>
.voter-login {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 1rem;
}

.login-card {
  background: white;
  padding: 3rem;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  text-align: center;
  max-width: 400px;
  width: 100%;
}

.login-card h1 {
  margin-bottom: 0.5rem;
  color: #333;
}

.login-card p {
  color: #666;
  margin-bottom: 2rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

input {
  width: 100%;
  padding: 1rem;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
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
  border-radius: 8px;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.2s;
}

button:hover:not(:disabled) {
  background: #5a67d8;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.admin-link {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid #eee;
}

.admin-link a {
  color: #667eea;
  text-decoration: none;
}

.admin-link a:hover {
  text-decoration: underline;
}
</style>
