# Codebase Structure

**Analysis Date:** 2026-01-23

## Directory Layout

```
converge.zone/
├── converge-platform/                    # Core platform (Rust workspace)
│   ├── Cargo.toml                        # Workspace manifest (4 crates)
│   ├── converge-core/                    # Runtime engine (proprietary)
│   │   └── src/
│   │       ├── lib.rs                    # Core exports
│   │       ├── engine.rs                 # Convergence loop (primary)
│   │       ├── agent.rs                  # Agent trait definition
│   │       ├── context.rs                # Context & Fact types
│   │       ├── effect.rs                 # AgentEffect type
│   │       ├── invariant.rs              # Runtime governance rules
│   │       ├── validation.rs             # Validation agents
│   │       ├── backend.rs                # LLM backend interface
│   │       ├── llm.rs                    # LLM provider abstraction
│   │       ├── model_selection.rs        # Cost/latency routing
│   │       ├── kernel_boundary.rs        # Constitutional kernel types
│   │       ├── governed_artifact.rs      # Lifecycle state machines
│   │       ├── recall.rs                 # Memory/retrieval systems
│   │       ├── root_intent.rs            # Job intent structure
│   │       ├── capability.rs             # Embedding/graph/vector abstractions
│   │       ├── integrity.rs              # Audit trail verification
│   │       ├── experience_store.rs       # Bridge to ExperienceStore
│   │       └── prompt.rs                 # Prompt templates & formatting
│   ├── converge-provider/                # 14+ LLM providers (MIT)
│   │   └── src/
│   │       ├── lib.rs                    # Provider exports
│   │       ├── anthropic.rs              # Anthropic SDK adapter
│   │       ├── openai.rs                 # OpenAI SDK adapter
│   │       ├── gemini.rs                 # Google Gemini adapter
│   │       ├── ollama.rs                 # Local Ollama adapter
│   │       ├── openrouter.rs             # OpenRouter aggregator
│   │       ├── deepseek.rs, baidu.rs, qwen.rs, zhipu.rs  # International providers
│   │       ├── factory.rs                # Provider instantiation
│   │       ├── model_selection.rs        # Model routing logic
│   │       ├── registry_loader.rs        # Dynamic provider registry
│   │       ├── contract.rs               # Contract result tracking
│   │       ├── common.rs                 # Shared LLM request/response
│   │       ├── prompt.rs                 # Prompt formatting for providers
│   │       ├── capability_registry.rs    # Capability discovery
│   │       ├── embedding/                # Embedding providers
│   │       ├── reranker/                 # Reranking providers
│   │       ├── vector/                   # Vector store integrations
│   │       ├── graph/                    # Graph DB integrations
│   │       ├── llm/                      # LLM model adapters
│   │       ├── tools/                    # Tool integrations (LinkedIn, Patent, etc.)
│   │       └── linkedin.rs, patent.rs    # Domain-specific tools
│   ├── converge-domain/                  # 12+ domain packs (MIT)
│   │   └── src/
│   │       ├── lib.rs                    # Domain exports & module list
│   │       ├── growth_strategy.rs        # Growth market analysis (deterministic)
│   │       ├── growth_strategy_llm.rs    # Growth with LLM variant
│   │       ├── sdr_sales.rs              # Sales qualification pipeline
│   │       ├── supply_chain.rs           # Supply chain optimization
│   │       ├── inventory_rebalancing.rs  # Multi-region inventory
│   │       ├── strategic_sourcing.rs     # Vendor selection
│   │       ├── catalog_enrichment.rs     # Data enrichment
│   │       ├── crm_account_health.rs     # CRM insights
│   │       ├── compliance_monitoring.rs  # Regulatory checks
│   │       ├── hr_policy_alignment.rs    # HR policy compliance
│   │       ├── release_readiness.rs      # Engineering gates
│   │       ├── meeting_scheduler.rs      # Constraint satisfaction
│   │       ├── patent_research.rs        # Patent landscape analysis
│   │       ├── travel.rs                 # Travel booking workflow
│   │       ├── form_filler.rs            # Form field population
│   │       ├── drafting.rs               # Document drafting
│   │       ├── ask_converge.rs           # Grounded Q&A
│   │       ├── evals.rs                  # Evaluation criteria (56KB+)
│   │       ├── blueprints/               # Pre-configured workflows
│   │       ├── packs/                    # Sub-packs (patent, dossier, signal, etc.)
│   │       ├── retrieval.rs              # Recall strategies
│   │       ├── llm_utils.rs              # Shared LLM utilities
│   │       └── *_llm.rs                  # LLM variants of domain packs
│   ├── converge-business/                # Documentation & specs
│   │   ├── blueprints/                   # Workflow templates
│   │   ├── knowledgebase/                # Business rules & specs
│   │   ├── packs/                        # Domain pack specifications
│   │   ├── research/                     # Market & technical research
│   │   ├── specs/                        # Formal workflow specs
│   │   └── assets/, docs/, flows/, gtm/  # Supporting materials
│   ├── experience-store/                 # Time-series event store (MIT)
│   │   └── src/                          # Artifact lifecycle tracking
│   └── docs/                             # Architecture documentation
├── converge-application/                 # Distribution layer (Rust)
│   ├── Cargo.toml                        # App-specific manifest
│   ├── src/
│   │   ├── main.rs                       # CLI entry point (primary)
│   │   ├── agents.rs                     # Application-level agents
│   │   ├── config.rs                     # Configuration loading
│   │   ├── packs.rs                      # Domain pack selection
│   │   ├── evals.rs                      # Evaluation orchestration
│   │   ├── streaming.rs                  # Result streaming to TUI
│   │   └── ui/                           # Ratatui TUI components
│   ├── docs/                             # Application documentation
│   ├── evals/                            # Evaluation test cases
│   ├── examples/                         # Usage examples
│   ├── university-course-application/    # Demo use case
│   └── formfiller/                       # Form-filling demo
├── converge-runtime/                     # HTTP/gRPC wrapper (Rust)
│   ├── src/                              # Server implementation
│   ├── proto/                            # gRPC protobuf definitions
│   ├── docker/                           # Docker images
│   ├── terraform/                        # IaC deployment
│   └── templates/                        # Job templates
├── converge-www/                         # Marketing website (React/TypeScript)
│   ├── src/
│   │   ├── main.tsx                      # Vite entry point
│   │   ├── app/
│   │   │   ├── App.tsx                   # Root component
│   │   │   ├── Layout.tsx                # Page layout wrapper
│   │   │   ├── Header.tsx, Footer.tsx    # Shell components
│   │   │   ├── Hero.tsx                  # Hero section
│   │   │   ├── Features.tsx              # Features showcase
│   │   │   ├── Axioms.tsx                # Platform axioms
│   │   │   ├── Install.tsx               # Installation guide
│   │   │   ├── components/               # Reusable components
│   │   │   │   ├── Terminal.tsx          # Terminal emulator
│   │   │   │   ├── DemoRequest.tsx       # Demo signup form
│   │   │   │   ├── ErrorBoundary.tsx     # Error handling
│   │   │   │   ├── EpisodePlayer.tsx     # Podcast player
│   │   │   │   └── EditorialSpotlight.tsx # Content blocks
│   │   │   ├── pages/                    # Route pages
│   │   │   │   ├── Home.tsx              # Homepage
│   │   │   │   ├── Demo.tsx              # Demo sandbox
│   │   │   │   ├── Podcast.tsx           # Podcast hub
│   │   │   │   ├── Signals.tsx           # Signal examples
│   │   │   │   ├── Runtime.tsx           # Runtime info
│   │   │   │   ├── Domain.tsx            # Domain pack browser
│   │   │   │   ├── Tools.tsx             # Tool showcase
│   │   │   │   ├── Manifesto.tsx         # Platform manifesto
│   │   │   │   └── DemoTravel.tsx        # Travel demo
│   │   │   ├── hooks/                    # Custom React hooks
│   │   │   │   ├── useSignals.ts         # Signal management
│   │   │   │   └── useValidateRules.ts   # Validation logic
│   │   │   ├── data/                     # Static content
│   │   │   │   ├── demoContent.ts        # Demo data
│   │   │   │   ├── podcastEpisodes.ts    # Podcast metadata
│   │   │   │   └── articles.ts           # Blog/content list
│   │   │   ├── App.module.css            # Root styles
│   │   │   └── Layout.module.css         # Layout styles
│   │   └── main.tsx                      # Vite bootstrap
│   ├── public/                           # Static assets (images, favicon)
│   ├── dist/                             # Build output (generated)
│   ├── functions/                        # Firebase Cloud Functions
│   ├── scripts/                          # Build & deploy scripts
│   │   ├── generate-rss.ts               # RSS feed generation
│   │   └── podcast-runner.ts             # Podcast integration
│   ├── package.json                      # Dependencies (React 19, TypeScript 5.8)
│   └── vite.config.ts                    # Vite configuration (Firebase deploy)
├── converge-llm/                         # Model training (Rust)
│   ├── src/                              # Model adapters
│   ├── adapters/                         # Provider adapters
│   ├── models/                           # Pre-trained models
│   ├── data/                             # Training datasets
│   ├── benches/                          # Performance benchmarks
│   └── truths/                           # Ground truth evaluations
├── converge-ledger/                      # Audit ledger (Elixir)
│   ├── lib/converge_ledger/              # Elixir source
│   ├── config/                           # Config files
│   ├── priv/                             # Private assets
│   └── test/                             # Elixir tests
├── converge-optimization/                # OR-Tools bindings (Rust)
│   ├── src/                              # Solver interfaces
│   ├── ortools/, ortools-sys/            # Native bindings
│   └── examples/                         # Optimization demos
├── converge-remote/                      # Remote execution (Rust)
│   ├── src/                              # Remote job runner
│   └── proto/                            # RPC definitions
├── converge-tool/                        # Utility CLI (Rust)
│   ├── src/                              # Tool implementations
│   └── examples/                         # Usage examples
├── converge-analytics/                   # Analytics & metrics (Rust)
│   ├── src/                              # Analysis code
│   ├── datasets/                         # Test data
│   └── models/                           # Metric models
├── converge-personas/                    # User personas & contracts
│   ├── personas/                         # User profiles
│   ├── evals/                            # Persona evaluation
│   └── contracts/                        # Behavioral contracts
├── converge-ios/                         # iOS client (Swift)
│   ├── ConvergeMobile/                   # App source
│   ├── ConvergeMobileTests/              # Tests
│   └── ConvergeMobile.xcodeproj/         # Xcode project
├── converge-android/                     # Android client (Kotlin)
│   ├── app/                              # Android app
│   ├── gradle/                           # Build config
│   └── config/                           # Gradle config
└── converge-business/                    # Business materials (symlink to platform)
    ├── assets/, docs/, blueprints/, etc.
```

