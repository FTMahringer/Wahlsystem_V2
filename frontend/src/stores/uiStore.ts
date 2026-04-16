import { defineStore } from 'pinia';
import { ref } from 'vue';
import type { Toast, ConfirmDialogOptions, BreadcrumbItem } from '@/types';

export const useUiStore = defineStore('ui', () => {
  const sidebarCollapsed = ref(false);
  const toasts = ref<Toast[]>([]);
  const confirmDialog = ref<ConfirmDialogOptions | null>(null);
  const breadcrumbs = ref<BreadcrumbItem[]>([]);
  const pageTitle = ref('');

  function toggleSidebar() {
    sidebarCollapsed.value = !sidebarCollapsed.value;
  }

  function collapseSidebar() {
    sidebarCollapsed.value = true;
  }

  function expandSidebar() {
    sidebarCollapsed.value = false;
  }

  function showToast(toast: Omit<Toast, 'id'>) {
    const id = Date.now().toString(36) + Math.random().toString(36).slice(2);
    const newToast: Toast = { ...toast, id };
    toasts.value.push(newToast);

    const duration = toast.duration ?? 4000;
    setTimeout(() => {
      dismissToast(id);
    }, duration);
  }

  function dismissToast(id: string) {
    toasts.value = toasts.value.filter(t => t.id !== id);
  }

  function openConfirm(options: Omit<ConfirmDialogOptions, 'open'>) {
    confirmDialog.value = { ...options, open: true };
  }

  function closeConfirm() {
    confirmDialog.value = null;
  }

  function setBreadcrumbs(crumbs: BreadcrumbItem[]) {
    breadcrumbs.value = crumbs;
  }

  function setPageTitle(title: string) {
    pageTitle.value = title;
  }

  return {
    sidebarCollapsed,
    toasts,
    confirmDialog,
    breadcrumbs,
    pageTitle,
    toggleSidebar,
    collapseSidebar,
    expandSidebar,
    showToast,
    dismissToast,
    openConfirm,
    closeConfirm,
    setBreadcrumbs,
    setPageTitle,
  };
});
