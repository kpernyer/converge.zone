# Phase 7: Documentation - Research

**Researched:** 2026-01-24
**Domain:** Rust crate documentation, cargo-semver-checks, Rustdoc best practices
**Confidence:** HIGH

## Summary

This phase focuses on completing documentation for converge-core v2.0.0. The codebase already has substantial documentation in place - lib.rs has a comprehensive crate-level overview, and all module files (types/, traits/, gates/) have module-level doc comments explaining their purpose. The primary work involves:

1. Adding module-level purity declarations to lib.rs (what's ALLOWED vs FORBIDDEN in core)
2. Documenting the nine design tenets formally in crate-level documentation
3. Ensuring all types/traits/gates modules have comprehensive doc comments on public items
4. Adding cargo-semver-checks to CI for API stability verification

The existing documentation follows Rust best practices with `//!` module-level comments, `///` item-level docs, and code examples. The gap is primarily the formal tenet documentation and purity declarations.

**Primary recommendation:** Enhance lib.rs with a formal "Design Tenets" section and "Purity Declaration" section, then audit all public items for doc comment completeness.

## Standard Stack

This is a documentation phase with minimal tooling requirements.

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| rustdoc | (built-in) | Generate HTML documentation | Standard Rust toolchain |
| cargo doc | (built-in) | Build documentation | Standard Rust toolchain |
| cargo-semver-checks | latest | API stability verification | Detects breaking changes automatically |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| cargo-semver-checks-action | v2 | GitHub Actions integration | CI pipeline |

**Installation:**
```bash
cargo install cargo-semver-checks
```

## Architecture Patterns

### Current Documentation Structure

The codebase already follows good patterns:

```
src/
├── lib.rs              # Crate-level docs (exists, needs enhancement)
├── types/
│   ├── mod.rs          # Module overview (has docs)
│   ├── id.rs           # ID newtypes (has docs)
│   ├── proposal.rs     # Type-state pattern (has docs)
│   ├── fact.rs         # Immutable facts (has docs)
│   └── ...             # Other types (have docs)
├── traits/
│   ├── mod.rs          # Capability boundary overview (has docs)
│   ├── llm.rs          # LLM traits (has docs)
│   └── ...             # Other traits (have docs)
└── gates/
    ├── mod.rs          # Gate pattern overview (has docs)
    ├── promotion.rs    # PromotionGate (has docs)
    └── ...             # Other gates (have docs)
```

### Pattern 1: Module-Level Documentation

**What:** Each module has a `//!` doc comment explaining purpose, design, and key types
**When to use:** Every module file (mod.rs, named modules)
**Example:**
```rust
// Source: converge-core/src/types/mod.rs (existing)
//! Core type vocabulary for Converge.
//!
//! This module contains the domain types that form Converge's type vocabulary:
//!
//! - **ID types** (id.rs): FactId, ObservationId, ProposalId, etc.
//! - **3-tier hierarchy**: Observation -> Proposal -> Fact
//! - **Provenance** (provenance.rs): PromotionRecord, EvidenceRef, TraceLink
//!
//! # Design Principles
//!
//! - **Type safety**: All IDs are newtypes to prevent mixing
//! - **Promotion invariant**: Facts can only be created via PromotionGate
```

### Pattern 2: Type Documentation with Invariants

**What:** Struct/enum docs include design invariants and examples
**When to use:** All public types, especially governance-critical ones
**Example:**
```rust
// Source: converge-core/src/types/fact.rs (existing)
/// A promoted, governed truth. Immutable after creation.
///
/// Facts can only be created via `PromotionGate::promote()`. Direct construction
/// is impossible outside converge-core.
///
/// # Invariants
///
/// - **Non-optional PromotionRecord**: Every Fact has a complete promotion record
/// - **Immutable**: No mutation methods - corrections are new Facts
/// - **Private fields**: All access via getters
```

### Pattern 3: Trait Documentation with Implementation Examples

**What:** Trait docs include usage patterns and implementation guidance
**When to use:** All capability boundary traits
**Example:**
```rust
// Source: converge-core/src/traits/mod.rs (existing)
/// Abstracts parallel or sequential execution strategy.
///
/// # Thread Safety
///
/// Implementations must be `Send + Sync` to allow sharing across threads.
///
/// # Example Implementation
///
/// ```ignore
/// pub struct RayonExecutor;
///
/// impl Executor for RayonExecutor {
///     fn execute_parallel<T, F, R>(&self, items: &[T], f: F) -> Vec<R>
///     where
///         T: Sync,
///         F: Fn(&T) -> R + Send + Sync,
///         R: Send,
///     {
///         items.par_iter().map(f).collect()
///     }
/// }
/// ```
```

### Anti-Patterns to Avoid
- **Missing invariant documentation:** Every type that enforces invariants must document them
- **Examples that don't compile:** Use `ignore` for examples requiring external crates, but prefer real examples
- **Orphan docs:** Every public item must have a doc comment, even if brief

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| API breaking change detection | Manual review of public API | cargo-semver-checks | Automated, catches subtle breaks |
| Documentation generation | Custom tooling | cargo doc / rustdoc | Standard, maintained, indexed |

**Key insight:** Rust's tooling (rustdoc, cargo-semver-checks) provides comprehensive documentation and API stability checking. Focus on content quality, not tooling.

## Common Pitfalls

### Pitfall 1: Incomplete Tenet Documentation
**What goes wrong:** Tenets are listed but not explained with examples
**Why it happens:** Rushing to check the box without actionable guidance
**How to avoid:** Each tenet needs: definition, why it matters, code example, anti-pattern
**Warning signs:** Tenets section is just a bulleted list

### Pitfall 2: Missing Purity Declarations
**What goes wrong:** lib.rs doesn't clearly state ALLOWED/FORBIDDEN dependencies
**Why it happens:** Assuming deny.toml is sufficient documentation
**How to avoid:** Add explicit `# Purity` section to lib.rs crate docs
**Warning signs:** New contributors add forbidden dependencies

### Pitfall 3: Stale Doc Examples
**What goes wrong:** Code examples in docs don't compile or use outdated API
**Why it happens:** Examples not tested, API evolved
**How to avoid:** Use `cargo test --doc` to verify doc examples
**Warning signs:** Doc examples marked with `ignore` that could be real tests

### Pitfall 4: cargo-semver-checks False Positives
**What goes wrong:** CI fails on intentional API changes
**Why it happens:** No baseline version published, or comparing against wrong version
**How to avoid:** Ensure baseline version is correct, use `--baseline-version` flag
**Warning signs:** Many "breaking change" errors on first run

## Code Examples

### Nine Tenets Documentation Structure (lib.rs)

```rust
// Template for lib.rs enhancement
//!
//! # Design Tenets
//!
//! Converge is built on nine non-negotiable design tenets. These are axioms
//! that converge-core exists to encode, enforce, and protect.
//!
//! ## 1. Explicit Authority
//!
//! **Axiom:** No defaults that grant authority. Authority is always explicit, typed, and traceable.
//!
//! **Why:** Implicit authority leads to unintended promotions, security holes, and audit gaps.
//!
//! **In code:** [`AuthorityGrant`] has `pub(crate)` constructors - external code cannot
//! create arbitrary authority. All promotion requires explicit grant.
//!
//! ```ignore
//! // Wrong: implicit authority
//! let fact = gate.auto_promote(proposal); // Does not exist
//!
//! // Right: explicit authority
//! let grant = AuthorityGrant::from_human_approval(approval_id);
//! let fact = gate.promote_with_authority(proposal, grant)?;
//! ```
//!
//! ## 2. Convergence Over Control Flow
//!
//! **Axiom:** We converge on outcomes via governed proposals, not ad-hoc loops.
//!
//! **Why:** Ad-hoc control flow is hard to audit, replay, and reason about.
//!
//! **In code:** [`Engine`] runs agents until a fixed point. Agents emit [`AgentEffect`],
//! never mutate state directly.
//!
//! [Continue for all 9 tenets...]
```

### Purity Declaration Section (lib.rs)

```rust
// Template for lib.rs purity declaration
//!
//! # Purity Declaration
//!
//! converge-core is pure by design. It contains only types, traits, and validation
//! logic - no I/O, no runtime behavior, no implementation logic.
//!
//! ## Allowed Dependencies
//!
//! | Crate | Purpose | Why Allowed |
//! |-------|---------|-------------|
//! | thiserror | Error derive macros | Pure, no runtime overhead |
//! | serde | Serialization traits | Pure, no I/O |
//! | serde_json | JSON types (Value) | Used for structured content only |
//! | tracing | Instrumentation (no spans) | Pure, subscriber lives outside core |
//! | hex | Hex encoding | Pure utility |
//! | strum | Enum derive macros | Pure, no runtime overhead |
//! | typed-builder | Builder derive macros | Pure, no runtime overhead |
//!
//! ## Forbidden Dependencies
//!
//! | Category | Examples | Why Forbidden |
//! |----------|----------|---------------|
//! | Async runtimes | tokio, async-std | Implies execution |
//! | HTTP/Network | reqwest, hyper, axum | Implies I/O |
//! | LLM execution | llama-cpp, burn | Implies inference |
//! | Databases | sqlx, surrealdb | Implies persistence |
//! | Random | rand | Implies non-determinism |
//!
//! These constraints are enforced by `deny.toml` and CI.
```

### cargo-semver-checks CI Integration

```yaml
# Add to .github/workflows/ci.yml
semver:
  name: API Stability
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Install Rust
      uses: dtolnay/rust-action@stable

    - name: Check semver
      uses: obi1kenobi/cargo-semver-checks-action@v2
      with:
        package: converge-core
        manifest-path: converge-platform/converge-core/Cargo.toml
        # Baseline: last published version (update when releasing)
        baseline-version: 0.6.2
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual API review | cargo-semver-checks | 2023+ | Automated breaking change detection |
| Doc examples ignored | `cargo test --doc` | Always | Doc examples are tested code |

**Deprecated/outdated:**
- Manual API stability tracking: Use cargo-semver-checks instead

## Open Questions

1. **Baseline version for cargo-semver-checks**
   - What we know: Current version is 0.6.2 per Cargo.toml
   - What's unclear: Is 0.6.2 published to a registry? If not, what baseline to use?
   - Recommendation: If first run, use `--baseline-rev HEAD~1` for git-based comparison

2. **Doc example verification scope**
   - What we know: Many examples use `ignore` due to needing external context
   - What's unclear: How many can be converted to real doc tests?
   - Recommendation: Audit and convert where possible, keep `ignore` for examples needing impl crates

## Sources

### Primary (HIGH confidence)
- Codebase inspection: src/lib.rs, src/types/, src/traits/, src/gates/
- cargo-semver-checks GitHub: https://github.com/obi1kenobi/cargo-semver-checks
- Existing CI workflow: .github/workflows/ci.yml

### Secondary (MEDIUM confidence)
- PROJECT.md: Nine tenets definition
- REQUIREMENTS.md: REQ-TYPE-09, REQ-CI-06, REQ-DOC-03, REQ-DOC-04

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - standard Rust tooling
- Architecture: HIGH - based on direct codebase inspection
- Pitfalls: HIGH - documented from common patterns

**Research date:** 2026-01-24
**Valid until:** 60 days (stable tooling, no fast-moving components)

---

## Appendix: Current Documentation Audit

### lib.rs (Crate Level)
- **Status:** Good foundation, needs enhancement
- **Has:** Quick start, core concepts, guarantees, module declarations, re-exports
- **Missing:**
  - Nine design tenets section
  - Purity declaration section
  - Module-level purity annotations on pub mod statements

### types/mod.rs
- **Status:** Comprehensive
- **Has:** Module overview, design principles, submodule list
- **Example:** Documents 3-tier hierarchy, type safety principles

### traits/mod.rs
- **Status:** Comprehensive
- **Has:** Design philosophy, trait hierarchy, trait listing with purposes
- **Example:** Thread safety requirements, dyn-safe patterns documented

### gates/mod.rs
- **Status:** Comprehensive
- **Has:** Design axiom, key types table, invariants list, module structure
- **Example:** "Agents suggest, engine decides" axiom clearly stated

### Individual Type Documentation
Most types have good documentation. Examples of well-documented types:
- `Fact` (fact.rs): Invariants, private constructor explanation, example
- `Proposal<State>` (proposal.rs): Type-state transitions, example
- `PromotionGate` (promotion.rs): Invariants, example usage
- `TraceLink` (provenance.rs): Local vs Remote semantics

### Areas Needing Attention
1. lib.rs needs formal tenet section
2. lib.rs needs purity declaration section
3. Some types may benefit from more examples
4. Doc examples should be audited for compilability
