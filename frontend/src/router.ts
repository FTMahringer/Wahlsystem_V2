import { createRouter, createWebHistory } from 'vue-router';
import type { RouteRecordRaw } from 'vue-router';
import { useAuthStore } from '@/stores/authStore';

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'Index',
    component: () => import('./views/IndexView.vue'),
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('./views/auth/LoginView.vue'),
  },

  // Voter routes — wrapped in VoterLayout
  {
    path: '/vote',
    component: () => import('./layouts/VoterLayout.vue'),
    children: [
      { path: '', redirect: '/vote/login' },
      {
        path: 'login',
        name: 'VoterLogin',
        component: () => import('./views/voter/VoterLoginView.vue'),
      },
      {
        path: 'election/:id',
        name: 'VoterElection',
        component: () => import('./views/voter/VoterElectionView.vue'),
      },
      {
        path: 'confirm',
        name: 'VoteConfirm',
        component: () => import('./views/voter/VoteConfirmView.vue'),
      },
      {
        path: 'success',
        name: 'VoteSuccess',
        component: () => import('./views/voter/VoteSuccessView.vue'),
      },
    ],
  },

  // Admin login — standalone, no layout
  {
    path: '/admin/login',
    name: 'AdminLogin',
    component: () => import('./views/admin/AdminLoginView.vue'),
  },

  // Admin routes — wrapped in AdminLayout
  {
    path: '/admin',
    component: () => import('./layouts/AdminLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      { path: '', redirect: '/admin/dashboard' },
      {
        path: 'dashboard',
        name: 'AdminDashboard',
        component: () => import('./views/admin/AdminDashboardView.vue'),
      },
      {
        path: 'elections',
        name: 'AdminElections',
        component: () => import('./views/admin/AdminElectionsView.vue'),
      },
      {
        path: 'elections/create',
        name: 'AdminElectionCreate',
        component: () => import('./views/admin/AdminElectionFormView.vue'),
      },
      {
        path: 'elections/:id/edit',
        name: 'AdminElectionEdit',
        component: () => import('./views/admin/AdminElectionFormView.vue'),
      },
      {
        path: 'elections/:id/candidates',
        name: 'AdminCandidates',
        component: () => import('./views/admin/AdminCandidatesView.vue'),
      },
      {
        path: 'elections/:id/results',
        name: 'AdminResults',
        component: () => import('./views/admin/AdminResultsView.vue'),
      },
      {
        path: 'users',
        name: 'AdminUsers',
        component: () => import('./views/admin/AdminUsersView.vue'),
        meta: { requiresRole: 'ADMIN' },
      },
      {
        path: 'settings',
        name: 'AdminSettings',
        component: () => import('./views/admin/AdminSettingsView.vue'),
        meta: { requiresRole: 'ADMIN' },
      },
      {
        path: 'profile',
        name: 'AdminProfile',
        component: () => import('./views/admin/AdminProfileView.vue'),
      },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, _from, next) => {
  const authStore = useAuthStore();

  // Check auth requirement
  if (to.matched.some(r => r.meta.requiresAuth)) {
    if (!authStore.isAuthenticated) {
      return next('/admin/login');
    }
  }

  // Check role requirement
  const requiredRole = to.meta.requiresRole as string | undefined;
  if (requiredRole) {
    if (authStore.user?.role !== requiredRole) {
      return next('/admin/dashboard');
    }
  }

  next();
});

export default router;
