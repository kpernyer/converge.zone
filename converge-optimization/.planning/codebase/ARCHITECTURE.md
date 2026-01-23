# Architecture

**Analysis Date:** 2026-01-22

## Pattern Overview

**Overall:** Layered Modular Optimization Solver Suite

OR-Tools is a multi-layer optimization library that provides a unified interface to multiple solver engines (CP-SAT, Linear Programming, Constraint Programming, Graph Algorithms). The architecture follows a clear separation between:

1. **Language Bindings Layer** - Python, Java, C#, Go wrappers over C++ core
2. **Core Solver Layer** - Multiple specialized solvers for different problem types
3. **Model Definition Layer** - Protocol Buffer-based model definitions
4. **Algorithm/Utilities Layer** - Shared algorithms and utility functions

**Key Characteristics:**
- Protocol Buffer-based model serialization for language interoperability
- Multi-solver abstraction with unified problem/response interfaces
- Bidirectional dependency graph: high-level solvers use lower-level utilities
- Callback-driven architecture for solution monitoring and control
- Reversible data structures for constraint propagation backtracking

## Layers

**Base Utilities Layer:**
- Purpose: Provide foundational data structures, logging, memory management, and platform abstractions
- Location: `ortools/base/`, `ortools/util/`, `ortools/port/`
- Contains: Logging facilities, priority queues, bitsets, hash functions, timers, file I/O, platform-specific code
- Depends on: Standard library, abseil-cpp
- Used by: All other layers

**Model Definition Layer:**
- Purpose: Define optimization problems in a solver-agnostic format
- Location: `ortools/sat/cp_model.proto`, `ortools/linear_solver/`, `ortools/graph/flow_problem.proto`
- Contains: Protocol Buffer definitions for variables, constraints, objectives, interval scheduling
- Depends on: Protocol Buffers framework
- Used by: All solver layers, language bindings

**Linear Programming Solvers:**
- Purpose: Solve linear and mixed-integer linear programs
- Location: `ortools/linear_solver/`, `ortools/glop/`, `ortools/pdlp/`
- Contains: MPSolver wrapper interface, Glop (simplex solver), PDLP (first-order method solver)
- Depends on: Base utilities, model definitions
- Used by: High-level solver interfaces, integration with commercial solvers (CPLEX, Gurobi, SCIP)

**Constraint Programming Core:**
- Purpose: Solve constraint satisfaction and constraint optimization problems
- Location: `ortools/constraint_solver/`, `ortools/sat/`
- Contains: CP-SAT solver with presolve/postsolve, SAT solver, constraint propagators, search strategies
- Depends on: Base utilities, linear programming solvers
- Used by: Routing solver, scheduling components, high-level APIs

**Specialized Solvers:**
- Purpose: Domain-specific optimization algorithms
- Location: `ortools/routing/`, `ortools/scheduling/`, `ortools/graph/`, `ortools/set_cover/`, `ortools/bop/`, `ortools/packing/`
- Contains: Vehicle routing (with time windows, constraints), scheduling algorithms, graph algorithms, set cover heuristics, Boolean optimization
- Depends on: Constraint solver, base utilities
- Used by: Application-level code, examples

**Language Bindings:**
- Purpose: Expose optimization solvers to non-C++ languages
- Location: `ortools/python/`, `ortools/java/`, `ortools/dotnet/`, `ortools/julia/`
- Contains: SWIG-generated wrappers, Python helper modules, language-specific APIs
- Depends on: Core solvers, protocol buffers
- Used by: End users in their preferred language

**Initialization & Configuration:**
- Purpose: Set up C++ runtime, logging, and load external libraries
- Location: `ortools/init/init.h`, `ortools/init/init.cc`
- Contains: CppBridge for logging setup, CppFlags for control, Gurobi library loader
- Depends on: Base utilities
- Used by: Language bindings on startup

## Data Flow

**Model Building & Solving:**

1. User creates model via language binding API (e.g., `cp_model.CpModel()` in Python)
2. User defines variables and constraints using language-specific methods
3. Model is serialized to Protocol Buffer format (CpModelProto, MPModel, etc.)
4. Serialized model passed to C++ solver layer
5. Solver applies presolve to simplify model (in `cp_model_presolve.h`)
6. Search algorithm explores solution space using propagators and heuristics
7. When feasible solution found, callback observers notified (NewFeasibleSolutionObserver)
8. Solver continues or terminates based on parameters and stopping criteria
9. Final response (CpSolverResponse) serialized back to language binding
10. User queries solution via binding API (e.g., `solver.SolveWithParameters()`)

**Solution Monitoring:**

```
Search Loop (SolveCpModel)
  ├── Propagation Phase
  │   ├── Apply domain propagators
  │   ├── Check constraint violations
  │   └── Backtrack if infeasible
  ├── Decision Phase
  │   ├── Select variable via strategy
  │   └── Reduce domain
  ├── Solution Found
  │   ├── Call FeasibleSolutionObserver callbacks
  │   └── Update best objective
  └── [Repeat or Stop]
```

