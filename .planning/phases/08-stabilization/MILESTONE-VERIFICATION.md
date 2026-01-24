# Milestone Verification: converge-core v1.0.0

**Generated:** 2026-01-24
**Phase:** 8 (Stabilization)
**Status:** COMPLETE

## Summary

| Category | Requirements | Verified |
|----------|-------------|----------|
| Core Types (REQ-TYPE-01 to REQ-TYPE-10) | 10 | 10 |
| Gate Pattern (REQ-GATE-01 to REQ-GATE-10) | 10 | 10 |
| Trait Definitions (REQ-TRAIT-01 to REQ-TRAIT-07) | 7 | 7 |
| CI & Testing (REQ-CI-01 to REQ-CI-08) | 8 | 8 |
| Documentation (REQ-DOC-01 to REQ-DOC-04) | 4 | 4 |
| **TOTAL** | **39** | **39** |

---

## Core Types (REQ-TYPE-01 through REQ-TYPE-10)

### REQ-TYPE-01: Define core type vocabulary
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/types/mod.rs` | Lines 1-70 | Module exports Context, Fact, ProposedFact, Intent types |
| `src/context.rs` | Lines 18-80 | `Context`, `ContextKey`, `Fact` definitions |
| `src/types/fact.rs` | Lines 100-187 | `Fact`, `FactContent`, `FactContentKind` |
| `src/types/intent.rs` | Full file | `TypesRootIntent`, `TypesIntentKind`, `TypesObjective` |
| `src/types/proposal.rs` | Lines 140-231 | `Proposal<State>` with type-state pattern |

### REQ-TYPE-02: Define trait interfaces for capability boundaries
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/traits/mod.rs` | Lines 1-306 | `Executor`, `Randomness`, `Fingerprint` trait definitions |
| `src/traits/llm.rs` | Lines 294-398 | `ChatBackend`, `EmbedBackend`, `LlmBackend` traits |
| `src/traits/recall.rs` | Lines 240-344 | `RecallReader`, `RecallWriter`, `Recall` traits |
| `src/traits/store.rs` | Lines 338-458 | `ExperienceAppender`, `ExperienceReplayer` traits |
| `src/traits/validator.rs` | Lines 152-219 | `Validator` trait with GAT async |
| `src/traits/promoter.rs` | Lines 214-284 | `Promoter` trait with type-state |

### REQ-TYPE-03: Implement enum-based state machines
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/types/proposal.rs` | Lines 26-41 | `Draft` and `Validated` marker types |
| `src/types/proposal.rs` | Lines 170-231 | `Proposal<State>` type-state pattern |
| `src/governed_artifact.rs` | Full file | `GovernedArtifactState` enum with transition validation |
| `src/gates/stop.rs` | Lines 24-138 | `StopReason` enum with `#[non_exhaustive]` |

### REQ-TYPE-04: Define error types with thiserror derivation
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/types/error.rs` | Lines 26-60 | `TypeError` with `#[derive(Error)]` |
| `src/types/error.rs` | Lines 92-144 | `PromotionError` with `#[derive(Error)]` |
| `src/types/error.rs` | Lines 190-236 | `TypesValidationError` with `#[derive(Error)]` |
| `src/types/error.rs` | Lines 278-337 | `ObservationError` with `#[derive(Error)]` |
| `src/types/error.rs` | Lines 342-417 | `CorrectionError` with `#[derive(Error)]` |
| `src/error.rs` | Full file | `ConvergeError` root error type |

### REQ-TYPE-05: Ensure serialization stability with explicit serde renames
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/types/provenance.rs` | Lines 31-39 | `EvidenceRef` with `#[serde(tag = "type", content = "id")]` |
| `src/types/provenance.rs` | Lines 67-74 | `TraceLink` with `#[serde(tag = "type")]` |
| `tests/types/fact_snapshots.rs` | Full file | Insta snapshot tests for Fact serialization |
| `tests/types/observation_snapshots.rs` | Full file | Insta snapshot tests for Observation |
| `tests/types/promotion_record_snapshots.rs` | Full file | Insta snapshot tests for PromotionRecord |

