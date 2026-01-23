# OR-Tools Algorithms Guide

**Purpose:** Understand what OR-Tools solves and how it maps to converge.zone use cases.

---

## Algorithm Categories at a Glance

```
┌─────────────────────────────────────────────────────────────────┐
│                        OR-TOOLS                                  │
├─────────────┬─────────────┬─────────────┬─────────────┬─────────┤
│   SAT/CP    │  Linear     │   Graph     │  Routing    │  Other  │
│             │ Programming │             │             │         │
├─────────────┼─────────────┼─────────────┼─────────────┼─────────┤
│ CP-SAT      │ GLOP        │ Shortest    │ VRP         │ Set     │
│ Scheduling  │ PDLP        │   Path      │ TSP         │  Cover  │
│ AllDiff     │ MIP (via    │ Max Flow    │ CVRP        │ Bin     │
│ Cumulative  │   external) │ Min Cost    │ PDPTW       │  Packing│
│ Intervals   │             │   Flow      │             │ Knapsack│
│ 2D Packing  │             │ Assignment  │             │         │
└─────────────┴─────────────┴─────────────┴─────────────┴─────────┘
```

---

## 1. Constraint Programming (CP-SAT)

### What It Solves
**Problems with discrete variables and complex constraints**

Think of it as: "Find values that satisfy all rules and optimize an objective"

### Practical Applications

| Problem Type | Example | Converge Use |
|-------------|---------|--------------|
| **Scheduling** | "Assign tasks to workers with no conflicts" | People pack: shift scheduling |
| **Assignment** | "Match students to courses" | Customers pack: lead routing |
| **Configuration** | "Build valid product configurations" | Pricing pack: valid bundles |
| **Timetabling** | "Create exam schedules" | Delivery pack: appointment slots |
| **Resource Allocation** | "Distribute budget across projects" | Money pack: allocation |

### Key Constraints

```
AllDifferent(x, y, z)     → All variables must have different values
Cumulative(tasks, cap)    → Resource usage ≤ capacity over time
NoOverlap(intervals)      → Tasks cannot overlap in time
Table(vars, tuples)       → Variables must match allowed combinations
Circuit(arcs)             → Variables form a cycle (routing)
```

### Converge Gate Example

```yaml
# converge-domain/packs/people/truths/scheduling.truths
@gate(type: optimization, provider: cpsat)
Scenario: Schedule shift assignments
  Given employees with availability constraints
  And shift requirements for the week
  When the scheduler optimizes
  Then all shifts are covered
  And no employee works consecutive days
  And total overtime is minimized
```

---

## 2. Linear Programming (LP/GLOP)

### What It Solves
**Optimize continuous variables with linear constraints**

Think of it as: "Maximize/minimize a linear function subject to linear inequalities"

### Standard Form
```
Maximize:    c₁x₁ + c₂x₂ + ... + cₙxₙ
Subject to:  a₁₁x₁ + a₁₂x₂ + ... ≤ b₁
             a₂₁x₁ + a₂₂x₂ + ... ≤ b₂
             x₁, x₂, ... ≥ 0
```

### Practical Applications

| Problem Type | Example | Converge Use |
|-------------|---------|--------------|
| **Pricing** | "Set prices to maximize profit" | Pricing pack: optimal price |
| **Blending** | "Mix ingredients at minimum cost" | Sustainability: resource mix |
| **Portfolio** | "Allocate investments" | Money pack: budget allocation |
| **Transportation** | "Ship goods at minimum cost" | Delivery pack: logistics |
| **Production** | "Schedule production lines" | Delivery pack: capacity |

### Converge Gate Example

```yaml
# converge-domain/packs/pricing/truths/optimization.truths
@gate(type: optimization, provider: glop)
Scenario: Optimize pricing strategy
  Given product costs and competitor prices
  And demand elasticity model
  When the pricing optimizer runs
  Then prices maximize expected profit
  And all prices are within acceptable bounds
```

---

## 3. Graph Algorithms

### What They Solve
**Problems on networks: paths, flows, matchings**

### Algorithm Menu

| Algorithm | Problem | Time Complexity | Converge Use |
|-----------|---------|-----------------|--------------|
| **Dijkstra** | Shortest path | O((V+E)log V) | Workflow routing |
| **Max Flow** | Maximum throughput | O(V²E) | Capacity planning |
| **Min Cost Flow** | Cheapest transport | O(V²E log V) | Resource allocation |
| **Assignment** | Optimal matching | O(V³) | Task assignment |
| **MST** | Minimum spanning tree | O(E log V) | Network design |
| **Connected Components** | Find clusters | O(V+E) | Data grouping |

### Shortest Path: When to Use

```
Need fastest route?           → Dijkstra
Need all-pairs shortest?      → Floyd-Warshall
Graph is a DAG?               → DAG shortest path
Need path through all nodes?  → Hamiltonian (NP-hard!)
```

### Flow Problems: When to Use

```
Maximum throughput?           → Max Flow
Minimum cost delivery?        → Min Cost Flow
Optimal assignment?           → Linear Assignment
Who pairs with whom?          → Bipartite Matching
```

### Converge Gate Example

```yaml
# converge-domain/packs/customers/truths/routing.truths
@gate(type: optimization, provider: assignment)
Scenario: Route leads to sales reps
  Given new leads with industry and size attributes
  And sales reps with expertise and capacity
  When the assignment optimizer runs
  Then each lead is assigned to best-fit rep
  And no rep exceeds capacity
```

---

## 4. Vehicle Routing (VRP)

### What It Solves
**Route vehicles to serve customers optimally**

Think of it as: "Multiple traveling salesmen with constraints"

### Problem Variants

