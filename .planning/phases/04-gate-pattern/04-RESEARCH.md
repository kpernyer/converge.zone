# Phase 4: Gate Pattern - Research

**Researched:** 2026-01-23
**Domain:** Rust type-state patterns, generic lifecycle abstraction, validation gates
**Confidence:** HIGH

## Summary

This research investigates how to implement the Gate Pattern for Phase 4, focusing on `ProposalLifecycle<I, P, V, F>`, `PromotionGate`, validation reports, budget types, `StopReason` enumeration, and kernel boundary types. The existing codebase from Phase 3 already provides the foundation: type-state `Proposal<Draft>` and `Proposal<Validated>`, private-constructor `Fact`, and `PromotionRecord` with typed provenance.

The research confirms that the type-state pattern is the established Rust idiom for enforcing compile-time state transitions. The generic `ProposalLifecycle<I, P, V, F>` abstraction should be a trait (not a struct) that defines the contract between Intent, Proposal, ValidationReport, and Fact types. The `PromotionGate` becomes the implementation that enforces "agents suggest, engine decides" by requiring a `ValidationReport` before any promotion can occur.

Budget types should be implemented as wrapper newtypes with explicit construction and exhaustion checking. `StopReason` should be a comprehensive enum covering all termination conditions. Kernel boundary types already exist in `kernel_boundary.rs` and should be extended/formalized in a new `gates/` module.

**Primary recommendation:** Create a `gates/` module with `ProposalLifecycle` trait, concrete `PromotionGate` implementation, `ValidationReport` type, budget newtypes, and `StopReason` enum. Integrate with existing `types/` module rather than duplicating types.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Rust std | 2021 edition | PhantomData for type-state | Built-in, zero-cost abstraction |
| serde | 1.x | Serialization for all gate types | Already in use, stable |
| thiserror | 1.x | Derive error types | Already in use for error handling |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| static_assertions | 1.x | Compile-time invariant verification | Phase 6 for testing bounds |
| hex | 0.4.x | Hash encoding (already available) | ContentHash operations |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Trait-based lifecycle | Struct with generics | Trait is more flexible for different promotion strategies |
| Associated types | Generic parameters | Phase 2 decided generic params for trait flexibility |
| Runtime validation | Compile-time type-state | Type-state prevents invalid states at compile time |

**Installation:**
No new dependencies required. All needed crates are already in Cargo.toml.

## Architecture Patterns

### Recommended Project Structure
```
src/
├── types/          # Existing types from Phase 3 (keep intact)
│   ├── id.rs       # FactId, ProposalId, GateId, etc.
│   ├── proposal.rs # Proposal<Draft>, Proposal<Validated>
│   ├── fact.rs     # Fact with pub(crate) new()
│   └── provenance.rs # PromotionRecord, EvidenceRef
├── gates/          # NEW: Gate Pattern implementation
│   ├── mod.rs      # Module exports
│   ├── lifecycle.rs # ProposalLifecycle<I, P, V, F> trait
│   ├── promotion.rs # PromotionGate struct and impl
│   ├── validation.rs # ValidationReport, ValidationPolicy
│   ├── budget.rs   # Budget types (cycles, facts, tokens)
│   ├── stop.rs     # StopReason enumeration
│   └── boundary.rs # Kernel boundary types (formalized)
└── lib.rs          # Add gates module
```

### Pattern 1: ProposalLifecycle Trait
**What:** Generic trait defining the contract between lifecycle stages
**When to use:** Any promotion flow (observations, proposals, facts)
**Example:**
```rust
// Source: Codebase analysis + Rust type-state patterns
/// Generic lifecycle for proposal-to-fact promotion.
///
/// Type parameters:
/// - I: Intent type (what we're trying to achieve)
/// - P: Proposal type (what agents suggest)
/// - V: Validation type (proof of validation)
/// - F: Fact type (promoted result)
pub trait ProposalLifecycle<I, P, V, F> {
    /// Validate a proposal against intent and policy.
    /// Returns a validation report that must be consumed to promote.
    fn validate(&self, intent: &I, proposal: P) -> Result<V, ValidationError>;

    /// Promote a validated proposal to a fact.
    /// Requires the validation report - no bypass path.
    fn promote(&self, validated: V) -> Result<F, PromotionError>;
}
```

