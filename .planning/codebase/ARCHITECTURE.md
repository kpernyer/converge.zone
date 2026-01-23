# Architecture

**Analysis Date:** 2026-01-23

## Pattern Overview

**Overall:** Semantic Convergence Engine - A deterministic multi-agent runtime where agents collaborate through shared context rather than direct calls.

**Key Characteristics:**
- Context-driven architecture: Agents depend on typed context keys, not each other
- Fixed-point convergence: Engine runs until no agent produces new facts
- Deterministic execution: Same input always produces same output (reproducible and auditable)
- Effect-based isolation: Agents emit effects, never mutate shared state directly
- Layered semantic governance: From core runtime through domain-specific business logic

## Layers

**converge-core (Runtime & Governance):**
- Purpose: Provides the deterministic convergence engine, context model, and agent trait
- Location: `converge-platform/converge-core/src/`
- Contains: Engine, Context, Agent trait, Invariants, Validation
- Depends on: tokio, serde, thiserror, rayon
- Used by: converge-provider, converge-domain, converge-application

**converge-provider (LLM & Capability Abstraction):**
- Purpose: Unified interface for 14+ LLM providers and capability backends (embedding, reranking, graph, vector stores)
- Location: `converge-platform/converge-provider/src/`
- Contains: Anthropic, OpenAI, Gemini, Ollama adapters; embedding/reranking/graph/vector integrations
- Depends on: converge-core, tokio, reqwest, serde_json
- Used by: converge-domain, converge-application, converge-llm

**converge-domain (Business Domains):**
- Purpose: 12+ domain packs with deterministic + LLM-enabled agents for real business workflows
- Location: `converge-platform/converge-domain/src/`
- Contains: growth-strategy, sdr-sales, patent-research, travel, form-filling, supply-chain, inventory, etc.
- Depends on: converge-core, converge-provider
- Used by: converge-application

**converge-application (Distribution & Packaging):**
- Purpose: Deployable product that selects domain packs, configures providers, sets runtime defaults
- Location: `converge-application/src/`
- Contains: CLI, TUI (ratatui), agent orchestration, streaming outputs
- Depends on: converge-core, converge-llm, converge-provider, converge-domain (git submodules)
- Used by: converge-runtime (HTTP wrapper)

**converge-platform/experience-store (Artifact Governance):**
- Purpose: Time-series event store for tracking governed artifact lifecycle (contracts, proposals, rollbacks)
- Location: `converge-platform/experience-store/src/`
- Contains: EventQuery, TimeRange, PolicySnapshot, ContractResultSnapshot
- Depends on: converge-core
- Used by: converge-application for audit trails

**converge-platform/converge-business (Partner Workspace):**
- Purpose: Knowledge base, blueprints, specs, research for domain packs
- Location: `converge-platform/converge-business/`
- Contains: markdown specs, business workflows, personas, evaluation criteria
- Depends on: None (reference documentation)
- Used by: Domain architects, documentation

**converge-www (Marketing Website):**
- Purpose: React + TypeScript marketing site for converge.zone
- Location: `converge-www/src/`
- Contains: Landing pages, demos, documentation, podcast integration
- Depends on: React 19, React Router, marked, zod, dompurify
- Used by: Public visitors

**converge-runtime (Server Wrapper):**
- Purpose: HTTP/gRPC server that wraps converge-application
- Location: `converge-runtime/src/`
- Contains: Server, proto definitions, terraform deployment
- Depends on: converge-application
- Used by: Remote clients, Docker deployment

**converge-llm (Model Training & Fine-tuning):**
- Purpose: Local and remote LLM model handling, adapter layers for model selection
- Location: `converge-llm/src/`
- Contains: Model adapters, tokenization, prompting strategies
- Depends on: burn, converge-core
- Used by: converge-application, converge-provider

