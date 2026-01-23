# Testing Patterns

**Analysis Date:** 2026-01-23

## Test Framework

**Status:** No automated testing framework currently implemented

The codebase has:
- No test runners (Jest, Vitest, etc.)
- No test files (`.test.ts`, `.test.tsx`, `.spec.ts`, `.spec.tsx`)
- No testing dependencies in `package.json`
- No test configuration files (jest.config.*, vitest.config.*)

**Current State:**
This is a frontend application (React + TypeScript) built with:
- Vite as build tool
- TypeScript for type checking (serves as compile-time validation)
- ESLint for static analysis
- Prettier for formatting

## Testing Approach Recommendations

**For Adding Tests:**

If tests are added, follow these patterns based on codebase characteristics:

### Test Organization

**Location:** Co-locate tests with source files
- Pattern: `component.tsx` + `component.test.tsx`
- Hooks: `useSignals.ts` + `useSignals.test.ts`
- Utilities: `guards.ts` + `guards.test.ts`

**Naming Convention:**
- Use `.test.ts` suffix for all test files
- Match the component/module name exactly

### What the Codebase is Testing (Implicitly)

**Type Safety:**
- TypeScript strict mode (`strict: true`, `noUnusedLocals`, `noUnusedParameters`)
- Serves as first line of validation
- Type checking: `npm run typecheck` (runs `tsc --noEmit`)

**API Boundary Validation:**
- Zod schema validation at all API responses
- `safeParse()` used exclusively (never throwing on validation failure)
- Validation errors caught and handled gracefully with fallbacks

**Component Rendering:**
- ErrorBoundary wraps the app (`ErrorBoundary` in `main.tsx`)
- Catches and logs rendering errors without crashing
- Components use React.StrictMode for double-invocation detection

### Test Patterns to Follow if Implemented

**API/Result Type Pattern:**

The codebase uses a Result type for error handling:

```typescript
// From src/api/result.ts
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };
```

Tests for Result-returning functions should verify both branches:

```typescript
// Hypothetical test structure
test('should return ok result on success', () => {
  const result = api.validateRules({ ... });
  expect(result.ok).toBe(true);
  if (result.ok) {
    expect(result.value).toMatchObject({ is_valid: true });
  }
});

test('should return error result on failure', () => {
  const result = api.validateRules({ ... });
  expect(result.ok).toBe(false);
  if (!result.ok) {
    expect(result.error).toBeInstanceOf(ConvergeApiError);
  }
});
```

**Discriminated Union Testing:**

Hooks return discriminated union states. Tests should verify state transitions:

```typescript
// Hypothetical: useValidateRules hook testing
test('should transition through validation states', async () => {
  const { validate, state } = useValidateRules();

  expect(state).toEqual({ status: 'idle' });

  const promise = validate(content, false);
  expect(state).toEqual({ status: 'loading' });

  await promise;
  expect(state.status).toBe('success');
  expect(state.mode).toMatch(/api|local/);
});
```

**Type Guard Testing:**

If tests are added for type guards, verify they correctly narrow types:

```typescript
// From src/api/guards.ts - example test pattern
test('isConvergeApiError should correctly identify error type', () => {
  const error = new ConvergeApiError(500, { error: 'test', message: 'Test error' });
  expect(isConvergeApiError(error)).toBe(true);
  expect(isValidationError(error)).toBe(false);
});
```

**Zod Schema Validation Testing:**

Test schema parsing for edge cases:

```typescript
// Hypothetical: schemas.test.ts
test('ValidationIssueSchema should accept valid issue', () => {
  const issue = {
    location: 'Scenario',
    category: 'convention',
    severity: 'warning',
    message: 'Test message',
    suggestion: 'Test suggestion'
  };
  const result = ValidationIssueSchema.safeParse(issue);
  expect(result.success).toBe(true);
});

test('ValidationIssueSchema should reject unknown category', () => {
  const issue = {
    location: 'Scenario',
    category: 'unknown_category',
    severity: 'warning',
    message: 'Test'
  };
  const result = ValidationIssueSchema.safeParse(issue);
  expect(result.success).toBe(false);
});
```

### Mocking Recommendations

**What to Mock:**
- fetch API calls (simulate responses in different scenarios: success, error, timeout)
- External API endpoints (health checks, validation endpoints)
- Browser APIs that can't run in test environment (audio playback, focus management)

**What NOT to Mock:**
- Result type behavior (it's simple, deterministic)
- Type guards and utility functions
- Component rendering logic (use integration tests or snapshots)
- Zod validation itself (it's a third-party library)

**Example Mock Pattern:**

```typescript
// Hypothetical: using native fetch mock
const mockFetch = jest.fn();
global.fetch = mockFetch;

test('should handle API validation failure', async () => {
  mockFetch.mockRejectedValueOnce(new Error('Network error'));

  const { validate, state } = useValidateRules();
  await validate(content, true);

  // Should fall back to local validation
  expect(state.status).toBe('success');
  expect(state.mode).toBe('local');
});
```

## Current Quality Assurance Mechanisms

**Type Checking:**
- Run: `npm run typecheck`
- Enforces strict TypeScript rules
- Catches type errors at compile time

**Linting:**
- Run: `npm run lint`
- ESLint with recommended and type-checked rules
- Enforces: No explicit `any`, unused variables, unsafe type operations

**Formatting:**
- Run: `npm run fmt`
- Prettier ensures consistent code style
- Configuration: `.prettierrc.json`

## Potential Test Coverage Gaps

**High Priority (if testing is added):**
- API error handling and fallback mechanisms (network failures, validation errors)
- Hook state transitions (idle → loading → success/error)
- Type guard correctness (differentiating error types)
- Zod schema validation (boundary validation)

**Medium Priority:**
- Component rendering with various state combinations
- Event handler interactions (clicks, keyboard input)
- Local storage or cached data scenarios

**Lower Priority:**
- Simple presentational components (Hero, Features, Axioms)
- Static data modules (articles.ts, podcastEpisodes.ts)
- CSS module imports

## Run Commands (When Tests are Added)

```bash
npm test              # Run all tests
npm test -- --watch  # Watch mode
npm test -- --coverage # Coverage report
```

**Note:** These commands do not currently exist. Testing framework and config would need to be installed and configured.

---

*Testing analysis: 2026-01-23*
