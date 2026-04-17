<template>
  <div class="admin-settings">
    <h1>{{ t("adminSettings.title") }}</h1>

    <section class="preferences-card">
      <div class="preferences-copy">
        <h2>{{ t("adminSettings.preferencesTitle") }}</h2>
        <p>{{ t("adminSettings.preferencesMessage") }}</p>
      </div>
      <AppPreferencesControls />
    </section>

    <AlertWidget
      type="info"
      :title="t('adminSettings.alertTitle')"
      :message="t('adminSettings.alertMessage')"
    />

    <BaseEmptyState
      :title="t('adminSettings.comingSoonTitle')"
      :message="t('adminSettings.comingSoonMessage')"
      icon="⚙️"
    />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from "vue";
import AppPreferencesControls from "@/components/common/AppPreferencesControls.vue";
import { useLocale } from "@/composables/useLocale";
import { useUiStore } from "@/stores/uiStore";
import AlertWidget from "@/components/dashboard/widgets/AlertWidget.vue";
import BaseEmptyState from "@/components/common/BaseEmptyState.vue";

const uiStore = useUiStore();
const { t } = useLocale();

onMounted(() => {
  uiStore.setBreadcrumbs([
    { label: t("nav.dashboard"), route: "/admin/dashboard" },
    { label: t("nav.settings") },
  ]);
  uiStore.setPageTitle(t("adminSettings.title"));
});
</script>

<style scoped>
.admin-settings {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.admin-settings h1 {
  margin: 0;
  color: var(--color-text);
}

.preferences-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  padding: 1.25rem 1.5rem;
  border: 1px solid var(--color-border);
  border-radius: 12px;
  background: var(--color-surface);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}

.preferences-copy h2 {
  margin: 0 0 0.35rem;
  color: var(--color-text);
  font-size: 1.05rem;
}

.preferences-copy p {
  margin: 0;
  color: var(--color-text-muted);
  max-width: 560px;
}

@media (max-width: 720px) {
  .preferences-card {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
