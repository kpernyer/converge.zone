# JOBS.md — converge-core Restoration and Forward Contract

## Purpose

This file is the operating instruction for all agent work in converge-core.

**Goal:** restore and protect the original vision: converge-core is pure, portable, and axiomatic. It defines the minimal mathematical / architectural foundations that all other Converge crates build upon—without importing their complexity, dependencies, or runtime concerns.

> **converge-core is the constitution, not the government.**

---

## What Converge Is

Converge is a governed system for agentic automation where:
- Models and tools suggest.
- The engine decides only by explicit validation and promotion.
- Truth is append-only and traceable.
- Execution is legible, bounded, and auditable.

Converge is not "AI that can talk." It is systems that can run work without silently taking authority.

---

## The Nine Non-Negotiable Design Tenets

These are the axioms converge-core exists to encode, enforce, and protect:

1. **Explicit Authority**
   No defaults that grant authority. Authority is always explicit, typed, and traceable.

2. **Convergence Over Control Flow**
   We converge on outcomes via governed proposals, not ad-hoc loops or hidden heuristics.

3. **Append-Only Truth**
   Facts are never mutated. Corrections are new facts.

4. **Agents Suggest, Engine Decides**
   Agents emit proposals; promotion requires validation gates (and sometimes humans).

5. **Safety by Construction**
   Make invalid states unrepresentable. Prefer types over conventions.

6. **Transparent Determinism**
   The system tells the truth about replayability and determinism. No "TraceLink + hope."

7. **Human Authority First-Class**
   There are explicit pause/approve gates for consequential actions.

8. **No Hidden Work**
   No silent background effects, retries, implicit state changes, or shadow decisioning.

9. **Scale by Intent Replication**
   Scale by replicating intent and invariants across domains—without central mutable magic.

These are not "values." They are contract surfaces we can test and enforce.

---

## What Changed Since converge-core Was First Designed

Converge expanded rapidly into multiple real subsystems:
- **converge-business / converge-domain**: many more JTBD packs, blueprints, invariants, evals.
- **converge-runtime**: services, servers, networks, docker/k8s, REST/OpenAPI, gRPC.
- **mobile apps**: clients now, eventual ambition to run converge-platform on-device.
- **converge-analytics**: Polars/Burn pipeline; inference and some training.
- **converge-llm**: local inference, adapters/LoRA, semantic recall, RAG thinking, trace links.
- **converge-optimization**: mathematically grounded solvers for routing/scheduling; exposed a clearer multi-backend agent flow (remote LLM, local LLM, solver libraries).
- **converge-provider**: swappable integration boundary for external systems and APIs.
- **converge-application track** (emerging): "app drivers" and composed flows that combine domain packs + runtime + providers.

This growth surfaced architecture drift: concepts and implementation logic leaked into converge-core, and duplication appeared across crates.

**This sprint is about making the vision true again.**

---

## converge-core: What It Is (and Must Remain)

### converge-core IS
- A pure crate containing:
  - Axioms as types and invariants
  - The proposal → validation → promotion lifecycle
  - Minimal interfaces/traits that other crates implement
  - Portable provenance and trace semantics (shape only)
- Typed boundaries for:
  - authority
  - determinism/replayability honesty
  - budgets/stop reasons
  - append-only truth

### converge-core IS NOT
- An execution engine for LLMs or solvers
- A prompt stack, model router, embedder, recall provider, or backend implementation
- A runtime (servers, network, docker, k8s, gRPC, HTTP)
- A storage layer (DB drivers, vector DB clients, file persistence)
- A domain pack library (JTBD definitions belong to converge-domain)
- A place for "helpful" defaults that bypass explicit authority

---

## Dependency and Purity Rules (Hard Constraints)

### Allowed dependencies (examples)
- error handling, serialization, basic utilities:
  - `thiserror`, `tracing`, `serde`, `serde_json`
- small pure libs (hashing ok if required for portable fingerprints)
- no async runtimes required

### Forbidden in converge-core
- Any heavy or runtime deps:
  - `tokio`, `reqwest`, `axum`, `tonic`, `prost`
  - `Burn` / `llama-burn` / `fastembed`
  - `Polars` / `Arrow` / `LanceDB` clients
  - DB drivers (`SurrealDB`, `Postgres`, etc.)
- Any implementation modules with I/O side effects

**Rule:** If a module implies execution, I/O, network, model inference, or persistence, it does not belong in core.

---

## The Architectural Shape: The Only Valid Authority Path

### The core boundary that must never be bypassed
- LLMs, solvers, retrieval, and tools can output only: `Proposed*` artifacts
- Only validators (and explicit human gates) can promote proposals into `Facts`

### Canonical lifecycle:
1. Agent/tool emits `ProposedFact` (or `ProposedPlan`, `ProposedDecision`, etc.)
2. Validation runs (invariants, contracts, solver report checks, grounding rules)
3. Promotion occurs explicitly:
   - `Proposed*` → `Fact` (append-only)
   - or rejection / escalation / halt with stop reason

