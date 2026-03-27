<template>
  <div class="register-container">
    <div class="register-card">
      <div class="register-header">
        <h1>Create Account</h1>
        <p class="subtitle">Register for Wahlsystem</p>
      </div>

      <form @submit.prevent="handleRegister" class="register-form">
        <!-- Account Type Selection -->
        <div class="form-group">
          <label>Account Type</label>
          <div class="role-selection">
            <label class="role-option">
              <input
                type="radio"
                v-model="form.role"
                value="STUDENT"
                :disabled="authStore.loading"
              />
              <span>Student</span>
            </label>
            <label class="role-option">
              <input
                type="radio"
                v-model="form.role"
                value="TEACHER"
                :disabled="authStore.loading"
              />
              <span>Teacher</span>
            </label>
          </div>
        </div>

        <!-- Basic Info -->
        <div class="form-row">
          <div class="form-group">
            <label for="firstName">First Name</label>
            <input
              id="firstName"
              v-model="form.firstName"
              type="text"
              :disabled="authStore.loading"
              placeholder="First name"
            />
          </div>
          <div class="form-group">
            <label for="lastName">Last Name</label>
            <input
              id="lastName"
              v-model="form.lastName"
              type="text"
              :disabled="authStore.loading"
              placeholder="Last name"
            />
          </div>
        </div>

        <div class="form-group">
          <label for="username">Username *</label>
          <input
            id="username"
            v-model="form.username"
            type="text"
            required
            :disabled="authStore.loading"
            placeholder="Choose a username"
          />
        </div>

        <div class="form-group">
          <label for="email">Email *</label>
          <input
            id="email"
            v-model="form.email"
            type="email"
            required
            :disabled="authStore.loading"
            placeholder="your@email.com"
          />
        </div>

        <div class="form-group">
          <label for="password">Password *</label>
          <input
            id="password"
            v-model="form.password"
            type="password"
            required
            minlength="6"
            :disabled="authStore.loading"
            placeholder="At least 6 characters"
          />
        </div>

        <!-- Student Fields -->
        <template v-if="form.role === 'STUDENT'">
          <div class="form-group">
            <label for="studentId">Student ID</label>
            <input
              id="studentId"
              v-model="form.studentId"
              type="text"
              :disabled="authStore.loading"
              placeholder="Your student ID"
            />
          </div>
          <div class="form-row">
            <div class="form-group">
              <label for="className">Class</label>
              <input
                id="className"
                v-model="form.className"
                type="text"
                :disabled="authStore.loading"
                placeholder="e.g., 10A"
              />
            </div>
            <div class="form-group">
              <label for="gradeLevel">Grade Level</label>
              <input
                id="gradeLevel"
                v-model.number="form.gradeLevel"
                type="number"
                :disabled="authStore.loading"
                placeholder="e.g., 10"
              />
            </div>
          </div>
        </template>

        <!-- Teacher Fields -->
        <template v-if="form.role === 'TEACHER'">
          <div class="form-group">
            <label for="employeeId">Employee ID</label>
            <input
              id="employeeId"
              v-model="form.employeeId"
              type="text"
              :disabled="authStore.loading"
              placeholder="Your employee ID"
            />
          </div>
          <div class="form-group">
            <label for="department">Department</label>
            <input
              id="department"
              v-model="form.department"
              type="text"
              :disabled="authStore.loading"
              placeholder="e.g., Mathematics"
            />
          </div>
          <div class="form-group">
            <label for="subjects">Subjects</label>
            <input
              id="subjects"
              v-model="form.subjects"
              type="text"
              :disabled="authStore.loading"
              placeholder="e.g., Math, Physics"
            />
          </div>
        </template>

        <div v-if="authStore.error" class="error-message">
          {{ authStore.error }}
        </div>

        <button
          type="submit"
          class="register-button"
          :disabled="authStore.loading || !isFormValid"
        >
          <span v-if="authStore.loading">Creating account...</span>
          <span v-else>Create Account</span>
        </button>
      </form>

      <div class="register-footer">
        <p>Already have an account? <router-link to="/login">Sign in</router-link></p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';
import type { RegisterRequest } from '@/types';

const authStore = useAuthStore();
const router = useRouter();

const form = reactive<RegisterRequest>({
  username: '',
  email: '',
  password: '',
  firstName: '',
  lastName: '',
  role: 'STUDENT',
  studentId: '',
  className: '',
  gradeLevel: undefined,
  employeeId: '',
  department: '',
  subjects: '',
});

const isFormValid = computed(() => {
  return (
    form.username.length >= 3 &&
    form.email.includes('@') &&
    form.password.length >= 6
  );
});

async function handleRegister() {
  // Remove empty optional fields
  const registerData: RegisterRequest = {
    username: form.username,
    email: form.email,
    password: form.password,
    role: form.role,
    firstName: form.firstName || undefined,
    lastName: form.lastName || undefined,
  };

  if (form.role === 'STUDENT') {
    registerData.studentId = form.studentId || undefined;
    registerData.className = form.className || undefined;
    registerData.gradeLevel = form.gradeLevel || undefined;
  } else if (form.role === 'TEACHER') {
    registerData.employeeId = form.employeeId || undefined;
    registerData.department = form.department || undefined;
    registerData.subjects = form.subjects || undefined;
  }

  const success = await authStore.register(registerData);
  if (success) {
    router.push('/');
  }
}
</script>

<style scoped>
.register-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 1rem;
}

.register-card {
  background: white;
  padding: 2.5rem;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 450px;
  max-height: 90vh;
  overflow-y: auto;
}

.register-header {
  text-align: center;
  margin-bottom: 2rem;
}

.register-header h1 {
  margin: 0 0 0.5rem 0;
  color: #333;
  font-size: 1.75rem;
}

.subtitle {
  color: #666;
  margin: 0;
}

.register-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
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

.role-selection {
  display: flex;
  gap: 1rem;
}

.role-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  flex: 1;
  justify-content: center;
}

.role-option:hover {
  border-color: #667eea;
}

.role-option input[type="radio"] {
  margin: 0;
}

.role-option input[type="radio"]:checked + span {
  color: #667eea;
  font-weight: 500;
}

.error-message {
  color: #e74c3c;
  font-size: 0.9rem;
  text-align: center;
}

.register-button {
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

.register-button:hover:not(:disabled) {
  background: #5a67d8;
}

.register-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.register-footer {
  margin-top: 1.5rem;
  text-align: center;
  color: #666;
  font-size: 0.9rem;
}

.register-footer a {
  color: #667eea;
  text-decoration: none;
  font-weight: 500;
}

.register-footer a:hover {
  text-decoration: underline;
}
</style>
