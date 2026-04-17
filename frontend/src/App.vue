<template>
  <router-view />
</template>

<script setup lang="ts">
import { onMounted } from "vue";
import { useAuthStore } from "@/stores/authStore";

const authStore = useAuthStore();

onMounted(() => {
  authStore.initializeAuth();
});
</script>

<style>
:root,
:root[data-theme="light"] {
  --color-primary: #667eea;
  --color-primary-hover: #5a67d8;
  --color-danger: #e53e3e;
  --color-success: #38a169;
  --color-warning: #d69e2e;
  --color-text: #1a202c;
  --color-text-muted: #718096;
  --color-bg: #f8fafc;
  --color-surface: #ffffff;
  --color-border: #e2e8f0;
  --color-surface-muted: #f1f5f9;
  --color-sidebar-bg: #131525;
  --color-sidebar-text: #ffffff;
  --color-overlay: rgba(0, 0, 0, 0.55);
  --sidebar-width: 240px;
  --navbar-height: 60px;
  color-scheme: light;
}

:root[data-theme="dark"] {
  --color-primary: #8b9cff;
  --color-primary-hover: #7589ff;
  --color-danger: #fc8181;
  --color-success: #68d391;
  --color-warning: #f6ad55;
  --color-text: #edf2f7;
  --color-text-muted: #a0aec0;
  --color-bg: #111827;
  --color-surface: #1f2937;
  --color-border: #374151;
  --color-surface-muted: #273244;
  --color-sidebar-bg: #0b1220;
  --color-sidebar-text: #edf2f7;
  --color-overlay: rgba(15, 23, 42, 0.72);
  color-scheme: dark;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family:
    -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu,
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: var(--color-text);
  background: var(--color-bg);
  transition: background 0.2s ease, color 0.2s ease;
}

#app {
  min-height: 100vh;
}
</style>
