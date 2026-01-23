# converge-core v2.0.0 Restoration

## What This Is

Restoration of converge-core to its pure, portable, axiomatic foundation. converge-core defines the minimal mathematical and architectural foundations that all other Converge crates build upon — without importing their complexity, dependencies, or runtime concerns. This is the constitution, not the government.

## Core Value

**converge-core encodes Converge's axioms as testable invariants and provides stable, portable interfaces for all capability crates to build upon.**

If everything else fails, converge-core must remain pure: no I/O, no runtime behavior, no implementation logic — only types, traits, and promotion gates.

## Requirements

### Validated

Existing converge-core capabilities that work and must be preserved:

- Engine convergence loop (deterministic fixed-point execution)
- Context and Fact types (append-only truth)
- Agent trait definition
- Invariant system (runtime governance rules)
- Effect-based isolation (agents emit effects, never mutate directly)

### Active

Restoration work for v2.0.0:

- [ ] **PURE-01**: Remove modules that perform/imply model execution, prompt orchestration, recall execution, backend routing, persistence, or network I/O
- [ ] **PURE-02**: Replace removed modules with traits + portable types in core, implementations living elsewhere
- [ ] **TYPE-01**: Consolidate canonical types — kernel boundary types (intent/context/policy/proposal)
- [ ] **TYPE-02**: Consolidate proposal lifecycle types with explicit promotion gates
- [ ] **TYPE-03**: Consolidate trace link shape and replayability honesty (no providers, just policy/provenance/stop reasons)
- [ ] **GATE-01**: Enforce promotion path — no API allows Facts to leak from tools/agents
- [ ] **GATE-02**: Every Fact creation requires ValidationReport + explicit Promotion act
- [ ] **GATE-03**: Abstract gate pattern from optimization learnings (ProblemSpec → ProposedPlan → SolverReport → PromotionGate)
- [ ] **TEST-01**: Serialization stability tests for stop reasons, replayability, provenance envelopes
- [ ] **TEST-02**: Invariant tests proving "cannot promote without validation"
- [ ] **TEST-03**: Invariant tests proving "facts are append-only"
- [ ] **TEST-04**: Property-based tests for determinism guarantees
- [ ] **CI-01**: Add boundary violation checks (forbidden deps, forbidden module patterns)
- [ ] **CI-02**: Fail fast when drift is reintroduced

### Out of Scope

- OR-Tools bindings, CP-SAT models, routing algorithms, schedulers — belong in converge-optimization
- LLM execution, prompt stacks, model routing, embedders, recall providers — belong in converge-llm/converge-provider
- Servers, networking, containers, gRPC, HTTP — belong in converge-runtime
- DB drivers, vector DB clients, file persistence — belong in converge-provider
- Domain packs, JTBD definitions — belong in converge-domain
- "Helpful" defaults that bypass explicit authority — forbidden everywhere

## Context

### Why Now

Converge expanded rapidly into capability crates:
- converge-analytics: Polars/Burn pipeline for ML resolution in agent flows
- converge-llm: Local inference, adapters/LoRA, semantic recall — became powerful fast, concepts not fully proven
- converge-optimization: Mathematical foundation (CP-SAT, routing, scheduling) revealed cleaner gate patterns

The optimization work was pivotal — it almost rebuilt core inside converge-optimization. The gate pattern (ProblemSpec → ProposedPlan → SolverReport → PromotionGate) is fundamental and should be abstracted into core as generic types.

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
- No async runtimes required

**Forbidden:**
- tokio, reqwest, axum, tonic, prost
- Burn / llama-burn / fastembed
- Polars / Arrow / LanceDB clients
- DB drivers (SurrealDB, Postgres, etc.)

Rule: If a module implies execution, I/O, network, model inference, or persistence, it does not belong in core.

### Reference Document

Full restoration instructions: `converge-platform/converge-core/JOBS.md`

## Constraints

- **Purity**: No I/O, no runtime behavior, no implementation logic in core
- **Portability**: Core must compile without heavy dependencies
- **Stability**: Serialization formats must remain stable for downstream crates
- **Backward Compatibility**: Minimize breaking changes to downstream crates during migration

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Abstract gate pattern into core | Optimization work proved this is fundamental, not solver-specific | — Pending |
| Traits over implementations | Core defines surfaces, capability crates implement | — Pending |
| Proposal → Validation → Promotion lifecycle | Only valid authority path, no bypassing | — Pending |
| Forbidden dependency list | Prevents drift back into impurity | — Pending |

---
*Last updated: 2026-01-23 after initialization*
