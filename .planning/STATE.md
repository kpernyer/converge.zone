# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-01-23)

**Core value:** converge-core encodes Converge's axioms as testable invariants and provides stable, portable interfaces for all capability crates to build upon.
**Current focus:** Phase 8 - Stabilization (IN PROGRESS)

## Current Position

Phase: 8 of 8 (Stabilization)
Plan: 1 of ? in current phase
Status: In progress
Last activity: 2026-01-24 - Completed 08-01-PLAN.md

Progress: [################] 100%+ (16/15+ plans complete)

## Performance Metrics

**Velocity:**
- Total plans completed: 16
- Average duration: 4.9 min
- Total execution time: 1.18 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01-ci-foundation | 1 | 6 min | 6 min |
| 02-dependency-cleanup | 2 | 8 min | 4 min |
| 03-type-consolidation | 2 | 15 min | 7.5 min |
| 04-gate-pattern | 2 | 14 min | 7 min |
| 05-trait-definitions | 3 | 16 min | 5.3 min |
| 06-testing-infrastructure | 5 | 28 min | 5.6 min |
| 07-documentation | 2 | 5 min | 2.5 min |
| 08-stabilization | 1 | 3 min | 3 min |

**Recent Trend:**
- Last 5 plans: 06-04 (4 min), 06-05 (4 min), 07-01 (4 min), 07-02 (1 min), 08-01 (3 min)
- Trend: Stable

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Pre-Phase 1]: Traits First approach - define traits in core, implementations stay temporarily, full extraction in v2
- [Pre-Phase 1]: Full CI suite with cargo-deny, proptest, insta, static_assertions
- [Pre-Phase 1]: Full Gate Pattern including ProposalLifecycle<I, P, V, F>
- [Phase 1-01]: deny.toml at crate level (not workspace) for explicit scope
- [Phase 1-01]: 16 forbidden crates including tonic/prost (gRPC)
- [Phase 1-01]: No continue-on-error in CI - enforcement is blocking
- [Phase 2-01]: Generic parameters over associated types for trait flexibility
- [Phase 2-01]: All capability boundary traits require Send + Sync bounds
- [Phase 2-02]: FNV-1a stub for hashing - non-cryptographic but deterministic
- [Phase 2-02]: Timestamp + pid + counter for ID generation without rand
- [Phase 2-02]: exclude-dev in deny.toml - test tools can use rand/rayon internally
- [Phase 3-01]: Type-state pattern for Proposal: Draft (public) vs Validated (crate-only)
- [Phase 3-01]: Fact::new() is pub(crate) - external code cannot create Facts
- [Phase 3-01]: PromotionRecord is required (not Option) on Fact
- [Phase 3-01]: EvidenceRef uses adjacently-tagged serde format
- [Phase 3-01]: ContentHash wraps [u8; 32] with hex crate
- [Phase 3-01]: Timestamp uses String ISO-8601 per RESEARCH.md
- [Phase 3-02]: typed-builder 0.20 for ergonomic type construction
- [Phase 3-02]: Types prefix on some types to avoid collision (TypesRootIntent, TypesContextKey)
- [Phase 3-02]: ConflictType enum includes Custom(String) variant for extensibility
- [Phase 3-02]: TypesValidationError implements Clone, PartialEq, Eq for test assertions
- [Phase 4-01]: ValidationToken ZST for forgery prevention (no runtime cost)
- [Phase 4-01]: ValidatedProposal bundles proof with proposal (type-safe)
- [Phase 4-01]: ContentHash implements Default returning zero()
- [Phase 4-02]: tick() returns Option<StopReason> for exhaustion detection
- [Phase 4-02]: StopReason #[non_exhaustive] for future extensibility
- [Phase 4-02]: AuthorityGrant pub(crate) constructors - no external forgery
- [Phase 5-01]: CapabilityError trait with category(), is_transient(), is_retryable(), retry_after()
- [Phase 5-01]: ErrorCategory enum with 9 variants (Timeout, RateLimit, Auth, etc.)
- [Phase 5-01]: ChatBackend and EmbedBackend use GAT async pattern
- [Phase 5-01]: LlmBackend umbrella combines ChatBackend + EmbedBackend
- [Phase 5-02]: RecallReader and RecallWriter split by authority boundary
- [Phase 5-02]: ExperienceAppender and ExperienceReplayer split by operation type
- [Phase 5-02]: Dyn-safe wrappers use explicit lifetime parameters
- [Phase 5-03]: Validator returns ValidationReport (proof object)
- [Phase 5-03]: Promoter takes Proposal<Validated> (type-state enforcement)
- [Phase 5-03]: PromotionContext bundles approver, evidence, trace
- [Phase 5-03]: Deprecation notes reference BOUNDARY.md
- [Phase 6-01]: FrozenClock uses Howard Hinnant date algorithm for leap years
- [Phase 6-01]: IdNormalizer tracks 10 field types for JSON normalization
- [Phase 6-01]: TestHarness wraps PromotionGate with state management
- [Phase 6-02]: Proptest state machine pattern with GateOp enum for operation sequences
- [Phase 6-02]: Extract matches! to local variable in prop_assert! for format string issues
- [Phase 6-02]: Clone String values in prop_assert_eq! to avoid move errors
- [Phase 6-04]: Top-level test file for static assertions (not subdirectory)
- [Phase 6-04]: 60+ types verified Send+Sync at compile time
- [Phase 6-04]: Trybuild for compile-fail tests on private constructors
- [Phase 6-05]: Golden scenarios as JSON files in tests/golden/
- [Phase 6-05]: TraceLink::Local is replay-eligible, TraceLink::Remote is not
- [Phase 6-05]: ReplayRunner verifies determinism by running scenarios twice
- [Phase 7-02]: Git-based baseline comparison for cargo-semver-checks (not crates.io)
- [Phase 7-02]: Path filtering in CI to only trigger on relevant file changes
- [Phase 7-02]: Separate CI jobs for parallel execution (check, deny, docs, semver)
- [Phase 7-01]: TypesFact/TypesTraceLink naming to avoid re-export ambiguity
- [Phase 7-01]: Tenet alignment tables in module documentation
- [Phase 7-01]: crate:: prefix for cross-module rustdoc links
- [Phase 8-01]: hex crate allowed for ContentHash serialization (not crypto)
- [Phase 8-01]: LicenseRef-Proprietary added to allowed licenses for converge-core

### Pending Todos

None.

### Blockers/Concerns

- **Nested git repositories:** converge-core has separate .git from workspace. Task commits split between repos. Requires separate push operations.
- **Pre-existing formatting issues:** cargo fmt --check shows differences across many files (technical debt)
- **Clippy warnings:** 518 clippy warnings exist (existing technical debt)

## Session Continuity

Last session: 2026-01-24 18:18
Stopped at: Completed 08-01-PLAN.md (doc warnings and cargo-deny fixes)
Resume file: None

---

## Next Steps

1. **Phase 08 IN PROGRESS** - Stabilization phase:
   - [COMPLETE] 08-01: Fix doc warnings and cargo-deny hex violation
   - Continue with remaining Phase 8 plans if any
