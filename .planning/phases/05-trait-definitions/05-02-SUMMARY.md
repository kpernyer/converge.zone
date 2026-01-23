---
phase: 05-trait-definitions
plan: 02
subsystem: capability-boundary
tags: [traits, recall, store, GAT, async]
dependency-graph:
  requires: [05-01]
  provides: [RecallReader, RecallWriter, ExperienceAppender, ExperienceReplayer]
  affects: [06-deprecation, converge-recall, converge-store]
tech-stack:
  added: []
  patterns: [GAT async, split traits, dyn-safe wrappers]
key-files:
  created:
    - converge-platform/converge-core/src/traits/recall.rs
    - converge-platform/converge-core/src/traits/store.rs
  modified:
    - converge-platform/converge-core/src/traits/mod.rs
decisions:
  - "RecallReader and RecallWriter split by authority boundary (read vs write)"
  - "ExperienceAppender and ExperienceReplayer split by operation type"
  - "All traits use GAT async pattern with Send + 'a future bounds"
  - "Dyn-safe wrappers use explicit lifetime parameters for proper blanket impl"
  - "RecallError and StoreError implement CapabilityError for generic retry logic"
metrics:
  duration: 6 min
  completed: 2026-01-24
---

# Phase 05 Plan 02: Recall and Store Capability Traits Summary

Split trait pattern for Recall (semantic memory) and ExperienceStore (event sourcing) with GAT async.

## Objective Achieved

Created traits/recall.rs with RecallReader + RecallWriter + Recall traits, and traits/store.rs with ExperienceAppender + ExperienceReplayer traits. All traits use GAT async pattern with Send + Sync bounds and implement CapabilityError.

## Key Decisions

1. **RecallReader vs RecallWriter split**: Read-only contexts (validators, auditors, replay) use RecallReader. Mutation contexts (ingestion) use RecallWriter. Recall umbrella combines both.

2. **ExperienceAppender vs ExperienceReplayer split**: Append is a hard governance boundary. Audit/replay contexts use ExperienceReplayer only.

3. **GAT async pattern**: All traits use generic associated types for zero-cost async without proc macros or tokio dependency.

4. **Dyn-safe wrappers with explicit lifetimes**: DynRecallReader and DynExperienceAppender/DynExperienceReplayer use explicit lifetime parameters to properly handle reference parameters in blanket impls.

## Commits

| Commit | Description |
|--------|-------------|
| 3c6ed84 | feat(05-02): add Recall capability traits with read/write separation |
| 788a9b8 | feat(05-02): add ExperienceStore capability traits with append/replay separation |
| 9c28e4e | feat(05-02): update traits/mod.rs with Recall and Store re-exports |

## Files Changed

### Created
- `converge-platform/converge-core/src/traits/recall.rs` - RecallReader, RecallWriter, Recall traits, RecallError, RecallRecord
- `converge-platform/converge-core/src/traits/store.rs` - ExperienceAppender, ExperienceReplayer traits, StoreError, ReplayCursor, ReplayBatch

### Modified
- `converge-platform/converge-core/src/traits/mod.rs` - Added recall and store module declarations and re-exports

## Trait Signatures

### RecallReader (query-only read access)
```rust
pub trait RecallReader: Send + Sync {
    type QueryFut<'a>: Future<Output = Result<Vec<RecallCandidate>, RecallError>> + Send + 'a
    where
        Self: 'a;

    fn query<'a>(&'a self, query: &'a RecallQuery) -> Self::QueryFut<'a>;
}
```

### RecallWriter (mutation access)
```rust
pub trait RecallWriter: Send + Sync {
    type StoreFut<'a>: Future<Output = Result<(), RecallError>> + Send + 'a where Self: 'a;
    type DeleteFut<'a>: Future<Output = Result<(), RecallError>> + Send + 'a where Self: 'a;

    fn store<'a>(&'a self, record: RecallRecord) -> Self::StoreFut<'a>;
    fn delete<'a>(&'a self, id: &'a str) -> Self::DeleteFut<'a>;
}
```

### ExperienceAppender (append-only event storage)
```rust
pub trait ExperienceAppender: Send + Sync {
    type AppendFut<'a>: Future<Output = Result<(), StoreError>> + Send + 'a where Self: 'a;

    fn append<'a>(&'a self, events: &'a [ExperienceEventEnvelope]) -> Self::AppendFut<'a>;
}
```

### ExperienceReplayer (streaming replay access)
```rust
pub trait ExperienceReplayer: Send + Sync {
    type ReplayFut<'a>: Future<Output = Result<ReplayBatch, StoreError>> + Send + 'a where Self: 'a;
    type QueryFut<'a>: Future<Output = Result<Vec<ExperienceEventEnvelope>, StoreError>> + Send + 'a where Self: 'a;

    fn replay<'a>(&'a self, options: &'a ReplayOptions, cursor: &'a ReplayCursor) -> Self::ReplayFut<'a>;
    fn query<'a>(&'a self, query: &'a EventQuery) -> Self::QueryFut<'a>;
}
```

## Verification Results

1. `cargo check -p converge-core` - PASS (with 1 warning about unused code)
2. `cargo test -p converge-core` - PASS (24 tests, 23 ignored doctests)
3. `grep -r "pub trait RecallReader"` - FOUND in recall.rs
4. `grep -r "pub trait ExperienceAppender"` - FOUND in store.rs
5. `grep -r "impl CapabilityError for RecallError"` - FOUND in recall.rs
6. `grep -r "impl CapabilityError for StoreError"` - FOUND in store.rs

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Created error.rs dependency**

- **Found during:** Task 1
- **Issue:** Plan 05-01 runs in parallel and creates error.rs with CapabilityError. When I started, error.rs didn't exist yet.
- **Fix:** Plan 05-01 actually completed first, so error.rs was available when needed.
- **Files used:** error.rs from 05-01

**2. [Rule 1 - Bug] Fixed lifetime parameters in dyn-safe wrappers**

- **Found during:** Task 3 verification
- **Issue:** DynRecallReader, DynExperienceAppender, DynExperienceReplayer blanket impls had lifetime mismatches
- **Fix:** Added explicit `<'a>` lifetime parameters to trait methods and impl methods
- **Files modified:** recall.rs, store.rs
- **Commit:** 9c28e4e (included in final commit)

## Next Phase Readiness

Phase 05-02 complete. The following are ready for use:

1. **RecallReader/RecallWriter/Recall traits** - Ready for implementations in converge-recall-* crates
2. **ExperienceAppender/ExperienceReplayer traits** - Ready for implementations in converge-store-* crates
3. **RecallError/StoreError** - Implement CapabilityError for generic retry/circuit breaker logic
4. **Dyn-safe wrappers** - Available for runtime polymorphism scenarios

## Metrics

- **Duration:** 6 min
- **Tasks:** 3/3 complete
- **Tests:** All passing
- **New code:** ~1000 lines (recall.rs + store.rs)
