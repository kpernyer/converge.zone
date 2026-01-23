# Phase 6: Testing Infrastructure - Context

**Gathered:** 2026-01-24
**Status:** Ready for planning

<domain>
## Phase Boundary

Property-based tests prove system invariants; snapshot tests lock serialization format. This phase implements the test infrastructure to verify axioms encoded in phases 3-5 actually hold. It does NOT implement new features or change existing behavior.

</domain>

<decisions>
## Implementation Decisions

### Invariant Selection
- **Scope:** Gate invariants + type safety invariants (Option 2)
- **Gate invariants:** no promotion without validation, facts append-only, budget exhaustion
- **Type-safety invariants:** type-state transitions enforced, ID uniqueness, timestamp ordering
- **Phase 6 items:** TraceLink separation, Send/Sync bounds, replayability/determinism
- **Testing approach for "no promotion without validation":**
  - Arbitrary single-call properties for boundary safety
  - Sequence/state-machine properties for systemic correctness
- **Compile-fail tests:** Use trybuild for private constructors, type-state enforcement
- **"Facts are append-only" testing:** Both API-level immutability + correction semantics

### Snapshot Coverage
- **Tier approach:**
  - P0: API types (Fact, Proposal, Context, Intent, ValidationReport, StopReason)
  - P1: Persistence types (IDs, budgets, evidence refs, trace links)
  - P2: Internal types if time permits
- **Format:** JSON only
- **Evolution policy:** Version-tagged snapshots with explicit version bumps for breaking changes; CI fails on unintentional drift
- **Schema versioning:**
  - P0 API types: no schema_version field; version in snapshot path only
  - P1 persistence types: include schema_version in serialized records
  - Wrapper pattern: `PersistedFact { schema_version, fact: Fact }` if needed

### Test Organization
- **Hybrid approach:** Unit tests inline in src/, property/snapshot tests in tests/
- **tests/ structure:** By module/subsystem (tests/gates/, tests/types/, tests/traits/)
- **Shared harness:** tests/common/ or tests/harness/ for generators, fixtures, mock implementations
- **Static assertions:**
  - Inline near trait definitions for critical contract-defining bounds
  - Comprehensive sweep in tests/traits/send_sync_static.rs

### Determinism Verification
- **Approach:** Both record/replay harness + golden file comparison
  - Harness for dynamic property tests
  - Golden files (scenario fixtures) for known scenarios
- **Harness scope:** Full capability injection (Executor, Randomness, Fingerprint all use test doubles)
- **TraceLink testing:** Snapshots for format stability + proptest for arbitrary payloads
- **Scenario system:** Named scenario fixtures (scenario_01.json etc.) with frozen inputs + expected outputs

### Claude's Discretion
- Exact proptest shrinking/config parameters
- Snapshot file naming conventions
- Internal module organization within tests/
- Specific mock implementations for test doubles

</decisions>

<specifics>
## Specific Ideas

- Use proptest state-machine testing style for sequence tests: generate `Vec<Op>`, apply to harness, assert invariants
- Keep sequences short (1-50 ops) but run many cases
- Static assertions should cover all capability boundary traits defined in Phase 5
- Scenario fixtures should freeze time and use deterministic IDs for replay assertions

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 06-testing-infrastructure*
*Context gathered: 2026-01-24*