### REQ-TYPE-06: Zero runtime dependencies
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `deny.toml` | Lines 58-101 | Forbidden crates: tokio, rand, rayon, sha2 |
| `PURITY.md` | Lines 44-98 | FORBIDDEN Dependencies section |
| `deny.toml` | Lines 12-14 | `exclude-dev = true` allows test-only dependencies |

### REQ-TYPE-07: Pure validation functions
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/gates/validation.rs` | Full file | Pure validation without I/O |
| `src/gates/promotion.rs` | Lines 162-214 | `validate_proposal()` - no I/O, no side effects |
| `src/invariant.rs` | Lines 1-36 | Pure invariant checking with `Invariant` trait |
| `PURITY.md` | Lines 5-17 | "No I/O" principle documented |

### REQ-TYPE-08: Builder patterns for complex type construction
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/types/intent.rs` | Full file | `TypesRootIntent` with typed-builder |
| `src/types/context.rs` | Full file | `ContextBuilder` pattern |
| `src/types/proposal.rs` | Lines 83-105 | `ProposedContent::with_*` builder methods |
| `src/types/fact.rs` | Lines 83-98 | `FactContent::with_*` builder methods |
| `src/traits/store.rs` | Lines 289-336 | `ReplayOptions` builder pattern |

### REQ-TYPE-09: Comprehensive module documentation
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/lib.rs` | Lines 1-193 | Crate-level docs with design tenets |
| `src/types/mod.rs` | Lines 1-45 | Module docs with tenet alignment table |
| `src/gates/mod.rs` | Lines 1-95 | Module docs with invariants and tenet alignment |
| `src/traits/mod.rs` | Lines 1-86 | Module docs with design philosophy |

### REQ-TYPE-10: Unit tests for all type invariants
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `tests/property_tests.rs` | Full file | Proptest for invariant verification |
| `tests/send_sync_static.rs` | Full file | 60+ static assertions for Send+Sync |
| `tests/gates/promotion_proptest.rs` | Full file | State machine property tests |
| `src/types/error.rs` | Lines 419-493 | Unit tests for error types |
| `src/types/fact.rs` | Lines 189-292 | Unit tests for Fact invariants |

---

## Gate Pattern (REQ-GATE-01 through REQ-GATE-10)

### REQ-GATE-01: Define ProposalLifecycle<I, P, V, F> generic abstraction
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/gates/lifecycle.rs` | Lines 66-154 | `ProposalLifecycle<I, P, V, F>` trait definition |
| `src/gates/lifecycle.rs` | Lines 96-153 | `validate()` and `promote()` methods |
| `src/gates/promotion.rs` | Lines 313-329 | `impl ProposalLifecycle for PromotionGate` |

### REQ-GATE-02: Implement PromotionGate with ValidationReport requirement
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/gates/promotion.rs` | Lines 86-129 | `PromotionGate` struct and constructors |
| `src/gates/promotion.rs` | Lines 162-214 | `validate_proposal()` returns `ValidatedProposal` |
| `src/gates/promotion.rs` | Lines 232-283 | `promote_to_fact()` requires `ValidatedProposal` |
| `src/gates/validation.rs` | Full file | `ValidationReport` with `pub(crate)` constructor |

### REQ-GATE-03: Explicit authority grants
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/gates/boundary.rs` | Lines 49-124 | `AuthorityGrant` with `pub(crate)` constructors |
| `src/gates/boundary.rs` | Lines 126-141 | `AuthorityGrantor` enum (System/Human/Policy) |
| `src/gates/boundary.rs` | Lines 143-190 | `AuthorityScope` for limiting grants |

