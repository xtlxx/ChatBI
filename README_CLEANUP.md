# Code Cleanup & Standards

## Overview

This project follows strict coding standards to ensure maintainability, readability, and performance.
We use **Ruff** (Python) and **ESLint** (TypeScript/React) for linting and formatting.

## Standards

### Backend (Python)
- **Linter/Formatter**: Ruff
- **Configuration**: `pyproject.toml`
- **Key Rules**:
  - `B904`: Always use `raise ... from e` within exception handlers.
  - `E402`: Imports must be at the top of the file.
  - `F401`: Remove unused imports.
  - `F821`: No undefined variables.
  - `SIM102`: Merge nested `if` statements.
- **Commands**:
  ```bash
  ruff check . --fix
  ruff format .
  ```

### Frontend (TypeScript/React)
- **Linter**: ESLint
- **Formatter**: Prettier (via ESLint)
- **Configuration**: `eslint.config.js`
- **Key Rules**:
  - No `any` types (use specific interfaces like `AxiosError` or `unknown`).
  - No unused variables (`no-unused-vars`).
  - React Hooks dependencies must be exhaustive (`react-hooks/exhaustive-deps`).
  - No console logs in production (`no-console`).
  - Use `useCallback`/`useMemo` for stable references.
- **Commands**:
  ```bash
  npm run lint
  npm run build
  ```

## Cleanup History

### [2026-02-08] Refactor & Cleanup
- **Frontend**:
  - **Refactoring**: Created `useSettingsData` hook to unify data fetching logic in `SettingsPanel.tsx` and `SidebarSettings.tsx`.
  - **Dependencies**: Removed 5 unused packages (`@radix-ui/react-label`, etc.).
  - **Type Safety**: Replaced `any` types with `unknown` or specific types (`AxiosError`) in `chat-service.ts`, `Login.tsx`, `MainPlayground.tsx`.
  - **Build**: Fixed TypeScript errors (verbatimModuleSyntax, implicit any).
  - **Accessibility**: Added ARIA labels and semantic tokens.
- **Backend**:
  - **Linting**: Fixed hundreds of Ruff errors (unused imports, indentation, exception chaining).
  - **Tests**: Fixed `test_tools.py` assertions and `app.py` `REGISTRY` initialization.
  - **Config**: Updated `pyproject.toml` for Python 3.13 compatibility.

## Testing

Ensure all tests pass before committing:
```bash
# Backend
pytest

# Frontend
npm run build
```

See `docs/DELETION_LOG.md` for a detailed log of deleted files and code.
