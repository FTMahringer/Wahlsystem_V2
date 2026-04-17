<template>
  <AdminPageShell :title="title" :description="description">
    <BaseEmptyState
      :title="title"
      :message="description"
      icon="🧩"
      :action="{ label: actionLabel, route: actionRoute }"
    />
  </AdminPageShell>
</template>

<script setup lang="ts">
import { computed, onMounted, watch } from 'vue';
import { useRoute } from 'vue-router';
import AdminPageShell from '@/components/admin/AdminPageShell.vue';
import BaseEmptyState from '@/components/common/BaseEmptyState.vue';
import { useLocale } from '@/composables/useLocale';
import { useUiStore } from '@/stores/uiStore';

const route = useRoute();
const uiStore = useUiStore();
const { t } = useLocale();

const placeholderKey = computed(() => String(route.meta.placeholderKey ?? 'candidates'));

const placeholderConfig = computed(() => {
  switch (placeholderKey.value) {
    case 'voters':
      return {
        title: t('placeholders.voters.title'),
        description: t('placeholders.voters.description'),
        actionLabel: t('placeholders.voters.action'),
        actionRoute: '/admin/users',
      };
    case 'results':
      return {
        title: t('placeholders.results.title'),
        description: t('placeholders.results.description'),
        actionLabel: t('placeholders.results.action'),
        actionRoute: '/admin/elections',
      };
    case 'audit':
      return {
        title: t('placeholders.audit.title'),
        description: t('placeholders.audit.description'),
        actionLabel: t('placeholders.audit.action'),
        actionRoute: '/admin/dashboard',
      };
    default:
      return {
        title: t('placeholders.candidates.title'),
        description: t('placeholders.candidates.description'),
        actionLabel: t('placeholders.candidates.action'),
        actionRoute: '/admin/elections',
      };
  }
});

const title = computed(() => placeholderConfig.value.title);
const description = computed(() => placeholderConfig.value.description);
const actionLabel = computed(() => placeholderConfig.value.actionLabel);
const actionRoute = computed(() => placeholderConfig.value.actionRoute);

function syncUi() {
  uiStore.setBreadcrumbs([
    { label: t('nav.dashboard'), route: '/admin/dashboard' },
    { label: title.value },
  ]);
  uiStore.setPageTitle(title.value);
}

onMounted(syncUi);
watch([title, () => route.fullPath], syncUi);
</script>
