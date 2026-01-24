---
phase: 06-testing-infrastructure
plan: 01
subsystem: testing
completed: 2026-01-24
duration: ~10 minutes
requires:
  - "05-03: Validator and Promoter trait definitions"
provides:
  - "Test helpers: DeterministicIdGenerator, FrozenClock, IdNormalizer"
  - "Proptest strategies for all core types"
  - "TestHarness for gate testing"
  - "ReplayRunner for golden scenarios"
affects:
  - "06-02: Gate proptest and invariant tests (uses strategies)"
  - "06-03: Snapshot tests (uses normalization)"
  - "06-04: Compile-fail tests (may use harness)"
tech-stack:
  added:
    - "proptest strategies in tests/common"
  patterns:
    - "Frozen clock for deterministic timestamps"
    - "Deterministic ID generation for reproducible tests"
    - "JSON normalization for snapshot stability"
key-files:
  created:
    - "converge-platform/converge-core/tests/common/mod.rs"
    - "converge-platform/converge-core/tests/common/ids.rs"
    - "converge-platform/converge-core/tests/common/time.rs"
    - "converge-platform/converge-core/tests/common/normalize.rs"
    - "converge-platform/converge-core/tests/common/strategies.rs"
    - "converge-platform/converge-core/tests/common/harness.rs"
    - "converge-platform/converge-core/tests/common/replay.rs"
  modified: []
decisions: []
tags:
  - proptest
  - testing
  - determinism
  - harness
---

# Phase 6 Plan 1: Test Infrastructure Summary

**One-liner:** Complete test harness with proptest strategies for all types, frozen clock, deterministic IDs, and replay infrastructure.

## What Was Built

### 1. Core Helpers (ids.rs, time.rs, normalize.rs)

**DeterministicIdGenerator** - Thread-safe sequential ID generator:
```rust
let ids = DeterministicIdGenerator::new("test");
ids.next_fact_id();       // "test-000001"
ids.next_observation_id(); // "test-000002"
```
- Uses `AtomicU64` for thread safety
- Generates 6 IDs per type (fact, observation, proposal, gate, approval, artifact)
- Reset capability for test isolation

**FrozenClock** - Fixed timestamp generation:
```rust
let clock = FrozenClock::test_date(); // 2024-01-01T00:00:00Z
clock.tick(3600);                      // Advance 1 hour
clock.now();                           // "2024-01-01T01:00:00Z"
```
- Uses `AtomicU64` for thread safety
- Built-in ISO-8601 formatting
- Proper leap year handling via Howard Hinnant's date algorithm

**IdNormalizer** - JSON normalization for snapshots:
```rust
let mut normalizer = IdNormalizer::new();
normalizer.normalize_json(&mut json);
// {"fact_id": "abc123"} -> {"fact_id": "<FACT_ID:1>"}
```
- Tracks 10 field types (IDs, timestamps, hashes, traces)
- Same value gets same placeholder
- Reset capability for isolated tests

### 2. Proptest Strategies (strategies.rs)

Created 30+ strategies covering all core types:

| Category | Strategies |
|----------|------------|
| ID Types | `arb_fact_id`, `arb_observation_id`, `arb_proposal_id`, `arb_gate_id`, `arb_approval_id`, `arb_artifact_id`, `arb_content_hash`, `arb_timestamp` |
| Content | `arb_proposed_content_kind`, `arb_proposed_content`, `arb_fact_content_kind`, `arb_fact_content` |
| Provenance | `arb_evidence_ref`, `arb_local_trace`, `arb_remote_ref`, `arb_trace_link`, `arb_actor_kind`, `arb_actor`, `arb_validation_summary` |
| Budget | `arb_cycle_budget`, `arb_fact_budget`, `arb_token_budget`, `arb_execution_budget` |
| Stop Reason | `arb_error_category`, `arb_invariant_class`, `arb_stop_reason` |
| Composite | `arb_promotion_record`, `arb_provider_identity`, `arb_capture_context`, `arb_observation_kind`, `arb_observation`, `arb_observation_provenance`, `arb_correction_reason`, `arb_correction_scope`, `arb_correction_event` |

Each strategy includes embedded proptest validation tests.

### 3. Test Harness (harness.rs)

Complete gate testing environment:

```rust
let mut harness = TestHarness::new();

// Create proposal
let content = ProposedContent::new(ProposedContentKind::Claim, "Test claim");
let proposal_id = harness.create_draft(content);

// Lifecycle operations
harness.validate(&proposal_id)?;
let fact_id = harness.promote(&proposal_id)?;

// Query facts
let fact = harness.get_fact(&fact_id);
```

Features:
- Draft/Validated/Fact state management
- Deterministic clock and ID integration
- `try_promote_unvalidated()` for invariant testing
- Reset capability for test isolation

### 4. Replay Infrastructure (replay.rs)

Golden scenario testing:

```rust
let scenario = GoldenScenario::new(
    "happy_path",
    ScenarioInput::simple("Valid claim"),
    ScenarioOutput::success(json!({"id": "fact-1"})),
);

let mut runner = ReplayRunner::new();
assert!(runner.verify_determinism(&scenario));
```

Features:
- JSON scenario format (load/save)
- Determinism verification (run twice, compare)
- Expected output verification
- VerificationResult enum for detailed feedback

## Verification

All tests compile and infrastructure is ready for use:

```bash
$ cargo test --no-run
# All 18 test executables compile successfully
```

## Files Created

| File | Lines | Purpose |
|------|-------|---------|
| `mod.rs` | 23 | Re-exports all modules |
| `ids.rs` | 115 | Deterministic ID generator |
| `time.rs` | 178 | Frozen clock |
| `normalize.rs` | 244 | JSON normalizer |
| `strategies.rs` | 538 | Proptest strategies |
| `harness.rs` | 476 | Test harness |
| `replay.rs` | 553 | Replay infrastructure |

## Deviations from Plan

None - plan executed exactly as written.

## Commits

| Hash | Message |
|------|---------|
| 6980ec8 | feat(06-01): create test infrastructure directory and core helpers |
| 658d122 | feat(06-01): add proptest strategies for all core types |
| 3c46e34 | feat(06-01): add test harness and replay infrastructure |

## Next Phase Readiness

Ready for 06-02 (Gate proptest and invariant tests):
- All strategies available for property-based testing
- TestHarness provides gate lifecycle testing
- ReplayRunner enables determinism verification
