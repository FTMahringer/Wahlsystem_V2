import { createRouter, createWebHistory } from "vue-router";
import type { RouteRecordRaw } from "vue-router";
import { useAuthStore } from "@/stores/authStore";

const routes: RouteRecordRaw[] = [
  {
    path: "/",
    name: "Index",
    component: () => import("./views/IndexView.vue"),
  },
  {
    path: "/login",
    name: "Login",
    component: () => import("./views/auth/LoginView.vue"),
  },

  // Voter routes — now part of student dashboard
  // (moved under /student/vote/* for authenticated student access)

  // Admin/Teacher/Student dashboard login — standalone, no layout
  {
    path: "/admin/login",
    name: "AdminLogin",
    component: () => import("./views/admin/AdminLoginView.vue"),
  },

  // Admin routes — wrapped in AdminLayout
  {
    path: "/admin",
    component: () => import("./layouts/AdminLayout.vue"),
    meta: { requiresAuth: true },
    children: [
      { path: "", redirect: "/admin/dashboard" },
      {
        path: "dashboard",
        name: "AdminDashboard",
        component: () => import("./views/admin/AdminDashboardView.vue"),
      },
      {
        path: "elections",
        name: "AdminElections",
        component: () => import("./views/admin/AdminElectionsView.vue"),
      },
      {
        path: "elections/create",
        name: "AdminElectionCreate",
        component: () => import("./views/admin/AdminElectionFormView.vue"),
      },
      {
        path: "elections/:id/edit",
        name: "AdminElectionEdit",
        component: () => import("./views/admin/AdminElectionFormView.vue"),
      },
      {
        path: "elections/:id/candidates",
        name: "AdminCandidates",
        component: () => import("./views/admin/AdminCandidatesView.vue"),
      },
      {
        path: "elections/:id/results",
        name: "AdminResults",
        component: () => import("./views/admin/AdminResultsView.vue"),
      },
      {
        path: "candidates",
        name: "AdminCandidatesOverview",
        component: () => import("./views/admin/AdminPlaceholderView.vue"),
        meta: { placeholderKey: "candidates" },
      },
      {
        path: "users",
        name: "AdminUsers",
        component: () => import("./views/admin/AdminUsersView.vue"),
        meta: { requiresRole: "ADMIN" },
      },
      {
        path: "classes",
        name: "AdminClasses",
        component: () => import("./views/admin/AdminClassesView.vue"),
        meta: { requiresRole: "ADMIN" },
      },
      {
        path: "voters",
        name: "AdminVotersOverview",
        component: () => import("./views/admin/AdminPlaceholderView.vue"),
        meta: { placeholderKey: "voters", requiresRole: "ADMIN" },
      },
      {
        path: "results",
        name: "AdminResultsOverview",
        component: () => import("./views/admin/AdminPlaceholderView.vue"),
        meta: { placeholderKey: "results" },
      },
      {
        path: "audit",
        name: "AdminAudit",
        component: () => import("./views/admin/AdminAuditView.vue"),
        meta: { requiresRole: "ADMIN" },
      },
      {
        path: "settings",
        name: "AdminSettings",
        component: () => import("./views/admin/AdminSettingsView.vue"),
        meta: { requiresRole: "ADMIN" },
      },
      {
        path: "profile",
        name: "AdminProfile",
        component: () => import("./views/admin/AdminProfileView.vue"),
      },
    ],
  },

  // Teacher dashboard
  {
    path: "/teacher",
    component: () => import("./layouts/AdminLayout.vue"),
    meta: { requiresAuth: true, requiresRole: "TEACHER" },
    children: [
      { path: "", redirect: "/teacher/dashboard" },
      {
        path: "dashboard",
        name: "TeacherDashboard",
        component: () => import("./views/teacher/TeacherDashboardView.vue"),
      },
      {
        path: "tokens",
        name: "TeacherTokens",
        component: () =>
          import("./views/teacher/TeacherTokenDistributionView.vue"),
      },
      {
        path: "my-class",
        name: "TeacherMyClass",
        component: () => import("./views/teacher/TeacherMyClassView.vue"),
      },
    ],
  },

  // Student dashboard
  {
    path: "/student",
    component: () => import("./layouts/AdminLayout.vue"),
    meta: { requiresAuth: true, requiresRole: "STUDENT" },
    children: [
      { path: "", redirect: "/student/dashboard" },
      {
        path: "dashboard",
        name: "StudentDashboard",
        component: () => import("./views/student/StudentDashboardView.vue"),
      },
      {
        path: "vote/election/:id",
        name: "StudentVoteElection",
        component: () => import("./views/voter/VoterElectionView.vue"),
      },
      {
        path: "vote/confirm",
        name: "StudentVoteConfirm",
        component: () => import("./views/voter/VoteConfirmView.vue"),
      },
      {
        path: "vote/success",
        name: "StudentVoteSuccess",
        component: () => import("./views/voter/VoteSuccessView.vue"),
      },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach(async (to, _from, next) => {
  const authStore = useAuthStore();

  const requiresAuth = to.matched.some((r) => r.meta.requiresAuth);
  if (!requiresAuth) return next();

  // Verify session with server on every protected navigation
  const valid = await authStore.verifySession();
  if (!valid) {
    return next("/admin/login");
  }

  // Role check - support multiple roles in meta
  const requiredRole = to.meta.requiresRole as string | undefined;
  if (requiredRole && authStore.user?.role !== requiredRole) {
    // Redirect to appropriate dashboard based on role
    if (authStore.user?.role === "ADMIN") return next("/admin/dashboard");
    if (authStore.user?.role === "TEACHER") return next("/teacher/dashboard");
    if (authStore.user?.role === "STUDENT") return next("/student/dashboard");
    return next("/");
  }

  next();
});

export default router;