**converge-ledger (Elixir Audit Trail):**
- Purpose: Immutable ledger for all contract executions and decisions
- Location: `converge-ledger/lib/`
- Contains: Elixir contracts, transaction storage
- Depends on: Phoenix (optional)
- Used by: Audit compliance, replaying decisions

**Mobile Clients (iOS/Android):**
- Purpose: Native mobile interfaces to Converge runtime
- Location: `converge-ios/`, `converge-android/`
- Contains: Native UI, API clients
- Depends on: (iOS) Swift, (Android) Kotlin
- Used by: Mobile users

## Data Flow

**Job Execution Flow:**

1. **Intent Setup** - User defines RootIntent with seeds, constraints, success criteria
2. **Context Initialization** - Engine creates Context with seed facts added
3. **Agent Registration** - Application registers agents in dependency order
4. **Convergence Loop** (repeated until fixed point):
   - Engine selects eligible agents (those whose dependencies changed)
   - Agents execute in parallel via rayon
   - Effects are collected and serialized by AgentId
   - New facts are validated against invariants
   - Proposed facts are promoted to facts if valid
   - Context updated with merged effects
   - Streaming callback notifies CLI/UI of new facts
5. **Termination** - Fixed point reached (no new facts) or budget exhausted
6. **Result Export** - Final context serialized and sent to client/storage

**Request Path (converge-application CLI):**

1. User invokes: `converge run --template growth-strategy --seeds '[]'`
2. CLI parser (clap) routes to Commands::Run handler (`src/main.rs`)
3. Config loaded from environment + .env
4. LLM providers initialized (AnthropicProvider, OpenAiProvider, etc.)
5. Domain pack agents registered (e.g., MarketSignalAgent → CompetitorAgent → StrategyAgent)
6. Engine created with budget limits
7. RootIntent converted to initial Context
8. Engine.run() called with streaming callback to TUI
9. TUI (ratatui) renders facts as they arrive
10. Final context returned and serialized to JSON

**Provider Selection Flow (in converge-provider):**

1. Agent requests LLM capability (e.g., language_model with gpt-4)
2. ModelSelector evaluates SelectionCriteria (cost, latency, jurisdiction, complexity)
3. Registry lookup returns candidate models
4. Capability registry checks available providers
5. Provider adapter creates request (system prompt, messages, temperature)
6. HTTP/API call to external service (Anthropic, OpenAI, etc.)
7. Response parsed, cost/usage tracked
8. Fact emitted with result

**State Management:**

- **Mutable State**: Only Engine owns mutable state (fact storage, cycle counter)
- **Read-Only Sharing**: Context is Arc-wrapped for read-only access to agents
- **Effect Merging**: Each agent produces AgentEffect (facts + diagnostics), merged serially
- **Convergence Detection**: Fixed point = no new facts added in cycle

## Key Abstractions

**Agent (converge-core):**
- Purpose: Represents a semantic capability that observes context and emits effects
- Files: `converge-core/src/agent.rs`, domain-specific implementations in `converge-domain/src/`
- Pattern: Trait with name(), dependencies(), accepts(), execute() methods
- Example: `MarketSignalAgent` in `converge-domain/src/growth_strategy.rs`

**Context (converge-core):**
- Purpose: Shared, immutable, typed state of a job
- Files: `converge-core/src/context.rs`
- Pattern: HashMap of ContextKey → Vec<Fact>, append-only
- ContextKey enum: Seeds, Hypotheses, Strategies, Constraints, Signals, Competitors, Evaluations, Proposals, Diagnostic

**Engine (converge-core):**
- Purpose: Coordinates agent execution and convergence
- Files: `converge-core/src/engine.rs`
- Pattern: Registers agents, builds dependency index, runs convergence loop with rayon parallelism

**Invariant (converge-core):**
- Purpose: Runtime governance rule (e.g., "all strategies must have evaluations")
- Files: `converge-core/src/invariant.rs`
- Pattern: Trait with validate(context) → Result, compiled from Gherkin specs
- Example: `BrandSafetyInvariant` in `converge-domain/src/growth_strategy.rs`

