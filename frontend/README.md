# Frontend Project

## Overview
This is a modern React application built with Vite, TypeScript, and Tailwind CSS. It features a Gemini-inspired UI and a robust theme switching system.

## Features

### Theme Switcher
The application includes a comprehensive theme switching module located in the Settings page.

- **Modes**:
  - **Light**: Standard light theme.
  - **Dark**: Dark theme for low-light environments.
  - **System**: Automatically follows the user's operating system preference (prefers-color-scheme).

- **Persistence**:
  - Theme preference is saved in `localStorage` under the key `theme-storage`.
  - The default setting is "System" for first-time users.

- **Real-time Switching**:
  - Theme changes are applied instantly without page reload.
  - When in "System" mode, the app listens for OS theme changes and updates accordingly.

- **Technical Details**:
  - **State Management**: Uses `zustand` with `persist` middleware (`src/store/theme-store.ts`).
  - **Logic**: `useThemeEffect` hook (`src/hooks/useThemeEffect.ts`) manages class application on the `<html>` element.
  - **CSS**: Uses CSS variables defined in `src/index.css` for easy theming.
  - **Accessibility**: Theme buttons include `aria-pressed` states and proper labels.

### Internationalization (i18n)
- Supports English (en-US) and Chinese (zh-CN).
- Theme labels are fully localized.

## Visual Design Validation

This project includes a visual validation system to ensure UI consistency and adherence to design tokens.

### Running Visual Check

Run the following command to scan the codebase for visual design issues (e.g., hardcoded colors):

```bash
npm run visual:check
```

This command will:
1. Scan `src/**/*.{tsx,ts,css}` files.
2. Identify hardcoded colors not present in `config/visual-design-foundations.json`.
3. Generate a report in `reports/visual-report.html` and `reports/visual-report.md`.
4. Automatically open the HTML report in your default browser.

### Updating Design Tokens

The design tokens are defined in `config/visual-design-foundations.json`. Update this file to add new allowed colors, spacing, or typography settings.

### CI/CD Integration

A GitHub Actions workflow (`.github/workflows/visual-validation.yml`) runs this check on every Pull Request to `frontend/`. It will:
- Block the PR if P0 (Critical) or P1 (High) issues are found.
- Post a comment if validation fails.

## Development

### Installation
```bash
npm install
```

### Running the App
```bash
npm run dev
```

### Testing
The project uses Vitest for unit and integration testing.

```bash
npm test
```

## Directory Structure
- `src/components`: UI components (including `SidebarSettings.tsx` for theme switcher).
- `src/store`: State management (including `theme-store.ts`).
- `src/hooks`: Custom hooks (including `useThemeEffect.ts`).
- `src/locales`: i18n translation files.
- `src/index.css`: Global styles and theme variables.
