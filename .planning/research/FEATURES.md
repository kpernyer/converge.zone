# Feature Landscape: Pure Axiomatic Rust Crate

**Domain:** converge-core v2.0.0 restoration
**Researched:** 2026-01-23
**Confidence:** HIGH

## Executive Summary

A pure axiomatic Rust crate should expose **types, traits, and validation logic** that encode invariants, while delegating **execution, I/O, and implementation** to downstream crates.

**Boundary Principle:** If a type answers "WHAT can happen?" it belongs in core. If it answers "HOW?" it belongs elsewhere.

## Table Stakes

Features expected in any axiomatic/foundational Rust crate.

| Feature | Why Expected | Complexity |
|---------|--------------|------------|
| **Core Type Definitions** | Foundation crates define vocabulary | Low |
| **Trait Definitions** | Enable downstream implementation | Low |
| **Enum-Based State Machines** | Make invalid states unrepresentable | Low |
| **Error Types with Context** | Structured errors for typed handling | Low |
| **Serialization Stability** | Portable across crate boundaries | Medium |
| **Zero Runtime Dependencies** | Portability, compile anywhere | Low |
| **Pure Validation Functions** | Stateless validation logic | Low |
| **Builder Patterns** | Ergonomic type construction | Low |
| **Comprehensive Documentation** | Axiom crates must be self-documenting | Medium |
| **Unit Tests for Invariants** | Prove the axioms hold | Medium |

## Differentiators

Features that make converge-core special.

| Feature | Value Proposition | Complexity |
|---------|-------------------|------------|
| **Proposal Lifecycle Types** | Encode "agents suggest, engine decides" | Medium |
| **Promotion Gate Pattern** | Abstract gate from optimization learnings | Medium |
| **Explicit Authority Grants** | No defaults that grant authority | Medium |
| **Replayability Honesty** | System tells truth about determinism | Medium |
| **Stop Reason Enumeration** | Explicit termination reasons | Low |
| **TraceLink Separation** | Local (replay) vs Remote (audit-only) | Medium |
| **Kernel Boundary Types** | Constitutional types for all kernels | High |
| **Governed Artifact Lifecycle** | Typed lifecycle with audit trails | Medium |
| **Invariant Classification** | Categorized governance rules | Low |
| **Budget Types** | Guarantee termination | Low |

## Anti-Features

Things to deliberately NOT include.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **Execution Logic** | Violates "types not behavior" | Traits define interface, impl elsewhere |
| **Retry Policies with Timing** | Implies scheduling | Move to converge-runtime |
| **Circuit Breaker State** | Runtime state, not types | Move to converge-runtime |
| **Backend Routing Logic** | Model selection is impl | Move to converge-provider |
| **Async Runtime Dependency** | Reduces portability | Pure sync types |
| **HTTP/Network Types** | I/O belongs elsewhere | Move to converge-runtime |
| **Embedding/Recall Execution** | Implementation not axiom | Move to converge-llm |
| **Prompt Rendering Logic** | Implementation not axiom | Move to converge-llm |
| **"Helpful" Defaults** | Violates explicit authority | All authority explicit |
| **Background Effects** | Violates no hidden work | All effects explicit |

## Current State Analysis

**Modules that belong in converge-core:**

| Module | Status | Notes |
|--------|--------|-------|
| `context.rs` | Keep | Context, Fact, ProposedFact, ContextKey |
| `agent.rs` | Keep | Agent trait, AgentId |
| `effect.rs` | Keep | AgentEffect |
| `engine.rs` | Partial | Keep Budget, ConvergeResult |
| `invariant.rs` | Keep | Invariant trait + types |
| `root_intent.rs` | Keep | Constitutional types |
| `governed_artifact.rs` | Keep | Lifecycle types |
| `kernel_boundary.rs` | Keep | Constitutional kernel types |
| `validation.rs` | Keep | Pure validation logic |

**Modules to extract:**

| Module | Destination | Reason |
|--------|-------------|--------|
| `backend.rs` | converge-runtime | Retry timing, circuit breaker |
| `llm.rs` | converge-llm | LLM-specific types/impls |
| `model_selection.rs` | converge-provider | Selection logic |
| `prompt.rs` | converge-llm | Prompt rendering |
| `capability.rs` | converge-provider | Capability implementations |
| `experience_store.rs` | converge-persistence | Event store impl |

## Rust-Specific Patterns

### Pattern 1: Sealed Traits

```rust
mod private { pub trait Sealed {} }

pub trait Agent: private::Sealed {
    fn execute(&self, ctx: &Context) -> AgentEffect;
}
```

### Pattern 2: Type-State for Lifecycle

```rust
pub struct Proposal<S> { data: ProposalData, _state: PhantomData<S> }

pub struct Draft;
pub struct Validated;

impl Proposal<Draft> {
    pub fn validate(self) -> Result<Proposal<Validated>, ValidationError>;
}

impl Proposal<Validated> {
    pub fn promote(self) -> Fact;  // Only valid path
}
```

### Pattern 3: New-Type IDs

```rust
pub struct IntentId(String);
pub struct AgentId(String);
// Cannot accidentally swap these
```

### Pattern 4: Non-Exhaustive Enums

```rust
#[non_exhaustive]
pub enum StopReason {
    BudgetExhausted,
    ConvergenceReached,
    // Future variants don't break downstream
}
```

## Sources

- PROJECT.md context and nine tenets
- Codebase analysis of converge-core modules
- Rust API Guidelines
