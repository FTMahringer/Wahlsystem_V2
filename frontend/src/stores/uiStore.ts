import { defineStore } from 'pinia';
import { ref } from 'vue';
import type { AppLanguage, AppTheme } from '@/locales';
import type { Toast, ConfirmDialogOptions, BreadcrumbItem } from '@/types';

const THEME_KEY = 'ui_theme';
const LANGUAGE_KEY = 'ui_language';

export const useUiStore = defineStore('ui', () => {
  const sidebarCollapsed = ref(false);
  const toasts = ref<Toast[]>([]);
  const confirmDialog = ref<ConfirmDialogOptions | null>(null);
  const breadcrumbs = ref<BreadcrumbItem[]>([]);
  const pageTitle = ref('');
  const theme = ref<AppTheme>('light');
  const language = ref<AppLanguage>('de');

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

  function setTheme(nextTheme: AppTheme) {
    theme.value = nextTheme;
    localStorage.setItem(THEME_KEY, nextTheme);
    document.documentElement.dataset.theme = nextTheme;
  }

  function setLanguage(nextLanguage: AppLanguage) {
    language.value = nextLanguage;
    localStorage.setItem(LANGUAGE_KEY, nextLanguage);
    document.documentElement.lang = nextLanguage;
  }

  function initializePreferences() {
    const storedTheme = localStorage.getItem(THEME_KEY) as AppTheme | null;
    const storedLanguage = localStorage.getItem(LANGUAGE_KEY) as AppLanguage | null;

    if (storedTheme === 'light' || storedTheme === 'dark') {
      theme.value = storedTheme;
    }

    if (storedLanguage === 'de' || storedLanguage === 'en') {
      language.value = storedLanguage;
    }

    document.documentElement.dataset.theme = theme.value;
    document.documentElement.lang = language.value;
  }

  return {
    sidebarCollapsed,
    toasts,
    confirmDialog,
    breadcrumbs,
    pageTitle,
    theme,
    language,
    toggleSidebar,
    collapseSidebar,
    expandSidebar,
    showToast,
    dismissToast,
    openConfirm,
    closeConfirm,
    setBreadcrumbs,
    setPageTitle,
    setTheme,
    setLanguage,
    initializePreferences,
  };
});
