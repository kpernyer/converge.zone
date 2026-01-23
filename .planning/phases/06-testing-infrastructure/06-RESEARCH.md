# Phase 6: Testing Infrastructure - Research

**Researched:** 2026-01-24
**Domain:** Rust property-based testing, snapshot testing, compile-fail testing, determinism verification
**Confidence:** HIGH (codebase-focused research)

## Summary

This research analyzed the converge-core codebase to identify exactly what needs testing in Phase 6. The codebase has a well-structured type system with:

1. **3-tier type hierarchy**: `Observation` -> `Proposal<State>` -> `Fact`
2. **Gate pattern enforcement**: `PromotionGate` with `ValidationReport` (pub(crate) constructors)
3. **Budget types**: `CycleBudget`, `FactBudget`, `TokenBudget`, `ExecutionBudget` with `StopReason`
4. **TraceLink semantics**: `Local` (replay-eligible) vs `Remote` (audit-only) distinction
5. **Capability boundary traits**: `Executor`, `Randomness`, `Fingerprint`, plus LLM/Recall/Store traits

The user's implementation plan provides a complete test architecture. This research maps each type to its required testing approach.

**Primary recommendation:** Follow the user-provided file/module plan exactly, implementing proptest strategies for each type and snapshot tests for all serializable types in the P0/P1 tiers.

## Type Inventory for Testing

### P0 API Types (Critical - Snapshot + Proptest)

| Type | Module | Serializable | Needs Proptest | Notes |
|------|--------|--------------|----------------|-------|
| `Fact` | `types/fact.rs` | Yes | Yes | Private constructor `Fact::new()` is `pub(crate)` |
| `Proposal<Draft>` | `types/proposal.rs` | Yes | Yes | Public constructor |
| `Proposal<Validated>` | `types/proposal.rs` | Yes | Yes | `pub(crate)` `from_validated()` |
| `ValidationReport` | `gates/validation.rs` | No (has private token) | Yes | Has `ValidationToken` - custom serialization needed |
| `StopReason` | `gates/stop.rs` | Yes | Yes | `#[non_exhaustive]` enum |
| `FactContent` | `types/fact.rs` | Yes | Yes | Public fields |
| `ProposedContent` | `types/proposal.rs` | Yes | Yes | Public fields |

### P1 Persistence Types (Snapshot + Proptest)

| Type | Module | Serializable | Needs Proptest |
|------|--------|--------------|----------------|
| `FactId`, `ObservationId`, `ProposalId`, `GateId`, `ApprovalId`, `ArtifactId` | `types/id.rs` | Yes (`#[serde(transparent)]`) | Yes |
| `ContentHash` | `types/id.rs` | Yes (hex) | Yes |
| `Timestamp` | `types/id.rs` | Yes | Yes |
| `PromotionRecord` | `types/provenance.rs` | Yes | Yes |
| `EvidenceRef` | `types/provenance.rs` | Yes (tagged enum) | Yes |
| `TraceLink` (types) | `types/provenance.rs` | Yes (tagged enum) | Yes |
| `LocalTrace` | `types/provenance.rs` | Yes | Yes |
| `RemoteRef` | `types/provenance.rs` | Yes | Yes |
| `Actor`, `ActorKind` | `types/provenance.rs` | Yes | Yes |
| `ValidationSummary` | `types/provenance.rs` | Yes | Yes |
| `CycleBudget`, `FactBudget`, `TokenBudget`, `ExecutionBudget` | `gates/budget.rs` | Yes | Yes |
| `CorrectionEvent`, `CorrectionReason`, `CorrectionScope` | `types/correction.rs` | Yes | Yes |
| `Observation`, `ObservationKind`, `CaptureContext`, `ProviderIdentity` | `types/observation.rs` | Yes | Yes |
| `ObservationProvenance` | `types/proposal.rs` | Yes | Yes |

### Kernel Boundary Types (Snapshot + Proptest)

| Type | Module | Serializable | Notes |
|------|--------|--------------|-------|
| `TraceLink` (kernel) | `kernel_boundary.rs` | Yes | Different from types::TraceLink |
| `LocalTraceLink` | `kernel_boundary.rs` | Yes | Full replay info |
| `RemoteTraceLink` | `kernel_boundary.rs` | Yes | Audit info + replayability |
| `Replayability` | `kernel_boundary.rs` | Yes | Enum |
| `KernelProposal` | `kernel_boundary.rs` | Yes | |
| `KernelIntent` | `kernel_boundary.rs` | Yes | |
| `KernelContext`, `ContextFact` | `kernel_boundary.rs` | Yes | |
| `KernelPolicy` | `kernel_boundary.rs` | Yes | |
| `ContractResult` | `kernel_boundary.rs` | Yes | |
| `AdapterTrace`, `SamplerParams`, `RecallTrace`, `ExecutionEnv` | `kernel_boundary.rs` | Yes | |

