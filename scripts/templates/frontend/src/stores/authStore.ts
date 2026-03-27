import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { authApi } from '@/api';
import type { User, LoginCredentials, RegisterRequest, AuthResponse } from '@/types';

const TOKEN_KEY = 'auth_token';
const REFRESH_TOKEN_KEY = 'refresh_token';
const USER_KEY = 'user';

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref<User | null>(null);
  const token = ref<string | null>(localStorage.getItem(TOKEN_KEY));
  const refreshToken = ref<string | null>(localStorage.getItem(REFRESH_TOKEN_KEY));
  const loading = ref(false);
  const error = ref<string | null>(null);

  // Getters
  const isAuthenticated = computed(() => !!token.value && !!user.value);
  const isAdmin = computed(() => user.value?.role === 'ADMIN');
  const isTeacher = computed(() => user.value?.role === 'TEACHER');
  const isStudent = computed(() => user.value?.role === 'STUDENT');
  const isAdminOrTeacher = computed(() => isAdmin.value || isTeacher.value);
  const currentUser = computed(() => user.value);

  // Actions
  async function login(credentials: LoginCredentials): Promise<boolean> {
    loading.value = true;
    error.value = null;
    try {
      const response: AuthResponse = await authApi.login(credentials);
      setAuthData(response);
      return true;
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Login failed. Please check your credentials.';
      return false;
    } finally {
      loading.value = false;
    }
  }

  async function register(data: RegisterRequest): Promise<boolean> {
    loading.value = true;
    error.value = null;
    try {
      const response: AuthResponse = await authApi.register(data);
      setAuthData(response);
      return true;
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Registration failed. Please try again.';
      return false;
    } finally {
      loading.value = false;
    }
  }

  async function registerAdmin(data: RegisterRequest): Promise<boolean> {
    loading.value = true;
    error.value = null;
    try {
      const response: AuthResponse = await authApi.registerAdmin(data);
      setAuthData(response);
      return true;
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Admin registration failed.';
      return false;
    } finally {
      loading.value = false;
    }
  }

  async function registerTeacher(data: RegisterRequest): Promise<boolean> {
    loading.value = true;
    error.value = null;
    try {
      const response: AuthResponse = await authApi.registerTeacher(data);
      setAuthData(response);
      return true;
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Teacher registration failed.';
      return false;
    } finally {
      loading.value = false;
    }
  }

  async function registerStudent(data: RegisterRequest): Promise<boolean> {
    loading.value = true;
    error.value = null;
    try {
      const response: AuthResponse = await authApi.registerStudent(data);
      setAuthData(response);
      return true;
    } catch (err: any) {
      error.value = err.response?.data?.message || 'Student registration failed.';
      return false;
    } finally {
      loading.value = false;
    }
  }

  async function logout(): Promise<void> {
    try {
      await authApi.logout();
    } catch (err) {
      // Ignore error
    } finally {
      clearAuthData();
    }
  }

  async function fetchCurrentUser(): Promise<boolean> {
    if (!token.value) return false;
    try {
      const currentUser = await authApi.getCurrentUser();
      user.value = currentUser;
      localStorage.setItem(USER_KEY, JSON.stringify(currentUser));
      return true;
    } catch (err) {
      // Token invalid, logout
      clearAuthData();
      return false;
    }
  }

  async function refreshAccessToken(): Promise<boolean> {
    if (!refreshToken.value) return false;
    try {
      const response = await authApi.refreshToken(refreshToken.value);
      setAuthData(response);
      return true;
    } catch (err) {
      clearAuthData();
      return false;
    }
  }

  function setAuthData(response: AuthResponse): void {
    token.value = response.token;
    refreshToken.value = response.refreshToken;
    user.value = response.user;
    
    localStorage.setItem(TOKEN_KEY, response.token);
    localStorage.setItem(REFRESH_TOKEN_KEY, response.refreshToken);
    localStorage.setItem(USER_KEY, JSON.stringify(response.user));
  }

  function clearAuthData(): void {
    user.value = null;
    token.value = null;
    refreshToken.value = null;
    
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(REFRESH_TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
  }

  // Initialize from localStorage
  function initializeAuth(): void {
    const storedToken = localStorage.getItem(TOKEN_KEY);
    const storedUser = localStorage.getItem(USER_KEY);
    
    if (storedToken && storedUser) {
      token.value = storedToken;
      try {
        user.value = JSON.parse(storedUser);
      } catch {
        clearAuthData();
      }
    }
  }

  return {
    user,
    token,
    refreshToken,
    loading,
    error,
    isAuthenticated,
    isAdmin,
    isTeacher,
    isStudent,
    isAdminOrTeacher,
    currentUser,
    login,
    register,
    registerAdmin,
    registerTeacher,
    registerStudent,
    logout,
    fetchCurrentUser,
    refreshAccessToken,
    initializeAuth,
    clearAuthData,
  };
});