### Pattern 2: Type-State Enforcement
**What:** Use marker types to enforce compile-time state transitions
**When to use:** Any state transition that must be enforced
**Example:**
```rust
// Source: Phase 3 types/proposal.rs (existing implementation)
// Already implemented - Proposal<Draft> -> Proposal<Validated> -> Fact

// The gate consumes Draft, produces Validated
impl PromotionGate {
    pub fn validate(
        &self,
        proposal: Proposal<Draft>,
        context: &ValidationContext,
    ) -> Result<(Proposal<Validated>, ValidationReport), ValidationError> {
        // Validation logic...
        let validated = Proposal::<Validated>::from_validated(
            proposal.id().clone(),
            proposal.content().clone(),
            proposal.provenance().clone(),
        );
        Ok((validated, report))
    }

    // Promotion requires BOTH validated proposal AND report
    pub fn promote(
        &self,
        proposal: Proposal<Validated>,
        report: ValidationReport,  // REQUIRED - no Option, no bypass
    ) -> Result<Fact, PromotionError> {
        // Create promotion record from report
        let record = PromotionRecord::from_report(&report, self.gate_id.clone());
        Ok(Fact::new(
            FactId::new(/* generate */),
            FactContent::from_proposal(proposal.content()),
            record,
            Timestamp::now(),
        ))
    }
}
```

### Pattern 3: ValidationReport as Proof Object
**What:** A type that can only be created by validation, consumed by promotion
**When to use:** Enforce that validation actually occurred
**Example:**
```rust
// Source: Rust validation patterns + codebase analysis
/// Proof that validation occurred. Can only be created by validators.
/// Consumed by promotion - ensures no bypass path.
pub struct ValidationReport {
    /// Which proposal was validated
    proposal_id: ProposalId,
    /// What checks passed
    checks_passed: Vec<CheckResult>,
    /// Policy version used (for audit)
    policy_version: ContentHash,
    /// When validation occurred
    validated_at: Timestamp,
    /// Token preventing forgery (internal field)
    _token: ValidationToken,
}

/// Private token - only validators can create
#[derive(Clone)]
pub(crate) struct ValidationToken(());

impl ValidationReport {
    /// Only callable by validators (pub(crate))
    pub(crate) fn new(
        proposal_id: ProposalId,
        checks_passed: Vec<CheckResult>,
        policy_version: ContentHash,
    ) -> Self {
        Self {
            proposal_id,
            checks_passed,
            policy_version,
            validated_at: Timestamp::now(),
            _token: ValidationToken(()),
        }
    }
}
```

### Pattern 4: Budget Types as Newtypes
**What:** Wrapper types for resource limits with checked arithmetic
**When to use:** Anywhere resource exhaustion must be tracked
**Example:**
```rust
// Source: Engine Budget pattern + Rust newtype idiom
/// Cycle budget - tracks remaining execution cycles
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct CycleBudget(u32);

impl CycleBudget {
    pub fn new(max: u32) -> Self {
        Self(max)
    }

    pub fn remaining(&self) -> u32 {
        self.0
    }

    pub fn is_exhausted(&self) -> bool {
        self.0 == 0
    }

    /// Decrement budget, returning StopReason if exhausted
    pub fn tick(&mut self) -> Option<StopReason> {
        if self.0 == 0 {
            Some(StopReason::CycleBudgetExhausted)
        } else {
            self.0 -= 1;
            None
        }
    }
}

/// Token budget - tracks LLM tokens consumed
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TokenBudget(u64);

/// Fact budget - tracks maximum facts in context
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct FactBudget(u32);
```

