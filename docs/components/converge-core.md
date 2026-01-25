# converge-core

**The Convergence Engine**

## Purpose

converge-core is the foundational crate that implements the deterministic convergence engine. It provides the core abstractions: `Engine`, `Agent`, `Invariant`, `Context`, and `Fact`. This is where the fixed-point iteration algorithm lives—the mechanism that runs agents in cycles until no new facts are produced and all invariants hold.

## Why It Matters

In a commitment-based business operating system, the engine is the enforcement layer. It guarantees that:

- **Termination**: Every flow eventually reaches a stable state
- **Determinism**: Same inputs produce same outputs, enabling replay and audit
- **Invariant Enforcement**: Business rules are checked before any commitment is accepted
- **Monotonicity**: Facts accumulate without contradiction; the system never silently reverts

Without a deterministic engine, you have a chatbot. With it, you have institutional infrastructure.

## Place in the Platform

converge-core sits at the bottom of the dependency graph. Every other Rust crate depends on it:

```
converge-core
    ↑
    ├── converge-domain (business logic)
    ├── converge-provider (LLM backends)
    ├── converge-llm (reasoning kernel)
    └── converge-runtime (server)
         ↑
         └── converge-application (distribution)
```

The engine doesn't know about HTTP, LLMs, or specific business domains. It only knows how to run agents until convergence and enforce invariants. This separation is deliberate: the governance mechanism is independent of the content being governed.

## Key Types

| Type | Role |
|------|------|
| `Engine` | Runs the convergence loop |
| `Agent` | Pure function: Context → Vec<Fact> |
| `Invariant` | Predicate that must hold for commitment |
| `Context` | Immutable, append-only fact store |
| `Fact` | Typed record with key, id, and content |
| `ContextKey` | Semantic category (Seeds, Signals, Strategies, etc.) |

## Governance Alignment

The engine implements the core governance primitive: **promotion semantics**. Facts don't appear by magic; they are produced by agents and survive invariant checks. This is how Converge enforces the rule that proposals must pass gates before becoming commitments.
