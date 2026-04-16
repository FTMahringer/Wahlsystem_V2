import apiClient from './axios';
import type { 
  LoginCredentials, 
  RegisterRequest, 
  AuthResponse, 
  User,
  TokenLoginCredentials 
} from '@/types';

export const authApi = {
  // Login
  login: async (credentials: LoginCredentials): Promise<AuthResponse> => {
    const response = await apiClient.post('/auth/login', credentials);
    return response.data;
  },

  // Register
  register: async (data: RegisterRequest): Promise<AuthResponse> => {
    const response = await apiClient.post('/auth/register', data);
    return response.data;
  },

  // Register Admin (admin only)
  registerAdmin: async (data: RegisterRequest): Promise<AuthResponse> => {
    const response = await apiClient.post('/auth/register/admin', data);
    return response.data;
  },

  // Register Teacher (admin only)
  registerTeacher: async (data: RegisterRequest): Promise<AuthResponse> => {
    const response = await apiClient.post('/auth/register/teacher', data);
    return response.data;
  },

  // Register Student (admin or teacher)
  registerStudent: async (data: RegisterRequest): Promise<AuthResponse> => {
    const response = await apiClient.post('/auth/register/student', data);
    return response.data;
  },

  // Logout
  logout: async (): Promise<void> => {
    await apiClient.post('/auth/logout');
    localStorage.removeItem('auth_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('user');
  },

  // Get current user
  getCurrentUser: async (): Promise<User> => {
    const response = await apiClient.get('/auth/me');
    return response.data;
  },

  // Refresh token
  refreshToken: async (refreshToken: string): Promise<AuthResponse> => {
    const response = await apiClient.post('/auth/refresh', { refreshToken });
    return response.data;
  },

  // Token-based voter login
  tokenLogin: async (credentials: TokenLoginCredentials): Promise<{ token: string; electionId: number }> => {
    const response = await apiClient.post('/auth/token-login', credentials);
    return response.data;
  },
};
