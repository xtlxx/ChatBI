# Code Deletion Log

## [2026-02-08] Refactor Session

### Unused Dependencies Removed (Frontend)
- `@radix-ui/react-label`: Not used in source code.
- `@radix-ui/react-select`: Not used in source code.
- `@radix-ui/react-slot`: Not used in source code.
- `class-variance-authority`: Not used in source code (replaced by `clsx` and `tailwind-merge` in `utils.ts`).
- `i18next-http-backend`: Not used (imports JSONs directly).

### Duplicate Code Consolidated
- `src/components/SettingsPanel.tsx` + `src/components/SidebarSettings.tsx` → `src/hooks/useSettingsData.ts`
  - Extracted common data fetching logic for connections and LLM configs.
  - Centralized state management for initial selection.

### Unused Exports/Imports Removed
- Removed unused imports in `src/components/Sidebar.tsx` and `src/components/MainPlayground.tsx`.
- Removed unused imports in backend files (`app.py`, `vis/engine.py`, etc.).
- Removed invalid/unused code in `src/lib/api.ts` (removed `error_detail`, `timestamp` from interfaces where not supported).

### Impact
- Dependencies removed: 5 packages.
- Frontend build size optimized (less unused code).
- Backend code quality improved (Ruff compliance).

### Testing
- Backend unit tests passing: ✓ (64 passed)
- Frontend build succeeds: ✓
