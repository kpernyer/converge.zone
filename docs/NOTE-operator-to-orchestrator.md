# From Operator to Orchestrator: The Interaction Model Shift

## The Core Insight

Many rewrites are not just technical modernization — they are **interaction-model modernization.**

**Old systems were built for operators. New systems will be built for orchestrators.**

## The Legacy Assumption

Most legacy systems were designed around:

```
human operator → navigates UI → executes workflows → system stores results
```

The human was the orchestration engine. The software provided screens, forms and reports.

That design shaped everything: menu hierarchies, manual validation steps, batch jobs, approval chains, navigation-heavy UX. The system is essentially a **human-driven state machine.**

## The New Interaction Model

When AI enters the picture:

```
human intent → orchestrator → agents → services → state updates
```

Where:
- The human sets goals
- AI agents execute subtasks
- The system enforces constraints
- The human supervises exceptions

The UX is no longer about data entry screens. It becomes about **visibility, control, intervention, auditability, and task prioritization.**

## Human as Governor

| Old Role (Operator) | New Role (Orchestrator) |
|---------------------|------------------------|
| Enter order | Review agent plan |
| Confirm order | Approve execution |
| Update shipping | Resolve exceptions |
| Create invoice | Monitor outcomes |

The human becomes something like **mission control.**

## Systems Designed for Agents Look Different

| Design Pattern | Why |
|---------------|-----|
| APIs first | Agents interact with structured interfaces, not screens |
| Explicit state | Agents must understand system state without guessing |
| Deterministic constraints | Policies, limits and invariants must be machine-readable |
| Event streams | Agents react to events instead of polling screens |
| Audit trails | Every decision must be explainable |

These patterns are closer to distributed systems than to classic enterprise software.

## Why Legacy Systems Feel So Heavy

Legacy systems encode business logic inside UI flows, manual procedures, implicit assumptions, tribal knowledge:

```
screen A → click button → screen B → copy value → paste value
```

Humans know what to do because they learned the ritual. Agents cannot rely on rituals. They require explicit logic.

**Rewrites often succeed simply by moving business logic from human workflow into system rules.**

## The Supervisory UX

Instead of many screens, a modern system exposes:

- Tasks
- Exceptions
- Explanations
- State views
- Decision controls

Think air traffic control, logistics command centers, financial trading dashboards. The human sees what the system is doing, not every step.

## The Real Modernization Question

If the new system still assumes human operators performing each step, you are not really modernizing. You are rebuilding the old architecture on a new stack.

A real modernization asks:

- Which tasks should humans perform?
- Which tasks should agents perform?
- Which tasks should be automated entirely?

Then the system is designed around that distribution.

## The Architecture

```
human
  ↓
intent / policy
  ↓
agent coordination
  ↓
services and tools
  ↓
shared state
```

## The Deep Insight

A lot of legacy software is: **software compensating for the limited cognitive bandwidth of humans.**

AI changes that constraint.

The real rewrite question becomes: **what parts of the system existed only because humans had to do the work?**

Once you remove those constraints, the architecture can become dramatically simpler.

## Connection to Converge

This aligns directly with the Converge architecture:

- **Human sets intent** → Seeds, framing
- **Agents propose** → facts accumulate through convergence
- **Authority validates** → gates, invariants, policy enforcement
- **Human supervises** → approval gates, exception handling
- **Ledger records** → full auditability

The Converge authority tiers map to the orchestrator model:

| Authority Tier | Orchestrator Role |
|---------------|-------------------|
| Advisory | AI suggests, human decides everything |
| Participatory | AI proposes and advances, human gates |
| Supervisory | AI executes within constraints, human handles exceptions |
| Sovereign | Fully autonomous (rare, high-trust domains) |

The shift from operator to orchestrator is the shift from Advisory-level systems to Participatory and Supervisory-level systems. The governance architecture makes that transition safe and auditable.

See also:
- NOTE-ai-legacy-modernization.md — the broader legacy rewrite strategy
- NOTE-agentic-trust-article-synthesis.md — why trust infrastructure makes this possible
- NOTE-agent-memory-category-error.md — why shared state replaces agent memory
