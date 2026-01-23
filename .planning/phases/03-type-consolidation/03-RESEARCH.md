# Phase 3: Type Consolidation - Research

**Researched:** 2026-01-23
**Domain:** Rust type system design, module organization, builder patterns, error handling
**Confidence:** HIGH

## Summary

This phase involves reorganizing the core type vocabulary of converge-core into a dedicated `types/` module. The research investigates the current type landscape scattered across multiple files, identifies what needs consolidation, and establishes patterns for the new types mandated by CONTEXT.md decisions.

The current codebase has types spread across `context.rs`, `root_intent.rs`, `kernel_boundary.rs`, `governed_artifact.rs`, and `error.rs`. The goal is to centralize core domain types (Observation, ProposedFact, Fact, Intent, Frame, Tension, etc.) in a well-organized `types/` module while preserving backward compatibility through re-exports.

**Primary recommendation:** Create `types/` module with submodules for each domain (observation, fact, intent, frame, provenance) using the type-state pattern for promotion invariants and typed-builder for complex construction.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| thiserror | 2.x | Error type derivation | Already in Cargo.toml; provides `#[derive(Error)]` with `#[error]`, `#[from]`, `#[source]` |
| serde | 1.x | Serialization | Already in Cargo.toml; stable serialization shapes |
| strum | 0.26 | Enum utilities | Already in Cargo.toml; provides `EnumIter`, `Display`, etc. |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| typed-builder | 0.18+ | Compile-time builder generation | For complex types like ProposalBuilder, FrameBuilder, IntentBuilder |
| derive_more | 1.x | Common trait derives | For Display, From, Into on newtypes (optional) |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| typed-builder | derive_builder | derive_builder does runtime checks, typed-builder does compile-time |
| typed-builder | hand-written builders | More boilerplate but full control |
| type-state-builder crate | manual type-state | The crate is newer, manual gives more flexibility |

**Installation:**
```bash
cargo add typed-builder
# derive_more is optional
```

## Architecture Patterns

### Recommended Project Structure
```
src/
├── types/
│   ├── mod.rs           # Re-exports, type aliases
│   ├── id.rs            # All ID newtypes (FactId, ObservationId, IntentId, etc.)
│   ├── observation.rs   # Observation, CaptureContext, raw_payload_ref
│   ├── proposal.rs      # ProposedFact, Proposal<State>, ProposalBuilder
│   ├── fact.rs          # Fact, PromotionRecord, EvidenceRef
│   ├── intent.rs        # RootIntent, IntentKind, Criterion, IntentBuilder
│   ├── frame.rs         # Frame, ConstraintKind, FrameBuilder
│   ├── tension.rs       # Tension, ConflictType, Hypothesis
│   ├── context.rs       # Context, ContextKey, ContextBuilder
│   ├── provenance.rs    # TraceLink, LocalTrace, RemoteRef, EvidenceRef
│   ├── correction.rs    # CorrectionEvent, supersession logic
│   └── error.rs         # All error types consolidated with thiserror
├── traits/              # Existing capability boundary traits
├── lib.rs               # Re-exports from types/ for backward compatibility
└── [other modules]      # Existing modules largely unchanged
```

### Pattern 1: Type-State for Proposal Promotion
**What:** Use phantom type parameters to encode proposal lifecycle states
**When to use:** When invalid state transitions must be compile-time errors
**Example:**
```rust
// Source: CONTEXT.md decisions + Rust type-state pattern best practices
use std::marker::PhantomData;

// Marker types for states
pub struct Draft;
pub struct Validated;

/// A proposal in a specific lifecycle state.
///
/// State transitions:
/// - Proposal<Draft> -> Proposal<Validated> via PromotionGate::validate()
/// - Proposal<Validated> -> Fact via PromotionGate::promote()
pub struct Proposal<State> {
    pub id: ProposalId,
    pub content: ProposedContent,
    pub provenance: ObservationProvenance,
    _state: PhantomData<State>,
}

impl Proposal<Draft> {
    /// Public constructor for draft proposals.
    pub fn new(id: ProposalId, content: ProposedContent, provenance: ObservationProvenance) -> Self {
        Self { id, content, provenance, _state: PhantomData }
    }
}

impl Proposal<Validated> {
    /// Private constructor - only callable by PromotionGate.
    pub(crate) fn from_validated(
        id: ProposalId,
        content: ProposedContent,
        provenance: ObservationProvenance
    ) -> Self {
        Self { id, content, provenance, _state: PhantomData }
    }
}
```

