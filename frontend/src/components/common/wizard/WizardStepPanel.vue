<template>
  <div v-show="active" class="wizard-step-panel">
    <slot />
  </div>
</template>

<script setup lang="ts">
defineProps<{
  active: boolean;
}>();
</script>

<style scoped>
.wizard-step-panel {
  display: block;
}
</style>
