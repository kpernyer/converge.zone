# converge-domain

**Business Domain Models**

## Purpose

converge-domain contains the typed business logic that defines what commitments mean in specific domains. It provides domain-specific agents, invariants, and fact types for use cases like growth strategy generation, SDR pipeline automation, and quote-to-close workflows.

## Why It Matters

The engine (converge-core) is domain-agnostic. It knows how to run convergence but not what "a valid strategy" or "an approved quote" means. converge-domain is where institutional knowledge becomes code:

- **Domain Agents**: MarketSignalAgent, CompetitorAgent, StrategyAgent, EvaluationAgent
- **Domain Invariants**: BrandSafetyInvariant, RequireMultipleStrategies, RequireEvaluationRationale
- **Domain Facts**: Signals, Strategies, Evaluations with typed schemas

This is where "business rules" stop being documentation and become enforcement.

## Place in the Platform

converge-domain depends only on converge-core and provides domain content to higher layers:

```
converge-core
    ↑
converge-domain  ←── Business knowledge lives here
    ↑
converge-application (packages domains as "packs")
```

When you run `converge run --template growth-strategy`, the application loads agents and invariants from converge-domain. The domain crate is the authoritative source of what each workflow means.

## Key Modules

| Module | Content |
|--------|---------|
| `growth_strategy` | SMB/Enterprise growth planning |
| `sdr_pipeline` | Sales development automation |
| `quote_to_close` | Pricing, approval, invoice matching |
| `patent_research` | Prior art search and claim strategy |

## Governance Alignment

Domain invariants encode the institutional rules for each commitment type:

- `RequireMultipleStrategies`: Never converge with a single option (prevents premature closure)
- `RequireEvaluationRationale`: Every scored option must have explicit justification
- `BrandSafetyInvariant`: Block outputs that violate brand guidelines

These invariants are the **gate logic** for domain-specific flows. They make "converged enough to commit" a design choice, not a model confidence score.
