---
phase: 05-trait-definitions
plan: 03
subsystem: core-traits
tags: [validator, promoter, deprecation, boundary-docs, GAT-async]

dependency-graph:
  requires: ["05-01", "05-02"]
  provides: ["validator-trait", "promoter-trait", "boundary-docs"]
  affects: ["06-deprecation", "07-integration"]

tech-stack:
  added: []
  patterns: ["GAT-async", "type-state-integration", "dyn-safe-wrappers"]

key-files:
  created:
    - converge-platform/converge-core/src/traits/validator.rs
    - converge-platform/converge-core/src/traits/promoter.rs
    - converge-platform/converge-core/BOUNDARY.md
  modified:
    - converge-platform/converge-core/src/traits/mod.rs
    - converge-platform/converge-core/src/llm.rs
    - converge-platform/converge-core/src/backend.rs
    - converge-platform/converge-core/src/experience_store.rs

decisions:
  - id: "05-03-D1"
    choice: "Validator returns ValidationReport (proof object)"
    rationale: "Consistent with existing gate pattern; report is unforgeable proof"
  - id: "05-03-D2"
    choice: "Promoter takes Proposal<Validated> (type-state enforcement)"
    rationale: "Compile-time enforcement of lifecycle; no bypass path"
  - id: "05-03-D3"
    choice: "PromotionContext bundles approver, evidence, trace"
    rationale: "Single parameter for all promotion metadata; clean API"
  - id: "05-03-D4"
    choice: "Deprecation notes reference BOUNDARY.md"
    rationale: "Central migration guide; avoids stale inline docs"

metrics:
  duration: "4 min"
  completed: "2026-01-24"
---

# Phase 05 Plan 03: Validator/Promoter Traits Summary

**One-liner:** Validator/Promoter capability traits with GAT async, type-state integration, and BOUNDARY.md migration guide.

## What Was Built

### 1. Validator Trait (`traits/validator.rs`)

Created the `Validator` capability trait for proposal validation:

```rust
pub trait Validator: Send + Sync {
    type ValidateFut<'a>: Future<Output = Result<ValidationReport, ValidatorError>> + Send + 'a
    where
        Self: 'a;

    fn validate<'a>(
        &'a self,
        proposal: &'a Proposal<Draft>,
        policy: &'a ValidationPolicy,
    ) -> Self::ValidateFut<'a>;
}
```

Key features:
- Takes `Proposal<Draft>` (type-state enforcement)
- Returns `ValidationReport` (unforgeable proof)
- `ValidatorError` implements `CapabilityError`
- `DynValidator` for runtime polymorphism

### 2. Promoter Trait (`traits/promoter.rs`)

Created the `Promoter` capability trait for fact creation:

```rust
pub trait Promoter: Send + Sync {
    type PromoteFut<'a>: Future<Output = Result<Fact, PromoterError>> + Send + 'a
    where
        Self: 'a;

    fn promote<'a>(
        &'a self,
        proposal: Proposal<Validated>,
        report: &'a ValidationReport,
        context: &'a PromotionContext,
    ) -> Self::PromoteFut<'a>;
}
```

Key features:
- Takes `Proposal<Validated>` (can only exist after validation)
- Requires `ValidationReport` (proof of validation)
- `PromotionContext` bundles approver, evidence, trace
- `PromoterError` implements `CapabilityError`
- `DynPromoter` for runtime polymorphism

### 3. Deprecation of Existing Traits

Added `#[deprecated]` attributes with actionable migration notes:

| Trait | Replacement | Note |
|-------|-------------|------|
| `LlmProvider` | `ChatBackend`, `EmbedBackend` | See BOUNDARY.md |
| `LlmBackend` (backend.rs) | `traits::LlmBackend` | GAT async version |
| `ExperienceStore` | `ExperienceAppender`, `ExperienceReplayer` | Split by capability |

### 4. BOUNDARY.md Documentation

Created comprehensive trait ownership documentation:

- **Trait ownership table:** 19+ traits with owner, module, purpose, dyn-safety
- **Deprecated traits table:** Old -> New mappings
- **Design principles:** Split by capability, GAT async, dyn-safe wrappers
- **Migration guide:** Code examples for each deprecated trait
- **Version history:** Changelog of trait evolution

## Commits

| Commit | Type | Description |
|--------|------|-------------|
| `07e1bad` | feat | Add Validator and Promoter capability traits |
| `a0c5e25` | chore | Deprecate LlmProvider, LlmBackend, ExperienceStore |
| `3eabd4f` | docs | Create BOUNDARY.md and update traits/mod.rs |

## Verification Results

All verification criteria passed:

- [x] `cargo check -p converge-core` compiles without errors
- [x] `cargo test -p converge-core` - 349 tests passed
- [x] `Validator` trait exists in `traits/validator.rs`
- [x] `Promoter` trait exists in `traits/promoter.rs`
- [x] `LlmProvider` marked `#[deprecated]`
- [x] `LlmBackend` (backend.rs) marked `#[deprecated]`
- [x] `ExperienceStore` marked `#[deprecated]`
- [x] `BOUNDARY.md` has trait ownership table

## Type-State Integration

The Validator/Promoter traits complete the type-state lifecycle:

```
Proposal<Draft>  --[Validator]--> ValidationReport
                                        |
Proposal<Draft> + ValidationReport --[internal]--> Proposal<Validated>
                                                          |
Proposal<Validated> + ValidationReport --[Promoter]--> Fact
```

The type system enforces:
- Cannot validate non-draft proposals
- Cannot promote without validation proof
- Cannot create Fact without going through promotion

## Deviations from Plan

None - plan executed exactly as written.

## Next Phase Readiness

Phase 05 complete. All capability boundary traits are defined:
- Error infrastructure (05-01)
- LLM traits (05-01)
- Recall traits (05-02)
- Store traits (05-02)
- Validator/Promoter traits (05-03)
- BOUNDARY.md documentation (05-03)

Ready for Phase 06: Integration with existing code.
