# Requirements: converge-core v2.0.0 Restoration

**Generated:** 2026-01-23
**Scope:** Milestone 1 (v1)

## Scope Summary

| Category | Scope |
|----------|-------|
| Core Types | All Table Stakes |
| Differentiators | Full Gate Pattern |
| Extractions | Traits First (implementations in v2) |
| CI & Testing | Full CI Suite |

---

## V1 Requirements

### Core Types (Table Stakes)

| ID | Requirement | Priority | Complexity |
|----|-------------|----------|------------|
| **REQ-TYPE-01** | Define core type vocabulary (Context, Fact, ProposedFact, Intent) | P0 | Low |
| **REQ-TYPE-02** | Define trait interfaces for all capability boundaries | P0 | Low |
| **REQ-TYPE-03** | Implement enum-based state machines (invalid states unrepresentable) | P0 | Medium |
| **REQ-TYPE-04** | Define error types with thiserror derivation | P0 | Low |
| **REQ-TYPE-05** | Ensure serialization stability with explicit serde renames | P1 | Medium |
| **REQ-TYPE-06** | Zero runtime dependencies (remove rayon, rand, sha2, hex) | P0 | Low |
| **REQ-TYPE-07** | Pure validation functions (no I/O, no side effects) | P0 | Low |
| **REQ-TYPE-08** | Builder patterns for complex type construction | P1 | Low |
| **REQ-TYPE-09** | Comprehensive module documentation | P2 | Medium |
| **REQ-TYPE-10** | Unit tests for all type invariants | P1 | Medium |

### Gate Pattern (Differentiators)

| ID | Requirement | Priority | Complexity |
|----|-------------|----------|------------|
| **REQ-GATE-01** | Define ProposalLifecycle<I, P, V, F> generic abstraction | P0 | High |
| **REQ-GATE-02** | Implement PromotionGate with ValidationReport requirement | P0 | Medium |
| **REQ-GATE-03** | Explicit authority grants (no defaults that grant authority) | P0 | Medium |
| **REQ-GATE-04** | Replayability honesty (system tells truth about determinism) | P1 | Medium |
| **REQ-GATE-05** | Stop reason enumeration (explicit termination reasons) | P0 | Low |
| **REQ-GATE-06** | TraceLink separation (Local for replay, Remote for audit) | P1 | Medium |
| **REQ-GATE-07** | Kernel boundary types (constitutional types for all kernels) | P0 | High |
| **REQ-GATE-08** | Governed artifact lifecycle with audit trails | P1 | Medium |
| **REQ-GATE-09** | Invariant classification (categorized governance rules) | P1 | Low |
| **REQ-GATE-10** | Budget types for guaranteed termination | P0 | Low |

### Trait Definitions (Extraction Prep)

| ID | Requirement | Priority | Complexity |
|----|-------------|----------|------------|
| **REQ-TRAIT-01** | Define LlmBackend trait (signature only, no impl) | P0 | Low |
| **REQ-TRAIT-02** | Define Recall trait (signature only, no impl) | P0 | Low |
| **REQ-TRAIT-03** | Define ExperienceStore trait (signature only, no impl) | P0 | Low |
| **REQ-TRAIT-04** | Define Validator trait (signature only, no impl) | P0 | Low |
| **REQ-TRAIT-05** | Define Promoter trait (signature only, no impl) | P0 | Low |
| **REQ-TRAIT-06** | Mark existing implementations as deprecated (not removed) | P1 | Low |
| **REQ-TRAIT-07** | Create BOUNDARY.md documenting trait ownership | P1 | Low |

### CI & Testing (Guardrails)

| ID | Requirement | Priority | Complexity |
|----|-------------|----------|------------|
| **REQ-CI-01** | Create deny.toml with forbidden dependency list | P0 | Low |
| **REQ-CI-02** | Add cargo-deny to CI pipeline | P0 | Low |
| **REQ-CI-03** | Property-based tests with proptest for invariants | P1 | Medium |
| **REQ-CI-04** | Snapshot tests with insta for serialization stability | P1 | Medium |
| **REQ-CI-05** | Compile-time assertions with static_assertions | P1 | Low |
| **REQ-CI-06** | API stability checks with cargo-semver-checks | P2 | Low |
| **REQ-CI-07** | Golden tests for every serializable type | P1 | Medium |
| **REQ-CI-08** | Create PURITY.md with ALLOWED/FORBIDDEN lists | P0 | Low |

### Documentation

| ID | Requirement | Priority | Complexity |
|----|-------------|----------|------------|
| **REQ-DOC-01** | Create PURITY.md contract document | P0 | Low |
| **REQ-DOC-02** | Create BOUNDARY.md trait ownership document | P1 | Low |
| **REQ-DOC-03** | Update lib.rs with module-level purity declarations | P1 | Low |
| **REQ-DOC-04** | Document nine design tenets in crate docs | P2 | Low |

