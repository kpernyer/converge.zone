# Project Research Summary

**Project:** converge-core v2.0.0 Restoration
**Domain:** Pure Axiomatic Rust Crate
**Researched:** 2026-01-23
**Confidence:** HIGH

## Executive Summary

converge-core is a foundational Rust crate that has accumulated implementation drift — dependencies like `rayon`, `rand`, and `sha2`, plus full LLM implementation code that should live in capability crates. The research reveals a clear restoration path: strip converge-core to pure types, traits, and validation gates, then extract implementations to new capability crates (converge-llm, converge-provider, converge-runtime).

The recommended approach follows the **ProblemSpec → ProposedPlan → SolverReport → PromotionGate** pattern discovered in the optimization work. This pattern generalizes beautifully: Intent → Proposal → Validation → Gate → Fact. Implementing this abstraction as a generic `ProposalLifecycle<I, P, V, F>` type makes the "agents suggest, engine decides" axiom compiler-enforced rather than documentation-enforced.

The critical risk is "just this once" dependency additions and trait implementations creeping back into core. Prevention requires automated enforcement: `cargo-deny` to block forbidden dependencies, CI checks that fail on implementation blocks in core, and a PURITY.md contract that makes boundaries explicit. Developer discipline fails; tooling succeeds.

## Key Findings

### Recommended Stack

converge-core must operate as a pure axiomatic foundation with minimal dependencies. All runtime concerns (async, I/O, parallelism) must be extracted.

**Core technologies:**
- **thiserror 2.0**: Error derivation — zero-cost error types, no runtime allocation
- **serde 1.0 + derive**: Serialization traits — stable, universal, trait-only (no I/O)
- **serde_json 1.0**: JSON serialization — required for stable wire formats
- **tracing 0.1**: Logging facade — facade only, no subscriber in core
- **strum 0.26**: Enum derives — compile-time only, aids serialization

**Dependencies to REMOVE:**
- **rayon**: Parallelism is runtime concern → converge-runtime
- **rand**: Randomness is runtime/test concern → dev-deps or converge-runtime
- **sha2**: Hashing implies computation → define Fingerprint trait, implement elsewhere
- **hex**: Only needed for sha2 → remove with sha2

**Testing infrastructure (dev-dependencies):**
- **proptest 1.5**: Property-based testing for invariants
- **insta 1.39**: Snapshot testing for serialization stability
- **static_assertions 1.1**: Compile-time invariant checks
- **criterion 0.5**: Benchmarking (ensure pure code has no perf regressions)

**CI enforcement:**
- **cargo-deny**: Block forbidden dependencies via deny.toml
- **cargo-nextest**: Fast test execution
- **cargo-semver-checks**: API stability verification

### Expected Features

A pure axiomatic crate provides types, traits, and validation logic — not execution.

**Must have (table stakes):**
- Core type definitions — Context, Fact, ProposedFact, ContextKey
- Trait definitions — Agent, Kernel, Validator, Promoter
- Enum-based state machines — make invalid states unrepresentable
- Error types with context — structured errors for typed handling
- Serialization stability — portable across crate boundaries
- Zero runtime dependencies — compile anywhere
- Pure validation functions — stateless validation logic
- Builder patterns — ergonomic type construction
- Comprehensive documentation — axiom crates must be self-documenting
- Unit tests for invariants — prove the axioms hold

**Should have (differentiators):**
- Proposal lifecycle types — encode "agents suggest, engine decides"
- Promotion gate pattern — abstract the gate from optimization learnings
- Explicit authority grants — no defaults that grant authority
- Replayability honesty — system tells truth about determinism
- Stop reason enumeration — explicit termination reasons (BudgetExhausted, ConvergenceReached)
- TraceLink separation — Local (replay) vs Remote (audit-only)
- Kernel boundary types — constitutional types for all kernels
- Governed artifact lifecycle — typed lifecycle with audit trails
- Invariant classification — categorized governance rules
- Budget types — guarantee termination

**Defer (v2+):**
- Execution logic — belongs in capability crates
- Retry policies with timing — implies scheduling, move to converge-runtime
- Circuit breaker state — runtime state, not types
- Backend routing logic — model selection is implementation
- Async runtime dependency — reduces portability
- HTTP/network types — I/O belongs elsewhere
- Embedding/recall execution — implementation not axiom
- Prompt rendering logic — implementation not axiom

### Architecture Approach

converge-core requires a three-layer architecture: axiomatic types (Layer 1), trait definitions (Layer 2), and gate abstractions (Layer 3). Dependencies flow upward toward core — core never depends on capability crates.