| Variant | Constraints | Example |
|---------|-------------|---------|
| **TSP** | Single vehicle, visit all | Delivery route |
| **CVRP** | Capacity limits | Truck delivery |
| **VRPTW** | Time windows | Appointments |
| **PDPTW** | Pickup & delivery | Rideshare |
| **VRPB** | Backhauls | Return shipments |

### Converge Gate Example

```yaml
# converge-domain/packs/delivery/truths/routing.truths
@gate(type: optimization, provider: vrp)
Scenario: Optimize delivery routes
  Given deliveries with time windows
  And drivers with shift constraints
  And vehicle capacities
  When the routing optimizer runs
  Then all deliveries are scheduled
  And total distance is minimized
  And time windows are respected
```

---

## 5. Scheduling

### What It Solves
**Allocate resources over time with constraints**

### Problem Types

| Type | Constraint | Example |
|------|------------|---------|
| **Job Shop** | Tasks on specific machines | Manufacturing |
| **Flow Shop** | Fixed machine sequence | Assembly line |
| **RCPSP** | Limited resources | Project management |
| **Cumulative** | Shared capacity | Meeting rooms |

### Key Constraints

```
Disjunctive(tasks)        → Tasks cannot overlap on resource
Cumulative(tasks, cap)    → Total usage ≤ capacity at any time
Precedence(a, b)          → Task a must complete before b starts
TimeWindow(task, [s, e])  → Task must occur within window
```

### Converge Gate Example

```yaml
# converge-domain/packs/delivery/truths/scheduling.truths
@gate(type: optimization, provider: cpsat_scheduling)
Scenario: Schedule project tasks
  Given tasks with durations and dependencies
  And resources with availability
  When the scheduler optimizes
  Then project completes by deadline
  And no resource is overallocated
```

---

## 6. Set Cover & Bin Packing

### Set Cover: What It Solves
**Find minimum collection of sets that cover all elements**

Applications: Facility location, test coverage, sensor placement

### Bin Packing: What It Solves
**Pack items into minimum bins respecting capacity**

Applications: Container loading, memory allocation, VM placement

### Converge Use Cases

```yaml
# Set Cover: Select minimum service locations
@gate(type: optimization, provider: set_cover)
Scenario: Optimize facility locations
  Given potential locations and coverage areas
  When the optimizer selects locations
  Then all regions are covered
  And number of facilities is minimized

# Bin Packing: Consolidate shipments
@gate(type: optimization, provider: bin_packing)
Scenario: Consolidate orders into shipments
  Given orders with sizes
  And container capacity
  When the packer optimizes
  Then all orders are packed
  And number of containers is minimized
```

---

## 7. Knapsack

### What It Solves
**Select items to maximize value within capacity**

```
Given:  Items with weights and values
        Knapsack with capacity W
Find:   Subset with max value, total weight ≤ W
```

### Variants

| Variant | Constraint | Example |
|---------|------------|---------|
| **0-1** | Take or leave | Investment selection |
| **Bounded** | Limited copies | Inventory |
| **Unbounded** | Unlimited copies | Cutting stock |
| **Multi-dimensional** | Multiple constraints | Portfolio |

### Converge Gate Example

```yaml
# converge-domain/packs/money/truths/allocation.truths
@gate(type: optimization, provider: knapsack)
Scenario: Allocate marketing budget
  Given campaigns with costs and expected ROI
  And total budget constraint
  When the optimizer selects campaigns
  Then expected ROI is maximized
  And budget is not exceeded
```

---

## Choosing the Right Algorithm

```
START
  │
  ├─ Variables continuous? ────────────────────► LP (GLOP/HiGHS)
  │
  ├─ Variables discrete?
  │    │
  │    ├─ Simple assignment? ──────────────────► Linear Assignment
  │    ├─ Routing/TSP? ────────────────────────► VRP Solver
  │    ├─ Scheduling with resources? ──────────► CP-SAT Cumulative
  │    ├─ Selection with capacity? ────────────► Knapsack
  │    ├─ Coverage problem? ───────────────────► Set Cover
  │    └─ Complex constraints? ────────────────► CP-SAT
  │
  └─ Network/graph structure?
       │
       ├─ Find shortest path? ─────────────────► Dijkstra
       ├─ Maximize throughput? ────────────────► Max Flow
       ├─ Minimize transport cost? ────────────► Min Cost Flow
       └─ Find optimal matching? ──────────────► Assignment
```

---

## Complexity Quick Reference

| Algorithm | Time Complexity | Problem Size Limit |
|-----------|-----------------|-------------------|
| Dijkstra | O((V+E)log V) | 10⁶ nodes |
| Max Flow | O(V²E) | 10⁴ nodes |
| Assignment | O(V³) | 10³ agents |
| Knapsack DP | O(nW) | 10⁶ items × capacity |
| CP-SAT | Exponential (smart) | 10⁵ variables |
| LP Simplex | Polynomial (practice) | 10⁶ variables |
| VRP | NP-hard | 10³ nodes (heuristic) |

---

## Integration Priority for Converge

### Immediate (Phase 1)
1. **Linear Assignment** - Task routing, lead assignment
2. **Knapsack** - Resource allocation, budget optimization
3. **Shortest Path** - Workflow routing

### Short-term (Phase 2)
4. **Min Cost Flow** - Resource distribution
5. **CP-SAT (basic)** - Constraint validation
6. **Scheduling** - Time window management

### Medium-term (Phase 3)
7. **VRP** - Delivery optimization
8. **Set Cover** - Facility/coverage problems
9. **LP** - Pricing optimization

---

## Next Steps

1. Review `.planning/RUST-REIMPLEMENTATION-ANALYSIS.md` for implementation plan
2. Set up Rust workspace with `converge-optimization` crate
3. Start with Linear Assignment (native Rust)
4. Build converge-provider integration
5. Add FFI bridge for complex algorithms
