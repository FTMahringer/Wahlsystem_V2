<template>
  <div class="preferences-controls">
    <label class="control">
      <span class="control__label">{{ t('common.language') }}</span>
      <select
        class="control__select"
        :value="uiStore.language"
        @change="handleLanguageChange"
      >
        <option
          v-for="languageOption in availableLanguages"
          :key="languageOption"
          :value="languageOption"
        >
          {{ t(`languages.${languageOption}`) }}
        </option>
      </select>
    </label>

    <label class="control">
      <span class="control__label">{{ t('common.theme') }}</span>
      <select
        class="control__select"
        :value="uiStore.theme"
        @change="handleThemeChange"
      >
        <option
          v-for="themeOption in availableThemes"
          :key="themeOption"
          :value="themeOption"
        >
          {{ t(`themes.${themeOption}`) }}
        </option>
      </select>
    </label>
  </div>
</template>

<script setup lang="ts">
import { availableLanguages, availableThemes, type AppLanguage, type AppTheme } from '@/locales';
import { useLocale } from '@/composables/useLocale';
import { useUiStore } from '@/stores/uiStore';

const uiStore = useUiStore();
const { t } = useLocale();

function handleLanguageChange(event: Event) {
  const value = (event.target as HTMLSelectElement).value;
  if (value === 'de' || value === 'en') {
    uiStore.setLanguage(value as AppLanguage);
  }
}

function handleThemeChange(event: Event) {
  const value = (event.target as HTMLSelectElement).value;
  if (value === 'light' || value === 'dark') {
    uiStore.setTheme(value as AppTheme);
  }
}
</script>

<style scoped>
.preferences-controls {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.control {
  display: flex;
  align-items: center;
  gap: 0.4rem;
}

.control__label {
  font-size: 0.78rem;
  color: var(--color-text-muted);
}

.control__select {
  min-width: 92px;
  padding: 0.35rem 0.55rem;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  background: var(--color-surface);
  color: var(--color-text);
  font-size: 0.85rem;
}

.control__select:focus {
  outline: none;
  border-color: var(--color-primary);
}
</style>
