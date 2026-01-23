# Technology Stack for Pure Axiomatic Rust Crate

**Project:** converge-core v2.0.0 Restoration
**Researched:** 2026-01-23
**Confidence:** HIGH

## Executive Summary

converge-core must be a **pure, portable, axiomatic foundation** — no I/O, no runtime, only types/traits/invariants. The current crate has accumulated drift: `rayon`, `rand`, `sha2`, and runtime-adjacent modules.

**Recommendation:** Strip to minimal dependencies, add comprehensive testing infrastructure, enforce purity through CI tooling.

## Recommended Stack

### Core Dependencies (Production)

| Dependency | Version | Purpose | Rationale | Confidence |
|------------|---------|---------|-----------|------------|
| **thiserror** | 2.0 | Error derivation | Zero-cost error types, no runtime allocation | HIGH |
| **serde** | 1.0 + derive | Serialization traits | Stable, universal. No I/O — traits only | HIGH |
| **serde_json** | 1.0 | JSON serialization | Required for stable formats | HIGH |
| **tracing** | 0.1 | Logging facade | Facade only, no subscriber | HIGH |
| **strum** | 0.26 | Enum derives | Compile-time only, aids serialization | HIGH |

### Dependencies to REMOVE

| Dependency | Why Remove | Migration Path |
|------------|------------|----------------|
| **rayon** | Parallelism is runtime concern | Move to converge-runtime |
| **rand** | Randomness is runtime/test concern | Move to dev-deps or converge-runtime |
| **sha2** | Hashing implies computation | Define Fingerprint trait, impl in converge-provider |
| **hex** | Only needed for sha2 | Remove with sha2 |

### Dev Dependencies (Testing)

| Dependency | Version | Purpose | Confidence |
|------------|---------|---------|------------|
| **proptest** | 1.5 | Property-based testing | HIGH |
| **tracing-test** | 0.2 | Tracing assertions | HIGH |
| **criterion** | 0.5 | Benchmarking | MEDIUM |
| **insta** | 1.39 | Snapshot testing | MEDIUM |
| **serde_test** | 1.0 | Serde roundtrip testing | HIGH |
| **static_assertions** | 1.1 | Compile-time invariants | HIGH |

### CI/Build Tools

| Tool | Purpose | Confidence |
|------|---------|------------|
| **cargo-deny** | Dependency auditing, forbidden deps | HIGH |
| **cargo-nextest** | Fast test runner | MEDIUM |
| **cargo-semver-checks** | API stability | MEDIUM |

## Dependency Rules (deny.toml)

### Forbidden Dependencies

```toml
[bans.deny]
# Runtime/async
{ name = "tokio" }
{ name = "async-trait" }
{ name = "futures" }

# I/O
{ name = "reqwest" }
{ name = "hyper" }
{ name = "axum" }
{ name = "tonic" }

# ML/LLM
{ name = "burn" }
{ name = "llama-burn" }
{ name = "polars" }
{ name = "arrow" }

# Database
{ name = "surrealdb" }
{ name = "sqlx" }

# Parallelism
{ name = "rayon" }
```

## Testing Strategy

### Property-Based Tests (Critical)

```rust
proptest! {
    #[test]
    fn facts_require_promotion_gate(proposal in proposed_fact_strategy()) {
        // Verify no API allows Fact creation without ValidationReport
    }

    #[test]
    fn facts_are_immutable(facts in unique_facts_strategy(10)) {
        // Verify no mutation API exists
    }
}
```

### Serialization Stability Tests

```rust
use insta::assert_json_snapshot;

#[test]
fn stop_reason_serialization_stable() {
    let reason = StopReason::ConvergenceReached { cycles: 5 };
    assert_json_snapshot!("stop_reason_convergence", reason);
}
```

### Compile-Time Invariants

```rust
use static_assertions::assert_impl_all;

assert_impl_all!(Context: Send, Sync);
assert_impl_all!(Fact: Send, Sync);
```

## Target Cargo.toml

```toml
[package]
name = "converge-core"
version = "2.0.0"
edition = "2024"
rust-version = "1.85"

[dependencies]
thiserror = "2"
tracing = "0.1"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
strum = { version = "0.26", features = ["derive"] }

[dev-dependencies]
proptest = "1.5"
tracing-test = "0.2"
criterion = { version = "0.5", features = ["html_reports"] }
insta = { version = "1.39", features = ["json"] }
serde_test = "1"
static_assertions = "1.1"

[lints.rust]
unsafe_code = "forbid"
```

## Migration Path

1. **Phase 1:** Remove rayon, rand, sha2, hex
2. **Phase 2:** Add insta, criterion, static_assertions
3. **Phase 3:** Create deny.toml, GitHub Actions workflow
4. **Phase 4:** Define capability traits, move implementations

## Sources

- Current Cargo.toml analysis
- PROJECT.md requirements
- Rust ecosystem best practices
