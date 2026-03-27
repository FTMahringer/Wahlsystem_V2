import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    redirect: '/vote/login'
  },
  // Voter routes
  {
    path: '/vote/login',
    name: 'VoterLogin',
    component: () => import('./views/voter/VoterLoginView.vue')
  },
  {
    path: '/vote/election/:id',
    name: 'VoterElection',
    component: () => import('./views/voter/VoterElectionView.vue')
  },
  // Admin routes
  {
    path: '/admin/login',
    name: 'AdminLogin',
    component: () => import('./views/admin/AdminLoginView.vue')
  },
  {
    path: '/admin/dashboard',
    name: 'AdminDashboard',
    component: () => import('./views/admin/AdminDashboardView.vue')
  },
  {
    path: '/admin/elections',
    name: 'AdminElections',
    component: () => import('./views/admin/AdminElectionsView.vue')
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