### REQ-GATE-04: Replayability honesty
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/types/provenance.rs` | Lines 62-91 | `TraceLink` with `is_replay_eligible()` |
| `src/kernel_boundary.rs` | Full file | `Replayability` enum, `ReplayabilityDowngradeReason` |
| `tests/gates/determinism_replay.rs` | Full file | Replay honesty verification tests |
| `tests/common/replay.rs` | Full file | `ReplayRunner` test infrastructure |

### REQ-GATE-05: Stop reason enumeration
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/gates/stop.rs` | Lines 24-138 | `StopReason` enum with `#[non_exhaustive]` |
| `src/gates/stop.rs` | Lines 140-261 | Constructor helpers and query methods |
| `src/gates/stop.rs` | Lines 315-328 | `ErrorCategory` enum |

### REQ-GATE-06: TraceLink separation (Local for replay, Remote for audit)
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/types/provenance.rs` | Lines 62-91 | `TraceLink::Local` vs `TraceLink::Remote` |
| `src/types/provenance.rs` | Lines 93-131 | `LocalTrace` (replay-eligible) |
| `src/types/provenance.rs` | Lines 133-147 | `RemoteRef` (audit-only) |
| `tests/types/tracelink_snapshots.rs` | Full file | TraceLink serialization tests |

### REQ-GATE-07: Kernel boundary types
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/kernel_boundary.rs` | Full file | `KernelIntent`, `KernelContext`, `KernelProposal` |
| `src/gates/boundary.rs` | Lines 24-47 | `constitutional` module re-exports |
| `tests/send_sync_static.rs` | Lines 174-205 | Kernel boundary types Send+Sync verification |

### REQ-GATE-08: Governed artifact lifecycle with audit trails
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/governed_artifact.rs` | Full file | `GovernedArtifactState`, `LifecycleEvent` |
| `src/governed_artifact.rs` | `validate_transition()` | State transition validation |
| `src/governed_artifact.rs` | `RollbackRecord` | Rollback audit types |

### REQ-GATE-09: Invariant classification
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/invariant.rs` | Lines 42-56 | `InvariantClass` enum (Structural/Semantic/Acceptance) |
| `src/invariant.rs` | Lines 58-79 | `InvariantResult` enum |
| `src/invariant.rs` | Lines 81-100 | `Violation` struct |

### REQ-GATE-10: Budget types for guaranteed termination
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/gates/budget.rs` | Lines 20-98 | `CycleBudget` with `tick()` returning `Option<StopReason>` |
| `src/gates/budget.rs` | Lines 100-174 | `FactBudget` with exhaustion detection |
| `src/gates/budget.rs` | Lines 176-251 | `TokenBudget` with consumption tracking |
| `src/gates/budget.rs` | Lines 253-329 | `ExecutionBudget` combined tracking |

---

## Trait Definitions (REQ-TRAIT-01 through REQ-TRAIT-07)

### REQ-TRAIT-01: Define LlmBackend trait
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/traits/llm.rs` | Lines 294-339 | `ChatBackend` trait (GAT async pattern) |
| `src/traits/llm.rs` | Lines 341-382 | `EmbedBackend` trait (GAT async pattern) |
| `src/traits/llm.rs` | Lines 384-397 | `LlmBackend` umbrella trait + blanket impl |

### REQ-TRAIT-02: Define Recall trait
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/traits/recall.rs` | Lines 240-282 | `RecallReader` trait (GAT async) |
| `src/traits/recall.rs` | Lines 284-329 | `RecallWriter` trait (GAT async) |
| `src/traits/recall.rs` | Lines 331-344 | `Recall` umbrella trait + blanket impl |

### REQ-TRAIT-03: Define ExperienceStore trait
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/traits/store.rs` | Lines 338-396 | `ExperienceAppender` trait (GAT async) |
| `src/traits/store.rs` | Lines 398-458 | `ExperienceReplayer` trait (GAT async) |
| `src/traits/store.rs` | Dyn wrappers | `DynExperienceAppender`, `DynExperienceReplayer` |

