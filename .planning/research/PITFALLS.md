# Domain Pitfalls: Rust Crate Restoration

**Domain:** Pure Rust crate design, brownfield restoration
**Researched:** 2026-01-23
**Confidence:** HIGH

## Executive Summary

Rust crate restoration projects commonly fail by treating purity as a code cleanup exercise rather than an architectural enforcement problem. Prevention requires automated guardrails, not developer discipline.

## Critical Pitfalls

### C1: "Just This Once" Dependency Additions

**What goes wrong:** Developer adds `tokio` or `reqwest` to core "just for this one trait implementation." Later never comes.

**Evidence from converge-core:**
- Cargo.toml has tokio and reqwest in workspace dependencies
- llm.rs contains full LlmAgent implementation with provider calls
- backend.rs defines LlmBackend trait with retry policies

**Prevention:**
1. CI Enforcement: Add cargo deny to fail on forbidden deps
2. Explicit Boundary File: Create BOUNDARY.md
3. PR Template: Require justification for Cargo.toml changes

**Detection:** Cargo.toml changes, new async primitives, compile time increases

**Phase Mapping:** Phase 1 (Immediate) - Set up CI checks first

---

### C2: Trait Implementations Living in Core

**What goes wrong:** Core defines a trait and provides "helpful" implementations. These accumulate logic, state, and dependencies.

**Evidence from converge-core:**
- llm.rs has MockProvider with call-counting state
- llm.rs has LlmAgent with prompt building, response parsing
- backend.rs has RetryPolicy, CircuitBreakerConfig with timing

**Prevention:**
1. Trait-Only Rule: Core defines traits, never impl blocks
2. Mock Crate: Create converge-core-test for test utilities
3. Code Review Gate: Block PRs adding impl blocks

**Phase Mapping:** Phase 2 (Extraction) - Move implementations out

---

### C3: No Explicit Purity Contract

**What goes wrong:** Developers have different mental models of "pure." Different interpretations lead to inconsistent decisions.

**Prevention:**
1. Write PURITY.md with ALLOWED/FORBIDDEN lists:
   ```markdown
   ## ALLOWED
   - Type definitions (structs, enums)
   - Trait definitions (no impl blocks)
   - Error types (thiserror-derived)
   - Serialization derives (serde)
   - Pure utility functions (no side effects)

   ## FORBIDDEN
   - Any impl block for trait defined in core
   - Any async fn or Future type
   - Any file/network I/O
   - Any timing/clock access
   - Any random number generation
   ```
2. CI Lint: Script that greps for forbidden patterns
3. Module Docstrings: Each module states purity level

**Phase Mapping:** Phase 1 (Immediate) - Write PURITY.md first

---

### C4: Promotion Gates Bypassed

**What goes wrong:** Core defines proposals must go through validation. But "helpful" APIs let agents create facts directly.

**Evidence from converge-core:**
- Context::add_fact() can be called directly
- AgentEffect::with_facts() takes Vec<Fact> not Vec<ProposedFact>
- Tests use direct fact creation

**Prevention:**
1. Type-Level Enforcement: Make Fact::new() private
2. Proposal-Only Effects: AgentEffect only accepts ProposedFact
3. Sealed Trait Pattern: Fact construction requires sealed trait

**Phase Mapping:** Phase 2 (Type Safety)

---

## Moderate Pitfalls

### M1: Serialization Stability as Afterthought

**What goes wrong:** Minor refactor renames a field, breaking persisted state and wire compatibility.

**Prevention:**
1. Golden Tests: Snapshot tests for every serializable type
2. Explicit Renames: All fields use `#[serde(rename = "...")]`
3. Versioned Enums: Use `#[serde(tag = "version")]`

**Phase Mapping:** Phase 3 (Stabilization)

---

### M2: Capability Crate Coupling Through Core

**What goes wrong:** Core accumulates types from all domains, becoming a coupling point.

**Evidence from converge-core:**
- llm.rs has LLM-specific types (LlmRole, ModelConfig)
- capability.rs has embedding/reranking types
- recall.rs has recall-specific types

**Prevention:**
1. Create converge-types for truly shared types only
2. Type Ownership Audit: Each type has one owning crate

**Phase Mapping:** Phase 2 (Extraction)

---

### M3: Test Utilities Become API Surface

**What goes wrong:** Core provides test helpers that become load-bearing for downstream tests.

**Evidence from converge-core:**
- MockProvider is public
- agents module has test agents that are public

**Prevention:**
1. Create converge-core-test for test utilities
2. Self-Contained Tests: Each crate owns its mocks

**Phase Mapping:** Phase 3 (Stabilization)

---

### M4: Invariant Enforcement at Wrong Layer

**What goes wrong:** Business invariants encoded in core rather than domain crates.

**Evidence from converge-core:**
- ContextKey enum has domain-specific keys (Strategies, Evaluations)
- Comments reference "growth strategy" domain in core

**Prevention:**
1. Core has structural invariants (append-only, convergence)
2. Domain Invariants in domain crates
3. Generic keys, not ContextKey::Strategies

**Phase Mapping:** Phase 2 (Extraction)

---

## Minor Pitfalls

- **m1:** Documentation claims more than code delivers
- **m2:** Feature flag proliferation (core should have none)
- **m3:** Module structure obscures boundaries (18+ modules)

---

## Phase-Specific Warnings

| Phase | Likely Pitfall | Mitigation |
|-------|----------------|------------|
| Phase 1: CI Setup | C1, C3 | Set up checks and PURITY.md first |
| Phase 2: Extraction | C2, M2, M4 | Extract implementations before types |
| Phase 3: Stabilization | M1, C4, M3 | Type-level enforcement, golden tests |

---

## Quick Reference Checklist

Before any PR to converge-core:

- [ ] Does this add a dependency? Check forbidden list
- [ ] Does this add an impl block? Should be in capability crate
- [ ] Does this add a struct with state? Should be in capability crate
- [ ] Does this touch serialization? Check golden tests
- [ ] Does this bypass proposal->fact flow? Verify gate enforcement
- [ ] Does this add domain terminology? Should be in domain crate
- [ ] Does this add async/Future? Forbidden in core

---

## Sources

- Direct codebase analysis of converge-core
- Cargo.toml review
- PROJECT.md requirements
- Observed drift patterns
