---
phase: 04
plan: 01
subsystem: gates
tags: [gate-pattern, validation, promotion, type-state, lifecycle-trait]

dependency_graph:
  requires:
    - "Phase 3: Type Consolidation"
    - "types/proposal.rs: Proposal<Draft>, Proposal<Validated>"
    - "types/fact.rs: Fact with PromotionRecord"
    - "types/provenance.rs: PromotionRecord, EvidenceRef, TraceLink"
  provides:
    - "gates module with ProposalLifecycle trait"
    - "PromotionGate enforcing agents suggest engine decides"
    - "ValidationReport as unforgeable proof object"
  affects:
    - "Phase 4-02: Budget types and StopReason"
    - "Phase 5: Kernel Interface"
    - "All future code creating Facts"

tech_stack:
  added: []
  patterns:
    - "Gate Pattern: validates proposals before promotion"
    - "ProposalLifecycle<I,P,V,F> generic trait"
    - "ValidatedProposal proof bundle"
    - "ValidationToken ZST for forgery prevention"

key_files:
  created:
    - "converge-platform/converge-core/src/gates/mod.rs"
    - "converge-platform/converge-core/src/gates/lifecycle.rs"
    - "converge-platform/converge-core/src/gates/promotion.rs"
    - "converge-platform/converge-core/src/gates/validation.rs"
  modified:
    - "converge-platform/converge-core/src/lib.rs"
    - "converge-platform/converge-core/src/types/error.rs"
    - "converge-platform/converge-core/src/types/fact.rs"
    - "converge-platform/converge-core/src/types/id.rs"

decisions:
  - id: "04-01-01"
    title: "ValidationToken ZST for forgery prevention"
    rationale: "Zero-sized private type ensures ValidationReport can only be created by validators within the crate"
    alternatives: "Could use sealed trait pattern but ZST is simpler and has no runtime cost"
  - id: "04-01-02"
    title: "ValidatedProposal bundles proof with proposal"
    rationale: "Prevents report and proposal from being separated between validation and promotion"
    alternatives: "Could use separate parameters but bundling is more type-safe"
  - id: "04-01-03"
    title: "ContentHash implements Default returning zero()"
    rationale: "Required for ValidationPolicy::default(), zero hash is the natural identity"
    alternatives: "Could remove Default derive from ValidationPolicy but this is cleaner"

metrics:
  duration: "8 min"
  completed: "2026-01-23"
---

# Phase 4 Plan 1: Gate Pattern Foundation Summary

**One-liner:** ProposalLifecycle trait with PromotionGate enforcing "agents suggest, engine decides" via unforgeable ValidationReport proof objects.

## What Was Built

### 1. gates/validation.rs - Validation Types

Created the validation infrastructure with forgery-prevention:

- **ValidationToken** - Private ZST ensuring only validators can create reports
- **CheckResult** - Single validation check result (passed/failed with message)
- **ValidationReport** - Proof object with `pub(crate)` constructor
- **ValidationPolicy** - Policy with required checks and FNV-1a version hash
- **ValidationContext** - Tenant/session context for validation
- **ValidationError** - thiserror-based error type

Key invariant: `ValidationReport::new()` is `pub(crate)` - external code cannot forge reports.

### 2. gates/lifecycle.rs - ProposalLifecycle Trait

Defined the generic lifecycle trait:

```rust
pub trait ProposalLifecycle<I, P, V, F> {
    fn validate(&self, intent: &I, proposal: P) -> Result<V, ValidationError>;
    fn promote(&self, validated: V) -> Result<F, PromotionError>;
}
```

Type parameters:
- `I`: Intent type (context for validation decisions)
- `P`: Proposal type (what agents suggest)
- `V`: Validation proof type (bundles report with validated proposal)
- `F`: Fact type (promoted result with audit trail)

### 3. gates/promotion.rs - PromotionGate Implementation

Implemented the concrete gate:

- **PromotionGate** - Validates Draft proposals, promotes to Facts
- **ValidatedProposal** - Proof bundle (Proposal<Validated> + ValidationReport)
- **SimpleIntent** - Basic intent for ProposalLifecycle implementation
- **ProposalLifecycle impl** - Gate implements the generic trait

The gate now uses the previously-unused `pub(crate)` constructors:
- `Proposal<Validated>::from_validated()` - called during validation
- `Fact::new()` - called during promotion

### 4. Supporting Changes

- **PromotionError::ReportMismatch** - New variant for mismatched report/proposal
- **FactContentKind::From<ProposedContentKind>** - Conversion during promotion
- **ContentHash::Default** - Returns zero(), needed for ValidationPolicy default

## Tests Added

16 tests verify the gate pattern invariants:

| Test | Purpose |
|------|---------|
| `gate_creation` | PromotionGate constructs correctly |
| `successful_validation` | Draft proposal validates to ValidatedProposal |
| `failed_validation_empty_content` | Empty content fails validation |
| `successful_promotion` | ValidatedProposal promotes to Fact |
| `proposal_lifecycle_trait` | ProposalLifecycle trait methods work |
| `policy_required_checks_run` | Policy required checks appear in report |
| `fact_content_kind_conversion` | ProposedContentKind converts correctly |
| `validation_report_creation` | Report has correct proposal ID and checks |
| `validation_report_with_failures` | Failed checks detected correctly |
| `validation_policy_builder` | Policy builder works correctly |
| `validation_context_builder` | Context builder works correctly |
| `validation_error_display` | Error messages format correctly |
| + 4 more | Additional coverage |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] ContentHash missing Default impl**

- **Found during:** Task 3 (PromotionGate implementation)
- **Issue:** ValidationPolicy derives Default but ContentHash didn't implement it
- **Fix:** Added `impl Default for ContentHash` returning `Self::zero()`
- **Files modified:** types/id.rs
- **Commit:** 5965947

## Decisions Made

1. **ValidationToken ZST pattern** - Zero-sized private type prevents forgery with no runtime cost
2. **ValidatedProposal bundles proof** - Ensures report and proposal stay together
3. **ContentHash::default() = zero()** - Natural identity for hash values

## Integration Points

### Types Used From Phase 3

- `Proposal<Draft>` / `Proposal<Validated>` - Type-state pattern
- `Fact`, `FactId`, `FactContent`, `FactContentKind` - Promoted facts
- `PromotionRecord`, `EvidenceRef`, `TraceLink` - Provenance types
- `Actor`, `ValidationSummary` - Supporting types
- `ProposalId`, `GateId`, `ContentHash`, `Timestamp` - ID types

### Types Provided for Future Phases

- `ProposalLifecycle<I, P, V, F>` - Generic trait for any domain
- `PromotionGate` - Standard gate implementation
- `ValidationReport` - Proof of validation
- `ValidatedProposal` - Proof bundle for promotion
- `ValidationPolicy`, `ValidationContext` - Policy types
- `CheckResult`, `ValidationError` - Validation primitives

## Commits

1. `128c9a0` - feat(04-01): add ValidationReport and supporting types for Gate Pattern
2. `380e0b4` - feat(04-01): add ProposalLifecycle trait for Gate Pattern
3. `5965947` - feat(04-01): add PromotionGate and wire up gates module

## Next Phase Readiness

**Ready for Phase 4-02:**
- Gate pattern foundation complete
- PromotionGate ready for budget integration
- StopReason can reference gate validation failures

**Blocking issues:** None
