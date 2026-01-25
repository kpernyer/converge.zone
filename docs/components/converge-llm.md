# converge-llm

**The Reasoning Kernel**

## Purpose

converge-llm implements the reasoning kernel: the contracts, structures, and validation logic that turn raw LLM outputs into governed proposals. It provides `PromptStack` (structured prompt layers), `InferenceEnvelope` (reproducibility contracts), `OutputContract` (expected output shapes), and validation logic.

## Why It Matters

"Why not just use OpenAI?" is a category error. Models generate text; businesses require **promotion semantics**—proposal → validated → committed—under explicit authority and policy gates.

converge-llm exists to make LLM reasoning:

- **Reproducible**: Same prompt + same seed = same output (when deterministic)
- **Auditable**: Every inference has a versioned prompt, parameters, and trace
- **Validated**: Outputs are checked against contracts before becoming facts
- **Bounded**: Prompts have explicit layers, not unbounded "context windows"

This is the difference between *using* intelligence and *engineering* intelligence.

## Place in the Platform

converge-llm is the reasoning layer between providers and domain logic:

```
converge-provider (API backends)
    ↑
converge-llm  ←── Reasoning contracts live here
    ↑
converge-domain (business agents use reasoning)
    ↑
converge-application
```

Domain agents that need LLM reasoning call through converge-llm contracts, not raw provider APIs. This ensures all reasoning is structured, versioned, and auditable.

## Key Concepts

### The Five-Layer PromptStack

```
[Model Priming]      ← rarely changes, encodes identity
[Role / Policy]      ← stable, versioned, per-deployment constraints
[Task Frame]         ← per capability/agent
[State Injection]    ← structured data (NOT narrative)
[User Intent]        ← thin, minimal
```

### Output Contracts

| Contract | Use Case |
|----------|----------|
| `Reasoning` | Derive conclusions with explicit steps |
| `Planning` | Produce ordered action steps |
| `Evaluation` | Score options with confidence and rationale |
| `Classification` | Assign categories |
| `Extraction` | Pull structured data |

### Reproducibility

```rust
// Deterministic: greedy + fixed seed = reproducible
let envelope = InferenceEnvelope::deterministic("reasoning:v1", 42);
assert!(envelope.is_deterministic());
```

## Governance Alignment

The reasoning kernel implements **bounded rationality** as software. Organizations don't optimize globally; they satisfice under constraints. converge-llm makes those constraints explicit:

- Prompts are versioned and bound to model lineage
- Outputs must match declared contracts
- Inference parameters are captured for replay
- "Confidence" is a structured claim, not a magic number

This is how Converge treats LLM reasoning as a governed subprocess, not an oracle.
