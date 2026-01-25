# converge-optimization

**Constraint Optimization Engine**

## Purpose

converge-optimization provides constraint programming and mixed-integer linear programming (CP-SAT/MILP) capabilities via Google OR-Tools. It handles problems where reasoning alone isn't enough: scheduling, allocation, routing, and resource optimization with hard constraints.

## Why It Matters

Not every business problem is a reasoning problem. Some are **constraint satisfaction problems**:

- Schedule 50 meetings across 10 rooms with no conflicts
- Allocate budget across 20 projects to maximize ROI under constraints
- Route deliveries to minimize cost while meeting time windows
- Assign staff to shifts with skill requirements and availability

These problems have:
- Explicit, enumerable constraints
- Coupled variables (changing one affects others)
- Combinatorial search spaces
- Material cost of error

LLMs are the wrong tool here. CP-SAT solvers are.

## Place in the Platform

converge-optimization sits behind an **Optimization Gate**:

```
converge-domain (flow definition)
    ↓
Optimization Gate (is this a constraint problem?)
    ↓
converge-optimization  ←── CP-SAT/MILP solver
    ↓
Fact: OptimizedSchedule, OptimizedAllocation, etc.
```

The gate ensures optimization is used only when justified:
- Constraints are explicit and enumerable
- Variables are coupled
- Search space is combinatorial
- Analytical optimum is required

This prevents overuse of optimization for problems that need reasoning, and overuse of reasoning for problems that need optimization.

## Key Capabilities

| Capability | Use Case |
|------------|----------|
| Scheduling | Meeting rooms, staff shifts, production |
| Allocation | Budget, resources, capacity |
| Routing | Delivery, logistics, network flow |
| Assignment | Tasks to workers, projects to teams |

## Technology

Built on Google OR-Tools:
- **CP-SAT**: Constraint programming with SAT solving
- **MILP**: Mixed-integer linear programming
- **Routing**: Vehicle routing problem (VRP) solver

Exposed through Rust bindings with typed problem definitions.

## Governance Alignment

Optimization under Converge follows the same governance rules:

- **Inputs are facts**: Constraints come from the Context
- **Outputs are proposals**: Solutions become ProposedFacts
- **Gates apply**: Optimization Gate checks problem type
- **Audit works**: Solver parameters and solution are recorded

This ensures that even analytically optimal solutions go through promotion semantics. An optimal schedule is still a proposal until it passes the Approval Gate.
