# Phase 2: Dependency Cleanup - Context

**Gathered:** 2026-01-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Remove forbidden runtime dependencies (rayon, rand, sha2, hex) from converge-core so cargo deny check passes. Add test infrastructure (proptest, insta, static_assertions, serde_test, criterion). This is the phase that makes CI green after Phase 1 established the guardrails.

</domain>

<decisions>
## Implementation Decisions

### Removal Strategy

- **Trait abstraction approach**: Don't just delete code — define minimal stub traits
  - Executor trait for parallel execution (replaces rayon)
  - Randomness trait for random number generation (replaces rand)
  - Fingerprint trait for hashing (replaces sha2/hex)

- **Trait placement**: Create new `traits/` module early, even if minimal
  - Traits use generic parameters (not associated types)
  - All stub traits require `Send + Sync` bounds

- **Complex code handling**: Deprecate with `#[deprecated]`, don't remove
  - Matches "Traits First" approach from v1 scope
  - Full removal happens in v2 after downstream migration

- **Breaking changes**: Accepted — bumping to v2.0.0 anyway
  - If parallel iteration was public API, it's a breaking change

- **Migration guide**: Create MIGRATION.md documenting changes and migration path

### Test Infrastructure

- **Crates to add (all as dev-dependencies)**:
  - proptest — property-based testing
  - insta — snapshot testing
  - static_assertions — compile-time checks
  - serde_test — serialization roundtrip testing
  - criterion — benchmarking

- **Test scope**: Full test suite, not just dependencies
  - Write comprehensive tests for removed/changed code
  - Unit tests inline with `#[cfg(test)]`
  - Integration tests in `tests/` directory

- **proptest strategies**: Shared module at `tests/strategies.rs`
  - Centralized strategies for Context, Fact, etc.

- **insta snapshots**: Committed to git
  - CI fails if snapshots change unexpectedly

- **static_assertions**: Comprehensive coverage
  - Every public type gets `assert_impl_all!(T: Send, Sync)`

- **criterion benchmarks**: In CI with regression threshold
  - Fail CI if performance regresses beyond threshold

### Claude's Discretion

- Exact trait method signatures
- Which specific code blocks use forbidden dependencies
- Benchmark threshold percentages
- Snapshot naming conventions

</decisions>

<specifics>
## Specific Ideas

- Stub traits should be minimal — just enough to compile, refined in Phase 5
- MIGRATION.md should feel like a changelog with upgrade instructions
- Keep deprecation warnings actionable: "Use XYZ in converge-runtime instead"

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-dependency-cleanup*
*Context gathered: 2026-01-23*
