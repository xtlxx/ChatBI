import { useEffect } from 'react';
import { useThemeStore } from '../store/theme-store';

export const useThemeEffect = () => {
  const theme = useThemeStore((state) => state.theme);

  useEffect(() => {
    const root = window.document.documentElement;
    root.classList.remove("light", "dark");

    if (theme === "system") {
      const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");
      const applySystem = (matches: boolean) => {
        root.classList.remove("light", "dark");
        root.classList.add(matches ? "dark" : "light");
      };

      applySystem(mediaQuery.matches);

      const handler = (e: MediaQueryListEvent) => applySystem(e.matches);
      mediaQuery.addEventListener("change", handler);
      return () => mediaQuery.removeEventListener("change", handler);
    } else {
      root.classList.add(theme);
    }
  }, [theme]);
};
