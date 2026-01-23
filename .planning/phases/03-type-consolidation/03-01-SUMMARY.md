---
phase: 03-type-consolidation
plan: 01
subsystem: types
tags: [rust, serde, type-state, newtype, observation, proposal, fact, provenance]

# Dependency graph
requires:
  - phase: 02-dependency-cleanup
    provides: Clean dependency graph, no rand/rayon
provides:
  - types/ module with core domain types
  - Newtype IDs (FactId, ObservationId, ProposalId, GateId, ApprovalId, ArtifactId, ContentHash, Timestamp)
  - 3-tier hierarchy types (Observation -> Proposal -> Fact)
  - Type-state Proposal<Draft>/Proposal<Validated>
  - Private-constructor Fact with required PromotionRecord
  - Provenance types (PromotionRecord, EvidenceRef, TraceLink, Actor, ValidationSummary)
affects:
  - 03-02 (gate trait definitions)
  - 04-gate-pattern (will use Proposal/Fact types)
  - 05-capability-boundaries (will use types in traits)

# Tech tracking
tech-stack:
  added: [hex]
  patterns: [type-state-pattern, newtype-id-pattern, private-constructor-invariant]

key-files:
  created:
    - converge-platform/converge-core/src/types/mod.rs
    - converge-platform/converge-core/src/types/id.rs
    - converge-platform/converge-core/src/types/observation.rs
    - converge-platform/converge-core/src/types/proposal.rs
    - converge-platform/converge-core/src/types/fact.rs
    - converge-platform/converge-core/src/types/provenance.rs
  modified:
    - converge-platform/converge-core/src/lib.rs
    - converge-platform/converge-core/Cargo.toml

key-decisions:
  - "Type-state pattern for Proposal lifecycle: Draft (public) vs Validated (crate-only)"
  - "Fact::new() is pub(crate) - external code cannot create Facts directly"
  - "PromotionRecord is required (not Option) on Fact per CONTEXT.md"
  - "EvidenceRef uses adjacently-tagged serde format for proper serialization"
  - "ContentHash wraps [u8; 32] with hex crate for serialization"
  - "Timestamp uses String ISO-8601 per RESEARCH.md recommendation"

patterns-established:
  - "Type-state pattern: Use marker types (Draft, Validated) with PhantomData"
  - "Private constructor: pub(crate) new() for types that require governance"
  - "Newtype ID pattern: All IDs are newtypes with serde(transparent)"
  - "3-tier hierarchy: Observation -> Proposal -> Fact enforces promotion pipeline"

# Metrics
duration: 8min
completed: 2026-01-23
---

# Phase 3 Plan 1: Create types/ Module Summary

**Newtype IDs with serde(transparent), 3-tier type hierarchy (Observation/Proposal/Fact) with type-state pattern and private-constructor Fact requiring PromotionRecord**

## Performance

- **Duration:** 8 min
- **Started:** 2026-01-23T18:26:08Z
- **Completed:** 2026-01-23T18:34:00Z
- **Tasks:** 3/3
- **Files modified:** 8

## Accomplishments

- Created types/ module with complete domain type vocabulary
- 9 newtype IDs (FactId, ObservationId, ProposalId, GateId, ApprovalId, ArtifactId, ContentHash, Timestamp) all with serde(transparent)
- Observation type with CaptureContext and ProviderIdentity for evidence ledger
- Type-state Proposal<Draft>/Proposal<Validated> - Draft is public, Validated is crate-only
- Fact with pub(crate) constructor and required PromotionRecord (not Option)
- Typed provenance: EvidenceRef enum, TraceLink Local/Remote, Actor, ValidationSummary

## Task Commits

Each task was committed atomically:

1. **Task 1: Create types/ module with ID newtypes** - `f457d80` (feat)
2. **Task 2: Create Observation and Provenance types** - `cef2618` (feat)
3. **Task 3: Create type-state Proposal and private-constructor Fact** - `25ed348` (feat)

## Files Created/Modified

- `converge-platform/converge-core/src/types/mod.rs` - Module structure with re-exports
- `converge-platform/converge-core/src/types/id.rs` - 9 newtype IDs with serde(transparent)
- `converge-platform/converge-core/src/types/observation.rs` - Observation, CaptureContext, ProviderIdentity
- `converge-platform/converge-core/src/types/proposal.rs` - Proposal<State> type-state pattern
- `converge-platform/converge-core/src/types/fact.rs` - Fact with private constructor
- `converge-platform/converge-core/src/types/provenance.rs` - PromotionRecord, EvidenceRef, TraceLink, Actor
- `converge-platform/converge-core/src/lib.rs` - Added types module and re-exports
- `converge-platform/converge-core/Cargo.toml` - Added hex dependency

## Decisions Made

1. **Type-state for Proposal:** Using marker types Draft and Validated with PhantomData to enforce lifecycle at compile-time. Draft::new() is public, Validated::from_validated() is pub(crate).

2. **Private constructor for Fact:** Fact::new() is pub(crate) so only code within converge-core (i.e., PromotionGate) can create Facts. External crates get compile error.

3. **Required PromotionRecord:** Per CONTEXT.md, promotion_record is not Option<PromotionRecord> but PromotionRecord directly - every Fact MUST have provenance.

4. **Adjacently-tagged EvidenceRef:** Changed from `#[serde(tag = "type")]` to `#[serde(tag = "type", content = "id")]` because newtype variants don't work with internally-tagged enums.

5. **hex crate for ContentHash:** Added hex dependency for encoding/decoding ContentHash bytes to/from hex strings in serde.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Added hex crate dependency**
- **Found during:** Task 1 (cargo check failed)
- **Issue:** ContentHash uses hex::encode/decode but hex crate not in dependencies
- **Fix:** Added `hex = "0.4"` to Cargo.toml
- **Files modified:** Cargo.toml
- **Verification:** cargo check passes
- **Committed in:** 25ed348 (part of Task 3 commit)

**2. [Rule 1 - Bug] Fixed EvidenceRef serde format**
- **Found during:** Task 3 (tests failed)
- **Issue:** `#[serde(tag = "type")]` doesn't work with newtype enum variants containing String
- **Fix:** Changed to `#[serde(tag = "type", content = "id")]` (adjacently tagged)
- **Files modified:** src/types/provenance.rs
- **Verification:** All serialization tests pass
- **Committed in:** 25ed348 (part of Task 3 commit)

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 bug)
**Impact on plan:** Both auto-fixes necessary for compilation and correctness. No scope creep.

## Issues Encountered

- **dead_code warnings:** Fact::new() and Proposal<Validated>::from_validated() show warnings because they're pub(crate) and not yet used. This is expected - they will be used by PromotionGate in Phase 4.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- types/ module complete with all planned types
- Ready for 03-02: Gate trait definitions (will use Proposal/Fact types)
- Type-state pattern and private constructor pattern established for gates

**Invariants verified:**
- Proposal<Draft>::new() is public
- Proposal<Validated>::from_validated() is pub(crate)
- Fact::new() is pub(crate)
- Fact.promotion_record is PromotionRecord (not Option)
- All ID types have #[serde(transparent)]

---
*Phase: 03-type-consolidation*
*Completed: 2026-01-23*
