# Roadmap: converge-core v2.0.0 Restoration

## Overview

Restore converge-core to its pure, portable, axiomatic foundation by establishing enforcement guardrails first, removing forbidden dependencies, consolidating types and traits, implementing the generic gate pattern, and locking down serialization stability. The journey prioritizes prevention over cure: automated enforcement precedes code changes to prevent regression.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: CI Foundation** - Guardrails before code changes
- [ ] **Phase 2: Dependency Cleanup** - Remove forbidden dependencies
- [ ] **Phase 3: Type Consolidation** - Organize core type vocabulary
- [ ] **Phase 4: Gate Pattern** - Implement ProposalLifecycle abstraction
- [ ] **Phase 5: Trait Definitions** - Define capability boundary traits
- [ ] **Phase 6: Testing Infrastructure** - Property-based and snapshot tests
- [ ] **Phase 7: Documentation** - BOUNDARY.md, module docs
- [ ] **Phase 8: Stabilization** - Final cleanup and validation

## Phase Details

### Phase 1: CI Foundation
**Goal**: Automated enforcement prevents dependency drift and purity violations before any code changes
**Depends on**: Nothing (first phase)
**Requirements**: REQ-CI-01, REQ-CI-02, REQ-CI-08, REQ-DOC-01
**Success Criteria** (what must be TRUE):
  1. `cargo deny check` runs and would fail on forbidden dependencies (tokio, reqwest, rayon, etc.)
  2. PURITY.md exists with explicit ALLOWED/FORBIDDEN dependency lists
  3. CI pipeline includes cargo-deny step that blocks forbidden dependencies
  4. deny.toml covers all forbidden patterns from PROJECT.md
**Plans**: 1 plan

Plans:
- [ ] 01-01-PLAN.md - Create deny.toml, PURITY.md, and CI workflow

### Phase 2: Dependency Cleanup
**Goal**: Cargo.toml contains only allowed dependencies; forbidden runtime dependencies removed
**Depends on**: Phase 1
**Requirements**: REQ-TYPE-06
**Success Criteria** (what must be TRUE):
  1. rayon, rand, sha2, hex are removed from dependencies
  2. `cargo deny check` passes with zero violations
  3. `cargo build` succeeds without forbidden dependencies
  4. proptest, insta, static_assertions added as dev-dependencies
**Plans**: TBD

Plans:
- [ ] 02-01: Remove forbidden dependencies and add test infrastructure

### Phase 3: Type Consolidation
**Goal**: Core type vocabulary organized in types/ module with stable serialization
**Depends on**: Phase 2
**Requirements**: REQ-TYPE-01, REQ-TYPE-03, REQ-TYPE-04, REQ-TYPE-07, REQ-TYPE-08
**Success Criteria** (what must be TRUE):
  1. Context, Fact, ProposedFact, Intent types exist in types/ module
  2. Error types use thiserror derivation with structured variants
  3. State machines use enums (invalid states unrepresentable)
  4. Builder patterns exist for complex type construction
  5. All validation functions are pure (no I/O, no side effects)
**Plans**: TBD

Plans:
- [ ] 03-01: Organize types/ module structure
- [ ] 03-02: Implement error types and builders

### Phase 4: Gate Pattern
**Goal**: Generic ProposalLifecycle<I, P, V, F> abstraction enforces "agents suggest, engine decides"
**Depends on**: Phase 3
**Requirements**: REQ-GATE-01, REQ-GATE-02, REQ-GATE-03, REQ-GATE-05, REQ-GATE-07, REQ-GATE-09, REQ-GATE-10
**Success Criteria** (what must be TRUE):
  1. ProposalLifecycle<I, P, V, F> generic type exists in gates/ module
  2. PromotionGate requires ValidationReport (no bypass path)
  3. Fact::new() is private; promotion is the only path to create facts
  4. Budget types exist for guaranteed termination
  5. StopReason enumeration covers all termination reasons
  6. Kernel boundary types define constitutional interfaces
**Plans**: TBD

Plans:
- [ ] 04-01: Implement ProposalLifecycle and PromotionGate
- [ ] 04-02: Implement kernel boundary types and budgets

### Phase 5: Trait Definitions
**Goal**: All capability boundary traits defined in traits/ module with clear ownership
**Depends on**: Phase 4
**Requirements**: REQ-TYPE-02, REQ-TRAIT-01, REQ-TRAIT-02, REQ-TRAIT-03, REQ-TRAIT-04, REQ-TRAIT-05, REQ-TRAIT-06, REQ-TRAIT-07, REQ-DOC-02
**Success Criteria** (what must be TRUE):
  1. LlmBackend, Recall, ExperienceStore, Validator, Promoter traits defined (signatures only)
  2. Existing implementations marked #[deprecated] (not removed)
  3. BOUNDARY.md documents which crate owns each trait implementation
  4. No impl blocks in core for capability traits
  5. traits/ module re-exports all capability boundary traits
**Plans**: TBD

Plans:
- [ ] 05-01: Define capability boundary traits
- [ ] 05-02: Create BOUNDARY.md and deprecate implementations

