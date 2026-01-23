# Coding Conventions

**Analysis Date:** 2026-01-23

## Naming Patterns

**Files:**
- Components: PascalCase (e.g., `ErrorBoundary.tsx`, `FeaturedPlayer.tsx`)
- Utility/Hook files: camelCase (e.g., `useSignals.ts`, `useValidateRules.ts`, `podcastEpisodes.ts`)
- CSS Modules: `[ComponentName].module.css` (e.g., `App.module.css`, `Header.module.css`)
- Type definition files: camelCase (e.g., `signals.types.ts`, `schemas.ts`, `guards.ts`)

**Functions:**
- Exported React components: PascalCase (e.g., `function Hero()`, `function Header()`, `function ErrorBoundary()`)
- Hooks: camelCase with `use` prefix (e.g., `useSignals()`, `useArticle()`, `useValidateRules()`)
- Utility functions: camelCase (e.g., `validateRuleLocally()`, `delay()`, `request()`)
- Type guards: camelCase with `is` prefix (e.g., `isConvergeApiError()`, `isValidationError()`)

**Variables:**
- State variables: camelCase (e.g., `dropdownOpen`, `mobileMenuOpen`, `errorMessage`)
- Type unions/states: camelCase (e.g., `requestState`, `validationState`, `fetchState`)
- Constants in objects: lowercase with underscores for JSON-like structures (e.g., `file_name`, `use_llm`, `duration_ms`, `fact_counts`)
- Component props: camelCase (e.g., `fetchRemote`, `onClose`, `linesPerPage`)

**Types:**
- Interfaces: PascalCase (e.g., `ErrorBoundaryProps`, `DemoRequestProps`, `TerminalProps`, `Env`)
- Type aliases for unions/discriminated unions: PascalCase (e.g., `RequestState`, `ValidationErrorType`, `FetchState<T>`)
- Zod schema names: PascalCase + "Schema" suffix (e.g., `ValidationCategorySchema`, `ErrorBoundarySchema`, `JobResponseSchema`)
- Exported types inferred from Zod: PascalCase (e.g., `PodcastEpisodes`, `PodcastEpisode`)

## Code Style

**Formatting:**
- Tool: Prettier
- Print width: 100 characters
- Quote style: Single quotes
- Semicolons: Required
- Trailing commas: ES5 compatible (trailing commas in objects/arrays but not function args)
- Indentation: 2 spaces (no tabs)
- Arrow function parentheses: Always included (e.g., `(args) => {}`, not `args => {}`)
- Line endings: LF

**Linting:**
- Tool: ESLint with TypeScript support (`typescript-eslint`)
- Config: `eslint.config.js` (flat config format)
- Plugins: `react-hooks`, `react-refresh`
- Strict type checking rules enforced:
  - `@typescript-eslint/no-explicit-any`: Error
  - `@typescript-eslint/no-unsafe-assignment`: Warn
  - `@typescript-eslint/no-unsafe-member-access`: Warn
  - `@typescript-eslint/no-unsafe-call`: Warn
- Unused variable handling: Allows `_` prefix to indicate intentional omissions (e.g., `_setErrorMessage`)
- React Refresh: Components should be exported to support fast refresh

**TypeScript Strict Mode:**
- Enabled in `tsconfig.app.json`
- No unused locals or parameters allowed
- Strict null checks enforced
- Module detection: Force (ensures correct module behavior)

## Import Organization

**Order:**
1. React imports and core framework imports first
2. Third-party library imports (e.g., `zod`, `react-router-dom`)
3. Type imports from third-party libraries (using `type` keyword)
4. Absolute imports from `@/` alias paths
5. Relative imports (using `../`)
6. CSS imports last

**Example:**
```typescript
import { useState, useEffect, useCallback, useRef } from 'react';
import { Link } from 'react-router-dom';
import type { ReactNode } from 'react';
import { api, type ValidationIssue, type ValidateRulesResponse } from '@/api';
import { isConvergeApiError } from '@/api/guards';
import styles from './Component.module.css';
```

**Path Aliases:**
- `@/*`: Maps to `src/*` for clean absolute imports
- Use this alias for cross-directory imports; relative imports acceptable within same directory