### Error Types (Snapshot optional, Proptest for serializable)

| Type | Module | Serializable | Notes |
|------|--------|--------------|-------|
| `TypeError` | `types/error.rs` | No (thiserror) | Display tests only |
| `PromotionError` | `types/error.rs` | No | Display tests only |
| `TypesValidationError` | `types/error.rs` | Yes | Clone + Eq + Serialize |
| `ObservationError` | `types/error.rs` | No | Display tests only |
| `CorrectionError` | `types/error.rs` | No | Display tests only |
| `ValidationError` | `gates/validation.rs` | No | Display tests only |
| `ErrorCategory` | `gates/stop.rs` | Yes | |

## Invariants to Test

### Gate Invariants (Proptest Sequence Tests)

| Invariant | Test Approach | Key Types |
|-----------|---------------|-----------|
| **No promotion without validation** | Proptest: Generate `Proposal<Draft>`, try all paths to `Fact`, assert only `PromotionGate` succeeds | `Proposal`, `PromotionGate`, `ValidationReport`, `Fact` |
| **Facts are append-only** | Compile-fail: Ensure no `&mut` methods on `Fact`; Proptest: Corrections create new facts | `Fact`, `CorrectionEvent` |
| **Budget exhaustion terminates** | Proptest: Tick budgets to exhaustion, assert `StopReason` returned | `CycleBudget`, `FactBudget`, `TokenBudget`, `StopReason` |

### Type-State Invariants (Compile-Fail + Proptest)

| Invariant | Test Approach | Files Needed |
|-----------|---------------|--------------|
| `Proposal<Validated>` cannot be constructed externally | trybuild: `ui/validated_new_private.rs` | Compile-fail test |
| `Fact::new()` cannot be called externally | trybuild: `ui/fact_new_private.rs` | Compile-fail test |
| `ValidationReport::new()` cannot be called externally | trybuild: `ui/validation_report_private.rs` | Compile-fail test |
| State transitions enforced | Proptest: Generate Draft, validate, promote sequence | `Proposal<Draft>`, `Proposal<Validated>`, `Fact` |

### TraceLink Separation (Snapshot + Proptest)

| Test | Approach |
|------|----------|
| Local vs Remote serialization distinct | Snapshot: different JSON shapes for each variant |
| Replay eligibility correct | Proptest: `TraceLink::Local(_)` always `is_replay_eligible()`, `Remote` never |
| Round-trip preserves identity | Proptest: serialize -> deserialize -> compare |

### Send/Sync Bounds (Static Assertions)

Types requiring `Send + Sync` verification:

```rust
// Capability boundary traits - MUST be Send + Sync
Executor: Send + Sync
Randomness: Send + Sync
Fingerprint: Send + Sync
ChatBackend: Send + Sync (+ GAT constraints)
EmbedBackend: Send + Sync (+ GAT constraints)
RecallReader: Send + Sync
RecallWriter: Send + Sync
ExperienceAppender: Send + Sync
ExperienceReplayer: Send + Sync
Validator: Send + Sync
Promoter: Send + Sync

// Core types that cross thread boundaries
Fact: Send + Sync
Proposal<Draft>: Send + Sync
Proposal<Validated>: Send + Sync
Context: Send + Sync
ExecutionBudget: Send + Sync
StopReason: Send + Sync
```

### Replayability Honesty (Determinism Tests)

| Scenario | Test |
|----------|------|
| Local trace -> deterministic | `TraceLink::Local(_).replayability() == Replayability::Deterministic` |
| Remote trace -> explicit level | `RemoteTraceLink.replayability` field matches `TraceLink::Remote(_).replayability()` |
| Same inputs -> same outputs | Golden file comparison with frozen clock + deterministic IDs |

## Proptest Strategy Requirements

### ID Type Strategies