### REQ-TRAIT-04: Define Validator trait
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/traits/validator.rs` | Lines 152-219 | `Validator` trait definition |
| `src/traits/validator.rs` | Lines 195-219 | GAT async `ValidateFut` pattern |
| `src/traits/validator.rs` | Lines 224-258 | `DynValidator` dyn-safe wrapper |

### REQ-TRAIT-05: Define Promoter trait
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/traits/promoter.rs` | Lines 214-284 | `Promoter` trait definition |
| `src/traits/promoter.rs` | Lines 258-284 | GAT async `PromoteFut` pattern |
| `src/traits/promoter.rs` | Lines 286-325 | `DynPromoter` dyn-safe wrapper |

### REQ-TRAIT-06: Mark existing implementations as deprecated
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `BOUNDARY.md` | Lines 36-41 | Deprecated Traits table |
| `BOUNDARY.md` | Lines 98-196 | Migration Guide sections |
| `src/llm.rs` | Deprecation notes | References to `traits::llm` |
| `src/backend.rs` | Deprecation notes | References to `traits::LlmBackend` |

### REQ-TRAIT-07: Create BOUNDARY.md documenting trait ownership
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `BOUNDARY.md` | Lines 1-247 | Complete capability boundary documentation |
| `BOUNDARY.md` | Lines 8-33 | Trait Ownership Table |
| `BOUNDARY.md` | Lines 42-96 | Design Principles |
| `BOUNDARY.md` | Lines 233-246 | Version History |

---

## CI & Testing (REQ-CI-01 through REQ-CI-08)

### REQ-CI-01: Create deny.toml with forbidden dependency list
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `deny.toml` | Full file (109 lines) | Complete cargo-deny configuration |
| `deny.toml` | Lines 54-102 | 15 forbidden crates with reasons |
| `deny.toml` | Lines 24-40 | License allowlist |

### REQ-CI-02: Add cargo-deny to CI pipeline
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `.github/workflows/ci.yml` | Lines 61-70 | `deny` job with cargo-deny-action |
| `.github/workflows/ci.yml` | Line 69 | `command: check bans licenses sources` |
| `PURITY.md` | Lines 119-149 | CI Integration documentation |

### REQ-CI-03: Property-based tests with proptest
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `tests/property_tests.rs` | Full file | Proptest strategies and tests |
| `tests/gates/promotion_proptest.rs` | Full file | Gate state machine property tests |
| `tests/gates/append_only_proptest.rs` | Full file | Append-only invariant tests |
| `tests/types/id_timestamp_ordering_proptest.rs` | Full file | ID ordering property tests |

### REQ-CI-04: Snapshot tests with insta
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `tests/snapshot_tests.rs` | Full file | Snapshot test entry point |
| `tests/types/fact_snapshots.rs` | Full file | Fact serialization snapshots |
| `tests/types/observation_snapshots.rs` | Full file | Observation snapshots |
| `tests/types/promotion_record_snapshots.rs` | Full file | PromotionRecord snapshots |
| `tests/types/tracelink_snapshots.rs` | Full file | TraceLink snapshots |

### REQ-CI-05: Compile-time assertions with static_assertions
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `tests/send_sync_static.rs` | Full file (239 lines) | 60+ `assert_impl_all!` statements |
| `tests/send_sync_static.rs` | Lines 35-47 | Core ID types verification |
| `tests/send_sync_static.rs` | Lines 126-170 | Gate types verification |
| `tests/send_sync_static.rs` | Lines 172-205 | Kernel boundary types verification |

### REQ-CI-06: API stability checks with cargo-semver-checks
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `.github/workflows/ci.yml` | Lines 86-97 | `semver` job with cargo-semver-checks-action |
| `.github/workflows/ci.yml` | Line 97 | Git-based baseline comparison |