### Pattern 2: Private Constructor for Fact Immutability
**What:** Make Fact fields private with pub(crate) constructor callable only by PromotionGate
**When to use:** For types where creation must be controlled
**Example:**
```rust
// Source: CONTEXT.md decisions
/// A promoted, governed truth. Immutable after creation.
///
/// Facts can only be created via PromotionGate::promote(). Direct construction
/// is impossible outside converge-core.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Fact {
    id: FactId,
    content: FactContent,
    promotion_record: PromotionRecord,  // Non-optional per CONTEXT.md
    created_at: Timestamp,
}

impl Fact {
    /// Private constructor - only callable by PromotionGate.
    pub(crate) fn new(
        id: FactId,
        content: FactContent,
        promotion_record: PromotionRecord,
        created_at: Timestamp,
    ) -> Self {
        Self { id, content, promotion_record, created_at }
    }

    // Only getter methods, no &mut self methods
    pub fn id(&self) -> &FactId { &self.id }
    pub fn content(&self) -> &FactContent { &self.content }
    pub fn promotion_record(&self) -> &PromotionRecord { &self.promotion_record }
}
```

### Pattern 3: Builder Pattern with typed-builder
**What:** Derive compile-time checked builders for complex types
**When to use:** Types with many optional fields or complex construction
**Example:**
```rust
// Source: typed-builder crate documentation
use typed_builder::TypedBuilder;

#[derive(TypedBuilder)]
pub struct Frame {
    pub id: FrameId,
    #[builder(setter(into))]
    pub scope: String,
    #[builder(default)]
    pub constraints: Vec<FrameConstraint>,
    #[builder(default)]
    pub success_criteria: Vec<Criterion>,
    #[builder(setter(into), default)]
    pub linked_intent: Option<IntentId>,
}

// Usage:
let frame = Frame::builder()
    .id(FrameId::new("frame-1"))
    .scope("Nordic B2B market")
    .constraints(vec![FrameConstraint::Budget(1_000_000)])
    .build();
```

### Pattern 4: Newtype IDs with serde
**What:** Wrap identifiers in newtype structs for type safety
**When to use:** All identifiers that could be confused
**Example:**
```rust
// Source: Rust newtype pattern + serde best practices
use serde::{Deserialize, Serialize};

/// Unique identifier for a Fact.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(transparent)]
pub struct FactId(String);

impl FactId {
    pub fn new(id: impl Into<String>) -> Self {
        Self(id.into())
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl std::fmt::Display for FactId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}
```

### Anti-Patterns to Avoid
- **Flat types/ with 30+ files:** Use submodules to group related types
- **Public Fact::new():** Would bypass promotion invariant
- **Mutable Facts:** No `&mut self` methods on Fact
- **String identifiers:** Use newtype IDs for FactId, ObservationId, IntentId, etc.
- **Optional PromotionRecord:** CONTEXT.md mandates it be required on Facts
- **Tests calling Fact::new():** Use converge-core-test crate with fixture builders

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Builder validation | Runtime checks | typed-builder | Compile-time guarantees |
| Error boilerplate | Manual Display/Error impls | thiserror derive | Less code, consistent |
| Enum iteration | Manual variant list | strum EnumIter | Kept in sync automatically |
| ID formatting | Inline format! | Display derive | Consistent, testable |
| State machine enforcement | Runtime state field | Type-state pattern | Compile-time safety |

**Key insight:** The type-state pattern makes invalid state transitions impossible at compile time. The cost is increased type complexity, but the benefit is zero runtime validation for promotion invariants.

## Common Pitfalls

### Pitfall 1: Breaking Public API
**What goes wrong:** Changing existing type signatures breaks downstream code
**Why it happens:** Types like Fact, ProposedFact, Context are already public
**How to avoid:**
- Re-export from lib.rs at same paths
- Use `#[deprecated]` for removed functionality
- Add new types alongside old, migrate incrementally
**Warning signs:** Compilation errors in tests or examples

### Pitfall 2: Orphan Rule for Trait Impls
**What goes wrong:** Can't implement traits from other crates on types from other crates
**Why it happens:** Rust's orphan rules prevent coherence issues
**How to avoid:**
- Keep trait definitions in same crate as types that impl them
- Use newtype wrappers when needed
**Warning signs:** "orphan impl" compiler error