```rust
// All ID types are String-based newtypes
fn arb_fact_id() -> impl Strategy<Value = FactId> {
    "[a-z][a-z0-9_-]{0,31}".prop_map(FactId::new)
}

fn arb_observation_id() -> impl Strategy<Value = ObservationId> {
    "[a-z][a-z0-9_-]{0,31}".prop_map(ObservationId::new)
}

fn arb_proposal_id() -> impl Strategy<Value = ProposalId> {
    "[a-z][a-z0-9_-]{0,31}".prop_map(ProposalId::new)
}

fn arb_gate_id() -> impl Strategy<Value = GateId> {
    "[a-z][a-z0-9_-]{0,31}".prop_map(GateId::new)
}

fn arb_content_hash() -> impl Strategy<Value = ContentHash> {
    prop::collection::vec(any::<u8>(), 32..=32)
        .prop_map(|v| ContentHash::new(v.try_into().unwrap()))
}

fn arb_timestamp() -> impl Strategy<Value = Timestamp> {
    // ISO-8601 format
    (1970u32..2100, 1u32..13, 1u32..29, 0u32..24, 0u32..60, 0u32..60)
        .prop_map(|(y, m, d, h, min, s)| {
            Timestamp::new(format!("{y:04}-{m:02}-{d:02}T{h:02}:{min:02}:{s:02}Z"))
        })
}
```

### Content Strategies

```rust
fn arb_proposed_content_kind() -> impl Strategy<Value = ProposedContentKind> {
    prop_oneof![
        Just(ProposedContentKind::Claim),
        Just(ProposedContentKind::Plan),
        Just(ProposedContentKind::Classification),
        Just(ProposedContentKind::Evaluation),
        Just(ProposedContentKind::Draft),
        Just(ProposedContentKind::Reasoning),
    ]
}

fn arb_proposed_content() -> impl Strategy<Value = ProposedContent> {
    (
        arb_proposed_content_kind(),
        "[a-zA-Z0-9 .,!?]{1,200}", // Non-empty content
        prop::option::of(any::<f32>().prop_filter_map("valid confidence", |f| {
            if (0.0..=1.0).contains(&f) { Some(f) } else { None }
        })),
    ).prop_map(|(kind, content, confidence)| {
        let mut pc = ProposedContent::new(kind, content);
        if let Some(c) = confidence {
            pc = pc.with_confidence(c);
        }
        pc
    })
}
```

### Evidence and Trace Strategies

```rust
fn arb_evidence_ref() -> impl Strategy<Value = EvidenceRef> {
    prop_oneof![
        arb_observation_id().prop_map(EvidenceRef::observation),
        arb_approval_id().prop_map(EvidenceRef::human_approval),
        arb_artifact_id().prop_map(EvidenceRef::derived),
    ]
}

fn arb_local_trace() -> impl Strategy<Value = LocalTrace> {
    (
        "[a-f0-9]{32}", // trace_id
        "[a-f0-9]{16}", // span_id
        prop::option::of("[a-f0-9]{16}"), // parent_span_id
        any::<bool>(), // sampled
    ).prop_map(|(trace_id, span_id, parent, sampled)| {
        let mut t = LocalTrace::new(trace_id, span_id);
        if let Some(p) = parent {
            t = t.with_parent(p);
        }
        t.with_sampled(sampled)
    })
}

fn arb_remote_ref() -> impl Strategy<Value = RemoteRef> {
    (
        prop_oneof!["datadog", "jaeger", "honeycomb", "tempo"],
        "[a-zA-Z0-9/._-]{10,100}", // reference URL/ID
    ).prop_map(|(system, reference)| RemoteRef::new(system, reference))
}

fn arb_trace_link() -> impl Strategy<Value = TraceLink> {
    prop_oneof![
        arb_local_trace().prop_map(TraceLink::local),
        arb_remote_ref().prop_map(TraceLink::remote),
    ]
}
```

### Actor and Validation Strategies

```rust
fn arb_actor_kind() -> impl Strategy<Value = ActorKind> {
    prop_oneof![
        Just(ActorKind::Human),
        Just(ActorKind::Agent),
        Just(ActorKind::System),
    ]
}

fn arb_actor() -> impl Strategy<Value = Actor> {
    (arb_actor_kind(), "[a-z][a-z0-9@._-]{0,63}")
        .prop_map(|(kind, id)| Actor::new(id, kind))
}

fn arb_validation_summary() -> impl Strategy<Value = ValidationSummary> {
    (
        prop::collection::vec("[a-z_]{1,30}", 0..5), // checks_passed
        prop::collection::vec("[a-z_]{1,30}", 0..3), // checks_skipped
        prop::collection::vec("[a-zA-Z0-9 ]{1,100}", 0..3), // warnings
    ).prop_map(|(passed, skipped, warnings)| {
        let mut s = ValidationSummary::new();
        for p in passed { s = s.with_passed(p); }
        for sk in skipped { s = s.with_skipped(sk); }
        for w in warnings { s = s.with_warning(w); }
        s
    })
}
```

