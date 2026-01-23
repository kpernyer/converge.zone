---
phase: 04-gate-pattern
plan: 02
subsystem: gates
tags: [budget, termination, stop-reason, kernel-boundary, authority]
dependency-graph:
  requires: [04-01]
  provides: [budget-types, stop-reason, authority-grant]
  affects: [05-kernel-extraction, 06-testing]
tech-stack:
  added: []
  patterns: [newtype-pattern, checked-arithmetic, exhaustive-enum]
key-files:
  created:
    - converge-platform/converge-core/src/gates/stop.rs
    - converge-platform/converge-core/src/gates/budget.rs
    - converge-platform/converge-core/src/gates/boundary.rs
  modified:
    - converge-platform/converge-core/src/gates/mod.rs
    - converge-platform/converge-core/src/lib.rs
decisions:
  - title: "tick() returns Option<StopReason>"
    context: "Budget exhaustion must be detectable"
    decision: "tick() and consume() return Option<StopReason> on exhaustion"
    rationale: "Caller cannot miss exhaustion moment; pattern encourages checking"
  - title: "StopReason #[non_exhaustive]"
    context: "May need to add new stop reasons"
    decision: "Mark StopReason with #[non_exhaustive]"
    rationale: "Allows adding variants without breaking downstream matches"
  - title: "AuthorityGrant pub(crate) constructors"
    context: "Authority grants must be controlled"
    decision: "system(), human(), policy() constructors are pub(crate)"
    rationale: "External code cannot forge authority grants"
metrics:
  duration: 6 min
  completed: 2026-01-23
---

# Phase 4 Plan 2: Budget Types and StopReason Summary

Budget newtypes with checked arithmetic, exhaustive StopReason enum, and AuthorityGrant for explicit authority.

## One-Liner

Budget newtypes (Cycle/Fact/Token) with tick() returning Option<StopReason> for guaranteed termination detection.

## What Was Built

### Task 1: StopReason Enumeration
**File:** `converge-platform/converge-core/src/gates/stop.rs`

- **StopReason enum** with 10 variants organized by category:
  - Success: `Converged`, `CriteriaMet`, `UserCancelled`
  - Budget: `CycleBudgetExhausted`, `FactBudgetExhausted`, `TokenBudgetExhausted`, `TimeBudgetExhausted`
  - Validation: `InvariantViolated`, `PromotionRejected`
  - Error: `Error`, `AgentRefused`
- **Constructor helpers** for each variant (e.g., `StopReason::converged()`)
- **Query methods**: `is_success()`, `is_budget_exhausted()`, `is_validation_failure()`, `is_error()`
- **Display trait** for human-readable output
- **ErrorCategory enum** for programmatic error handling
- **18 tests** covering all variants and serde roundtrip

### Task 2: Budget Newtypes
**File:** `converge-platform/converge-core/src/gates/budget.rs`

- **CycleBudget**: Tracks execution cycles
  - `new(max)`, `remaining()`, `initial()`, `consumed()`, `is_exhausted()`
  - `tick() -> Option<StopReason>` - returns stop reason when budget exhausted
  - `try_reserve(n) -> Result<(), StopReason>` - reserve multiple cycles

- **FactBudget**: Tracks facts in context (same API as CycleBudget)

- **TokenBudget**: Tracks LLM tokens consumed
  - `consume(n) -> Option<StopReason>` - consume variable tokens
  - Uses u64 for token counts (larger scale)

- **ExecutionBudget**: Combines all budget types
  - `new(max_cycles, max_facts)`, `with_tokens(max_tokens)`
  - `check_exhaustion() -> Option<StopReason>` - first exhausted budget
  - `tick_cycle()`, `tick_fact()`, `consume_tokens(n)`
  - Default: 100 cycles, 10,000 facts

- **30 tests** including edge cases (zero budget, single tick exhaustion)

### Task 3: Kernel Boundary Types
**File:** `converge-platform/converge-core/src/gates/boundary.rs`

- **constitutional module**: Re-exports all kernel_boundary types organized by purpose:
  - Input types: `KernelIntent`, `KernelContext`, `KernelPolicy`, `ContextFact`
  - Output types: `KernelProposal`, `ProposalKind`, `ContentKind`, etc.
  - Tracing types: `TraceLink`, `LocalTraceLink`, `RemoteTraceLink`, `Replayability`
  - Supporting types: `AdapterTrace`, `SamplerParams`, `RecallTrace`, `ExecutionEnv`
  - Routing types: `RiskTier`, `DataClassification`, `RoutingPolicy`

- **AuthorityGrant**: Explicit permission for promotion
  - `pub(crate) system()`, `human(approver_id)`, `policy(policy_id)` constructors
  - `grantor()`, `granted_at()`, `scope()` accessors
  - External code cannot forge grants

- **AuthorityGrantor enum**: `System`, `Human { approver_id }`, `Policy { policy_id }`

- **AuthorityScope**: Limits on grants
  - `proposal_kinds`, `gate_ids`, `expires_at`
  - Builder pattern: `with_proposal_kinds()`, `with_gate_ids()`, `with_expiration()`

- **5 tests** for authority grant creation and scoping

### Module Updates
**File:** `converge-platform/converge-core/src/gates/mod.rs`
- Added `boundary`, `budget`, `stop` modules
- Updated documentation with new types and invariants
- Re-exports all new types

**File:** `converge-platform/converge-core/src/lib.rs`
- Re-exports: `CycleBudget`, `FactBudget`, `TokenBudget`, `ExecutionBudget`
- Re-exports: `StopReason`, `ErrorCategory`
- Re-exports: `AuthorityGrant`, `AuthorityGrantor`, `AuthorityScope`

## Key Design Decisions

1. **tick() returns Option<StopReason>**
   - Pattern ensures callers cannot miss budget exhaustion
   - Matches Rust Option semantics (Some = exhausted, None = continue)
   - Returns stop reason even when already exhausted (idempotent)

2. **StopReason #[non_exhaustive]**
   - Allows adding new variants in future
   - Downstream code must handle wildcard case
   - Standard Rust practice for public enums

3. **AuthorityGrant pub(crate) constructors**
   - Enforces REQ-GATE-03: "No defaults that grant authority"
   - External code can read grants but cannot create them
   - Grants come from system, human approval, or policy delegation only

## Commits

| Hash | Message |
|------|---------|
| ac5e12a | feat(04-02): add StopReason enumeration for engine termination |
| ff0ad8d | feat(04-02): add Budget newtypes for guaranteed termination |
| 850c58d | feat(04-02): add kernel boundary types and update gate exports |

## Tests Summary

| Module | Tests | Status |
|--------|-------|--------|
| gates::stop | 18 | Pass |
| gates::budget | 30 | Pass |
| gates::boundary | 5 | Pass |
| **Total** | **53** | **Pass** |

## Deviations from Plan

None - plan executed exactly as written.

## Success Criteria Verification

| Criterion | Status |
|-----------|--------|
| CycleBudget, FactBudget, TokenBudget newtypes exist with tick() -> Option<StopReason> | Done |
| StopReason enum covers all termination conditions | Done |
| ExecutionBudget combines all budget types | Done |
| AuthorityGrant enforces explicit authority (no defaults) | Done |
| constitutional module re-exports kernel boundary types | Done |
| All types re-exported from lib.rs | Done |
| Tests verify budget exhaustion and stop reason generation | Done |

## Next Phase Readiness

**Ready for Phase 04-03** (if exists) or Phase 05:
- Budget types ready for engine integration
- StopReason ready for convergence loop termination
- AuthorityGrant ready for promotion flow
- No blockers or concerns
