# Converge

**A Business Operating System for Responsible Commitment**

> Converge is not "AI for tasks." It is an operating system for business commitments. Businesses do not win because a model completes a task; they win because they make reliable commitments under uncertainty—and those commitments survive time, personnel changes, audits, and stress.

---

## The Thesis

The core unit of value is a **commitment**: a quote that binds commercial terms, a contract that creates obligations, an invoice that asserts a claim, a hiring decision that creates legal and financial duties. These are not just artifacts; they are institutional acts that need authority, traceability, and repeatability.

Converge exists to govern how those commitments are made.

That is why Converge measures progress by **ambiguity reduction**, not steps completed. A flow is successful when uncertainty collapses responsibly into a decision that is ownable, auditable, and operationally consistent across systems.

**The business claim is clear**: Converge operationalizes responsible commitments under uncertainty, not clever text. It turns ambiguity into governed decisions through structured doubt, explicit phases, and gate-based promotion.

This is why "why not just use OpenAI?" is a category error: models generate proposals; businesses require **promotion semantics**—proposal → validated → committed—under explicit authority and policy gates.

---

## Converge as Institutional Design

Converge is institutional design expressed as software. It treats the business as a commitment system, not a queue of tasks.

The platform shift follows enterprise history:
- **SAP** operationalized transactions
- **Salesforce** operationalized configurable workflows
- **Converge** operationalizes responsible commitments under uncertainty

The differentiation is not "smarter models." It is **institutional reliability**:

| Question | Converge Answer |
|----------|-----------------|
| Who can authorize this commitment? | Authority roles: Advisory, Supervisory, Participatory, Sovereign |
| Which constraints are binding? | Invariants checked before commitment |
| What tension must be surfaced? | Tension phase is required work, not dysfunction |
| What counts as converged enough? | Explicit stopping rules, not model confidence |
| Can we replay and audit later? | Full decision trail in converge-ledger |
| Can this adapt to company logic? | Flow taxonomy and gate selection |

---

## Academic Backbone

The positioning is not a brand posture; it is aligned with research on how organizations actually decide and survive.

### Bounded Rationality (Herbert Simon)
Organizations do not optimize globally; they **satisfice** under constraints of time, attention, and information. Converge is a procedure designer: it structures how evidence, constraints, and authority collapse into commitment.

### Wicked Problems (Rittel & Webber)
Many business decisions have no definitive formulation and no true/false outcome. The stopping point is a governance decision. Converge makes **stopping rules explicit and first-class**.

### Decision Psychology (Kahneman, Janis)
Humans converge too early; groups suppress tension to preserve cohesion. Converge encodes a **tension phase as required work**, not dysfunction, and treats dissent as an institutional artifact.

### Institutional Economics (Coase, Ostrom)
Firms exist because governance reduces transaction costs. Converge is **polycentric governance expressed as software**, where gates, authority, and audit are the institutional mechanism.

### Uncertainty Typologies (Dewulf & Biesbroek)
Uncertainty has natures (epistemic, ontological, ambiguity) and objects (substantive, strategic, institutional). Converge maps these to **gate selection and flow tuning**, preventing "everything is reasoning."

---

## Technical Mechanics

The system encodes ambiguity collapse as typed transitions with explicit gates, not as "model confidence."

### The Six Phases

Every converging flow passes through:

```
Intent → Framing → Exploration → Tension → Convergence → Commitment
```

Skipping phases creates oscillation or brittleness. Each phase has explicit stop conditions.

### Promotion Semantics

Core invariant—proposals are not facts:

```
Observation → ProposedFact → Fact
Draft → Validated → Fact
CorrectionEvent for revisions, never silent edits
```

### Gate Primitives

| Gate | Enforces |
|------|----------|
| Frame Gate | Intent and bounds |
| Evidence Gate | Provenance |
| Consistency Gate | Contradiction search |
| Robustness Gate | Scenario tests |
| Stakeholder Gate | Alignment |
| Policy Gate | Compliance, budgets |
| Optimization Gate | Feasibility/optimality |
| Approval Gate | Human authority |

### Human Roles as Authority

| Role | Meaning |
|------|---------|
| Advisory | Can suggest, cannot commit |
| Supervisory | Can approve within bounds |
| Participatory | Part of human decision process |
| Sovereign | Full autonomous authority (rare) |

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

## Component Repositories

All component repositories are **private**. Each implements a specific part of the commitment operating system.

### Core Platform