### Budget Strategies

```rust
fn arb_cycle_budget() -> impl Strategy<Value = CycleBudget> {
    (1u32..1000).prop_map(CycleBudget::new)
}

fn arb_fact_budget() -> impl Strategy<Value = FactBudget> {
    (1u32..100_000).prop_map(FactBudget::new)
}

fn arb_token_budget() -> impl Strategy<Value = TokenBudget> {
    (1u64..10_000_000).prop_map(TokenBudget::new)
}

fn arb_execution_budget() -> impl Strategy<Value = ExecutionBudget> {
    (arb_cycle_budget(), arb_fact_budget(), prop::option::of(arb_token_budget()))
        .prop_map(|(c, f, t)| {
            let mut b = ExecutionBudget::new(c.initial(), f.initial());
            if let Some(tok) = t {
                b = b.with_tokens(tok.initial());
            }
            b
        })
}
```

### Stop Reason Strategies

```rust
fn arb_error_category() -> impl Strategy<Value = ErrorCategory> {
    prop_oneof![
        Just(ErrorCategory::Internal),
        Just(ErrorCategory::Configuration),
        Just(ErrorCategory::External),
        Just(ErrorCategory::Resource),
        Just(ErrorCategory::Unknown),
    ]
}

fn arb_stop_reason() -> impl Strategy<Value = StopReason> {
    prop_oneof![
        Just(StopReason::Converged),
        prop::collection::vec("[a-z_]{1,30}", 1..5)
            .prop_map(StopReason::criteria_met),
        Just(StopReason::UserCancelled),
        (1u32..1000, 1u32..1000).prop_map(|(exec, limit)|
            StopReason::cycle_budget_exhausted(exec, limit)),
        (1u32..100000, 1u32..100000).prop_map(|(count, limit)|
            StopReason::fact_budget_exhausted(count, limit)),
        (1u64..10000000, 1u64..10000000).prop_map(|(consumed, limit)|
            StopReason::token_budget_exhausted(consumed, limit)),
        // ... more variants
    ]
}
```

## Compile-Fail Test Cases

### Private Constructor Tests (trybuild)

**`ui/fact_new_private.rs`**:
```rust
// This should fail to compile
use converge_core::types::Fact;

fn main() {
    // ERROR: `new` is private
    let _fact = Fact::new(
        converge_core::types::FactId::new("id"),
        converge_core::types::FactContent::new(
            converge_core::types::FactContentKind::Claim,
            "content"
        ),
        todo!(), // PromotionRecord
        converge_core::types::Timestamp::now(),
    );
}
```

**`ui/validated_new_private.rs`**:
```rust
// This should fail to compile
use converge_core::types::{Proposal, Validated, ProposalId, ProposedContent, ProposedContentKind, ObservationProvenance};

fn main() {
    // ERROR: `from_validated` is private
    let _validated = Proposal::<Validated>::from_validated(
        ProposalId::new("id"),
        ProposedContent::new(ProposedContentKind::Claim, "content"),
        todo!(), // ObservationProvenance
    );
}
```

**`ui/validation_report_private.rs`**:
```rust
// This should fail to compile
use converge_core::gates::{ValidationReport, CheckResult};
use converge_core::types::{ProposalId, ContentHash};

fn main() {
    // ERROR: `new` is private
    let _report = ValidationReport::new(
        ProposalId::new("id"),
        vec![CheckResult::passed("test")],
        ContentHash::zero(),
    );
}
```

## Test Harness Requirements

### Frozen Clock Helper

```rust
pub struct FrozenClock {
    current: std::sync::atomic::AtomicU64,
}

impl FrozenClock {
    pub fn new(initial_unix_secs: u64) -> Self { /* ... */ }
    pub fn now(&self) -> Timestamp { /* ... */ }
    pub fn tick(&self, seconds: u64) { /* ... */ }
}
```

### Deterministic ID Generator