**Fact & ProposedFact (converge-core):**
- Purpose: Strongly typed assertion vs LLM output (prevent accidental trust)
- Files: `converge-core/src/context.rs`
- Pattern: Fact is trusted; ProposedFact requires validation before promotion
- Key pattern: ProposedFact has confidence field; Fact is authoritative

**Domain Pack (converge-domain):**
- Purpose: Bundled set of agents + invariants for a business workflow
- Files: `converge-domain/src/growth_strategy.rs`, `sdr_sales.rs`, `patent_research.rs`, etc.
- Pattern: Agents form a pipeline; invariants enforce business rules
- Variants: Deterministic (hardcoded logic) + LLM (uses language_model capability)

**Backend (converge-core):**
- Purpose: Unified interface for local/remote LLM execution
- Files: `converge-core/src/backend.rs`
- Pattern: Trait with execute(request) → Response; implements retry + circuit breaker

**Model Selector (converge-provider):**
- Purpose: Route requests to appropriate LLM based on task complexity, cost, jurisdiction
- Files: `converge-provider/src/model_selection.rs`
- Pattern: SelectionCriteria struct maps to available models; registry tracks costs

## Entry Points

**converge-application CLI:**
- Location: `converge-application/src/main.rs`
- Triggers: User runs `converge run`, `converge packs list`, `converge eval`
- Responsibilities: Parse CLI args, load config, register agents, run engine, render results

**converge-www Frontend:**
- Location: `converge-www/src/main.tsx`
- Triggers: Browser opens converge.zone
- Responsibilities: Render landing page, demo request form, podcast player

**converge-runtime HTTP Server:**
- Location: `converge-runtime/src/main.rs` (implied, server wrapper)
- Triggers: HTTP POST to /execute endpoint
- Responsibilities: Accept job intent, delegate to converge-application, stream results

**converge-ledger Elixir Service:**
- Location: `converge-ledger/lib/` (implied, audit service)
- Triggers: Contract executed, needs recording
- Responsibilities: Log contract result, enforce immutability

## Error Handling

**Strategy:** Multi-level error types with clear recovery semantics

**Patterns:**

- **Propagation via Result**: All fallible operations return Result<T, Error>
- **Custom Error Types**: thiserror-derived enums (ConvergeError, BackendError, InvariantError)
- **Invariant Violations**: Not fatal; recorded as Diagnostic facts for agent inspection
- **Agent Panics**: Caught at engine boundary; fact emission fails gracefully
- **Budget Exhaustion**: Forced termination; converged=false returned to indicate incomplete state
- **LLM Failures**: Retry policy (exponential backoff) + circuit breaker; fallback to hardcoded strategy
- **Validation Failures**: ProposedFact rejected; not merged into Context
- **File I/O**: Config loading panics if critical files missing; streaming output is best-effort

## Cross-Cutting Concerns

**Logging:**
- Framework: tracing (structured logging)
- Approach: Engine emits Diagnostic facts for user-visible events; tracing spans for internal flow
- Key instrumentation: `engine.rs` spans on_cycle_start, on_cycle_end; agent execution

**Validation:**
- Framework: converge-core/src/validation.rs (ValidationAgent trait)
- Approach: Invariants validate facts before merge; ProposedFact requires explicit promotion
- Key pattern: Gherkin specs compiled to InvariantRegistry; runtime enforcement via engine

**Authentication:**
- Approach: None in converge-application CLI; converge-runtime handles HTTP auth
- Secrets: Env vars for LLM API keys (ANTHROPIC_API_KEY, OPENAI_API_KEY, etc.)

**Observability:**
- Experience Store: `experience-store/src/` tracks artifact lifecycle (state transitions, rollbacks)
- Audit Trail: All effects merged into context; convergence replay-deterministic
- Convergence Callback: StreamingCallback trait for real-time fact emission to UI

---

*Architecture analysis: 2026-01-23*
