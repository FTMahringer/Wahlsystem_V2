<template>
  <div class="admin-settings">
    <h1>{{ t('adminSettings.title') }}</h1>

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
import { onMounted } from 'vue';
import { useLocale } from '@/composables/useLocale';
import { useUiStore } from '@/stores/uiStore';
import AlertWidget from '@/components/dashboard/widgets/AlertWidget.vue';
import BaseEmptyState from '@/components/common/BaseEmptyState.vue';

const uiStore = useUiStore();
const { t } = useLocale();

onMounted(() => {
  uiStore.setBreadcrumbs([
    { label: t('nav.dashboard'), route: '/admin/dashboard' },
    { label: t('nav.settings') },
  ]);
  uiStore.setPageTitle(t('adminSettings.title'));
});
</script>

<style scoped>
.admin-settings h1 {
  margin-bottom: 1.5rem;
  color: var(--color-text);
}
</style>
