# OR-Tools Rust Reimplementation Analysis

**Date:** 2026-01-22
**Purpose:** Analyze complexity and prioritize Rust replacement of OR-Tools components for converge.zone

---

## Executive Summary

Reimplementing OR-Tools in Rust is a **multi-year effort** if targeting full parity. However, for converge.zone's specific use cases (gates in convergence flows, OR services), we can achieve value with a **targeted subset**.

**Recommendation:** Build a Rust-native optimization layer that:
1. Implements high-value, lower-complexity algorithms natively in Rust
2. Keeps CP-SAT (and other complex solvers) as an optional C++ capability
3. Provides a clean Rust API that matches converge-platform patterns

**Decision (2026-01-22):** Adopt the pragmatic hybrid approach.
- Default path is **pure Rust** for common optimization gates.
- CP-SAT remains available **as an optional C++ dependency** (FFI or sidecar).
- The Rust runtime stays clean unless a CP feature is explicitly enabled.

---

## Converge.zone Integration Points

### Use Case 1: OR as Gates in Convergence Flows

In converge-platform, gates are authority injection points where optimization can make decisions:

```yaml
# Example: Pricing optimization gate
- id: optimal_pricing_gate
  description: "Use LP to find optimal price point"
  type: optimization
  provider: pricing_optimizer
  violation_action: propose_solution
```

**Required Algorithms:**
| Algorithm | Use Case | Priority |
|-----------|----------|----------|
| Linear Assignment | Task/agent assignment | HIGH |
| Knapsack | Resource allocation | HIGH |
| Shortest Path | Workflow routing | MEDIUM |
| Min Cost Flow | Resource flow | MEDIUM |
| CP-SAT (subset) | Constraint validation | MEDIUM |

### Use Case 2: OR Services in Applications

Offering optimization as a service through converge-runtime:

```rust
// converge-provider/src/optimization.rs
pub struct OptimizationProvider {
    solver_type: SolverType,
    config: OptimizationConfig,
}

impl Provider for OptimizationProvider {
    async fn solve(&self, problem: &Problem) -> Result<Solution> {
        match self.solver_type {
            SolverType::LinearAssignment => solve_assignment(problem),
            SolverType::VehicleRouting => solve_vrp(problem),
            SolverType::Scheduling => solve_schedule(problem),
        }
    }
}
```

**Required Services:**
| Service | Business Use | Priority |
|---------|-------------|----------|
| Assignment | People → Tasks, Agents → Jobs | HIGH |
| Scheduling | Resource scheduling, time windows | HIGH |
| Routing | Delivery, supply chain | HIGH |
| Pricing | Quote optimization | MEDIUM |
| Bin Packing | Resource consolidation | LOW |

---

## Algorithm Complexity Analysis

### Tier 1: Simple (Rust-native feasible)
**Effort: 1-4 weeks each**

| Algorithm | Lines C++ | Rust Effort | Notes |
|-----------|-----------|-------------|-------|
| Dijkstra | ~500 | 1 week | Well-understood, Rust crates exist |
| Union-Find | ~200 | 2 days | Trivial |
| Topological Sort | ~300 | 2 days | Trivial |
| Hungarian (O(n⁴)) | ~800 | 2 weeks | Straightforward DP |
| Knapsack DP | ~600 | 1 week | Classic algorithm |
| Connected Components | ~400 | 1 week | Uses Union-Find |

### Tier 2: Moderate (Rust-native possible)
**Effort: 1-3 months each**

| Algorithm | Lines C++ | Rust Effort | Notes |
|-----------|-----------|-------------|-------|
| Linear Assignment (Goldberg) | ~2,000 | 6 weeks | Push-relabel, well-documented |
| Max Flow | ~1,500 | 4 weeks | Push-relabel variant |
| Min Cost Flow | ~3,000 | 8 weeks | Cost-scaling complexity |
| Set Cover Greedy | ~1,500 | 4 weeks | Heuristic focus |
| Hamiltonian Path | ~1,200 | 4 weeks | Held-Karp DP |
| MST (Prim/Kruskal) | ~800 | 2 weeks | Standard algorithms |