## Directory Purposes

**converge-platform/converge-core:**
- Purpose: The deterministic convergence engine and core types
- Contains: Engine, Agent trait, Context, Fact, Invariant, Backend interface
- Key files: `engine.rs` (convergence loop), `agent.rs` (agent trait), `context.rs` (typed state)
- Generated: No
- Committed: Yes (proprietary)

**converge-platform/converge-provider:**
- Purpose: 14+ LLM provider adapters and capability backends
- Contains: Anthropic, OpenAI, Gemini, Ollama, Deepseek, Baidu, etc.; embedding, reranking, vector, graph
- Key files: `model_selection.rs` (routing logic), `factory.rs` (instantiation), individual provider files
- Generated: No
- Committed: Yes (MIT licensed)

**converge-platform/converge-domain:**
- Purpose: Business domain packs with agents and invariants
- Contains: 12+ use cases (growth-strategy, sdr-sales, patent-research, travel, etc.); blueprints; evals
- Key files: Individual pack files (growth_strategy.rs, sdr_sales.rs, etc.), evals.rs (56KB evaluation criteria)
- Generated: No
- Committed: Yes (MIT licensed)

**converge-application/src:**
- Purpose: Deployable CLI application that packages platform components
- Contains: CLI entry point, config loading, agent orchestration, TUI rendering
- Key files: `main.rs` (primary), `agents.rs` (app-level agents), `ui/` (ratatui components)
- Generated: No (binary output in target/)
- Committed: Yes

