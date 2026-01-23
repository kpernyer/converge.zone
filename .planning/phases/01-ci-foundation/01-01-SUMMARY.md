---
phase: 01-ci-foundation
plan: 01
subsystem: infra
tags: [cargo-deny, ci, github-actions, dependency-enforcement, purity]

# Dependency graph
requires: []
provides:
  - cargo-deny configuration blocking 16 forbidden dependencies
  - PURITY.md contract documenting allowed/forbidden boundaries
  - CI workflow with cargo-deny-action enforcement
affects: [02-dependency-cleanup, all-future-phases]

# Tech tracking
tech-stack:
  added: [cargo-deny, cargo-deny-action@v2]
  patterns: [dependency-banning, purity-enforcement]

key-files:
  created:
    - converge-platform/converge-core/deny.toml
    - converge-platform/converge-core/PURITY.md
    - .github/workflows/ci.yml
  modified: []

key-decisions:
  - "deny.toml at crate level (not workspace) for explicit scope"
  - "16 forbidden crates including tonic/prost (gRPC) added beyond initial 15"
  - "No continue-on-error in CI - enforcement is blocking"

patterns-established:
  - "Purity enforcement: deny.toml + PURITY.md for machine + human contracts"
  - "cargo-deny check runs bans, licenses, sources together"

# Metrics
duration: 6min
completed: 2026-01-23
---

# Phase 1 Plan 1: CI Foundation Summary

**cargo-deny enforcement blocking 16 forbidden dependencies with PURITY.md contract and GitHub Actions CI integration**

## Performance

- **Duration:** ~6 min
- **Started:** 2026-01-23T15:07:43Z
- **Completed:** 2026-01-23T15:13:12Z
- **Tasks:** 3
- **Files created:** 3

## Accomplishments

- deny.toml configured to block all 16 forbidden dependency categories (async runtimes, HTTP, gRPC, parallelism, randomness, hashing, ML/data)
- PURITY.md contract documenting allowed (5 crates) and forbidden (16 crates) dependencies with justifications
- CI workflow with cargo-deny-action@v2 that blocks PRs adding forbidden dependencies

## Task Commits

Each task was committed atomically:

1. **Task 1: Create deny.toml with forbidden dependency list** - `56165d5` (feat)
   - Repository: converge-platform/converge-core
2. **Task 2: Create PURITY.md contract document** - `408b888` (docs)
   - Repository: converge-platform/converge-core
3. **Task 3: Create CI workflow with cargo-deny step** - `4d9576d` (feat)
   - Repository: converge.zone (workspace)

## Files Created

- `converge-platform/converge-core/deny.toml` - cargo-deny configuration with 16 banned crates, license allow-list, and source restrictions
- `converge-platform/converge-core/PURITY.md` - Human-readable purity contract with allowed/forbidden tables, nine tenets reference, enforcement docs
- `.github/workflows/ci.yml` - GitHub Actions workflow running cargo-deny on push/PR to main

## Decisions Made

1. **deny.toml at crate level** - Placed in converge-core rather than workspace root for explicit scope and clearer ownership
2. **16 forbidden crates** - Added tonic and prost (gRPC) beyond initial 15, as they violate purity like other runtime dependencies
3. **Blocking enforcement** - No continue-on-error in CI; enforcement must block, not warn
4. **cargo-deny v0.19.0 config format** - Updated from research template to match current syntax (no unmaintained/yanked fields in advisories)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Updated deny.toml config for cargo-deny v0.19.0**
- **Found during:** Task 1 (deny.toml verification)
- **Issue:** Research template used deprecated `unmaintained = "warn"` and `yanked = "warn"` fields not valid in v0.19.0
- **Fix:** Removed deprecated fields, used `ignore = []` array format per official template
- **Files modified:** converge-platform/converge-core/deny.toml
- **Verification:** `cargo deny check bans` runs successfully and reports violations
- **Committed in:** 56165d5

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Config format update required for cargo-deny to run. No scope creep.

## Issues Encountered

- **Nested git repositories:** converge-core has its own .git directory separate from workspace. Tasks 1-2 committed to converge-core repo; Task 3 committed to workspace repo. Both repositories need separate push operations.

## User Setup Required

None - no external service configuration required. cargo-deny is fetched by GitHub Actions automatically.

## Next Phase Readiness

- **Ready for Phase 2:** deny.toml is blocking the 4 current violations (rayon, rand, sha2, hex)
- **Expected CI behavior:** CI will FAIL until Phase 2 removes forbidden dependencies - this is intentional
- **No blockers:** All infrastructure for dependency enforcement is in place

## Verification Results

```
$ cargo deny check bans
error[banned]: crate 'hex = 0.4.3' is explicitly banned
error[banned]: crate 'rand = 0.8.5' is explicitly banned
error[banned]: crate 'rand_core = 0.6.4' is explicitly banned
error[banned]: crate 'rayon = 1.11.0' is explicitly banned
error[banned]: crate 'sha2 = 0.10.9' is explicitly banned
bans FAILED
```

This failure proves enforcement is working correctly.

---
*Phase: 01-ci-foundation*
*Completed: 2026-01-23*
