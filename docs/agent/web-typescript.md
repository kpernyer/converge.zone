# Web TypeScript Agent Guide

Baseline commands (adapt per repo):

```bash
just fmt
just lint
just typecheck
just build
```

Bun test patterns:

```bash
bun test
bun test path/to/file.test.ts
bun test path/to/file.test.ts -t "test name pattern"
```

TypeScript rules:

- Keep strict typing enabled
- Avoid `any`; use `unknown` at boundaries and narrow immediately
- Prefer schema-backed validation for external data

React rules:

- Functional components and typed props
- Keep side effects in hooks
- Keep components focused and composable

Imports/style:

- Import order: external -> internal absolute -> relative -> styles
- Use `import type` for type-only imports
- Keep styling in CSS modules unless repo conventions differ

Errors:

- Never throw strings
- Keep user-facing errors clear and safe
- Avoid logging secrets/tokens/PII
