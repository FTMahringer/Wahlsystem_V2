import { computed } from 'vue';
import { useAuthStore } from '@/stores/authStore';
import type { UserRole } from '@/types';

export function useRole() {
  const authStore = useAuthStore();

  const user = computed(() => authStore.user);
  const role = computed<UserRole | null>(() => authStore.user?.role ?? null);

  const isAdmin = computed(() => role.value === 'ADMIN');
  const isTeacher = computed(() => role.value === 'TEACHER');
  const isStudent = computed(() => role.value === 'STUDENT');
  const isAdminOrTeacher = computed(() => isAdmin.value || isTeacher.value);
  const isAuthenticated = computed(() => authStore.isAuthenticated);

  function hasRole(requiredRole: UserRole): boolean {
    return role.value === requiredRole;
  }

  function hasAnyRole(roles: UserRole[]): boolean {
    return role.value ? roles.includes(role.value) : false;
  }

  return {
    user,
    role,
    isAdmin,
    isTeacher,
    isStudent,
    isAdminOrTeacher,
    isAuthenticated,
    hasRole,
    hasAnyRole,
  };
}
