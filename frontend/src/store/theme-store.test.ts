import { describe, it, expect, beforeEach } from 'vitest';
import { useThemeStore } from './theme-store';

describe('useThemeStore', () => {
  beforeEach(() => {
    useThemeStore.setState({ theme: 'system' });
    localStorage.clear();
  });

  it('should have default theme as system', () => {
    expect(useThemeStore.getState().theme).toBe('system');
  });

  it('should update theme to light', () => {
    useThemeStore.getState().setTheme('light');
    expect(useThemeStore.getState().theme).toBe('light');
  });

  it('should update theme to dark', () => {
    useThemeStore.getState().setTheme('dark');
    expect(useThemeStore.getState().theme).toBe('dark');
  });

  it('should persist theme in localStorage', () => {
    useThemeStore.getState().setTheme('dark');
    const storage = JSON.parse(localStorage.getItem('theme-storage') || '{}');
    expect(storage.state.theme).toBe('dark');
  });
});
