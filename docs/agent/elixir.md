# Elixir Agent Guide

Baseline commands:

```bash
mix deps.get
mix compile
mix format --check-formatted
mix credo --strict
mix test
```

Targeted tests:

```bash
mix test test/my_feature_test.exs
mix test test/my_feature_test.exs:42
```

Style:

- Keep OTP responsibilities clear and small
- Prefer explicit return tuples for expected failures
- Keep modules focused by domain responsibility

Naming:

- Modules: `PascalCase` namespace
- Functions/variables: `snake_case`

Errors/logging:

- Keep telemetry/logging structured
- Avoid logging secrets/tokens/PII