| Repository | Summary |
|------------|---------|
| [**converge-core**](docs/components/converge-core.md) | The deterministic convergence engine. Runs agents in cycles until fixed-point, enforces invariants before commitment. The foundation everything else builds on. |
| [**converge-domain**](docs/components/converge-domain.md) | Business domain models—agents, invariants, and fact types for growth strategy, SDR pipeline, quote-to-close. Where institutional knowledge becomes enforcement code. |
| [**converge-provider**](docs/components/converge-provider.md) | LLM backend implementations for Anthropic, OpenAI, and others. Abstracts vendor APIs behind the ChatProvider trait. Models are interchangeable; governance is not. |
| [**converge-llm**](docs/components/converge-llm.md) | The reasoning kernel. Prompt contracts, reproducibility envelopes, output validation. Makes LLM reasoning auditable, versioned, and bounded—not an oracle, a governed subprocess. |

### Runtime & Distribution

| Repository | Summary |
|------------|---------|
| [**converge-runtime**](docs/components/converge-runtime.md) | HTTP, gRPC, and SSE server. Exposes the engine as network services—submit jobs, stream progress, query results. Makes Converge deployable as infrastructure. |
| [**converge-application**](docs/components/converge-application.md) | The user-facing CLI and domain packs. What you install and run. Packages everything into `converge serve` and `converge run` with built-in eval framework. |
| [**converge-optimization**](docs/components/converge-optimization.md) | CP-SAT/MILP constraint optimization via OR-Tools. For problems where reasoning fails: scheduling, allocation, routing. Used only behind an Optimization Gate when justified. |

### Mobile & Web

| Repository | Summary |
|------------|---------|
| [**converge-ios**](docs/components/converge-ios.md) | Native Swift SDK for iOS. Async/await, Combine, offline queuing, Keychain storage. Brings full governance to mobile approval workflows. |
| [**converge-android**](docs/components/converge-android.md) | Native Kotlin SDK for Android. Coroutines, Flow, Room persistence, WorkManager sync. Enterprise mobile with the same governance guarantees. |
| [**converge-www**](docs/components/converge-www.md) | The converge.zone website. Documentation, examples, API reference. The public face of the platform. |

### Infrastructure & Tools

| Repository | Summary |
|------------|---------|
| [**converge-analytics**](docs/components/converge-analytics.md) | Polars-based data analysis. Computes metrics, detects patterns, prepares structured data for reasoning. Evidence for the Evidence Gate. |
| [**converge-ledger**](docs/components/converge-ledger.md) | Immutable audit log. Every fact, gate, and commitment recorded. Tamper-evident, replayable, compliant. Audit by construction, not afterthought. |
| [**converge-personas**](docs/components/converge-personas.md) | AI persona definitions. Not personalities—governance configs. Authority levels, constraints, policy bindings. Makes "the AI said" into "the Strategic Analyst agent, under Policy v2.3, said." |
| [**converge-remote**](docs/components/converge-remote.md) | Remote execution infrastructure. Distribute flows across cloud functions, edge nodes, worker pools. Scale without compromising governance. |
| [**converge-tool**](docs/components/converge-tool.md) | CLI utilities for operators. Inspect contexts, validate flows, test agents, manage config. Makes the system observable, not a black box. |

### Business & Strategy

| Repository | Summary |
|------------|---------|
| [**converge-business**](docs/components/converge-business.md) | Business documentation—knowledgebase, strategy, ADRs, collaboration guides. The "why" behind the "what." Institutional design in documentation form. |

---

## Flow Examples

### Quote-to-Close

A convergence machine, not a document generator:
- Enforces pricing constraints
- Routes approvals by authority level
- Matches invoices to quotes
- Records learning loop

### Governance Gates

Institutional proof—policy as code:
- Approvals as automation
- Budget enforcement
- Compliance checks
- Audit by construction

Together they show the thesis: **commitment promotion is the product, not the text.**

---

## Quick Start

```bash
# Install (when published)
cargo install converge-application

# Start server
converge serve

# Run a job
converge run --template growth-strategy --seeds @seeds.json

# List templates
converge list-templates
```

---

## The Final Positioning

Converge is a **business operating system for responsible commitment**. It does not compete with foundation models; it governs them.

- Models produce proposals
- Converge governs promotion into commitment
- Through explicit phases, gates, authority, and audit

This is why Converge remains defensible even as models improve: **institutions still need rules, enforcement, and traceability.**

The ultimate claim is measurable:
- Reduce ambiguity
- Reduce leakage
- Reduce disputes
- Speed approvals
- Enforce policy

Across tools and across time. That is the business operating system view, backed by academic grounding and implemented as a technical enforcement layer.

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

*Institutional design expressed as software.*