```rust
pub struct DeterministicIdGenerator {
    counter: std::sync::atomic::AtomicU64,
    prefix: String,
}

impl DeterministicIdGenerator {
    pub fn new(prefix: &str) -> Self { /* ... */ }
    pub fn next_fact_id(&self) -> FactId { /* ... */ }
    pub fn next_observation_id(&self) -> ObservationId { /* ... */ }
    pub fn next_proposal_id(&self) -> ProposalId { /* ... */ }
}
```

### Placeholder Mapping for Snapshots

```rust
pub struct IdNormalizer {
    fact_ids: HashMap<String, String>,
    timestamps: HashMap<String, String>,
    counter: u64,
}

impl IdNormalizer {
    pub fn normalize_json(&mut self, value: &mut serde_json::Value) { /* ... */ }
}
```

### In-Memory Capability Fakes

For the capability traits defined in `traits/mod.rs`:

```rust
// Mock Executor (sequential for determinism)
pub struct SequentialExecutor;
impl Executor for SequentialExecutor { /* ... */ }

// Mock Randomness (seeded for determinism)
pub struct SeededRandomness { seed: u64, ... }
impl Randomness for SeededRandomness { /* ... */ }

// Mock Fingerprint (real SHA-256 is fine)
pub struct TestFingerprint;
impl Fingerprint for TestFingerprint { /* ... */ }
```

## Golden Scenarios

### `promotion_happy_path.json`

```json
{
  "input": {
    "draft_proposal": {
      "id": "prop-001",
      "content": { "kind": "Claim", "content": "Test claim" },
      "provenance": { "observation_id": "obs-001", ... }
    },
    "gate_id": "test-gate",
    "policy": { "required_checks": ["content_not_empty"] }
  },
  "expected_output": {
    "fact": {
      "id": "fact:prop-001",
      "content": { "kind": "Claim", "content": "Test claim" },
      "promotion_record": {
        "gate_id": "test-gate",
        ...
      }
    }
  }
}
```

### `correction_supersedes.json`

```json
{
  "input": {
    "original_fact_id": "fact-001",
    "new_fact_id": "fact-002",
    "reason": "DataError",
    "actor": { "id": "admin", "kind": "Human" }
  },
  "expected_output": {
    "correction_event": {
      "new_fact_id": "fact-002",
      "supersedes_fact_id": "fact-001",
      "reason_code": "DataError"
    }
  }
}
```

### `tracelink_local_vs_remote.json`

```json
{
  "local_trace": {
    "type": "Local",
    "trace_id": "abc123",
    "span_id": "def456",
    "sampled": true
  },
  "remote_trace": {
    "type": "Remote",
    "system": "datadog",
    "reference": "https://app.datadoghq.com/..."
  },
  "assertions": {
    "local_is_replay_eligible": true,
    "remote_is_replay_eligible": false
  }
}
```

## Architecture Patterns

### Test Organization

```
converge-core/tests/
├── common/
│   ├── mod.rs            # Re-exports all helpers
│   ├── ids.rs            # Deterministic ID generators
│   ├── time.rs           # Frozen clock
│   ├── normalize.rs      # JSON normalization for snapshots
│   ├── harness.rs        # In-memory gate harness
│   ├── strategies.rs     # Proptest strategies
│   └── replay.rs         # Record/replay runner
├── gates/
│   ├── promotion_proptest.rs
│   ├── append_only_proptest.rs
│   ├── budget_exhaustion_proptest.rs
│   └── determinism_replay.rs
├── types/
│   ├── fact_snapshots.rs
│   ├── promotion_record_snapshots.rs
│   ├── tracelink_snapshots.rs
│   ├── observation_snapshots.rs
│   ├── correction_event_snapshots.rs
│   └── id_timestamp_ordering_proptest.rs
├── traits/
│   └── send_sync_static.rs
└── compile_fail/
    ├── compile_fail.rs   # trybuild runner
    └── ui/
        ├── fact_new_private.rs
        ├── validated_new_private.rs
        └── validation_report_private.rs
```

### Static Assertion Pattern

```rust
// In tests/traits/send_sync_static.rs
use static_assertions::{assert_impl_all, assert_obj_safe};
use converge_core::*;
use converge_core::traits::*;

// Core types
assert_impl_all!(types::Fact: Send, Sync);
assert_impl_all!(types::Proposal<types::Draft>: Send, Sync);
assert_impl_all!(types::Proposal<types::Validated>: Send, Sync);
assert_impl_all!(gates::ExecutionBudget: Send, Sync);
assert_impl_all!(gates::StopReason: Send, Sync);

// Capability traits - require Send + Sync
// Note: Can't assert traits directly, assert on concrete test implementations
```