### Pattern 5: StopReason Enumeration
**What:** Exhaustive enum covering all termination reasons
**When to use:** Whenever execution terminates
**Example:**
```rust
// Source: argmin TerminationReason + agent-client-protocol StopReason
/// Why execution stopped. Exhaustive enumeration for audit trails.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum StopReason {
    // Successful termination
    /// Convergence reached (fixed point)
    Converged,
    /// Intent criteria satisfied
    CriteriaMet,
    /// User requested stop
    UserCancelled,

    // Budget exhaustion
    /// Maximum cycles exceeded
    CycleBudgetExhausted,
    /// Maximum facts exceeded
    FactBudgetExhausted,
    /// Maximum tokens exceeded
    TokenBudgetExhausted,
    /// Maximum wall-clock time exceeded
    TimeBudgetExhausted,

    // Validation failures
    /// Invariant violation (structural/semantic/acceptance)
    InvariantViolated { class: InvariantClass, name: String },
    /// Promotion gate rejected proposal
    PromotionRejected { reason: String },

    // System errors
    /// Unrecoverable error
    Error { message: String },
    /// Agent refused to continue
    AgentRefused { agent_id: AgentId },
}
```

### Anti-Patterns to Avoid
- **Option<ValidationReport>:** Never make the report optional. The type system should enforce its presence.
- **Public Fact::new():** Keep the constructor private. External code must go through PromotionGate.
- **String-based evidence refs:** Use the existing typed `EvidenceRef` enum.
- **Unchecked budget arithmetic:** Always check for exhaustion before decrementing.
- **Default authority grants:** No function should implicitly grant promotion authority.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Type-state transitions | Manual state checking | PhantomData + marker types | Compile-time enforcement |
| Hash/fingerprint | Custom hashing | ContentHash (existing) | Already has serde support |
| Timestamping | Custom format | Timestamp (existing) | Consistent ISO-8601 format |
| Error handling | Custom result types | thiserror derives | Standard, composable |
| ID generation | String concatenation | Newtype IDs (existing) | Type safety, Display impl |
| Trace linking | String references | TraceLink enum (existing) | Local vs Remote semantics |
| Actor identification | String user IDs | Actor (existing) | Typed kind enum |

**Key insight:** Phase 3 already built most of the foundation types. The gate pattern orchestrates them rather than replacing them.

## Common Pitfalls

### Pitfall 1: Bypass Path Through Deserialization
**What goes wrong:** Fact implements Deserialize, so external code could construct a Fact by deserializing JSON
**Why it happens:** Serde derives are convenient but can bypass constructors
**How to avoid:**
- Make `Fact::new()` the only path to create valid Facts
- Add validation in Deserialize impl that verifies PromotionRecord
- Consider: Facts from storage are "replay", not creation
**Warning signs:** Tests that construct Facts via serde_json::from_str

### Pitfall 2: ValidationReport Forgery
**What goes wrong:** External code creates a ValidationReport without validation
**Why it happens:** Report is just a struct with data
**How to avoid:**
- Private constructor (pub(crate))
- Internal token field that can't be constructed outside module
- Gate creates reports, gate consumes reports
**Warning signs:** ValidationReport::new() visible in public API

### Pitfall 3: Budget Underflow
**What goes wrong:** Budget decremented below zero, wraps to MAX
**Why it happens:** Using u32 arithmetic without checking
**How to avoid:**
- Use checked_sub or saturating_sub
- Return Option<StopReason> from tick()
- Test with budget = 0 initial conditions
**Warning signs:** Tests that don't exercise exhaustion paths

### Pitfall 4: Incomplete StopReason Coverage
**What goes wrong:** New termination condition added but not to enum
**Why it happens:** Enum forgotten when adding features
**How to avoid:**
- Make StopReason exhaustive from the start
- Use `#[non_exhaustive]` for future extensibility
- Document that new stop reasons require ROADMAP update
**Warning signs:** `_ => panic!()` or `unreachable!()` in match arms

### Pitfall 5: Kernel Boundary Type Duplication
**What goes wrong:** gates/ duplicates types from kernel_boundary.rs
**Why it happens:** Unclear ownership between modules
**How to avoid:**
- Formalize: kernel_boundary.rs = kernel-to-platform contract
- gates/ = promotion lifecycle within platform
- Use re-exports, not duplication
**Warning signs:** Two versions of KernelProposal or TraceLink

## Code Examples

Verified patterns from official sources and codebase analysis:

