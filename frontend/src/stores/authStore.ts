import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { authApi } from '@/api';
import type { User, LoginCredentials, RegisterRequest, AuthResponse } from '@/types';

// sessionStorage: cleared when the tab/browser is closed
const storage = sessionStorage;
const TOKEN_KEY = 'auth_token';
const REFRESH_TOKEN_KEY = 'refresh_token';
const USER_KEY = 'user';

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref<User | null>(null);
  const token = ref<string | null>(storage.getItem(TOKEN_KEY));
  const refreshToken = ref<string | null>(storage.getItem(REFRESH_TOKEN_KEY));
  const loading = ref(false);
  const error = ref<string | null>(null);
  // Tracks last time we hit /auth/me so we don't spam the API on rapid navigation
  let lastVerifiedAt = 0;

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
      lastVerifiedAt = Date.now();
      return true;
    } catch (err: any) {
      const msg = err.response?.data?.message || err.response?.data || '';
      error.value = typeof msg === 'string' && msg.length > 0
        ? msg
        : 'Login failed. Please check your credentials.';
      return false;
    } finally {
      loading.value = false;
    }
  }

  /**
   * Verifies the session against the server.
   * Returns true if the session is valid and the stored user matches the server user.
   * Caches the result for 30 seconds to avoid spamming the API on rapid navigation.
   */
  async function verifySession(): Promise<boolean> {
    if (!token.value) return false;

    // Use cached result if verified within the last 30 seconds
    if (Date.now() - lastVerifiedAt < 30_000) return true;

    try {
      const serverUser = await authApi.getCurrentUser();
      // Ensure stored user matches the server user (id + username must match)
      if (!user.value || serverUser.id !== user.value.id || serverUser.username !== user.value.username) {
        clearAuthData();
        return false;
      }
      // Refresh stored user with latest server data
      user.value = serverUser;
      storage.setItem(USER_KEY, JSON.stringify(serverUser));
      lastVerifiedAt = Date.now();
      return true;
    } catch {
      clearAuthData();
      return false;
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
    } catch {
      // Ignore — clear locally regardless
    } finally {
      clearAuthData();
    }
  }

  async function fetchCurrentUser(): Promise<boolean> {
    if (!token.value) return false;
    try {
      const current = await authApi.getCurrentUser();
      user.value = current;
      storage.setItem(USER_KEY, JSON.stringify(current));
      lastVerifiedAt = Date.now();
      return true;
    } catch {
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
    } catch {
      clearAuthData();
      return false;
    }
  }

  function setAuthData(response: AuthResponse): void {
    token.value = response.token;
    refreshToken.value = response.refreshToken;
    user.value = response.user;

    storage.setItem(TOKEN_KEY, response.token);
    storage.setItem(REFRESH_TOKEN_KEY, response.refreshToken);
    storage.setItem(USER_KEY, JSON.stringify(response.user));
  }

  function clearAuthData(): void {
    user.value = null;
    token.value = null;
    refreshToken.value = null;
    lastVerifiedAt = 0;

    storage.removeItem(TOKEN_KEY);
    storage.removeItem(REFRESH_TOKEN_KEY);
    storage.removeItem(USER_KEY);
  }

  function initializeAuth(): void {
    const storedToken = storage.getItem(TOKEN_KEY);
    const storedUser = storage.getItem(USER_KEY);

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
    verifySession,
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