### Pitfall 3: Serde Breaking Changes
**What goes wrong:** Serialized format changes, breaking persistence/APIs
**Why it happens:** Field renames, enum representation changes
**How to avoid:**
- Use `#[serde(rename = "...")]` for stability
- Use internally tagged enums: `#[serde(tag = "type")]`
- Add tests with insta snapshots (Phase 6)
**Warning signs:** Deserialization failures on old data

### Pitfall 4: Circular Dependencies in types/
**What goes wrong:** Module A uses type from B, B uses type from A
**Why it happens:** Domain types often reference each other
**How to avoid:**
- Put ID types in separate `id.rs` used by all
- Use forward declarations or split into smaller modules
- Consider traits for decoupling
**Warning signs:** Compiler error about cyclic dependencies

### Pitfall 5: Generic Parameter Explosion
**What goes wrong:** Types become unusable due to too many generics
**Why it happens:** Over-applying type-state pattern
**How to avoid:**
- Only use type-state where compile-time checks are essential
- Use Box<dyn Trait> or enums for non-critical flexibility
**Warning signs:** Builder types requiring 10+ generic parameters

## Code Examples

Verified patterns from official sources and CONTEXT.md decisions:

### Observation Type (3-tier hierarchy root)
```rust
// Source: CONTEXT.md decisions
use serde::{Deserialize, Serialize};

/// Raw provider output - the evidence ledger.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Observation {
    pub id: ObservationId,
    pub kind: ObservationKind,
    pub raw_payload_ref: ContentHash,
    pub capture_context: CaptureContext,
    pub provider: ProviderIdentity,
    pub captured_at: Timestamp,
}

/// Context of how the observation was captured.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CaptureContext {
    pub request_params: serde_json::Value,
    pub environment: HashMap<String, String>,
    pub session_id: Option<String>,
    pub correlation_id: Option<String>,
}

/// Provider identity and version.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProviderIdentity {
    pub name: String,
    pub version: String,
    pub adapter_id: Option<String>,
}

impl Observation {
    /// Create from an API response.
    pub fn from_api_response(
        id: ObservationId,
        raw_payload_ref: ContentHash,
        provider: ProviderIdentity,
        capture_context: CaptureContext,
    ) -> Self {
        Self {
            id,
            kind: ObservationKind::ApiResponse,
            raw_payload_ref,
            capture_context,
            provider,
            captured_at: Timestamp::now(),
        }
    }
}
```

### PromotionRecord (Required on Facts)
```rust
// Source: CONTEXT.md decisions
use serde::{Deserialize, Serialize};

/// Record of how a Fact was promoted.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PromotionRecord {
    pub gate_id: GateId,
    pub policy_version_hash: ContentHash,
    pub approver: Actor,
    pub validation_summary: ValidationSummary,
    pub evidence_refs: Vec<EvidenceRef>,
    pub trace_link: TraceLink,
    pub promoted_at: Timestamp,
}

impl PromotionRecord {
    /// Strict constructor - all fields required.
    pub fn new(
        gate_id: GateId,
        policy_version_hash: ContentHash,
        approver: Actor,
        validation_summary: ValidationSummary,
        evidence_refs: Vec<EvidenceRef>,
        trace_link: TraceLink,
        promoted_at: Timestamp,
    ) -> Self {
        Self {
            gate_id,
            policy_version_hash,
            approver,
            validation_summary,
            evidence_refs,
            trace_link,
            promoted_at,
        }
    }
}
```

### EvidenceRef and TraceLink (Typed Enums)
```rust
// Source: CONTEXT.md decisions
use serde::{Deserialize, Serialize};

/// Typed reference to supporting evidence.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum EvidenceRef {
    Observation(ObservationId),
    HumanApproval(ApprovalId),
    Derived(ArtifactId),
}

/// Trace link for audit and replay.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum TraceLink {
    Local(LocalTrace),
    Remote(RemoteRef),
}

/// Local trace link - replay eligible.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LocalTrace {
    pub trace_id: String,
    pub span_id: String,
    pub parent_span_id: Option<String>,
    pub sampled: bool,  // Per CONTEXT.md specifics
}

/// Remote trace link - audit eligible only.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RemoteRef {
    pub system: String,  // datadog, jaeger, etc.
    pub reference: String,
    pub retrieval_auth: Option<String>,
    pub retention_hint: Option<String>,
}
```

