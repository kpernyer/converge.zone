# Rust Agent Guide

Build/lint/test baseline:

```bash
cargo build
cargo fmt -- --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test
```

Targeted testing:

```bash
cargo test test_name
cargo test --test integration_test_name
cargo test -p package_name
cargo test -- --nocapture
```

Style:

- Prefer explicit types at module boundaries
- Use `Result<T, E>` for fallible paths; avoid panic-driven control flow
- Avoid `unwrap()`/`expect()` in non-test code
- Keep `pub` surfaces minimal and intentional
- Prefer explicit imports over wildcard imports

Errors and observability:

- Preserve root causes and add context at boundaries
- Keep logs structured and non-sensitive

When performance-sensitive:

- Measure before and after changes
- Include regression/behavior tests for algorithmic edits
