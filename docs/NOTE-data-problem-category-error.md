# The "Data Problem" Is Three Problems Wearing a Trenchcoat

## The Claim

Many smart people say the biggest problem in AI is data. Data engineering itself is not the hard theoretical problem. Pipelines, cleaning, feature extraction, training jobs, indexing, retrieval — all well understood. We have solved many harder problems in computing.

**The phrase "the data problem" hides three different issues.**

## 1. The Technical Data Problem (Solvable, Mostly Solved)

Ingesting, cleaning, normalizing, ETL/ELT, feature generation, training ML models, building indexes — these are engineering problems. A mature stack exists:

```
data ingestion → transformation → storage → indexing → ML training → serving
```

Tools are abundant: Airflow/Dagster, Spark/Polars, warehouses, vector databases, feature stores, streaming pipelines. From a pure engineering perspective, this is routine infrastructure.

## 2. The Organizational Data Problem (The Real Bottleneck)

The difficulty most companies face is not technology. It is organizational entropy:

- Data spread across 40 systems
- Inconsistent schemas
- Ownership unclear
- No canonical truth
- Sensitive data locked behind departments
- No governance

Cleaning the data might be easy technically, but first you must answer: Who owns it? Who is allowed to use it? Which version is correct? What is the legal exposure?

**This turns a technical task into a political process.** Many AI projects stall here.

## 3. The Semantic Data Problem (The Subtle One)

Even if data is available and clean: meaning alignment.

"Customer" in different systems might mean billing account, CRM contact, shipping address, or legal entity. If an AI system uses the wrong interpretation, the output becomes unreliable.

This is why knowledge graphs and ontologies keep returning in enterprise AI. The problem is not data cleanliness but **semantic consistency**.

## 4. The Incentive Problem (Rarely Discussed)

Data is often organizational power. Departments hoard it because data = influence, budget justification, career protection.

When people say "the data isn't ready", sometimes they mean "we don't want to lose control of this."

## The Structural Shift Nobody Updated Their Mental Model For

### The Old Model: Training-Centric AI (2010-2022)

For about 15 years:

```
collect data → clean data → train model → deploy model
```

Performance depended on dataset size and quality. The entire AI community internalized: **the main bottleneck in AI is data.**

### Foundation Models Broke That Equation

With LLMs, intelligence is pre-trained. The model already knows language, reasoning, code, science, business concepts. Your internal data rarely teaches the model how to think. **It mainly tells the model what is currently true in your environment.**

### The New Model: Runtime Intelligence

```
user intent → agent reasoning → retrieve context → call tools → update state
```

The critical resource is **runtime context**, not training data:

- Documents
- Operational state
- Transaction history
- Policies
- System events
- Knowledge graphs

These are orders of magnitude smaller than training datasets.

### Why People Still Say "Data Problem"

Many practitioners still think: "we need lots of labeled data to train a model." But for most modern AI systems, what you actually need is **structured access to operational reality**. That's a system design problem, not a machine learning problem.

## Where Data Still Matters

### Domain Expertise
Medical imaging, industrial sensors, trading data, manufacturing telemetry — internal datasets encode specialized signals. (This connects to the MultiphysicsAI agent concept — see NOTE-multiphysics-agent.md.)

### Operational Context
Product catalog, contracts, maintenance logs, inventory, machine states. Not huge datasets. Structured context.

### Feedback Loops
```
agent action → result → evaluation → improved policy
```
This produces experience data, not massive training datasets.

## The Paradigm Shift

| Old AI | Emerging AI Systems |
|--------|-------------------|
| data → model → prediction | context → reasoning → action → state update |
| Training problem | Systems architecture problem |
| Dataset is the asset | Operational state is the asset |
| More data → better model | Better coordination → better outcomes |
| Machine learning problem | Distributed systems problem |

**The biggest shift happening in AI: from training problems to systems architecture problems. Less machine learning, more distributed systems design.**

## Why Converge Is Already on the Right Side of This Shift

The Converge pattern:

```
agents propose facts
→ authority validates
→ ledger becomes shared truth
→ agents react
```

Naturally solves runtime problems:

- **State persistence** — the ledger accumulates operational context
- **Shared memory** — agents read system state, not their own memory (see NOTE-agent-memory-category-error.md)
- **Auditability** — every decision traceable
- **Coordination** — deterministic convergence loops
- **Semantic consistency** — facts have typed keys, invariants enforce meaning

The system creates its own structured data through operation. That's a fundamentally different paradigm from "collect dataset → train model → deploy."

## The Short Answer

```
Data engineering difficulty:    moderate (solved infrastructure)
Organizational difficulty:      very high (political, not technical)
Semantic alignment difficulty:  subtle but real (meaning, not volume)
```

Once you see the shift from training-centric AI to runtime intelligence systems, the "data problem" stops looking like a fundamental obstacle and starts looking like normal infrastructure work.

## The Next Question

The real bottleneck in agent systems isn't data or memory at all — it's **coordination**. And that's where most current agent frameworks quietly fail. (That thread connects to the Agentic Trust synthesis — see NOTE-agentic-trust-article-synthesis.md.)