**If any subsystem can output `Fact` without a promotion gate, the architecture is broken.**

---

## What We Learned from converge-optimization (and How It Should Influence Core)

Optimization work clarified a reusable "gate" pattern that Converge should treat as first-class in abstract:

```
ProblemSpec → ProposedPlan → SolverReport → PromotionGate
```

This is valuable in converge-core only as generic types and invariants, not as solver bindings.

### What belongs in core from this learning
- Abstract types/interfaces:
  - `ProblemSpec` (pure, serializable)
  - `ProposedPlan` (proposal artifact)
  - `SolverReport` (evidence-like report, still not a Fact)
  - `GateDecision` / `PromotionDecision`
- Stop reasons and budgets for solver gating
- Determinism honesty:
  - "replayable vs audit-only" applies equally to solvers and remote LLMs

### What does NOT belong in core
- OR-Tools bindings, CP-SAT models, routing algorithms, schedulers, etc.

---

## Tracks and Responsibility Boundaries (Holistic View)

Agents working on converge-core must understand the whole system, but design core as if it were the only crate shipped.

| Track | Responsibility |
|-------|----------------|
| **converge-provider** | Implements provider traits, connects to external systems, brings context |
| **converge-domain** | Encodes "Jobs to be Done" as executable packs (Gherkin/Converge Truths + YAML → Rust artifacts). Owns domain invariants and eval logic |
| **converge-application** | Orchestrates flows across domain packs and capabilities. Composes solutions |
| **converge-runtime** | Manages servers/services/networking, container and cluster concerns |
| **converge-llm / converge-analytics / converge-optimization** | Implement heavy logic (inference, recall, LoRA, analytics, solvers). Must consume core interfaces, not push their implementation back into core |

---

## Do / Don't for Agents Working in converge-core

### DO
- Reduce core to:
  - minimal types
  - portable traits
  - invariants and state machines
  - explicit authority and promotion boundaries
- Prefer:
  - clear enums over magic strings
  - deterministic serialization formats
  - stable API shapes
- Add tests that prove axioms:
  - "cannot promote without validation"
  - "facts are append-only"
  - "stop reasons serialize stably"
  - "replayability is honest and explicit"
- Make it easy for other crates to implement:
  - providers, LLM backends, solvers, stores

### DO NOT
- Import "convenient" runtime behavior into core
- Add default authority, implicit promotions, silent retries
- Add heavyweight dependencies "just for convenience"
- Copy modules from converge-llm into core; core should define surfaces, not systems
- Let core become "a second converge-llm"

---

## Jobs for This converge-core Sprint

### Job 1 — Restore Purity
- Identify and remove any modules that perform or imply:
  - model execution, prompt orchestration, recall execution, backend routing, persistence, network I/O
- Replace with:
  - traits + portable types in core
  - implementations living elsewhere

### Job 2 — Consolidate Canonical Types
Move/keep in core only:
- kernel boundary types (intent/context/policy/proposal)
- proposal lifecycle types
- trace link shape and replayability honesty
- recall types that are portable (policy/provenance/stop reasons) — no providers

### Job 3 — Enforce Promotion Path
- Ensure no API design allows "Facts" to leak from tools/agents
- Ensure every "Fact creation" requires:
  - `ValidationReport` (or equivalent)
  - explicit Promotion act

### Job 4 — Stabilize Contracts
- Serialization stability tests for:
  - stop reasons
  - replayability and downgrade reasons
  - provenance envelopes
- Prevent breaking downstream crates unnecessarily

### Job 5 — Guardrails in CI
- Add boundary violation checks:
  - forbid listed deps
  - forbid certain module names/patterns in core
- Fail fast when someone reintroduces drift

---

## Output Expectations

When agent work is "done" for converge-core, we should be able to say:
- converge-core compiles fast, stays small, and is dependency-light.
- converge-core encodes Converge's axioms as testable invariants.
- converge-core provides stable, portable interfaces for:
  - providers
  - LLM backends
  - recall stores
  - solver gates
  - domain packs
  - application orchestrators
- All capability crates can evolve independently without core absorbing their complexity.

---

## Review Checklist (Agent Must Self-Certify)

Before proposing a PR to converge-core, the agent must answer:

1. Did I add any new dependency? If yes, is it absolutely necessary and purity-safe?
2. Did I accidentally introduce I/O or runtime behavior?
3. Does this change strengthen explicit authority and promotion gates?
4. Can an external crate implement this trait cleanly without importing heavy deps?
5. Is replayability/determinism truthfully represented?
6. Are there tests proving the intended invariant, not just "code coverage"?

**If any answer is unclear, the change is not ready.**

---

## North Star: The Product View (Why This Matters)

Converge's product-market fit is **trustworthy automation**: one system that can run meaningful work for a user or business because it is governed, legible, auditable, and safe-by-construction.

converge-core is the deep foundation that allows everything else to scale—domain packs, mobile, runtime, LLM kernels, solvers—without collapsing into "wild agents."

> **Autonomy is cheap. Trust is engineered.**
> converge-core is where that engineering starts.
