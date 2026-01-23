# Phase 3: Type Consolidation - Context

**Gathered:** 2026-01-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Organize core type vocabulary in types/ module with stable serialization. Define Context, Fact, ProposedFact, Intent, and supporting types. Implement builders for complex construction and ensure invalid states are unrepresentable.

Higher-order values from REFACTORY_FACTS.md and STORYTELLING.md inform the design:
- Six-phase converging flows (Intent → Framing → Exploration → Tension → Convergence → Commitment)
- "Providers return observations, never facts" — authority requires promotion gates
- Append-only Context; Facts are immutable; corrections are new Facts
- Every decision is logged with provenance

</domain>

<decisions>
## Implementation Decisions

### Type Hierarchy for Six-Phase Flows

- **Explicit phase types**: Define Frame, Hypothesis (exploration), Tension, Resolution as first-class types alongside Intent/Fact/Context
- **RootIntent with success criteria**: RootIntent contains `success_criteria: Vec<Criterion>` field
- **Frame as separate type**: `Frame { scope, constraints, success_criteria }` linked to Intent
- **Tension with conflict pairs**: `Tension { left: ProposedFact, right: ProposedFact, conflict_type }` as explicit type

### Observation vs Fact Distinction

- **3-type hierarchy**: `Observation → ProposedFact → Fact`
  - Observation = raw provider output (evidence ledger)
  - ProposedFact = normalized claim ready for promotion
  - Fact = promoted, governed truth

- **Double enforcement for promotion invariant**:
  - Type-state pattern: `Proposal<Draft> → Proposal<Validated> → Fact`
  - Private constructor: `Fact::new()` only callable by `PromotionGate::promote()`

- **Fully immutable Facts**:
  - All Fact fields are private; no `&mut` methods
  - Metadata/annotations live in separate append-only stream keyed by FactId
  - Corrections are new Facts, never mutations

- **CorrectionEvent in event stream**:
  - Facts stay pure data
  - `CorrectionEvent { new_fact_id, supersedes_fact_id, reason_code, reason_text, scope, actor, policy_version, timestamp }`
  - "Current truth" = latest promoted Fact not superseded within scope

### Provenance and TraceLink Design

- **Observation provenance**:
  - `raw_payload_ref: ContentHash` (hash/pointer to original response)
  - `capture_context: CaptureContext` (request params, environment, session)
  - Plus: provider identity/version, timestamp, correlation ID

- **Fact promotion metadata** (PromotionRecord):
  - `gate_id: GateId` (which gate approved)
  - `policy_version_hash: ContentHash` (hashable for audit/replay)
  - `approver: Actor` (human/agent/system identity)
  - `validation_summary: ValidationSummary` (key checks that passed)
  - `evidence_refs: Vec<EvidenceRef>` (typed references to supporting evidence)
  - `trace_link: TraceLink`
  - `promoted_at: Timestamp`

- **EvidenceRef as typed enum**:
  ```rust
  enum EvidenceRef {
      Observation(ObservationId),
      HumanApproval(ApprovalId),
      Derived(ArtifactId),
  }
  ```

- **TraceLink as enum**:
  ```rust
  enum TraceLink {
      Local(LocalTrace),    // trace_id, span_id, parent_span_id
      Remote(RemoteRef),    // system, ref, retrieval_auth, retention_hint
  }
  ```

- **Required provenance**: `promotion_record: PromotionRecord` is non-optional on Facts
  - Test helpers via separate crate (not #[cfg(test)])

### Builder vs Constructor Patterns

**Builders (fluent API, build-time validation):**
- `ProposalBuilder` → `Proposal<Draft>` (many optional fields, partial construction)
- `FrameBuilder` → `Frame` (compositional: constraints, scope, success_criteria)
- `IntentBuilder` → `RootIntent` (assembled from request, job-to-be-done, risk posture)
- `ContextBuilder` → immutable `Context` (fluent add_fact, set_intent)

**Strict constructors (no builder):**
- `Observation::new()` or kind-specific helpers (`Observation::from_api_response()`)
- `PromotionRecord::new()` (strict constructor)

**Private constructors (gate-controlled):**
- `Fact::new()` — only `PromotionGate::promote()` can create Facts
- `Proposal<Validated>::new()` — only `PromotionGate::validate()` can create

**Test fixtures:**
- Separate `converge-core-test` crate with fixture builders
- `PromotionRecord::stub()`, `Observation::fixture_*()`, `Proposal::fixture_*()`

### Claude's Discretion

- Exact field names and types for CaptureContext, ValidationSummary
- Module organization within types/ (flat vs nested)
- Specific Criterion variant types for success criteria
- ConflictType variants for Tension

</decisions>

<specifics>
## Specific Ideas

- Observation should be an envelope; kind-specific helpers for different sources
- Frame constraints should be typed (not just String) — consider ConstraintKind enum
- Consider valid_from/valid_to on Facts for time-bounded truth
- LocalTrace should include sampled flag for trace sampling decisions
- RemoteRef should have system identifier (datadog, jaeger, etc.)

</specifics>

<deferred>
## Deferred Ideas

- Full gate pattern implementation (Phase 4)
- LlmBackend, Recall, ExperienceStore traits (Phase 5)
- proptest strategies for types (Phase 6)
- insta snapshots for serialization (Phase 6)
- Nine tenets documentation (Phase 7)

</deferred>

---

*Phase: 03-type-consolidation*
*Context gathered: 2026-01-23*