**Major components:**
1. **types/** — Pure data structures: Intent, Context, Policy, Proposal, Trace, Budgets, StopReason, Provenance, Authority, Artifact
2. **traits/** — Interface definitions: Agent, Kernel, Validator, Promoter, Recall, Backend, Store
3. **gates/** — Gate abstractions: ProposalLifecycle<I,P,V,F>, ValidationReport, PromotionGate, Invariant

**The generic gate pattern:**
```rust
ProposalLifecycle<I, P, V, F>:
  intent(I) → IntentPhase
  propose(P, TraceLink) → ProposalPhase
  validate(V) → ValidationPhase
  decide(PromotionGate) → GatePhase
  promote(F) → Fact
```

**Data flow:** Intent flows IN → Proposal flows OUT → Validation happens → Gate decides → Fact flows IN (only if gate approves)

**Boundary enforcement:** Private constructors on Fact (only engine can create), public constructors on Proposal (anyone can propose)

### Critical Pitfalls

1. **"Just this once" dependency additions** — Developer adds `tokio` or `reqwest` "just for this one trait implementation." Prevention: CI enforcement with cargo-deny, explicit BOUNDARY.md, PR template requiring justification for Cargo.toml changes. (Phase 1)

2. **Trait implementations living in core** — Core defines trait and provides "helpful" implementations that accumulate logic, state, dependencies. Evidence: llm.rs has MockProvider with call-counting state, LlmAgent with prompt building. Prevention: Trait-only rule (core defines traits, never impl blocks), create converge-core-test for test utilities, code review gate blocking impl blocks. (Phase 2)

3. **No explicit purity contract** — Developers have different mental models of "pure." Prevention: Write PURITY.md with ALLOWED/FORBIDDEN lists, CI lint that greps for forbidden patterns, module docstrings stating purity level. (Phase 1)

4. **Promotion gates bypassed** — "Helpful" APIs let agents create facts directly, bypassing validation. Evidence: Context::add_fact() can be called directly, AgentEffect::with_facts() takes Vec<Fact> not Vec<ProposedFact>. Prevention: Type-level enforcement with private Fact::new(), Proposal-only effects, sealed trait pattern. (Phase 2)

5. **Serialization stability as afterthought** — Minor refactor renames field, breaking persisted state and wire compatibility. Prevention: Golden tests (snapshot tests for every serializable type), explicit renames with `#[serde(rename = "...")]`, versioned enums. (Phase 3)

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Enforcement Infrastructure
**Rationale:** Set up automated guardrails before making changes. Attempting cleanup without enforcement leads to immediate regression (Pitfall C1, C3).
**Delivers:** CI enforcement, purity contract, dependency bans
**Features:**
- Create PURITY.md with explicit ALLOWED/FORBIDDEN lists
- Configure cargo-deny with deny.toml (ban tokio, async-trait, futures, reqwest, rayon, etc.)
- Add CI workflow that fails on forbidden dependencies
- Add PR template requiring justification for Cargo.toml changes
**Avoids:** C1 (dependency additions), C3 (no explicit contract)
**Research needs:** LOW — standard Rust tooling

### Phase 2: Dependency Cleanup
**Rationale:** Remove forbidden dependencies before extracting implementations. Dependencies create coupling; removing them first clarifies boundaries.
**Delivers:** Clean Cargo.toml with only allowed dependencies
**Features:**
- Remove rayon, rand, sha2, hex from dependencies
- Move rayon to dev-dependencies if needed for benchmarks
- Define Fingerprint trait (abstract sha2 requirement)
- Add proptest, insta, static_assertions to dev-dependencies
**Avoids:** C1 (forbidden dependencies)
**Research needs:** LOW — straightforward dependency removal

### Phase 3: Gate Pattern Implementation
**Rationale:** Implement the generic ProposalLifecycle abstraction before extracting modules. This creates the target architecture that extracted code will use.
**Delivers:** Generic gate pattern, type-level lifecycle enforcement
**Features:**
- Create gates/ module with ProposalLifecycle<I,P,V,F>
- Implement ValidationReport, PromotionGate abstractions
- Add Invariant trait
- Make Fact::new() private, force promotion path
**Uses:** thiserror for gate errors, serde for gate results
**Implements:** Layer 3 (gate abstractions)
**Avoids:** C4 (bypassed promotion gates)
**Research needs:** MEDIUM — generic pattern application, verify with property tests

### Phase 4: Module Restructuring
**Rationale:** Organize existing types/traits into three-layer architecture before extraction. Clear structure prevents accidental coupling during extraction.
**Delivers:** types/, traits/, gates/ module organization
**Features:**
- Reorganize existing files into types/ (context.rs, budgets.rs, stop_reasons.rs, provenance.rs)
- Move trait definitions to traits/ (agent.rs, kernel.rs, validator.rs)
- Keep gates/ from Phase 3
- Update lib.rs re-exports
**Implements:** Layer 1 (types), Layer 2 (traits)
**Avoids:** M2 (coupling through core)
**Research needs:** LOW — file moves, no logic changes

### Phase 5: Implementation Extraction
**Rationale:** Extract implementation code to capability crates now that boundaries are clear and enforced.
**Delivers:** converge-provider, converge-llm, converge-runtime crates
**Features:**
- Extract llm.rs → converge-provider (LlmAgent, MockProvider)
- Extract backend.rs → converge-llm (RetryPolicy, CircuitBreaker, LlmBackend impls)
- Extract capability.rs → converge-provider
- Extract model_selection.rs → converge-provider
- Extract prompt.rs → converge-llm
- Keep trait signatures in converge-core/traits/
**Avoids:** C2 (implementations in core), M2 (coupling)
**Research needs:** MEDIUM — verify capability crate boundaries, ensure clean trait/impl split

### Phase 6: Type Safety Hardening
**Rationale:** Enforce invariants at compile time now that structure is clean. Type-state pattern and sealed traits prevent misuse.
**Delivers:** Type-state proposal lifecycle, sealed traits, compile-time invariants
**Features:**
- Implement type-state pattern for Proposal<Draft> → Proposal<Validated> → Fact
- Seal Agent trait (prevents external implementations)
- Add static_assertions for Send/Sync bounds
- Convert Context::add_fact() to package-private
- Change AgentEffect to only accept ProposedFact
**Avoids:** C4 (bypassed gates), structural invariants
**Research needs:** LOW — standard Rust type-state pattern

### Phase 7: Serialization Stability
**Rationale:** Lock down serialization after structure is stable. Adding golden tests during refactoring creates noise.
**Delivers:** Snapshot tests, explicit serialization contracts
**Features:**
- Add insta snapshot tests for all serializable types
- Add explicit `#[serde(rename = "...")]` to all fields
- Version enums with `#[serde(tag = "version")]`
- Add serde_test roundtrip tests
- Document serialization stability guarantees
**Avoids:** M1 (serialization stability afterthought)
**Research needs:** LOW — standard serde testing patterns

### Phase 8: Documentation & Examples
**Rationale:** Document after structure is stable. Early documentation becomes stale during refactoring.
**Delivers:** Comprehensive API docs, usage examples, migration guide
**Features:**
- Module-level documentation for types/, traits/, gates/
- Example: basic agent implementation (in external crate)
- Example: custom kernel with gate integration
- Migration guide from v1.x to v2.0
- ARCHITECTURE.md documenting three-layer design
**Avoids:** m1 (docs claim more than code delivers)
**Research needs:** LOW — documentation writing

### Phase Ordering Rationale

- **Infrastructure first (Phase 1)** — Prevention tooling before code changes prevents regression
- **Dependencies before extraction (Phase 2)** — Removing dependencies clarifies what needs extraction
- **Gates before restructuring (Phase 3)** — Target architecture must exist before organizing toward it
- **Structure before extraction (Phase 4)** — Clear boundaries prevent accidental coupling
- **Extraction before hardening (Phase 5)** — Can't harden types while implementation code remains
- **Type safety before serialization (Phase 6-7)** — Serialization tests after types are stable
- **Documentation last (Phase 8)** — Document stable, finished architecture

### Research Flags

Phases needing deeper research during planning:
- **Phase 3 (Gate Pattern):** Generic trait design, verify pattern with property tests, ensure no accidental runtime coupling
- **Phase 5 (Extraction):** Capability crate boundaries, trait/impl split verification, workspace configuration

Phases with standard patterns (skip research-phase):
- **Phase 1 (Enforcement):** cargo-deny is well-documented
- **Phase 2 (Dependency Cleanup):** Straightforward Cargo.toml changes
- **Phase 4 (Restructuring):** File moves, standard module organization
- **Phase 6 (Type Safety):** Type-state pattern is established Rust idiom
- **Phase 7 (Serialization):** insta and serde_test are standard tools
- **Phase 8 (Documentation):** Documentation writing

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Current Cargo.toml provides baseline, forbidden dependencies clear from PROJECT.md |
| Features | HIGH | PROJECT.md nine tenets provide explicit requirements, current codebase shows what to remove |
| Architecture | HIGH | Three-layer pattern verified in converge-optimization, gate pattern proven |
| Pitfalls | HIGH | Evidence drawn directly from codebase analysis, prevention strategies proven in Rust ecosystem |

**Overall confidence:** HIGH

### Gaps to Address

- **Generic gate ergonomics:** ProposalLifecycle<I,P,V,F> may be verbose for consumers. Consider type aliases or builder pattern. Validate ergonomics with example usage in Phase 3.

- **Capability crate naming/organization:** Need to determine exact split between converge-llm, converge-provider, converge-runtime during Phase 5. May discover during extraction that different boundaries make more sense.

- **Migration path for existing consumers:** If any downstream crates depend on current converge-core API, breaking changes in v2.0 need documented migration. Assess during Phase 4 restructuring.

- **Test utilities location:** Decision between converge-core-test crate vs examples/ directory. Standard pattern is separate -test crate, but examples/ may suffice if utilities are minimal.

## Sources

### Primary (HIGH confidence)
- Current converge-core codebase — direct analysis of Cargo.toml, lib.rs, modules
- PROJECT.md — explicit requirements, nine tenets, purity constraints
- converge-optimization gate pattern — proven abstraction pattern

### Secondary (MEDIUM confidence)
- Rust API Guidelines — trait design, error handling, type-state patterns
- cargo-deny documentation — dependency enforcement patterns
- Rust ecosystem best practices — serde stability, proptest usage

### Tertiary (LOW confidence)
- None — all findings backed by codebase evidence or established Rust patterns

---
*Research completed: 2026-01-23*
*Ready for roadmap: yes*
