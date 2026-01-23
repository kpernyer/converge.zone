---
phase: 02-dependency-cleanup
plan: 01
subsystem: core
tags: [traits, capability-boundaries, executor, randomness, fingerprint, abstraction]

# Dependency graph
requires: [01-ci-foundation]
provides:
  - Executor trait for parallel/sequential execution abstraction
  - Randomness trait for random number generation abstraction
  - Fingerprint trait for cryptographic hashing abstraction
  - FingerprintError enum for hex parsing errors
affects: [02-02, 02-03, 02-04, 05-runtime-integration]

# Tech tracking
tech-stack:
  added: []
  patterns: [capability-boundary-traits, interface-over-implementation]

key-files:
  created:
    - converge-platform/converge-core/src/traits/mod.rs
  modified:
    - converge-platform/converge-core/src/lib.rs

key-decisions:
  - "Generic parameters over associated types for trait flexibility"
  - "All traits require Send + Sync bounds for thread safety"
  - "FingerprintError uses specific variants (InvalidHex, InvalidLength) not generic"

patterns-established:
  - "Capability boundary pattern: core defines interface, runtime provides implementation"
  - "Re-export traits from crate root for convenience (converge_core::Executor)"

# Metrics
duration: 2min
completed: 2026-01-23
---

# Phase 2 Plan 1: Capability Boundary Traits Summary

**Executor, Randomness, and Fingerprint stub traits defining abstraction layer for forbidden dependencies (rayon, rand, sha2/hex)**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-01-23T17:05:54Z
- **Completed:** 2026-01-23T17:07:28Z
- **Tasks:** 2
- **Files created:** 1
- **Files modified:** 1

## Accomplishments

- Created `traits/mod.rs` with three capability boundary traits
- Executor trait abstracts parallel/sequential execution (replaces rayon)
- Randomness trait abstracts random number generation (replaces rand)
- Fingerprint trait abstracts cryptographic hashing (replaces sha2/hex)
- FingerprintError enum with InvalidHex and InvalidLength variants
- All traits have Send + Sync bounds for thread safety
- Module exported from lib.rs with convenient re-exports

## Task Commits

Each task was committed atomically:

1. **Task 1: Create traits module with stub traits** - `ecb4563` (feat)
   - Repository: converge-platform/converge-core
   - Files: src/traits/mod.rs (204 lines)
2. **Task 2: Export traits module from lib.rs** - `56d8e1a` (feat)
   - Repository: converge-platform/converge-core
   - Files: src/lib.rs (+10 lines)

## Files Created

- `converge-platform/converge-core/src/traits/mod.rs` - Capability boundary traits module with:
  - Module documentation explaining capability boundary pattern
  - `Executor` trait with `execute_parallel` method
  - `Randomness` trait with `random_u32` and `random_bytes` methods
  - `Fingerprint` trait with `compute`, `to_hex`, and `from_hex` methods
  - `FingerprintError` enum with Display and Error impls
  - Example implementations in doc comments for each trait

## Files Modified

- `converge-platform/converge-core/src/lib.rs` - Added:
  - `pub mod traits;` declaration in module section
  - Re-export: `pub use traits::{Executor, Fingerprint, FingerprintError, Randomness};`

## Decisions Made

1. **Generic parameters over associated types** - Per CONTEXT.md, traits use generic type parameters for maximum flexibility
2. **Send + Sync bounds on all traits** - Required for safe use in concurrent contexts
3. **FingerprintError variants** - Two specific variants (InvalidHex, InvalidLength) rather than generic error

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external configuration needed.

## Next Phase Readiness

- **Ready for Phase 2 Plan 2:** Traits established, now can be used to replace direct dependency usage
- **Expected usage:** Code currently using rayon/rand/sha2/hex will be migrated to use these traits
- **No blockers:** Trait definitions complete and exported

## Verification Results

```
$ cd converge-platform/converge-core && cargo check
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.07s

$ grep -n "pub mod traits" src/lib.rs
71:pub mod traits;

$ grep -n "pub trait Executor" src/traits/mod.rs
86:pub trait Executor: Send + Sync {

$ grep -n "pub trait Randomness" src/traits/mod.rs
138:pub trait Randomness: Send + Sync {

$ grep -n "pub trait Fingerprint" src/traits/mod.rs
190:pub trait Fingerprint: Send + Sync {
```

All verifications pass.

---
*Phase: 02-dependency-cleanup*
*Completed: 2026-01-23*