---

## V2 Requirements (Deferred)

### Full Extraction

| ID | Requirement | Notes |
|----|-------------|-------|
| **REQ-V2-01** | Extract llm.rs implementations to converge-llm | After traits stable |
| **REQ-V2-02** | Extract backend.rs implementations to converge-runtime | After traits stable |
| **REQ-V2-03** | Extract capability.rs to converge-provider | After traits stable |
| **REQ-V2-04** | Extract model_selection.rs to converge-provider | After traits stable |
| **REQ-V2-05** | Extract prompt.rs to converge-llm | After traits stable |
| **REQ-V2-06** | Create converge-core-test for test utilities | MockProvider, test agents |
| **REQ-V2-07** | Remove deprecated implementations from core | After downstream migration |

### Advanced Testing

| ID | Requirement | Notes |
|----|-------------|-------|
| **REQ-V2-08** | Benchmark suite with criterion | Performance baselines |
| **REQ-V2-09** | Negative tests for boundary violations | Ensure APIs reject bad input |
| **REQ-V2-10** | Integration tests with capability crates | End-to-end validation |

---

## Out of Scope

| Item | Reason |
|------|--------|
| Async runtime integration | Core must remain sync/pure |
| HTTP/Network types | I/O belongs in capability crates |
| Embedding/Recall execution | Implementation, not axiom |
| Prompt rendering logic | Implementation, not axiom |
| "Helpful" defaults | Violates explicit authority tenet |
| Background effects | Violates no hidden work tenet |

---

## Requirement Dependencies

```
REQ-CI-01 --> REQ-CI-02 (deny.toml before CI)
REQ-DOC-01 --> REQ-TRAIT-* (PURITY.md guides trait design)
REQ-GATE-01 --> REQ-GATE-02 (Lifecycle before PromotionGate)
REQ-TYPE-01 --> REQ-GATE-* (Core types before gates)
REQ-TRAIT-* --> REQ-V2-* (Traits before extraction)
```

---

## Success Criteria

1. **Purity:** `cargo deny check` passes with zero forbidden dependencies
2. **Type Safety:** No API allows Fact creation without ValidationReport
3. **Stability:** All serializable types have golden snapshot tests
4. **Documentation:** PURITY.md and BOUNDARY.md exist and are accurate
5. **Compilation:** `cargo build` succeeds with zero warnings
6. **Tests:** All tests pass including proptest invariant checks

---

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| REQ-TYPE-01 | Phase 3 | Pending |
| REQ-TYPE-02 | Phase 5 | Pending |
| REQ-TYPE-03 | Phase 3 | Pending |
| REQ-TYPE-04 | Phase 3 | Pending |
| REQ-TYPE-05 | Phase 6 | Pending |
| REQ-TYPE-06 | Phase 2 | Pending |
| REQ-TYPE-07 | Phase 3 | Pending |
| REQ-TYPE-08 | Phase 3 | Pending |
| REQ-TYPE-09 | Phase 7 | Pending |
| REQ-TYPE-10 | Phase 6 | Pending |
| REQ-GATE-01 | Phase 4 | Pending |
| REQ-GATE-02 | Phase 4 | Pending |
| REQ-GATE-03 | Phase 4 | Pending |
| REQ-GATE-04 | Phase 6 | Pending |
| REQ-GATE-05 | Phase 4 | Pending |
| REQ-GATE-06 | Phase 6 | Pending |
| REQ-GATE-07 | Phase 4 | Pending |
| REQ-GATE-08 | Phase 6 | Pending |
| REQ-GATE-09 | Phase 4 | Pending |
| REQ-GATE-10 | Phase 4 | Pending |
| REQ-TRAIT-01 | Phase 5 | Pending |
| REQ-TRAIT-02 | Phase 5 | Pending |
| REQ-TRAIT-03 | Phase 5 | Pending |
| REQ-TRAIT-04 | Phase 5 | Pending |
| REQ-TRAIT-05 | Phase 5 | Pending |
| REQ-TRAIT-06 | Phase 5 | Pending |
| REQ-TRAIT-07 | Phase 5 | Pending |
| REQ-CI-01 | Phase 1 | Complete |
| REQ-CI-02 | Phase 1 | Complete |
| REQ-CI-03 | Phase 6 | Pending |
| REQ-CI-04 | Phase 6 | Pending |
| REQ-CI-05 | Phase 6 | Pending |
| REQ-CI-06 | Phase 7 | Pending |
| REQ-CI-07 | Phase 6 | Pending |
| REQ-CI-08 | Phase 1 | Complete |
| REQ-DOC-01 | Phase 1 | Complete |
| REQ-DOC-02 | Phase 5 | Pending |
| REQ-DOC-03 | Phase 7 | Pending |
| REQ-DOC-04 | Phase 7 | Pending |

---
*Last updated: 2026-01-23*