## Error Handling

**Patterns:**
- Result type pattern used throughout: `Result<T, E> = { ok: true; value: T } | { ok: false; error: E }`
- Discriminated unions for error states in hooks (e.g., `ValidationState` with `status` and `error` fields)
- Type guards to distinguish error types: `isConvergeApiError()`, `isValidationError()`, `isNetworkError()`
- Zod schemas for API boundary validation: All responses validated with `safeParse()`, never throwing on invalid responses
- Fallback mechanisms: Network errors fall back to local/static data (e.g., in `useSignals`, `useValidateRules`)
- Logging: `console.error()` with sanitized information (no tokens/PII), message + context object

**Example error handling:**
```typescript
if (result.ok) {
  setState({ status: 'success', data: result.value, source: 'remote' });
}
// On error, keep existing data (no state change)
```

## Logging

**Framework:** `console` object (standard browser API)

**Patterns:**
- Log at error boundaries: `console.error()` in ErrorBoundary, API error handlers
- Include context object with sanitized data: Include status codes, endpoints, error types but never tokens or PII
- Format: `console.error('Context message:', { field1, field2 })`
- No logging in success paths; only on errors or critical flow transitions

**Example:**
```typescript
console.error('API validation failed:', {
  status: error.status,
  message: error.message,
  endpoint: '/api/v1/validate-rules',
});
```

## Comments

**When to Comment:**
- Header comments for non-obvious files (e.g., `// React hooks for fetching Signals articles`)
- JSDoc-style comments for public functions and exported components
- Inline comments only for complex business logic or non-obvious intent
- Comments explaining fallback behavior (e.g., "Fallback to local validation on network errors")

**JSDoc/TSDoc:**
- Format: Block comments with `/**` for exported functions and components
- Structure: One-line summary, blank line, optional detailed explanation
- Tags: `@param`, `@returns` for complex signatures (optional for simple functions)

**Example:**
```typescript
/**
 * Hook to fetch the article index with fallback to static data
 *
 * Initializes with static data immediately to prevent CLS (Cumulative Layout Shift).
 * Optionally fetches remote data in the background for dynamic updates.
 */
export function useArticleIndex(options?: { fetchRemote?: boolean }) {
  // ...
}
```

## Function Design

**Size:**
- Keep functions focused on single responsibility
- Typical functions: 20-60 lines (some hooks 100+ lines acceptable for complex state management)
- Break into smaller functions if conditional branches dominate

**Parameters:**
- Named parameters via object destructuring preferred for options (e.g., `{ fetchRemote = false }`)
- Avoid positional parameters when more than 2 required
- Use optional parameters with defaults for non-critical inputs
- Type all parameters explicitly

**Return Values:**
- Hooks return object with named properties (e.g., `{ state, refetch }`, `{ state, validate }`)
- Components return JSX (implicitly `JSX.Element`)
- Utility functions return Result types or direct values
- Async functions return Promise wrapped Result types

**Example:**
```typescript
export function useSignals() {
  return {
    state,
    refetch: fetchIndex,
  };
}
```

## Module Design

**Exports:**
- Default exports for React components (e.g., `export default Component`)
- Named exports for utilities, hooks, and types
- API module exports object with methods: `export const api = { health(), ready(), createJob() }`
- Types exported explicitly via type-only imports when needed

**Barrel Files:**
- `index.ts` files re-export public APIs from subdirectories
- Example: `/api/index.ts` exports types and the api client object
- Use to simplify imports: `import { api, type ValidationIssue } from '@/api'`

**File Grouping:**
- Components organized by feature: `app/components/`, `app/pages/`
- Utilities grouped by domain: `api/`, `config/`, `data/`
- Hooks isolated in `hooks/` directory
- Tests co-located with source when applicable

## Type Safety Standards

- Always use explicit types for function parameters and returns
- Discriminated unions for state management (`status` field drives type narrowing)
- Zod schemas at all API boundaries (request validation, response validation)
- Infer types from Zod schemas using `z.infer<typeof Schema>` (single source of truth)
- Avoid `any`; use `unknown` with type guards if truly dynamic

---

*Convention analysis: 2026-01-23*
