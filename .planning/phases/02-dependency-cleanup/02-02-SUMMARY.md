---
phase: 02-dependency-cleanup
plan: 02
subsystem: core
tags: [rayon, rand, sha2, hex, deprecation, migration, cargo-deny, dev-dependencies]

# Dependency graph
requires:
  - phase: 02-01
    provides: Capability boundary traits (Executor, Fingerprint, Randomness)
provides:
  - Clean dependency list (no rayon, rand, sha2, hex)
  - Stub implementations with deprecation notices
  - Test infrastructure (insta, static_assertions, serde_test, criterion)
  - MIGRATION.md documenting v2.0.0 changes
affects: [03-context-traits, 05-capability-extraction, converge-runtime]

# Tech tracking
tech-stack:
  added: [insta, static_assertions, serde_test, criterion]
  patterns: [deprecation-with-migration-path, stub-implementations, fnv1a-hashing]

key-files:
  created:
    - converge-platform/converge-core/MIGRATION.md
    - converge-platform/converge-core/benches/engine_bench.rs
  modified:
    - converge-platform/converge-core/src/engine.rs
    - converge-platform/converge-core/src/integrity.rs
    - converge-platform/converge-core/src/root_intent.rs
    - converge-platform/converge-core/Cargo.toml
    - converge-platform/converge-core/deny.toml

key-decisions:
  - "FNV-1a stub for hashing: non-cryptographic but deterministic, sufficient for testing"
  - "Timestamp + pid + counter for ID generation: unique without randomness dependency"
  - "exclude-dev in deny.toml: test tools (proptest, criterion) need rand/rayon internally"
  - "deprecation notices reference converge-runtime traits for migration path"

patterns-established:
  - "Deprecation pattern: #[deprecated(since, note)] with migration path to runtime traits"
  - "Internal #[allow(deprecated)]: suppress warnings for internal usage of deprecated APIs"
  - "Test infrastructure: insta for snapshots, proptest for property tests, criterion for benchmarks"

# Metrics
duration: 6min
completed: 2026-01-23
---

# Phase 02 Plan 02: Dependency Cleanup Summary

**Removed all forbidden dependencies (rayon, rand, sha2, hex) with stub implementations and documented v2.0.0 migration path**

## Performance

- **Duration:** 6 min
- **Started:** 2026-01-23T17:10:37Z
- **Completed:** 2026-01-23T17:17:05Z
- **Tasks:** 4 + 1 bug fix
- **Files modified:** 7

## Accomplishments
- Removed rayon, rand, sha2, hex from production dependencies
- Replaced with stub implementations (FNV-1a hash, timestamp+pid+counter)
- Added test infrastructure: insta, static_assertions, serde_test, criterion
- Created comprehensive MIGRATION.md (136 lines) documenting all breaking changes
- cargo deny check bans now passes

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace rayon in engine.rs** - `bd41626` (refactor)
2. **Task 2: Replace sha2/hex in integrity.rs** - `d6c2a8a` (refactor)
3. **Task 3: Remove rand, update Cargo.toml** - `16d3ebe` (refactor)
4. **Task 4: Create MIGRATION.md** - `926c9f5` (docs)
5. **Bug fix: XOR hash combination** - `80960f9` (fix)

## Files Created/Modified
- `converge-platform/converge-core/src/engine.rs` - Sequential execution with deprecation
- `converge-platform/converge-core/src/integrity.rs` - FNV-1a stub with ContentHashError
- `converge-platform/converge-core/src/root_intent.rs` - Timestamp+pid+counter ID generation
- `converge-platform/converge-core/Cargo.toml` - Removed forbidden deps, added test infra
- `converge-platform/converge-core/deny.toml` - Added exclude-dev for test dependencies
- `converge-platform/converge-core/MIGRATION.md` - Comprehensive migration guide
- `converge-platform/converge-core/benches/engine_bench.rs` - Criterion benchmark placeholder

## Decisions Made
- **FNV-1a for stub hashing:** Non-cryptographic but deterministic, appropriate for testing while clearly marking the need for real hashing via Fingerprint trait
- **exclude-dev in deny.toml:** Test tools like proptest and criterion internally use rand/rayon, but these don't ship with the crate
- **Timestamp + pid + counter:** Provides uniqueness without randomness dependency, sufficient for development/testing

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed XOR-based hash combination causing Merkle root collisions**
- **Found during:** Task 2 verification (cargo test)
- **Issue:** XOR combination (A XOR A = 0) caused identical Merkle roots for different fact sets
- **Fix:** Changed ContentHash::combine to use FNV-1a on concatenated hashes
- **Files modified:** src/integrity.rs
- **Verification:** tracked_context_computes_merkle_root test passes
- **Committed in:** 80960f9 (separate fix commit)

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Bug fix necessary for test suite to pass. No scope creep.

## Issues Encountered
- **Criterion brings rayon:** criterion 0.5 has rayon as a default feature; fixed by using `default-features = false` and selecting only needed features
- **Proptest uses rand:** proptest inherently needs randomness; resolved by adding `exclude-dev = true` to deny.toml graph section

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- cargo deny check bans passes (CI green for dependency checks)
- cargo build and cargo test succeed
- All deprecated methods have migration notes pointing to converge-runtime traits
- Ready for Phase 2 remaining plans (if any) or Phase 3

---
*Phase: 02-dependency-cleanup*
*Completed: 2026-01-23*
