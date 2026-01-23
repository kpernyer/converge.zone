# Architecture Patterns for Pure Axiomatic Rust Crate

**Domain:** converge-core restoration
**Researched:** 2026-01-23
**Confidence:** HIGH

## Executive Summary

converge-core requires restructuring to become a pure axiomatic crate: types, traits, and promotion gates only. The key insight from optimization work: the **ProblemSpec → ProposedPlan → SolverReport → PromotionGate** pattern is universal and should be abstracted.

## Dependency Direction (The Cardinal Rule)

```
                 +-----------------+
                 |  converge-core  |  <- Pure: types, traits, gates
                 +-----------------+
                        ^
       +----------------+----------------+
       |                |                |
+------+------+  +------+------+  +------+------+
|converge-llm |  |converge-opt |  |converge-    |
|             |  |             |  |provider     |
+-------------+  +-------------+  +-------------+
```

**Rule:** Dependencies flow UP toward core. Core never depends on capability crates.

## Module Boundaries

| In Core | In Capability Crates |
|---------|---------------------|
| Types (data structures) | Implementations |
| Traits (interfaces) | Async wrappers |
| Gate abstractions | Gate instantiations |
| Pure validation functions | Validators with I/O |
| Error type definitions | Runtime error handling |
| Constants/enums | Domain-specific variants |

## Three-Layer Architecture

### Layer 1: Axiomatic Types (`types/`)

```
types/
  intent.rs        # KernelIntent, IntentId
  context.rs       # Context, ContextKey, Fact
  policy.rs        # KernelPolicy, RoutingPolicy
  proposal.rs      # KernelProposal, ProposedContent
  trace.rs         # TraceLink, Replayability
  budgets.rs       # Budgets, SolveBudgets
  stop_reasons.rs  # StopReason enum
  provenance.rs    # ProvenanceEnvelope
  authority.rs     # AuthorityPolicy, GateDecision
  artifact.rs      # GovernedArtifactState
```

### Layer 2: Trait Definitions (`traits/`)

```
traits/
  agent.rs         # Agent trait
  kernel.rs        # Kernel, DeterministicKernel, StochasticKernel
  validator.rs     # Validator, CompositeValidator
  promoter.rs      # Promoter trait
  recall.rs        # Recall trait signature
  backend.rs       # LlmBackend trait signature
  store.rs         # ExperienceStore trait signature
```

### Layer 3: Gate Abstractions (`gates/`)

```
gates/
  lifecycle.rs     # ProposalLifecycle<I, P, V, F>
  validation.rs    # ValidationReport, ValidationOutcome
  promotion.rs     # PromotionGate, PromotionResult
  invariants.rs    # Invariant trait
```

## The Generic Gate Pattern

```rust
pub struct ProposalLifecycle<I, P, V, F> {
    _intent: PhantomData<I>,
    _proposal: PhantomData<P>,
    _validation: PhantomData<V>,
    _fact: PhantomData<F>,
}

impl<I, P, V, F> ProposalLifecycle<I, P, V, F> {
    /// Phase 1: Intent specifies what we want
    pub fn intent(intent: I) -> IntentPhase<I>;

    /// Phase 2: Kernel produces proposal (never authority)
    pub fn propose(proposal: P, trace: TraceLink) -> ProposalPhase<P>;

    /// Phase 3: Validators check against invariants
    pub fn validate(validation: V) -> ValidationPhase<V>;

    /// Phase 4: Gate decides: promote, reject, or escalate
    pub fn decide(gate: PromotionGate) -> GatePhase;

    /// Phase 5: Only if gate approves, proposal becomes fact
    pub fn promote(fact: F) -> Fact<F>;
}
```

## Data Flow Direction

1. **Intent flows IN:** Platform creates KernelIntent
2. **Proposal flows OUT:** Capability crate produces KernelProposal + TraceLink
3. **Validation happens:** Validators check invariants → ValidationReport
4. **Gate decides:** PromotionGate determines if promotion allowed
5. **Fact flows IN:** Only engine can add Fact to Context

## Boundary Enforcement

```rust
impl Fact {
    /// Private constructor - only engine can create facts
    pub(crate) fn new_trusted(...) -> Self;
}

impl KernelProposal {
    /// Public constructor - anyone can propose
    pub fn new(...) -> Self;
}
```

## Suggested Extraction Order

### Phase 1: Foundation (Low Risk)
1. `types/stop_reasons.rs` - Unified StopReason enum
2. `types/budgets.rs` - Solve/Execution budgets
3. `types/provenance.rs` - ProvenanceEnvelope

### Phase 2: Gate Pattern (High Value)
4. `gates/validation.rs` - ValidationReport
5. `gates/promotion.rs` - PromotionGate
6. `gates/lifecycle.rs` - Generic ProposalLifecycle

### Phase 3: Trait Cleanup
7. `traits/kernel.rs` - Kernel traits
8. `traits/validator.rs` - Validator trait
9. `traits/store.rs` - ExperienceStore trait signature

### Phase 4: Implementation Extraction
10. Remove `llm.rs` → converge-provider
11. Remove `backend.rs` → converge-llm
12. Remove `capability.rs` → converge-provider

## Anti-Patterns to Avoid

### "Helpful" Defaults
```rust
// BAD
impl Default for KernelPolicy {
    fn default() -> Self {
        Self { recall_enabled: true }  // Hidden authority
    }
}

// GOOD - forces explicit configuration
impl KernelPolicy {
    pub fn new() -> PolicyBuilder { PolicyBuilder::new() }
}
```

### Traits with Default Methods That Do Work
```rust
// BAD
pub trait LlmBackend {
    fn execute(&self, req: &Request) -> Result<Response> {
        reqwest::blocking::get(...)?  // I/O in core!
    }
}

// GOOD - abstract, no I/O
pub trait LlmBackend {
    fn execute(&self, req: &Request) -> Result<Response>;
}
```

### Leaky Abstractions
```rust
// BAD - provider-specific fields
pub struct TraceLink {
    pub anthropic_system_fingerprint: Option<String>,
}

// GOOD - generic shape
pub enum TraceLink {
    Local(LocalTraceLink),
    Remote(RemoteTraceLink),
}
```

## File-Level Mapping

| Current File | Target |
|--------------|--------|
| `lib.rs` | Simplified re-exports |
| `agent.rs` | `traits/agent.rs` |
| `context.rs` | `types/context.rs` |
| `engine.rs` | `engine/mod.rs` |
| `kernel_boundary.rs` | Split into types/ modules |
| `llm.rs` | REMOVE → converge-provider |
| `backend.rs` | Trait → `traits/backend.rs`, impl → converge-llm |
| `capability.rs` | REMOVE → converge-provider |

## CI Boundary Detection

```rust
#[test]
fn core_has_no_runtime_dependencies() {
    let metadata = cargo_metadata::MetadataCommand::new().exec().unwrap();
    let core = metadata.packages.iter()
        .find(|p| p.name == "converge-core").unwrap();

    let forbidden = ["tokio", "reqwest", "axum", "burn", "polars"];
    for dep in &core.dependencies {
        assert!(!forbidden.contains(&dep.name.as_str()),
            "converge-core has forbidden dependency: {}", dep.name);
    }
}
```

## Sources

- Codebase analysis: converge-core sources
- Gate pattern: converge-optimization/src/gate/
- PROJECT.md context
- Rust API Guidelines