### Complete PromotionGate Implementation
```rust
// Source: Codebase types/proposal.rs + types/fact.rs + provenance.rs
use crate::types::{
    Proposal, Draft, Validated, Fact, FactId, FactContent, FactContentKind,
    PromotionRecord, GateId, ContentHash, Actor, ValidationSummary,
    EvidenceRef, TraceLink, Timestamp,
};

/// The promotion gate - enforces "agents suggest, engine decides"
pub struct PromotionGate {
    /// Unique identifier for this gate
    pub gate_id: GateId,
    /// Current policy version (for audit trails)
    pub policy_version: ContentHash,
    /// Validation policy
    policy: ValidationPolicy,
}

impl PromotionGate {
    pub fn new(gate_id: GateId, policy: ValidationPolicy) -> Self {
        Self {
            gate_id,
            policy_version: policy.version_hash(),
            policy,
        }
    }

    /// Validate a draft proposal. Returns validated proposal + report.
    pub fn validate(
        &self,
        proposal: Proposal<Draft>,
        context: &ValidationContext,
    ) -> Result<(Proposal<Validated>, ValidationReport), ValidationError> {
        // Run all checks
        let checks = self.policy.run_checks(&proposal, context)?;

        // Create validated proposal (pub(crate) constructor)
        let validated = Proposal::<Validated>::from_validated(
            proposal.id().clone(),
            proposal.content().clone(),
            proposal.provenance().clone(),
        );

        // Create validation report
        let report = ValidationReport::new(
            proposal.id().clone(),
            checks,
            self.policy_version.clone(),
        );

        Ok((validated, report))
    }

    /// Promote validated proposal to fact. REQUIRES report.
    pub fn promote(
        &self,
        proposal: Proposal<Validated>,
        report: ValidationReport,
        approver: Actor,
        evidence: Vec<EvidenceRef>,
        trace: TraceLink,
    ) -> Result<Fact, PromotionError> {
        // Verify report matches proposal
        if report.proposal_id() != proposal.id() {
            return Err(PromotionError::ReportMismatch {
                expected: proposal.id().clone(),
                got: report.proposal_id().clone(),
            });
        }

        // Build promotion record
        let record = PromotionRecord::new(
            self.gate_id.clone(),
            self.policy_version.clone(),
            approver,
            ValidationSummary::from_report(&report),
            evidence,
            trace,
            Timestamp::now(),
        );

        // Create fact (pub(crate) constructor)
        let fact = Fact::new(
            FactId::new(format!("fact:{}", proposal.id())),
            FactContent::new(
                FactContentKind::from(proposal.content().kind),
                proposal.content().content.clone(),
            ),
            record,
            Timestamp::now(),
        );

        Ok(fact)
    }
}
```

### Budget Type Integration with Engine
```rust
// Source: engine.rs Budget pattern extended
/// Combined budget for engine execution
#[derive(Debug, Clone)]
pub struct ExecutionBudget {
    pub cycles: CycleBudget,
    pub facts: FactBudget,
    pub tokens: Option<TokenBudget>,
}

impl ExecutionBudget {
    pub fn check_exhaustion(&self) -> Option<StopReason> {
        if self.cycles.is_exhausted() {
            return Some(StopReason::CycleBudgetExhausted);
        }
        if self.facts.is_exhausted() {
            return Some(StopReason::FactBudgetExhausted);
        }
        if let Some(ref tokens) = self.tokens {
            if tokens.is_exhausted() {
                return Some(StopReason::TokenBudgetExhausted);
            }
        }
        None
    }
}
```

