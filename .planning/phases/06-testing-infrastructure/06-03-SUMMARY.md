---
phase: "06-testing-infrastructure"
plan: "03"
subsystem: "testing"
tags: ["insta", "snapshot-testing", "serialization", "json"]

dependency-graph:
  requires: ["06-01"]
  provides: ["snapshot-tests-p0-p1"]
  affects: ["07-*"]

tech-stack:
  added: []
  patterns: ["insta-snapshots", "sort_maps-deterministic"]

key-files:
  created:
    - "converge-platform/converge-core/tests/types/fact_snapshots.rs"
    - "converge-platform/converge-core/tests/types/promotion_record_snapshots.rs"
    - "converge-platform/converge-core/tests/types/tracelink_snapshots.rs"
    - "converge-platform/converge-core/tests/types/observation_snapshots.rs"
    - "converge-platform/converge-core/tests/types/correction_event_snapshots.rs"
    - "converge-platform/converge-core/tests/snapshot_tests.rs"
    - "converge-platform/converge-core/tests/snapshots/.gitkeep"
    - "converge-platform/converge-core/tests/types/snapshots/*.snap (80 files)"
  modified:
    - "converge-platform/converge-core/tests/common/ids.rs"
    - "converge-platform/converge-core/tests/common/normalize.rs"
    - "converge-platform/converge-core/tests/common/time.rs"

decisions:
  - key: "sort_maps_for_determinism"
    choice: "Use insta sort_maps setting for HashMap fields"
    rationale: "HashMap iteration order is non-deterministic; sort_maps ensures stable snapshots"

metrics:
  duration: "~9 minutes"
  completed: "2026-01-24"
  tests-total: 125
  snapshot-files: 80
---

# Phase 06 Plan 03: Snapshot Tests Summary

**One-liner:** Insta snapshot tests locking JSON format for all P0/P1 serializable types

## Artifacts Created

### Snapshot Test Files

| File | Types Covered | Tests |
|------|---------------|-------|
| fact_snapshots.rs | Fact, FactContent, ProposedContent | 8 |
| promotion_record_snapshots.rs | PromotionRecord, EvidenceRef, Actor, ValidationSummary | 14 |
| tracelink_snapshots.rs | types::TraceLink, kernel_boundary::TraceLink, Replayability | 16 |
| observation_snapshots.rs | Observation, ObservationKind, ProviderIdentity, CaptureContext | 15 |
| correction_event_snapshots.rs | CorrectionEvent, CorrectionReason, CorrectionScope | 17 |

### Type Coverage

**P0 API Types (Critical):**
- Fact (via TestHarness promotion path)
- FactContent (all 6 FactContentKind variants)
- ProposedContent (all 6 ProposedContentKind variants)
- StopReason (via 06-01)

**P1 Persistence Types:**
- PromotionRecord (minimal and full)
- EvidenceRef (observation, human_approval, derived)
- Actor (human, agent, system variants)
- ValidationSummary (empty and full)
- TraceLink (Local, Remote - both types and kernel_boundary modules)
- Observation (all 4 ObservationKind variants)
- CorrectionEvent (all 5 CorrectionReason variants)
- CorrectionScope (global, tenant, session)

### TraceLink Shapes Documented

**types::TraceLink (provenance marker):**
```json
// Local
{"type": "Local", "trace_id": "...", "span_id": "...", "parent_span_id": "...", "sampled": true}
// Remote
{"type": "Remote", "system": "datadog", "reference": "...", "retrieval_auth": null, "retention_hint": null}
```

**kernel_boundary::TraceLink (LLM reproducibility):**
```json
// Local - full determinism info
{"type": "Local", "base_model_hash": "...", "adapter": null, "tokenizer_hash": "...", "seed": 42, "sampler": {...}, ...}
// Remote - audit-only
{"type": "Remote", "provider_name": "anthropic", "provider_model_id": "...", "request_fingerprint": "...", ...}
```

## Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| HashMap ordering | Use insta `sort_maps => true` | HashMap iteration is non-deterministic; sort_maps ensures stable snapshots across runs |
| Test structure | Single snapshot_tests.rs entry point | Integrates with common module (TestHarness, IdNormalizer) |
| ID normalization | Alphabetical JSON key ordering | Matches serde_json::Map iteration behavior |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed DeterministicIdGenerator `gen` keyword conflict**
- **Found during:** Test compilation
- **Issue:** `gen` is a reserved keyword in Rust 2024 edition
- **Fix:** Renamed variable to `generator` in tests/common/ids.rs
- **Commit:** 43f8741

**2. [Rule 1 - Bug] Fixed IdNormalizer test expectations**
- **Found during:** Test execution
- **Issue:** Tests expected insertion-order but JSON iteration is alphabetical
- **Fix:** Updated test expectations to match alphabetical key ordering
- **Files modified:** tests/common/normalize.rs
- **Commit:** 43f8741

**3. [Rule 1 - Bug] Fixed FrozenClock known_timestamps test**
- **Found during:** Test execution
- **Issue:** Expected "2024-06-15T12:30:45Z" but Unix seconds 1718451045 = "2024-06-15T11:30:45Z"
- **Fix:** Corrected expected timestamp value
- **Files modified:** tests/common/time.rs
- **Commit:** 43f8741

## Testing Results

```
test result: ok. 125 passed; 0 failed; 0 ignored; 0 measured
```

**Breakdown:**
- 70 snapshot tests (types module)
- 31 proptest tests (from 06-02)
- 24 unit tests (common module)

## Verification

All success criteria met:
- [x] tests/types/ contains all snapshot test files
- [x] All P0 types have snapshot tests (Fact, Proposal via Fact, StopReason)
- [x] All P1 types have snapshot tests (IDs, PromotionRecord, EvidenceRef, TraceLink, Actor, Observation, CorrectionEvent)
- [x] TraceLink Local vs Remote distinct shapes documented and tested
- [x] Both types::TraceLink and kernel_boundary::TraceLink covered
- [x] cargo test --test snapshot_tests passes (125 tests)

## Next Phase Readiness

Plan 06-03 complete. Phase 06 testing infrastructure is now fully established:
- Test infrastructure (06-01): TestHarness, IdNormalizer, FrozenClock
- Property tests (06-02): Ordering proptests
- Snapshot tests (06-03): JSON format locked for P0/P1 types

Ready for Phase 07 with comprehensive test coverage foundation.
