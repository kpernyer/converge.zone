# converge-optimization

**Constraint Optimization Engine**

## Purpose

converge-optimization provides constraint programming, assignment, graph, and
scheduling algorithms as both a standalone Rust library and a Converge platform
agent. It handles problems where reasoning alone isn't enough: scheduling,
allocation, routing, and resource optimization with hard constraints.

## Why It Matters

Not every business problem is a reasoning problem. Some are **constraint
satisfaction problems**:

- Schedule 50 meetings across 10 rooms with no conflicts
- Allocate budget across 20 projects to maximize ROI under constraints
- Route deliveries to minimize cost while meeting time windows
- Assign staff to shifts with skill requirements and availability

These problems have:
- Explicit, enumerable constraints
- Coupled variables (changing one affects others)
- Combinatorial search spaces
- Material cost of error

LLMs are the wrong tool here. Solvers are.

## Place in the Platform

converge-optimization sits behind an **Optimization Gate**:

```
converge-domain (flow definition)
    ↓
Optimization Gate (is this a constraint problem?)
    ↓
converge-optimization  ←── solver agents
    ↓
Fact: OptimizedSchedule, OptimizedAllocation, etc.
```

The gate ensures optimization is used only when justified:
- Constraints are explicit and enumerable
- Variables are coupled
- Search space is combinatorial
- Analytical optimum is required

This prevents overuse of optimization for problems that need reasoning, and
overuse of reasoning for problems that need optimization.

## Architecture: Hybrid Library + Agent

converge-optimization is designed as a **layered crate** with two usage modes:

```
┌─────────────────────────────────────────────┐
│  converge agent layer (feature: "agent")    │  ← implements converge-core Agent trait
│  Each Pack becomes an Agent that takes      │     for each domain pack
│  Context → Vec<Fact> through the solver     │
├─────────────────────────────────────────────┤
│  gate + packs layer                         │  ← ProblemSpec, ProposedPlan, PromotionGate
│  Domain packs with invariants & governance  │     Pack trait, GateProvider
├─────────────────────────────────────────────┤
│  algorithm layer (always available)         │  ← pure algorithms, no platform deps
│  assignment, graph, knapsack, scheduling,   │     Hungarian, Dijkstra, push-relabel,
│  set cover, CP/SAT                          │     min-cost flow, varisat
├─────────────────────────────────────────────┤
│  ortools-sys (feature: "ffi")               │  ← optional C++ OR-Tools FFI
└─────────────────────────────────────────────┘
```

### Standalone Library (default)

No converge dependencies. Pure algorithms usable by anyone:

```rust
use converge_optimization::assignment::hungarian;
use converge_optimization::graph::dijkstra;
```

### Converge Agent (feature: "agent")

Depends on converge-core. Each domain Pack becomes an Agent:

```rust
use converge_optimization::packs::meeting_scheduler::MeetingSchedulerAgent;

// Agent trait: Context → Vec<Fact>
// Internally: extracts ProblemSpec from Context, runs solver, wraps result as Facts
let agent = MeetingSchedulerAgent::new();
```

This means you can instantiate an optimization agent the same way you'd
instantiate an LLM agent — same trait, same convergence loop, same promotion
semantics. The runtime doesn't care whether a Fact came from a neural network
or a SAT solver.

## Integration Plan (Current State: Not Yet Wired)

converge-optimization currently has **no dependency on converge-core**. The
agent layer described above does not exist yet. Here's what needs to happen:

### What Exists Today

- 7 pure algorithm modules (assignment, graph, knapsack, scheduling, set cover, CP, provider)
- Gate architecture (ProblemSpec → ProposedPlan → PromotionGate) — local types
- 10 domain packs (2 implemented: meeting scheduler, inventory rebalancing; 8 stubs)
- 357 passing tests
- Optional ortools-sys FFI subcrate (WIP)

### What Needs to Change

1. **Add `converge-core` as optional dependency** behind `feature = "agent"`
2. **Map local types to core types**:
   - `ProblemSpec` inputs → extracted from `Context` facts
   - `ProposedPlan` → wrapped as `Fact` with appropriate `ContextKey`
   - `InvariantDef`/`InvariantResult` → implement core `Invariant` trait
   - `PromotionGate` decisions → align with converge-policy authority model
3. **Implement `Agent` trait for each Pack** — thin adapter that bridges
   Pack::solve to Agent::run
4. **Wire PromotionGate to converge-policy** — gate decisions go through
   the Cedar PDP instead of local evaluation

### What Stays the Same

- Algorithm layer — no changes, no converge deps
- Pack trait and domain packs — no changes to solving logic
- Gate types — stay as optimization-specific contracts
- ortools-sys — unchanged, remains optional FFI

## Key Capabilities

| Capability | Algorithms | Domain Packs |
|------------|-----------|--------------|
| Assignment | Hungarian (O(n³)), Auction (O(n²)) | lead routing, vendor shortlist |
| Scheduling | Interval, disjunctive, cumulative | meeting scheduler, capacity planning |
| Allocation | Knapsack, set cover | budget allocation, inventory rebalancing |
| Graph | Dijkstra, push-relabel, min-cost flow | shipping choice |
| CP/SAT | varisat (native), CP-SAT (FFI) | general constraint problems |

## Governance Alignment

Optimization under Converge follows the same governance rules:

- **Inputs are facts**: Constraints come from the Context
- **Outputs are proposals**: Solutions become ProposedFacts
- **Gates apply**: Optimization Gate checks problem type; PromotionGate
  checks solution quality
- **Policy enforced**: PromotionGate decisions route through converge-policy
- **Audit works**: Solver parameters, solution, and SolverReport are recorded

An optimal schedule is still a proposal until it passes promotion. The solver
doesn't get special treatment — it's just another agent.