### Kernel Boundary Type Formalization
```rust
// Source: kernel_boundary.rs (existing) + new formalization
/// Kernel boundary types are "constitutional" - they define the
/// contract between reasoning kernels and the Converge platform.
///
/// Constitutional properties:
/// - Kernels emit proposals, never facts
/// - All proposals have trace links
/// - Human authority is first-class
pub mod constitutional {
    pub use crate::kernel_boundary::{
        KernelIntent, KernelContext, KernelPolicy,
        KernelProposal, TraceLink, Replayability,
    };
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Runtime state validation | Compile-time type-state | Rust 1.0+ | Bugs caught at compile time |
| Optional PromotionRecord | Required PromotionRecord | Phase 3 decision | No facts without provenance |
| String evidence refs | Typed EvidenceRef enum | Phase 3 | Type-safe evidence linking |
| context::Fact | types::Fact with private new() | Phase 3 | Promotion gate is only path |

**Deprecated/outdated:**
- `context::Fact` - Still exists for backward compat, but `types::Fact` is the new governed type
- Direct Fact construction - Must go through PromotionGate

## Open Questions

Things that couldn't be fully resolved:

1. **Invariant Classification (REQ-GATE-09)**
   - What we know: InvariantClass exists (Structural, Semantic, Acceptance)
   - What's unclear: How "categorized governance rules" differ from existing invariants
   - Recommendation: Extend InvariantClass or create InvariantCategory for governance-specific rules

2. **Authority Grant Mechanism (REQ-GATE-03)**
   - What we know: "No defaults that grant authority" is the requirement
   - What's unclear: Exact mechanism for explicit authority grants
   - Recommendation: AuthorityGrant type that must be explicitly constructed and passed

3. **Integration with Existing Engine**
   - What we know: Engine uses Budget struct, runs convergence loop
   - What's unclear: Whether PromotionGate replaces or wraps existing validation
   - Recommendation: PromotionGate operates within merge_effects, ValidationAgent deprecated

## Sources

### Primary (HIGH confidence)
- Existing codebase: types/proposal.rs, types/fact.rs, types/provenance.rs
- Existing codebase: kernel_boundary.rs, engine.rs, invariant.rs
- Phase 3 CONTEXT.md: Design decisions already made

### Secondary (MEDIUM confidence)
- [Cliffle: Typestate Pattern in Rust](https://cliffle.com/blog/rust-typestate/)
- [Hoverbear: State Machine Patterns in Rust](https://hoverbear.org/blog/rust-state-machine-pattern/)
- [Medium: Generic FSM with Type State](https://medium.com/@alfred.weirich/generic-finite-state-machines-with-rusts-type-state-pattern-04593bba34a8)
- [argmin: TerminationReason enum](https://argmin-rs.github.io/argmin/argmin/core/enum.TerminationReason.html)
- [agent-client-protocol: StopReason](https://docs.rs/agent-client-protocol-schema/latest/agent_client_protocol_schema/enum.StopReason.html)

### Tertiary (LOW confidence)
- [Keats/validator](https://github.com/Keats/validator) - Validation patterns reference
- [jprochazk/garde](https://github.com/jprochazk/garde) - Validation with context

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Using existing crate dependencies
- Architecture: HIGH - Building on Phase 3 foundation, well-established Rust patterns
- Pitfalls: MEDIUM - Derived from analysis, not production experience

**Research date:** 2026-01-23
**Valid until:** 30 days (stable patterns, project-specific)

---

## Integration Notes for Planner

### What Already Exists (Don't Duplicate)
1. `Proposal<Draft>` / `Proposal<Validated>` - type-state markers
2. `Fact::new()` is already `pub(crate)` - private constructor
3. `PromotionRecord` with all required fields
4. `ValidationSummary`, `EvidenceRef`, `TraceLink` types
5. `ContentHash`, `GateId`, `Timestamp` newtypes
6. `kernel_boundary.rs` with KernelProposal, KernelIntent, etc.
7. `engine.rs` with `Budget` struct

### What Needs to Be Created
1. `gates/` module structure
2. `ProposalLifecycle<I, P, V, F>` trait
3. `PromotionGate` struct implementing the trait
4. `ValidationReport` proof object with private token
5. `ValidationPolicy` and `ValidationContext` types
6. `CycleBudget`, `FactBudget`, `TokenBudget` newtypes
7. `StopReason` comprehensive enumeration
8. `AuthorityGrant` explicit authority mechanism

### Plan Splitting Recommendation
- **Plan 04-01:** ProposalLifecycle trait, PromotionGate, ValidationReport
- **Plan 04-02:** Budget types, StopReason, kernel boundary formalization
