# Converge

**Semantic Governance & Alignment for AI-Powered Decision Systems**

> Converge is a vision for **semantic governance**. We move from fragmented intent to unified, converged states through a deterministic alignment engine. Our mission is to provide a stable foundation for complex decision-making where human authority and AI agency coexist in a transparent, explainable ecosystem.

---

## What is Converge?

Converge is an **Agent OS** - an operating system for AI agents that provides:

- **Deterministic Convergence** - Agents reach stable, verifiable states through fixed-point iteration
- **Invariant Enforcement** - Business rules and constraints are guaranteed, not hoped for
- **Semantic Transparency** - Every decision is traceable, auditable, and explainable
- **Human Authority** - AI agency operates within human-defined boundaries

Unlike chatbots or prompt chains, Converge agents operate as a **governance layer** over business processes.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     CONVERGE ECOSYSTEM                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │ converge-core   │◄───│ converge-domain │                    │
│  │ (Engine, Types) │    │ (Business Logic)│                    │
│  └────────┬────────┘    └─────────────────┘                    │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │ converge-llm    │◄───│ converge-provider│                   │
│  │ (Reasoning)     │    │ (API Backends)  │                    │
│  └────────┬────────┘    └─────────────────┘                    │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐                                           │
│  │ converge-runtime│    HTTP / gRPC / SSE                      │
│  │ (Server)        │──────────────────────────►                │
│  └─────────────────┘                                           │
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │ converge-       │    │ converge-ios    │                    │
│  │ application     │    │ converge-android│                    │
│  │ (CLI + Packs)   │    │ (Mobile SDKs)   │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Core Concepts

### The Convergence Engine

The engine runs agents in cycles until a **fixed point** is reached - no new facts are produced. This guarantees:

- **Termination** - All runs eventually complete
- **Stability** - Results don't depend on execution order
- **Monotonicity** - Facts accumulate, never conflict

### Agents

Agents are pure functions: `Context → Vec<Fact>`. They:
- Read from a shared, immutable context
- Produce new facts (or none)
- Have no side effects during computation

### Invariants

Invariants are rules that must hold before convergence is accepted:
- `RequireMultipleStrategies` - Don't converge with a single option
- `BrandSafetyInvariant` - Block outputs violating brand guidelines
- Custom invariants for any business rule

### Facts & Context

Facts are immutable, typed records:
```rust
Fact {
    key: ContextKey::Strategies,
    id: "strategy:growth:aggressive",
    content: "Expand market share through pricing competition",
}
```

The Context is a append-only store organized by semantic keys.

---

## Component Repositories

All component repositories are **private**. To request access for evaluation or collaboration, please contact the author.

### Core Platform

| Repository | Description | Language |
|------------|-------------|----------|
| **converge-core** | Engine, agents, invariants, and core types | Rust |
| **converge-domain** | Business domain models (growth strategy, etc.) | Rust |
| **converge-provider** | LLM backend implementations (Anthropic, OpenAI) | Rust |
| **converge-llm** | Reasoning kernel with prompt contracts | Rust |

### Runtime & Distribution

| Repository | Description | Language |
|------------|-------------|----------|
| **converge-runtime** | HTTP, gRPC, and SSE server | Rust |
| **converge-application** | CLI and domain packs | Rust |
| **converge-optimization** | OR-Tools based constraint optimization | Rust/C++ |

### Mobile & Web

| Repository | Description | Language |
|------------|-------------|----------|
| **converge-ios** | iOS SDK and sample apps | Swift |
| **converge-android** | Android SDK and sample apps | Kotlin |
| **converge-www** | Website and documentation (converge.zone) | TypeScript |

### Experimental & Tools

| Repository | Description | Language |
|------------|-------------|----------|
| **converge-analytics** | Polars-based data analysis | Rust |
| **converge-personas** | AI persona definitions | YAML/Rust |
| **converge-ledger** | Immutable audit logging | Rust |
| **converge-remote** | Remote execution infrastructure | Rust |
| **converge-tool** | CLI tooling and utilities | Rust |

### Business & Strategy

| Repository | Description |
|------------|-------------|
| **converge-business** | Business documentation, knowledgebase, strategy |

---

## Technology Stack

### Rust Core

| Crate | Purpose |
|-------|---------|
| `tokio` | Async runtime |
| `axum` | HTTP framework |
| `tonic` / `prost` | gRPC support |
| `serde` / `serde_json` | Serialization |
| `thiserror` | Error handling |
| `tracing` | Structured logging |
| `rayon` | Parallel computation |
| `proptest` | Property-based testing |
| `burn` | ML/deep learning |
| `polars` | DataFrames |

### Development Tools

- **[Claude Code](https://claude.ai/claude-code)** - Primary development tool
- **[Cursor](https://cursor.com)** - AI-powered IDE
- **[Jujutsu (jj)](https://github.com/martinvonz/jj)** - Git-compatible VCS

---

## Use Cases

### Growth Strategy Generation

Given seed facts about a company (market, size, competitive position), Converge:
1. Gathers market signals
2. Analyzes competitors
3. Generates multiple strategies
4. Evaluates each with rationale
5. Produces a ranked recommendation

All while enforcing brand safety, requiring diversity of options, and ensuring explainability.

### Patent Prior Art Search

Given an invention disclosure, Converge:
1. Builds structured search queries
2. Searches multiple patent databases
3. Collects and ranks relevant prior art
4. Produces a shortlist with evidence

### SDR Pipeline Automation

For sales development, Converge:
1. Ingests lead data
2. Qualifies based on ICP
3. Generates personalized outreach
4. Tracks engagement and iterates

---

## Quick Start

```bash
# Install (when published)
cargo install converge-application

# Start server
converge serve

# Run a job
converge run --template growth-strategy --seeds @seeds.json

# List available templates
converge list-templates
```

---

## Requesting Access

All component repositories are private. To request access:

1. **Email**: kenneth@aprio.one
2. **Subject**: "Converge Access Request"
3. **Include**:
   - Your use case
   - Organization (if applicable)
   - GitHub username for repository access

---

## License

Copyright (c) 2024-2025 Aprio One AB, Sweden

This parent repository (converge.zone) is public for documentation purposes.
All component repositories are proprietary. See individual LICENSE files.

---

## Author

**Kenneth Pernyer**
Founder, Aprio One AB
kenneth@aprio.one

---

*Built with Rust. Powered by determination.*
