import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

// Import translation files directly to bundle them (simpler for now, or use Backend to load from /public)
// Since we are in a dev environment and want to ensure files are available without network requests to self if possible,
// or just standard pattern. Let's use standard import for type safety and simplicity in this scale.
// Actually, standard import is better for single bundle.

import zhCN from '../locales/zh-CN.json';
import enUS from '../locales/en-US.json';

const resources = {
  'en-US': {
    translation: enUS
  },
  'zh-CN': {
    translation: zhCN
  }
};

i18n
  // detect user language
  // learn more: https://github.com/i18next/i18next-browser-languagedetector
  .use(LanguageDetector)
  // pass the i18n instance to react-i18next.
  .use(initReactI18next)
  // init i18next
  // for all options read: https://www.i18next.com/overview/configuration-options
  .init({
    resources,
    fallbackLng: 'zh-CN', // Default to Chinese as requested
    debug: true,

    interpolation: {
      escapeValue: false, // not needed for react as it escapes by default
    },
    detection: {
        order: ['querystring', 'cookie', 'localStorage', 'navigator', 'htmlTag', 'path', 'subdomain'],
        caches: ['localStorage', 'cookie'],
    }
  });

export default i18n;
