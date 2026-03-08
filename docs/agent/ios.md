# iOS Agent Guide

Baseline commands (adjust to repo wrappers):

```bash
swift build
swift test
xcodebuild build -scheme <Scheme>
xcodebuild test -scheme <Scheme>
```

Targeted tests:

```bash
swift test --filter TestName
```

Style:

- Keep business logic out of view render paths
- Prefer explicit models and value semantics where possible
- Use async/await and structured concurrency for async flows

Naming:

- Types/protocols: `PascalCase`
- Methods/properties: `camelCase`

Errors:

- Use typed `Error` conformers
- Keep user-safe error messages
- Avoid logging sensitive values
