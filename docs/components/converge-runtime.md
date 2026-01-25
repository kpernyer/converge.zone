# converge-runtime

**The Server Layer**

## Purpose

converge-runtime provides HTTP, gRPC, and Server-Sent Events (SSE) interfaces for running Converge flows. It exposes the convergence engine as network services: submit jobs, stream progress, query results, and monitor health.

## Why It Matters

Converge is not a library you embed; it's an operating system for commitments. Operating systems need runtime infrastructure:

- **Job Submission**: POST a job with seeds and template, get back a run ID
- **Progress Streaming**: SSE stream of facts as they're produced
- **Result Retrieval**: Query the final converged state
- **Health/Readiness**: Kubernetes-compatible probes for orchestration

The runtime makes Converge deployable as a service, not just a CLI tool.

## Place in the Platform

converge-runtime is the network boundary of the platform:

```
External Clients (Web, Mobile, CLI)
    ↑
converge-runtime  ←── HTTP/gRPC/SSE server
    ↑
converge-domain + converge-llm (business logic + reasoning)
    ↑
converge-core (engine)
```

The application layer (converge-application) embeds the runtime for the `converge serve` command. Mobile SDKs (converge-ios, converge-android) call the runtime over HTTP.

## Key Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Health check |
| `/ready` | GET | Readiness probe |
| `/api/v1/jobs` | POST | Submit a job |
| `/api/v1/jobs/:id` | GET | Get job result |
| `/api/v1/jobs/:id/stream` | GET (SSE) | Stream job progress |

## Flow Templates

The runtime exposes flows as **templates**:

- `growth-strategy`: Market signals → Strategies → Evaluations
- `drafting-short`: Research → Compose (Perplexity + Anthropic)
- `novelty-search`: Patent query → Search → Prior art shortlist
- `patent-research`: Full invention capture → Claim strategy → Spec draft

Templates are the unit of deployment. Each template references a Gherkin spec for semantics and a wiring file for runtime requirements.

## Governance Alignment

The runtime enforces **operational consistency**. Every job submission creates:

- A unique run ID for tracing
- Structured logging with tracing spans
- Deterministic execution (same seeds → same results)
- Audit-ready output (facts, cycles, convergence status)

This is how Converge ensures that commitments are replayable and defensible, not just "what the model said."