**converge-www/src:**
- Purpose: React marketing website for converge.zone
- Contains: Landing page, demos, documentation, podcast integration
- Key files: `app/App.tsx` (root), pages/ (route components), components/ (reusable UI)
- Generated: dist/ (from build)
- Committed: Yes (source)

**converge-runtime/src:**
- Purpose: HTTP/gRPC server wrapper around converge-application
- Contains: Server handlers, proto definitions, deployment manifests
- Generated: target/ (binary), docker images
- Committed: Yes (source)

**converge-ledger/lib:**
- Purpose: Immutable audit ledger for contract execution
- Contains: Elixir contracts, transaction storage
- Generated: No
- Committed: Yes

## Key File Locations

**Entry Points:**
- `converge-application/src/main.rs`: CLI entry point, Commands enum routes to execution
- `converge-www/src/main.tsx`: Vite React app entry point
- `converge-runtime/src/main.rs` (implied): HTTP server startup
- `converge-ledger/lib/converge_ledger.ex`: Elixir application entry

**Configuration:**
- `converge-platform/Cargo.toml`: Workspace manifest with 4 member crates
- `converge-application/Cargo.toml`: App-specific dependencies (ratatui, clap, tokio)
- `converge-www/package.json`: React/TypeScript dependencies
- `converge-www/vite.config.ts`: Build configuration (Firebase deployment)
- `converge-application/.env.example`: Environment variable template
- `converge-platform/.env`: LLM provider API keys

**Core Logic:**
- `converge-platform/converge-core/src/engine.rs`: Convergence loop (primary architectural implementation)
- `converge-platform/converge-core/src/context.rs`: Context & Fact types
- `converge-platform/converge-core/src/agent.rs`: Agent trait definition
- `converge-platform/converge-core/src/invariant.rs`: Runtime governance rules
- `converge-platform/converge-provider/src/model_selection.rs`: Cost/latency-based routing
- `converge-platform/converge-domain/src/growth_strategy.rs`: Example domain pack (agent pipeline)