### Phase 6: Testing Infrastructure
**Goal**: Property-based tests prove invariants; snapshot tests lock serialization
**Depends on**: Phase 5
**Requirements**: REQ-TYPE-05, REQ-TYPE-10, REQ-CI-03, REQ-CI-04, REQ-CI-05, REQ-CI-07, REQ-GATE-04, REQ-GATE-06, REQ-GATE-08
**Success Criteria** (what must be TRUE):
  1. proptest tests verify "cannot promote without validation" invariant
  2. proptest tests verify "facts are append-only" invariant
  3. insta snapshot tests exist for all serializable types
  4. static_assertions verify Send/Sync bounds at compile time
  5. TraceLink separation (Local vs Remote) is tested
  6. Replayability honesty is verified (determinism guarantees hold)
**Plans**: TBD

Plans:
- [ ] 06-01: Implement proptest invariant tests
- [ ] 06-02: Implement insta snapshot tests and static assertions

### Phase 7: Documentation
**Goal**: Module documentation complete; nine tenets documented in crate docs
**Depends on**: Phase 6
**Requirements**: REQ-TYPE-09, REQ-CI-06, REQ-DOC-03, REQ-DOC-04
**Success Criteria** (what must be TRUE):
  1. lib.rs has module-level purity declarations
  2. types/, traits/, gates/ modules have comprehensive doc comments
  3. Nine design tenets documented in crate-level documentation
  4. cargo-semver-checks added to CI (API stability verification)
**Plans**: TBD

Plans:
- [ ] 07-01: Write module and crate documentation
- [ ] 07-02: Add cargo-semver-checks to CI

### Phase 8: Stabilization
**Goal**: Final validation confirms purity, stability, and test coverage
**Depends on**: Phase 7
**Requirements**: None (validation phase)
**Success Criteria** (what must be TRUE):
  1. `cargo deny check` passes with zero violations
  2. All tests pass including proptest invariant checks
  3. `cargo build` succeeds with zero warnings
  4. `cargo doc` builds without warnings
  5. All 39 v1 requirements verified complete
**Plans**: TBD

Plans:
- [ ] 08-01: Final validation and cleanup

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. CI Foundation | 0/1 | Planned | - |
| 2. Dependency Cleanup | 0/1 | Not started | - |
| 3. Type Consolidation | 0/2 | Not started | - |
| 4. Gate Pattern | 0/2 | Not started | - |
| 5. Trait Definitions | 0/2 | Not started | - |
| 6. Testing Infrastructure | 0/2 | Not started | - |
| 7. Documentation | 0/2 | Not started | - |
| 8. Stabilization | 0/1 | Not started | - |

## Requirement Coverage

All 39 v1 requirements mapped:

| Requirement | Phase | Category |
|-------------|-------|----------|
| REQ-TYPE-01 | 3 | Core Types |
| REQ-TYPE-02 | 5 | Core Types |
| REQ-TYPE-03 | 3 | Core Types |
| REQ-TYPE-04 | 3 | Core Types |
| REQ-TYPE-05 | 6 | Core Types |
| REQ-TYPE-06 | 2 | Core Types |
| REQ-TYPE-07 | 3 | Core Types |
| REQ-TYPE-08 | 3 | Core Types |
| REQ-TYPE-09 | 7 | Core Types |
| REQ-TYPE-10 | 6 | Core Types |
| REQ-GATE-01 | 4 | Gate Pattern |
| REQ-GATE-02 | 4 | Gate Pattern |
| REQ-GATE-03 | 4 | Gate Pattern |
| REQ-GATE-04 | 6 | Gate Pattern |
| REQ-GATE-05 | 4 | Gate Pattern |
| REQ-GATE-06 | 6 | Gate Pattern |
| REQ-GATE-07 | 4 | Gate Pattern |
| REQ-GATE-08 | 6 | Gate Pattern |
| REQ-GATE-09 | 4 | Gate Pattern |
| REQ-GATE-10 | 4 | Gate Pattern |
| REQ-TRAIT-01 | 5 | Trait Definitions |
| REQ-TRAIT-02 | 5 | Trait Definitions |
| REQ-TRAIT-03 | 5 | Trait Definitions |
| REQ-TRAIT-04 | 5 | Trait Definitions |
| REQ-TRAIT-05 | 5 | Trait Definitions |
| REQ-TRAIT-06 | 5 | Trait Definitions |
| REQ-TRAIT-07 | 5 | Trait Definitions |
| REQ-CI-01 | 1 | CI & Testing |
| REQ-CI-02 | 1 | CI & Testing |
| REQ-CI-03 | 6 | CI & Testing |
| REQ-CI-04 | 6 | CI & Testing |
| REQ-CI-05 | 6 | CI & Testing |
| REQ-CI-06 | 7 | CI & Testing |
| REQ-CI-07 | 6 | CI & Testing |
| REQ-CI-08 | 1 | CI & Testing |
| REQ-DOC-01 | 1 | Documentation |
| REQ-DOC-02 | 5 | Documentation |
| REQ-DOC-03 | 7 | Documentation |
| REQ-DOC-04 | 7 | Documentation |

**Coverage: 39/39 requirements mapped**

---
*Last updated: 2026-01-23*