**State Management:**

- **Model State:** Immutable after serialization to proto; modifications require re-solve
- **Solver State:** Maintained in Model* object; includes search log, callbacks, parameters
- **Solution State:** Stored in CpSolverResponse; can be extracted mid-search via callbacks
- **Reversible Data Structures:** Used during search (SimpleRevFIFO, RevBitSet, RevSwitch) to efficiently undo decisions on backtrack

## Key Abstractions

**IntVar (Integer Variable):**
- Purpose: Represents decision variables with domain constraints
- Examples: `ortools/constraint_solver/constraint_solver.h`, `ortools/sat/cp_model.py`
- Pattern: Variables have min/max bounds, support domain operations (SetMin, SetMax, RemoveValue). Variables are linked to propagators that maintain feasibility.

**Constraint:**
- Purpose: Enforces relationships between variables
- Examples: `LinearConstraintProto`, `AllDifferentConstraintProto`, `NoOverlapConstraintProto` in `ortools/sat/cp_model.proto`
- Pattern: Proto-based definition; each constraint type has corresponding C++ propagator class (AllDifferent, NoOverlap, Cumulative, etc.)

**Demon (Propagator):**
- Purpose: Efficiently propagate constraint when variable domain changes
- Examples: `MakeConstraintDemon<n>`, `MakeDelayedConstraintDemon<n>` in `ortools/constraint_solver/constraint_solveri.h`
- Pattern: Demons are callbacks that run on variable changes; they reduce domains of other variables or detect infeasibility

**LinearExpr:**
- Purpose: Represent linear combinations of variables (e.g., 3*x + 2*y + 5)
- Examples: `ortools/sat/python/cp_model.py`, `ortools/linear_solver/linear_expr.h`
- Pattern: Builder pattern for constructing expressions; supports arithmetic operators (+, -, *, /)

**LocalSearchOperator:**
- Purpose: Define neighborhood for local search / large neighborhood search
- Examples: `PathOperator`, `IntVarLocalSearchOperator` in `ortools/constraint_solver/constraint_solveri.h`
- Pattern: Operator generates neighboring solutions from current solution; used in routing and scheduling

**SearchLog & Callback:**
- Purpose: Monitor and control search progress
- Examples: `NewFeasibleSolutionObserver`, `NewBestBoundCallback`, `SearchLog` in `ortools/sat/cp_model_solver.h`
- Pattern: Callbacks invoked at solution discovery or bound updates; can terminate search early

## Entry Points

**C++ CP-SAT Solver:**
- Location: `ortools/sat/cp_model_solver.h`
- Triggers: Direct C++ code calling `Solve()` or `SolveCpModel()`
- Responsibilities: Parse model, apply presolve, run search loop, postsolve, return response

**Python CP-SAT API:**
- Location: `ortools/sat/python/cp_model.py`
- Triggers: `CpModel()` instantiation, `CpSolver().Solve()`
- Responsibilities: Python model builder → CpModelProto → C++ solver → CpSolverResponse → Python solution

**Linear Solver Wrapper:**
- Location: `ortools/linear_solver/linear_solver.h`
- Triggers: `MPSolver` instantiation with solver type (GLOP, CLP, CBC, etc.)
- Responsibilities: Unified interface to multiple LP/MIP backends

**Routing Solver (VRP):**
- Location: `ortools/routing/routing.h`
- Triggers: `RoutingIndexManager` + `RoutingModel` creation
- Responsibilities: Vehicle routing with time windows, capacities, custom local search

**Graph Algorithms:**
- Location: `ortools/graph/` (shortest_paths.h, min_cost_flow.h, linear_assignment.h, etc.)
- Triggers: Direct algorithm calls (dijkstra, max_flow, etc.)
- Responsibilities: Specialized implementations for graph problems

## Error Handling

**Strategy:** Fail-fast with logging; invalid models detected at validation

**Patterns:**
- Model validation: `cp_model_checker.cc` validates proto before solving
- Infeasibility detection: Propagators return false on infeasibility; search backtracks
- Status reporting: CpSolverStatus enum returned in response (OPTIMAL, FEASIBLE, INFEASIBLE, MODEL_INVALID, UNKNOWN)
- Callback exceptions: Exceptions in user callbacks are caught and logged; search continues

## Cross-Cutting Concerns

**Logging:**
- Via `absl::log` in `ortools/base/logging.h`
- Configurable via CppFlags.stderrthreshold
- Search progress logged by SearchLog

**Validation:**
- Model proto validation in `cp_model_checker.cc` before solve
- Domain overflow checks to prevent integer overflow
- Constraint-specific validation (e.g., interval constraint size >= 0)

**Authentication:**
- Gurobi library loaded dynamically via `CppBridge::LoadGurobiSharedLibrary()`
- No built-in auth; caller responsible for Gurobi licensing

**Memory Management:**
- Pool-based allocation for frequently created objects
- Reversible data structures use arena allocator during search
- SWIG helpers manage memory transfer between languages

---

*Architecture analysis: 2026-01-22*
