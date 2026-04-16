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
:root {
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
  --sidebar-width: 240px;
  --navbar-height: 60px;
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
}

#app {
  min-height: 100vh;
}
</style>
