# converge-application

**The Distribution Layer**

## Purpose

converge-application is the user-facing distribution of Converge. It packages the CLI (`converge` command), domain packs, LLM provider configurations, and the runtime server into a single installable binary. This is what users install and run.

## Why It Matters

A platform is only as good as its distribution. converge-application makes Converge:

- **Installable**: `cargo install converge-application`
- **Runnable**: `converge serve`, `converge run`, `converge eval`
- **Configurable**: Environment-based provider selection, template choice
- **Testable**: Built-in eval framework for reproducible testing

This is the interface between Converge as infrastructure and Converge as a product.

## Place in the Platform

converge-application sits at the top of the Rust dependency graph:

```
converge-application  ←── User-facing CLI + server
    ↑
    ├── converge-runtime (HTTP/gRPC)
    ├── converge-domain (business packs)
    ├── converge-llm (reasoning)
    └── converge-provider (LLM backends)
         ↑
         └── converge-core (engine)
```

Everything flows up to the application layer, which assembles the platform into a coherent product.

## Key Commands

| Command | Purpose |
|---------|---------|
| `converge serve` | Start HTTP server |
| `converge run` | Run a job from CLI |
| `converge eval run` | Run evaluation fixtures |
| `converge eval list` | List available evals |
| `converge list-templates` | Show available flow templates |

## Domain Packs

The application bundles domain packs:

- **growth-strategy**: SMB/Enterprise growth planning
- **sdr-pipeline**: Sales development automation
- **drafting-short**: Research + composition
- **patent-research**: Prior art and claim strategy

Packs are the unit of business capability. Each pack includes agents, invariants, and eval fixtures.

## Eval Framework

```bash
# Run all evals
converge eval run

# Run specific eval
converge eval run growth_strategy_smb_001
```

Evals are reproducible tests that verify:
- Convergence within cycle limits
- Required facts are produced
- Invariants hold
- Latency bounds are met

## Governance Alignment

The application layer enforces **institutional reliability** at the product level:

- Templates define what commitments are possible
- Evals prove that flows produce correct results
- Configuration controls which providers and policies apply
- The CLI provides a stable interface for automation

This is how Converge becomes operational infrastructure, not a demo.