### Tier 3: Complex (C++ optional only)
**Effort: 6-12 months each if native**

| Algorithm | Lines C++ | Recommendation | Notes |
|-----------|-----------|----------------|-------|
| Simplex (GLOP) | ~15,000 | Optional C++ | Numerically sensitive |
| CP-SAT Core | ~50,000+ | Optional C++ | Decades of optimization |
| Vehicle Routing | ~20,000+ | Optional C++ | Complex metaheuristics |
| PDLP | ~10,000 | Optional C++ | Specialized research |
| Cumulative Scheduling | ~8,000 | Optional C++ | Multiple propagators |

### Tier 4: Extreme (Do not reimplement)
**Effort: Years**

| Algorithm | Lines C++ | Recommendation | Notes |
|-----------|-----------|----------------|-------|
| Full SAT Solver | ~30,000 | Use existing | CaDiCaL, Varisat (Rust) |
| LP Solver | ~20,000 | Use HiGHS/CLP | Industry standard |
| MIP Solver | ~100,000+ | Commercial | Gurobi/CPLEX/SCIP |

---

## Recommended Rust Architecture

```
converge-optimization/
├── Cargo.toml
├── src/
│   ├── lib.rs
│   ├── assignment/           # Tier 1-2: Native Rust
│   │   ├── mod.rs
│   │   ├── hungarian.rs      # O(n⁴) implementation
│   │   └── goldberg.rs       # Push-relabel O(n³)
│   ├── graph/                # Tier 1: Native Rust
│   │   ├── mod.rs
│   │   ├── dijkstra.rs
│   │   ├── min_cost_flow.rs
│   │   └── max_flow.rs
│   ├── scheduling/           # Tier 2: Native for simple cases
│   │   ├── mod.rs
│   │   └── interval.rs
│   ├── knapsack/             # Tier 1: Native Rust
│   │   ├── mod.rs
│   │   └── dynamic.rs
│   ├── ffi/                  # Optional C++ bindings (feature-gated)
│   │   ├── mod.rs
│   │   ├── cpsat.rs          # Wrap CP-SAT
│   │   ├── glop.rs           # Wrap GLOP
│   │   └── routing.rs        # Wrap VRP
│   └── provider/             # Converge integration
│       ├── mod.rs
│       └── capability.rs
├── ortools-sys/              # C++ FFI bindings
│   ├── build.rs
│   ├── wrapper.h
│   └── src/lib.rs
└── tests/
    └── baseline/             # Comparison with C++ results
```

---

## Phased Implementation Plan

### Phase 1: Foundation (Months 1-2)
**Goal:** Basic optimization gates for converge-platform

1. **Linear Assignment (Native Rust)**
   - Hungarian algorithm for small problems
   - Goldberg-Kennedy for larger problems
   - API: `assign(costs: &[&[i64]]) -> Vec<(usize, usize)>`

2. **Knapsack (Native Rust)**
   - 0-1 knapsack via DP
   - API: `knapsack(weights: &[i64], values: &[i64], capacity: i64) -> Vec<usize>`

3. **Basic Graph (Native Rust)**
   - Dijkstra shortest path
   - Connected components
   - API: `shortest_path(graph: &Graph, from: NodeId, to: NodeId) -> Path`

**Integration Point:**
```rust
// converge-provider integration
capability_registry.register("optimize.assignment", AssignmentProvider);
capability_registry.register("optimize.knapsack", KnapsackProvider);
capability_registry.register("optimize.path", ShortestPathProvider);
```

### Phase 2: Flow Algorithms (Months 3-4)
**Goal:** Network optimization for resource allocation

1. **Max Flow (Native Rust)**
   - Push-relabel algorithm
   - Used for: capacity planning, bottleneck analysis

2. **Min Cost Flow (Native Rust)**
   - Cost-scaling push-relabel
   - Used for: resource allocation, transportation

