<template>
  <div class="wizard-shell">
    <div v-if="$slots.header" class="wizard-header">
      <slot name="header" />
    </div>

    <div class="wizard-body">
      <aside v-if="$slots.nav" class="wizard-nav">
        <slot name="nav" />
      </aside>

      <section class="wizard-content">
        <slot />
      </section>
    </div>

    <div v-if="$slots.actions" class="wizard-actions">
      <slot name="actions" />
    </div>
  </div>
</template>

<style scoped>
.wizard-shell {
  background: var(--color-surface, #ffffff);
  border-radius: 16px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

.wizard-header {
  padding: 1.5rem 1.75rem;
  border-bottom: 1px solid var(--color-border, #e2e8f0);
}

.wizard-body {
  display: grid;
  grid-template-columns: minmax(220px, 260px) 1fr;
  min-height: 520px;
}

.wizard-nav {
  border-right: 1px solid var(--color-border, #e2e8f0);
  background: #f8fafc;
}

.wizard-content {
  padding: 1.75rem;
}

.wizard-actions {
  border-top: 1px solid var(--color-border, #e2e8f0);
  padding: 1rem 1.75rem;
  background: #ffffff;
}

@media (max-width: 900px) {
  .wizard-body {
    grid-template-columns: 1fr;
  }

  .wizard-nav {
    border-right: none;
    border-bottom: 1px solid var(--color-border, #e2e8f0);
  }
}
</style>
