<template>
  <div class="voter-layout">
    <header class="voter-topbar">
      <router-link to="/vote/login" class="voter-brand">
        <span class="brand-icon">🗳️</span>
        <span class="brand-text">Wahlsystem</span>
      </router-link>
    </header>
    <main class="voter-content">
      <router-view />
    </main>
    <footer class="voter-footer">
      <p>&copy; {{ new Date().getFullYear() }} Wahlsystem</p>
    </footer>
    <GlobalToastLayer />
  </div>
</template>

<script setup lang="ts">
import GlobalToastLayer from '@/components/ui/GlobalToastLayer.vue';
</script>

<style scoped>
.voter-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.voter-topbar {
  padding: 1rem 2rem;
  display: flex;
  align-items: center;
}

.voter-brand {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
  color: white;
}

.brand-icon {
  font-size: 1.5rem;
}

.brand-text {
  font-size: 1.25rem;
  font-weight: 700;
}

.voter-content {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.voter-footer {
  text-align: center;
  padding: 1rem;
  color: rgba(255, 255, 255, 0.6);
  font-size: 0.85rem;
}
.voter-footer p { margin: 0; }
</style>
