import { renderHook } from '@testing-library/react';
import { useThemeEffect } from './useThemeEffect';
import { useThemeStore } from '../store/theme-store';
import { describe, it, expect, vi, beforeEach, afterEach, type Mock } from 'vitest';

describe('useThemeEffect', () => {
  let addSpy: Mock;
  let removeSpy: Mock;
  let matchMediaSpy: Mock;
  let listeners: Record<string, (e: MediaQueryListEvent) => void> = {};

  beforeEach(() => {
    // Reset store
    useThemeStore.setState({ theme: 'system' });

    // Mock classList
    addSpy = vi.fn();
    removeSpy = vi.fn();
    
    // Using Object.defineProperty to mock classList on document.documentElement
    Object.defineProperty(document.documentElement, 'classList', {
      writable: true,
      value: {
        add: addSpy,
        remove: removeSpy,
      },
    });

    // Mock matchMedia
    listeners = {};
    matchMediaSpy = vi.fn().mockImplementation((query) => ({
      matches: false, // Default to light mode
      media: query,
      onchange: null,
      addListener: vi.fn(), // Deprecated
      removeListener: vi.fn(), // Deprecated
      addEventListener: vi.fn((event, cb) => {
        listeners[event] = cb;
      }),
      removeEventListener: vi.fn((event) => {
        delete listeners[event];
      }),
      dispatchEvent: vi.fn(),
    }));
    window.matchMedia = matchMediaSpy;
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('should apply light mode when theme is light', () => {
    useThemeStore.setState({ theme: 'light' });
    renderHook(() => useThemeEffect());
    
    expect(removeSpy).toHaveBeenCalledWith('light', 'dark');
    expect(addSpy).toHaveBeenCalledWith('light');
  });

  it('should apply dark mode when theme is dark', () => {
    useThemeStore.setState({ theme: 'dark' });
    renderHook(() => useThemeEffect());
    
    expect(removeSpy).toHaveBeenCalledWith('light', 'dark');
    expect(addSpy).toHaveBeenCalledWith('dark');
  });

  it('should respond to system preferences in system mode (light)', () => {
    useThemeStore.setState({ theme: 'system' });
    matchMediaSpy.mockReturnValue({
      matches: false, // Light mode
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
    });
    
    renderHook(() => useThemeEffect());
    
    expect(removeSpy).toHaveBeenCalledWith('light', 'dark');
    expect(addSpy).toHaveBeenCalledWith('light');
  });

  it('should respond to system preferences in system mode (dark)', () => {
    useThemeStore.setState({ theme: 'system' });
    matchMediaSpy.mockReturnValue({
      matches: true, // Dark mode
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
    });
    
    renderHook(() => useThemeEffect());
    
    expect(removeSpy).toHaveBeenCalledWith('light', 'dark');
    expect(addSpy).toHaveBeenCalledWith('dark');
  });
});