### CorrectionEvent (Append-only corrections)
```rust
// Source: CONTEXT.md decisions
use serde::{Deserialize, Serialize};

/// Event recording that one Fact supersedes another.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CorrectionEvent {
    pub new_fact_id: FactId,
    pub supersedes_fact_id: FactId,
    pub reason_code: CorrectionReason,
    pub reason_text: String,
    pub scope: CorrectionScope,
    pub actor: Actor,
    pub policy_version: ContentHash,
    pub timestamp: Timestamp,
}

/// Why the correction was made.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum CorrectionReason {
    DataError,
    PolicyChange,
    SourceRetraction,
    ManualOverride,
    SystemReconciliation,
}

/// Scope of the correction.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum CorrectionScope {
    Global,
    Tenant(String),
    Session(String),
}
```

### Error Type with thiserror
```rust
// Source: thiserror v2.0.18 documentation
use thiserror::Error;

/// Core type system errors.
#[derive(Debug, Error)]
pub enum TypeError {
    #[error("invalid state transition: {from} -> {to}")]
    InvalidStateTransition { from: String, to: String },

    #[error("promotion invariant violated: {0}")]
    PromotionInvariant(String),

    #[error("missing required field: {field}")]
    MissingField { field: &'static str },

    #[error("validation failed: {reason}")]
    ValidationFailed { reason: String },

    #[error(transparent)]
    Serialization(#[from] serde_json::Error),
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| String IDs everywhere | Newtype IDs (FactId, etc.) | This phase | Type safety, prevents ID confusion |
| Public Fact::new() | Private constructor + PromotionGate | This phase | Enforces promotion invariant |
| Mutable Facts | Immutable Facts + CorrectionEvent | This phase | Append-only, audit-friendly |
| ProposedFact only | Observation -> ProposedFact -> Fact | This phase | 3-tier hierarchy |
| Runtime state checks | Type-state pattern | This phase | Compile-time safety |

**Deprecated/outdated:**
- `Fact::new()` public constructor: replaced by private constructor
- Direct fact mutation: replaced by CorrectionEvent pattern
- Optional provenance: PromotionRecord is now required

## Open Questions

Things that couldn't be fully resolved:

1. **Timestamp type choice**
   - What we know: Need timestamps throughout
   - What's unclear: Use `std::time::SystemTime`, chrono, or string ISO-8601?
   - Recommendation: Use string ISO-8601 for serialization stability, keep time dependency out of converge-core (inject from runtime)

2. **ContentHash implementation**
   - What we know: Need content-addressed hashes for raw_payload_ref, policy_version_hash
   - What's unclear: SHA-256 bytes, hex string, or base64?
   - Recommendation: Use `[u8; 32]` with hex Display impl, leverage existing Fingerprint trait

3. **Test fixture crate timing**
   - What we know: CONTEXT.md specifies separate converge-core-test crate
   - What's unclear: Create in this phase or defer?
   - Recommendation: Defer to Phase 4 or 5; use `#[cfg(test)]` module for now with TODO

4. **Validation module migration**
   - What we know: `validation.rs` has ValidationAgent that uses current types
   - What's unclear: How much refactoring needed after type changes?
   - Recommendation: Treat as consumer of new types; refactor in place, don't move to types/

## Sources

### Primary (HIGH confidence)
- Codebase analysis: converge-core/src/*.rs - direct code inspection
- CONTEXT.md: Phase 3 decisions document
- [thiserror documentation](https://docs.rs/thiserror) v2.0.18 - attribute syntax
- [Serde enum representations](https://serde.rs/enum-representations.html) - serialization patterns

### Secondary (MEDIUM confidence)
- [typed-builder crate](https://github.com/idanarye/rust-typed-builder) - builder pattern
- [Rust type-state pattern guide](https://cliffle.com/blog/rust-typestate/) - state machine encoding
- [The Embedded Rust Book - Typestate Programming](https://docs.rust-embedded.org/book/static-guarantees/typestate-programming.html)

### Tertiary (LOW confidence)
- WebSearch results on Rust best practices 2026 - general patterns

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - using crates already in Cargo.toml
- Architecture: HIGH - patterns well-established in Rust ecosystem
- Migration plan: MEDIUM - breaking changes need careful handling
- Open questions: MEDIUM - some decisions can be deferred

**Research date:** 2026-01-23
**Valid until:** 60 days (stable Rust patterns, no fast-moving dependencies)
