---
phase: 06-testing-infrastructure
plan: 02
subsystem: testing
tags: [proptest, property-based, invariants, gates, budgets]

# Dependency graph
requires:
  - phase: 06-01
    provides: TestHarness, proptest strategies, FrozenClock, DeterministicIdGenerator
provides:
  - Promotion invariant proptests (no promotion without validation)
  - Append-only invariant proptests (Facts have no &mut methods)
  - Budget exhaustion proptests (StopReason returned correctly)
  - ID timestamp ordering proptests (deterministic ordering)
affects: [06-03, 06-04, 07-documentation]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - prop_assert! with external variable for matches! patterns
    - Clone for String comparisons in prop_assert_eq!
    - Integration test entry points (gate_proptest.rs)

key-files:
  created:
    - tests/gates/mod.rs
    - tests/gates/promotion_proptest.rs
    - tests/gates/append_only_proptest.rs
    - tests/gates/budget_exhaustion_proptest.rs
    - tests/types/id_timestamp_ordering_proptest.rs
    - tests/gate_proptest.rs
  modified:
    - tests/types/mod.rs

key-decisions:
  - "Extract matches! to local variable in prop_assert! to avoid format string parsing issues"
  - "Clone String values for prop_assert_eq! comparisons to avoid move errors"
  - "Create gate_proptest.rs entry point for integration test organization"

patterns-established:
  - "Proptest with state machines: GateOp enum for operation sequences"
  - "Invariant testing: Single-call boundary + sequence tests + happy path"
  - "Budget testing: Exhaustion cycle, try_reserve, edge cases (zero, exact, over)"

# Metrics
duration: 8min
completed: 2026-01-24
---

# Phase 6 Plan 2: Proptest Invariants Summary

**Proptest invariant tests for three gate invariants plus ID/timestamp ordering with 89+ new property tests**

## Performance

- **Duration:** 8 min
- **Started:** 2026-01-24T08:32:54Z
- **Completed:** 2026-01-24T08:41:00Z
- **Tasks:** 3
- **Files modified:** 7

## Accomplishments
- "No promotion without validation" invariant tested with single-call and state-machine approaches
- "Facts are append-only" invariant tested via API immutability and correction semantics
- Budget exhaustion tested for CycleBudget, FactBudget, TokenBudget, ExecutionBudget
- ID and timestamp ordering consistency verified with deterministic generators

## Task Commits

Each task was committed atomically:

1. **Task 1: Create promotion invariant proptest** - `b668891` (test)
2. **Task 2: Create append-only and budget exhaustion proptests** - `b765692` (test)
3. **Task 3: Create ID timestamp ordering proptest** - `ded4949` (test)
4. **Fix: Proptest compilation issues** - `2d99a06` (fix)

## Files Created/Modified
- `tests/gates/mod.rs` - Module declarations for gate tests
- `tests/gates/promotion_proptest.rs` - Promotion invariant proptests
- `tests/gates/append_only_proptest.rs` - Append-only invariant proptests
- `tests/gates/budget_exhaustion_proptest.rs` - Budget exhaustion proptests
- `tests/types/id_timestamp_ordering_proptest.rs` - ID/timestamp ordering proptests
- `tests/types/mod.rs` - Added id_timestamp_ordering module
- `tests/gate_proptest.rs` - Integration test entry point

## Decisions Made
1. **Matches pattern extraction:** The `matches!` macro with `{ .. }` patterns causes format string parsing issues inside `prop_assert!`. Solution: Extract to local bool variable first.
2. **String clone for comparisons:** `prop_assert_eq!` tries to move String values. Solution: Use `.clone()` on the left-hand side.
3. **Integration test entry point:** Created `gate_proptest.rs` to include common and gates modules as a proper Cargo test target.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Format string parsing in prop_assert! with matches!**
- **Found during:** Task 2 (budget_exhaustion_proptest.rs compilation)
- **Issue:** `prop_assert!(matches!(x, SomeVariant { .. }))` interprets `{ .. }` as format string
- **Fix:** Extract matches! result to local variable: `let is_match = matches!(x, SomeVariant { .. }); prop_assert!(is_match);`
- **Files modified:** tests/gates/budget_exhaustion_proptest.rs
- **Verification:** cargo test --test gate_proptest passes
- **Committed in:** 2d99a06

**2. [Rule 3 - Blocking] Move errors in prop_assert_eq! with String**
- **Found during:** Task 2 (append_only_proptest.rs compilation)
- **Issue:** `prop_assert_eq!(fact.content().content, expected)` moves String
- **Fix:** Add `.clone()` to create owned copy for comparison
- **Files modified:** tests/gates/append_only_proptest.rs
- **Verification:** cargo test --test gate_proptest passes
- **Committed in:** 2d99a06

---

**Total deviations:** 2 auto-fixed (2 blocking)
**Impact on plan:** Compilation fixes required for proptest macro compatibility. No scope creep.

## Issues Encountered
- Method name: ContentHash uses `to_hex()` not `as_hex()` - linter auto-corrected

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Proptest infrastructure complete for gate invariants
- TestHarness working with property-based testing
- Ready for Phase 06-03: Snapshot tests (insta)
- Ready for Phase 06-04: Compile-fail tests (if not already done)

---
*Phase: 06-testing-infrastructure*
*Completed: 2026-01-24*
