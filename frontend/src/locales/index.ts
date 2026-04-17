import de from './de';
import en from './en';

export const locales = {
  de,
  en,
} as const;

export type AppLanguage = keyof typeof locales;
export type AppTheme = 'light' | 'dark';
export type TranslationParams = Record<string, string | number>;
export type TranslateFunction = (path: string, params?: TranslationParams) => string;

export const availableLanguages: AppLanguage[] = ['de', 'en'];
export const availableThemes: AppTheme[] = ['light', 'dark'];

const LANGUAGE_KEY = 'ui_language';

function getNestedValue(source: unknown, path: string): string | undefined {
  return path.split('.').reduce<unknown>((current, segment) => {
    if (current && typeof current === 'object' && segment in current) {
      return (current as Record<string, unknown>)[segment];
    }
    return undefined;
  }, source) as string | undefined;
}

function interpolate(template: string, params?: TranslationParams) {
  if (!params) {
    return template;
  }

  return Object.entries(params).reduce((result, [key, value]) => {
    return result.replaceAll(`{${key}}`, String(value));
  }, template);
}

export function resolveLanguage(explicitLanguage?: AppLanguage): AppLanguage {
  if (explicitLanguage) {
    return explicitLanguage;
  }

  const storedLanguage =
    typeof window !== 'undefined' ? window.localStorage.getItem(LANGUAGE_KEY) : null;

  if (storedLanguage === 'de' || storedLanguage === 'en') {
    return storedLanguage;
  }

  if (typeof document !== 'undefined' && (document.documentElement.lang === 'de' || document.documentElement.lang === 'en')) {
    return document.documentElement.lang as AppLanguage;
  }

  return 'de';
}

export function translate(path: string, params?: TranslationParams, language?: AppLanguage) {
  const resolvedLanguage = resolveLanguage(language);
  const template = getNestedValue(locales[resolvedLanguage], path) ?? path;
  return interpolate(template, params);
}

export function toIntlLocale(language: AppLanguage) {
  return language === 'de' ? 'de-DE' : 'en-US';
}