**Testing:**
- `converge-platform/converge-core/src/engine.rs` (lines 450+): Unit tests for engine
- `converge-platform/converge-domain/src/stress_tests.rs`: Domain-level convergence tests
- `converge-application/evals/`: Evaluation test cases
- `converge-www/src/__tests__/` (implied): Component tests

## Naming Conventions

**Files:**
- Rust: `snake_case.rs` for modules; crates use kebab-case (converge-core, converge-provider)
- TypeScript: `PascalCase.tsx` for React components, `camelCase.ts` for utilities
- Elixir: `snake_case.ex` or `snake_case.exs`
- Proto: `snake_case.proto`

**Directories:**
- Workspace crates: `converge-{domain}` (converge-core, converge-application, converge-www)
- Rust modules: `snake_case/` (src/embedding/, src/llm/, src/tools/)
- React components: PascalCase/ or per-feature (src/app/components/, src/app/pages/)

**Functions/Types:**
- Agent implementations: `[Domain]Agent` (MarketSignalAgent, CompetitorAgent, StrategyAgent)
- Invariants: `[Concept]Invariant` (BrandSafetyInvariant, GroundedAnswerInvariant)
- Context keys: `[Noun]` (Seeds, Hypotheses, Strategies, Signals, Evaluations)
- Provider modules: `provider_name.rs` (anthropic.rs, openai.rs, ollama.rs)
- LLM variant modules: `{domain}_llm.rs` (growth_strategy_llm.rs, sdr_sales_llm.rs)

## Where to Add New Code

**New Domain Pack:**
- Primary code: `converge-platform/converge-domain/src/{domain_name}.rs`
  - Define agents (struct + Agent impl)
  - Define invariants (struct + Invariant impl)
  - Create pipeline in module documentation
- LLM variant: `converge-platform/converge-domain/src/{domain_name}_llm.rs`
- Export in: `converge-platform/converge-domain/src/lib.rs`
- Tests: Co-locate in domain file or `converge-platform/converge-domain/src/stress_tests.rs`
- Specification: `converge-platform/converge-business/specs/{domain_name}.md`

**New LLM Provider:**
- Implementation: `converge-platform/converge-provider/src/{provider_name}.rs`
- Adapter module: Follow anthropic.rs pattern (client initialization, request translation, response parsing)
- Registry update: `converge-platform/converge-provider/src/factory.rs` (factory pattern)
- Model selection: Add cost tier + latency metrics to `model_selection.rs`
- Tests: Unit tests in provider file; integration tests in converge-application/evals/

**New Website Page:**
- Component: `converge-www/src/app/pages/{PageName}.tsx`
- Route: Register in router (likely in App.tsx or Layout.tsx)
- Styles: Co-locate or use module CSS (PageName.module.css)
- Data: Add to `converge-www/src/app/data/` if static content
- Tests: `converge-www/src/app/pages/{PageName}.test.tsx` (if testing)

**New Agent for Application:**
- Implementation: `converge-application/src/agents.rs` or new module
- Registration: Add to Commands::Run handler in `main.rs`
- Config: Environment variables in `.env.example`
- Streaming: Emit facts via AgentEffect; engine callback handles UI updates

**Utilities & Helpers:**
- Shared Rust utilities: `converge-platform/converge-core/src/` (if fundamental) or within domain/provider
- Shared TypeScript utilities: `converge-www/src/app/hooks/` (React hooks) or `converge-www/src/app/utils/` (standalone)
- Shared data: `converge-www/src/app/data/` for static content

## Special Directories

**converge-platform/converge-business:**
- Purpose: Knowledge base and specification documents
- Generated: No
- Committed: Yes
- Contains: Blueprints, specs, research, personas, GTM materials
- Note: Used as reference by architects; not executed

**converge-www/dist:**
- Purpose: Build output (generated JavaScript, CSS, HTML)
- Generated: Yes (from Vite build)
- Committed: No (in .gitignore)

**converge-application/target:**
- Purpose: Rust build artifacts
- Generated: Yes (from cargo build)
- Committed: No (in .gitignore)

**converge-www/functions:**
- Purpose: Firebase Cloud Functions (serverless)
- Generated: No (authored)
- Committed: Yes
- Role: Backend for demo signup, webhook handlers

**converge-platform/converge-core/tests/**
- Purpose: Integration tests for core engine
- Generated: No (authored)
- Committed: Yes
- Pattern: Tests use converge-domain agents to validate convergence

---

*Structure analysis: 2026-01-23*