### REQ-CI-07: Golden tests for every serializable type
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `tests/golden/` | Directory | Golden scenario JSON files |
| `tests/gates/determinism_replay.rs` | Full file | Golden scenario verification |
| `tests/common/replay.rs` | `GoldenScenario` | Golden scenario infrastructure |

### REQ-CI-08: Create PURITY.md with ALLOWED/FORBIDDEN lists
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `PURITY.md` | Full file (195 lines) | Complete purity contract |
| `PURITY.md` | Lines 24-40 | ALLOWED Dependencies table |
| `PURITY.md` | Lines 44-98 | FORBIDDEN Dependencies tables |
| `PURITY.md` | Lines 100-116 | Nine Design Tenets |

---

## Documentation (REQ-DOC-01 through REQ-DOC-04)

### REQ-DOC-01: Create PURITY.md contract document
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `PURITY.md` | Full file | Complete purity contract document |
| `PURITY.md` | Lines 1-22 | Overview and Why Purity Matters |
| `PURITY.md` | Lines 119-149 | Enforcement section |
| `PURITY.md` | Lines 151-186 | Exception Process |

### REQ-DOC-02: Create BOUNDARY.md trait ownership document
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `BOUNDARY.md` | Full file (247 lines) | Complete capability boundary documentation |
| `BOUNDARY.md` | Lines 8-33 | Trait Ownership Table |
| `BOUNDARY.md` | Lines 98-232 | Migration Guides |

### REQ-DOC-03: Update lib.rs with module-level purity declarations
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/lib.rs` | Lines 147-193 | Purity Declaration section |
| `src/lib.rs` | Lines 153-164 | Allowed Dependencies table |
| `src/lib.rs` | Lines 165-184 | Forbidden Dependencies table |
| `src/lib.rs` | Lines 185-193 | The Purity Rule statement |

### REQ-DOC-04: Document nine design tenets in crate docs
**Status:** VERIFIED

| File | Line/Function | Evidence |
|------|---------------|----------|
| `src/lib.rs` | Lines 52-146 | Complete nine tenets documentation |
| `src/lib.rs` | Lines 56-67 | Tenet 1: Explicit Authority |
| `src/lib.rs` | Lines 68-76 | Tenet 2: Convergence Over Control Flow |
| `src/lib.rs` | Lines 77-86 | Tenet 3: Append-Only Truth |
| `src/lib.rs` | Lines 87-96 | Tenet 4: Agents Suggest, Engine Decides |
| `src/lib.rs` | Lines 97-106 | Tenet 5: Safety by Construction |
| `src/lib.rs` | Lines 107-116 | Tenet 6: Transparent Determinism |
| `src/lib.rs` | Lines 117-126 | Tenet 7: Human Authority First-Class |
| `src/lib.rs` | Lines 127-136 | Tenet 8: No Hidden Work |
| `src/lib.rs` | Lines 137-146 | Tenet 9: Scale by Intent Replication |

---

## File Reference Index

All evidence files are located relative to `converge-platform/converge-core/`:

| Path | Purpose |
|------|---------|
| `src/lib.rs` | Crate root with tenets and purity docs |
| `src/types/*.rs` | Core type vocabulary |
| `src/gates/*.rs` | Gate pattern implementation |
| `src/traits/*.rs` | Capability boundary traits |
| `src/invariant.rs` | Invariant classification |
| `src/kernel_boundary.rs` | Constitutional kernel types |
| `src/governed_artifact.rs` | Artifact lifecycle |
| `PURITY.md` | Purity contract document |
| `BOUNDARY.md` | Trait ownership document |
| `deny.toml` | Dependency policy |
| `.github/workflows/ci.yml` | CI pipeline |
| `tests/*.rs` | Test files |

---

## Verification Summary

All 39 v1 requirements have been verified with code evidence.

**Milestone:** v1.0.0 Complete
**Date:** 2026-01-24
**Verified by:** Phase 8 Stabilization
