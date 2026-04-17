import { computed } from 'vue';
import { locales, translate, type AppLanguage, type TranslationParams } from '@/locales';
import { useUiStore } from '@/stores/uiStore';

export function useLocale() {
  const uiStore = useUiStore();

  const language = computed(() => uiStore.language);
  const messages = computed(() => locales[language.value as AppLanguage]);

  function t(path: string, params?: TranslationParams) {
    messages.value;
    return translate(path, params, language.value as AppLanguage);
  }

  return {
    language,
    t,
  };
}