3. **Set Cover Greedy (Native Rust)**
   - Chvátal greedy heuristic
   - Used for: coverage problems, selection

### Phase 3: Optional C++ Bridge (Months 5-6)
**Goal:** Keep complex algorithms available without polluting the core Rust runtime

1. **CP-SAT Wrapper (optional)**
   - Build `ortools-sys` crate with bindgen
   - Safe Rust API over C++ CP-SAT
   - Used for: constraint validation, scheduling

2. **GLOP Wrapper (optional)**
   - LP solving for pricing, resource optimization
   - Used for: continuous optimization

3. **VRP Wrapper (optional)**
   - Vehicle routing if needed
   - Used for: delivery, supply chain

### Phase 4: Advanced Native (Months 7-12)
**Goal:** Replace more C++ with native Rust

1. **Simple CP Constraints**
   - AllDifferent propagator
   - Interval variables
   - Cumulative (simple version)

2. **Scheduling Core**
   - Disjunctive scheduling
   - Time windows
   - Resource constraints

---

## Existing Rust Optimization Crates

Consider using/adapting:

| Crate | Algorithms | Maturity | Notes |
|-------|-----------|----------|-------|
| `good_lp` | LP interface | Good | Wraps multiple solvers |
| `varisat` | SAT solver | Good | Pure Rust SAT |
| `petgraph` | Graph algorithms | Excellent | Foundation for graph work |
| `pathfinding` | Dijkstra, A*, etc | Good | Ready to use |
| `highs` | LP/MIP | Good | Rust bindings to HiGHS |
| `minilp` | Simple LP | Basic | Pure Rust, limited |

**Recommendation:** Build on `petgraph` for graph algorithms, use `highs` crate for LP.

---

## Risk Assessment

### High Risk
- **CP-SAT complexity**: The solver has 50,000+ lines of highly optimized C++
- **Numerical stability**: LP solvers require careful floating-point handling
- **Performance regression**: Rust reimplementation may be slower initially

### Mitigation
- Use FFI for complex algorithms, native for simple ones
- Extensive testing against C++ baseline
- Keep C++ as fallback during transition

### Low Risk
- **Graph algorithms**: Well-understood, good Rust ecosystem
- **Assignment/Knapsack**: Classic algorithms, straightforward to implement
- **API design**: Clean slate opportunity for Rust-idiomatic API

---

## Effort Estimates

| Component | Native Rust | FFI Wrapper | Recommended |
|-----------|-------------|-------------|-------------|
| Linear Assignment | 6 weeks | 2 weeks | Native |
| Knapsack | 2 weeks | 1 week | Native |
| Dijkstra | 1 week | 1 week | Native |
| Max/Min Flow | 8 weeks | 2 weeks | Native |
| CP-SAT | 2+ years | 4 weeks | FFI |
| GLOP | 1+ year | 3 weeks | FFI |
| VRP | 1+ year | 4 weeks | FFI |
| Full parity | 5+ years | 6 months | Hybrid |

**Total for converge.zone MVP (Phase 1-2):** 4 months
**Total for production-ready (Phase 1-3):** 6 months
**Total for native replacement (Phase 1-4):** 12+ months

---

## Recommendation Summary

1. **Default to native Rust** for Tier 1-2 algorithms (assignment, knapsack, graph)
2. **Keep C++ solvers optional** (CP-SAT, GLOP, VRP) behind feature flags
3. **Integrate as converge-provider** matching platform patterns
4. **Validate against C++ baseline** before removing Python
5. **Incrementally replace optional C++** with native as capacity allows

This approach gives you:
- Working optimization in converge-platform within 2 months
- Full OR-Tools capability via FFI within 6 months
- Path to pure Rust over 1-2 years

## Policy: Pure Rust by Default
The core `converge-optimization` crate remains pure Rust. If CP-SAT is required,
it is enabled explicitly (feature gate or sidecar), preserving a clean default build.