### Proptest Sequence Pattern

```rust
// State machine for "no promotion without validation"
#[derive(Clone, Debug)]
enum Op {
    CreateDraft(ProposalId, ProposedContent),
    ValidateDraft(ProposalId),
    TryPromoteWithoutValidation(ProposalId),
    PromoteValidated(ProposalId),
}

fn arb_op_sequence() -> impl Strategy<Value = Vec<Op>> {
    prop::collection::vec(arb_op(), 1..50)
}

proptest! {
    #[test]
    fn no_promotion_without_validation(ops in arb_op_sequence()) {
        let mut harness = TestHarness::new();
        for op in ops {
            match op {
                Op::TryPromoteWithoutValidation(id) => {
                    // This MUST fail - no path from Draft to Fact without validation
                    assert!(harness.try_promote_unvalidated(&id).is_err());
                }
                // ... other ops
            }
        }
    }
}
```

## Common Pitfalls

### Pitfall 1: Timestamp Non-Determinism

**What goes wrong:** Tests fail intermittently due to `Timestamp::now()` producing different values.
**Why it happens:** Real system time is used instead of frozen clock.
**How to avoid:** Always use `FrozenClock` in tests; never call `Timestamp::now()` directly in test code.
**Warning signs:** Snapshot diffs showing only timestamp changes.

### Pitfall 2: ValidationReport Serialization

**What goes wrong:** Can't snapshot `ValidationReport` because it contains private `ValidationToken`.
**Why it happens:** Token is a ZST but doesn't impl Serialize.
**How to avoid:** Create a separate `ValidationReportSnapshot` type for testing that mirrors the public fields.
**Warning signs:** Compile errors about `ValidationToken: Serialize`.

### Pitfall 3: ID Collision in Property Tests

**What goes wrong:** Proptest generates duplicate IDs causing unexpected behavior.
**Why it happens:** Random string generation can produce duplicates in long sequences.
**How to avoid:** Use `prop_filter` to ensure uniqueness or use `HashSet` based deduplication.
**Warning signs:** Flaky tests that pass/fail depending on generated values.

### Pitfall 4: TraceLink Type Confusion

**What goes wrong:** Tests use wrong `TraceLink` type (kernel_boundary vs types::provenance).
**Why it happens:** Both modules define `TraceLink` with similar but different shapes.
**How to avoid:** Use explicit module prefixes: `types::TraceLink` vs `kernel_boundary::TraceLink`.
**Warning signs:** Compile errors about field mismatches.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Property-based testing | Custom random generators | proptest crate | Shrinking, reproducibility, stateful testing |
| Snapshot testing | Manual JSON comparison | insta crate | Diff visualization, interactive review |
| Compile-fail tests | Build script hacks | trybuild crate | Proper error message matching |
| Static assertions | Runtime panics | static_assertions crate | Compile-time guarantees |
| Time mocking | Global statics | Inject FrozenClock | Thread-safe, explicit |

## Open Questions

1. **ValidationReport serialization strategy**
   - What we know: Has private `ValidationToken` field that can't be serialized
   - What's unclear: Best approach for snapshot testing
   - Recommendation: Create `ValidationReportSnapshot` mirroring public fields, or implement custom Serialize that omits token

2. **Kernel boundary vs types TraceLink**
   - What we know: Two different TraceLink definitions exist
   - What's unclear: Whether they should be unified or remain separate
   - Recommendation: Test both with explicit module prefixes, document the distinction

## Sources

### Primary (HIGH confidence)
- Direct codebase analysis of converge-core source files
- `src/types/*.rs` - All type definitions
- `src/gates/*.rs` - Gate pattern implementation
- `src/traits/mod.rs` - Capability boundary traits
- `src/kernel_boundary.rs` - Kernel contract types
- `tests/property_tests.rs` - Existing proptest patterns

### Secondary (MEDIUM confidence)
- User-provided implementation plan in phase context
- 06-CONTEXT.md decisions document

## Metadata

**Confidence breakdown:**
- Type inventory: HIGH - Direct codebase analysis
- Proptest strategies: HIGH - Based on actual type definitions
- Compile-fail tests: HIGH - Based on `pub(crate)` visibility analysis
- Harness requirements: MEDIUM - Inferred from capability traits

**Research date:** 2026-01-24
**Valid until:** Until codebase types change (stable - 60+ days)
