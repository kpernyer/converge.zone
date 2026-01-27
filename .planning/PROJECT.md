# converge-core

## What This Is

A pure, portable, axiomatic foundation crate for the Converge platform. converge-core defines the minimal mathematical and architectural foundations that all other Converge crates build upon — without importing their complexity, dependencies, or runtime concerns. This is the constitution, not the government.

**Current state:** v1.0.0 shipped with 22,853 lines of Rust across 47 source files. Type-state enforcement, capability boundary traits, and comprehensive property-based testing in place.

## Core Value

**converge-core encodes Converge's axioms as testable invariants and provides stable, portable interfaces for all capability crates to build upon.**

If everything else fails, converge-core must remain pure: no I/O, no runtime behavior, no implementation logic — only types, traits, and promotion gates.

## Requirements

### Validated

Shipped in v1.0.0:

- ✓ Engine convergence loop (deterministic fixed-point execution) — existing
- ✓ Context and Fact types (append-only truth) — existing
- ✓ Agent trait definition — existing
- ✓ Invariant system (runtime governance rules) — existing
- ✓ Effect-based isolation (agents emit effects, never mutate directly) — existing
- ✓ Type-state Proposal pattern (Draft → Validated) — v1.0.0
- ✓ Private-constructor Fact (promotion is only path) — v1.0.0
- ✓ ProposalLifecycle trait with ValidationReport proof objects — v1.0.0
- ✓ Capability boundary traits (LlmBackend, Recall, ExperienceStore, Validator, Promoter) — v1.0.0
- ✓ cargo-deny enforcement (16 forbidden crate bans) — v1.0.0
- ✓ Property-based tests for invariants — v1.0.0
- ✓ Serialization stability with insta snapshots — v1.0.0
- ✓ Nine design tenets documented in crate docs — v1.0.0

### Active

(To be defined in next milestone)

### Out of Scope

- OR-Tools bindings, CP-SAT models, routing algorithms, schedulers — belong in converge-optimization
- LLM execution, prompt stacks, model routing, embedders, recall providers — belong in converge-llm/converge-provider
- Servers, networking, containers, gRPC, HTTP — belong in converge-runtime
- DB drivers, vector DB clients, file persistence — belong in converge-provider
- Domain packs, JTBD definitions — belong in converge-domain
- "Helpful" defaults that bypass explicit authority — forbidden everywhere

## Context

### Current State (v1.0.0)

**Tech stack:** Rust with thiserror, serde, serde_json, tracing, typed-builder, hex
**Testing:** proptest, insta, static_assertions, trybuild
**CI:** cargo-deny, cargo-semver-checks

**Codebase:**
- 47 Rust source files
- 22,853 lines of Rust
- 39 requirements verified with code evidence
- Property-based tests proving "cannot promote without validation" and "facts are append-only"

**Known technical debt:**
- 518 clippy warnings (pre-existing)
- cargo fmt formatting differences (pre-existing)
- Deprecated implementations not yet extracted to capability crates

### The Nine Non-Negotiable Design Tenets

These are axioms converge-core exists to encode, enforce, and protect:

1. **Explicit Authority** — No defaults that grant authority. Authority is always explicit, typed, and traceable.
2. **Convergence Over Control Flow** — We converge on outcomes via governed proposals, not ad-hoc loops or hidden heuristics.
3. **Append-Only Truth** — Facts are never mutated. Corrections are new facts.
4. **Agents Suggest, Engine Decides** — Agents emit proposals; promotion requires validation gates (and sometimes humans).
5. **Safety by Construction** — Make invalid states unrepresentable. Prefer types over conventions.
6. **Transparent Determinism** — The system tells the truth about replayability and determinism.
7. **Human Authority First-Class** — Explicit pause/approve gates for consequential actions.
8. **No Hidden Work** — No silent background effects, retries, implicit state changes, or shadow decisioning.
9. **Scale by Intent Replication** — Scale by replicating intent and invariants across domains.

### Dependency Rules (Hard Constraints)

**Allowed:**
- thiserror, tracing, serde, serde_json
- Small pure libs (hashing ok for portable fingerprints)
- hex (for ContentHash serialization)
- No async runtimes required

**Forbidden:**
- tokio, reqwest, axum, tonic, prost
- Burn / llama-burn / fastembed
- Polars / Arrow / LanceDB clients
- DB drivers (SurrealDB, Postgres, etc.)
- rayon, rand, sha2

Rule: If a module implies execution, I/O, network, model inference, or persistence, it does not belong in core.

## Constraints

- **Purity**: No I/O, no runtime behavior, no implementation logic in core
- **Portability**: Core must compile without heavy dependencies
- **Stability**: Serialization formats must remain stable for downstream crates
- **Backward Compatibility**: Minimize breaking changes to downstream crates during migration

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Abstract gate pattern into core | Optimization work proved this is fundamental, not solver-specific | ✓ Good — ProposalLifecycle trait implemented |
| Traits over implementations | Core defines surfaces, capability crates implement | ✓ Good — All capability traits defined |
| Proposal → Validation → Promotion lifecycle | Only valid authority path, no bypassing | ✓ Good — Type-state enforced |
| Forbidden dependency list | Prevents drift back into impurity | ✓ Good — cargo-deny enforcing 16 bans |
| Type-state for Proposal | Compile-time enforcement of Draft→Validated flow | ✓ Good — Cannot bypass validation |
| ValidationToken ZST | Unforgeable proof at zero runtime cost | ✓ Good — No overhead |
| GAT async for capability traits | Zero-cost static dispatch, future-proof for async | ✓ Good — ChatBackend, EmbedBackend use pattern |
| Git-based cargo-semver-checks | Compare against main branch, not crates.io | ✓ Good — Works pre-publication |

---
*Last updated: 2026-01-27 after v1.0.0 milestone*
