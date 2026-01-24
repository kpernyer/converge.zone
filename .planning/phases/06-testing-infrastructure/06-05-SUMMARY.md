---
phase: 06-testing-infrastructure
plan: 05
subsystem: testing/determinism
tags: [determinism, replay, golden-scenarios, tracelink, replayability]

dependency-graph:
  requires: ["06-01", "06-02"]
  provides: ["determinism-verification", "golden-scenarios", "tracelink-tests"]
  affects: ["07-crate-structure", "08-boundary-documentation"]

tech-stack:
  added: []
  patterns: ["golden-scenario-testing", "replay-verification", "replayability-honesty"]

key-files:
  created:
    - converge-platform/converge-core/tests/golden/promotion_happy_path.json
    - converge-platform/converge-core/tests/golden/correction_supersedes.json
    - converge-platform/converge-core/tests/golden/tracelink_local_vs_remote.json
    - converge-platform/converge-core/tests/gates/determinism_replay.rs
  modified:
    - converge-platform/converge-core/tests/gates/mod.rs

decisions:
  - "Golden scenarios as JSON files in tests/golden/"
  - "TraceLink::Local is replay-eligible, TraceLink::Remote is not"
  - "Kernel TraceLink has explicit Replayability enum (Deterministic, BestEffort, None)"
  - "ReplayRunner verifies determinism by running scenarios twice"

metrics:
  duration: "4 min"
  completed: "2026-01-24"
  tests_added: 12
  golden_scenarios: 3
---

# Phase 06 Plan 05: Determinism Verification Summary

Determinism verification tests proving replayability honesty - TraceLink::Local is deterministically replayable, TraceLink::Remote is audit-only.

## One-liner

Golden scenarios and replay tests verifying determinism guarantees: same inputs produce same outputs with frozen clock/IDs.

## What Was Done

### Task 1: Golden Scenario Files
- Created `tests/golden/` directory with 3 golden scenarios:
  - `promotion_happy_path.json`: Successful promotion flow
  - `correction_supersedes.json`: Correction creating new fact
  - `tracelink_local_vs_remote.json`: TraceLink separation

### Task 2: Determinism Replay Tests
- Created `tests/gates/determinism_replay.rs` with 11 tests:
  - **TraceLink eligibility**: Local vs Remote replay eligibility
  - **Kernel TraceLink**: Deterministic, BestEffort, None replayability
  - **Golden scenario loading**: tracelink_local_vs_remote, promotion_happy_path
  - **Determinism properties**: Same inputs same outputs, promotion sequence ordering
  - **Replay verification**: Harness reset enables replay, ReplayRunner verify

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Golden scenarios as JSON | Human-readable, version-controllable test fixtures |
| TraceLink::Local is replay-eligible | Local traces are deterministic by definition |
| TraceLink::Remote is NOT replay-eligible | External systems introduce bounded stochasticity |
| ReplayRunner double-execution | Running twice and comparing outputs proves determinism |

## Deviations from Plan

None - plan executed exactly as written.

## Tests Added

| Category | Count | Description |
|----------|-------|-------------|
| TraceLink eligibility | 4 | Local/Remote replay eligibility tests |
| Golden scenarios | 2 | Load and verify golden scenario files |
| Determinism properties | 5 | Same inputs same outputs, sequence ordering |
| **Total** | **11** | Plus 1 in common/replay module |

## Key Patterns Established

### Replayability Honesty
The system tells the truth about what can and cannot be deterministically replayed:
- `TraceLink::Local` -> Deterministic (replay-eligible)
- `TraceLink::Remote` -> BestEffort or None (audit-only)

### Golden Scenario Testing
Pre-recorded scenarios in JSON format enable:
- Regression testing against known-good outputs
- Documentation of expected behavior
- Reproducible debugging scenarios

## Next Phase Readiness

Phase 06 Testing Infrastructure complete:
- [x] Test harness (FrozenClock, DeterministicIdGenerator, TestHarness, ReplayRunner)
- [x] Proptest invariants (89 tests)
- [x] Snapshot tests (80 snapshots)
- [x] Static assertions (60+ types Send+Sync)
- [x] Compile-fail tests (private constructors)
- [x] Determinism verification (12 tests, 3 golden scenarios)

Ready for Phase 07 (Crate Structure) or Phase 08 (Boundary Documentation).
