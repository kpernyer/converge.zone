# Codebase Structure

**Analysis Date:** 2026-01-22

## Directory Layout

```
converge-optimization/                    # Project root (OR-Tools)
├── ortools/                               # Core source code
│   ├── base/                              # Foundational utilities (logging, data structures)
│   ├── util/                              # General utilities (bitsets, sorting, intervals)
│   ├── port/                              # Platform abstractions
│   ├── init/                              # Initialization and version management
│   ├── linear_solver/                     # LP/MIP wrapper interface
│   ├── glop/                              # Simplex-based LP solver
│   ├── pdlp/                              # First-order LP solver
│   ├── lp_data/                           # Data structures for LP models
│   ├── constraint_solver/                 # Constraint programming core
│   ├── sat/                               # SAT solver and CP-SAT
│   ├── bop/                               # Boolean optimization
│   ├── routing/                           # Vehicle routing solver
│   ├── scheduling/                        # Scheduling algorithms
│   ├── graph/                             # Graph algorithms
│   ├── set_cover/                         # Set cover solver
│   ├── packing/                           # Bin packing algorithms
│   ├── flatzinc/                          # FlatZinc solver support
│   ├── python/                            # Python bindings
│   ├── java/                              # Java bindings
│   ├── dotnet/                            # C# bindings
│   ├── julia/                             # Julia bindings
│   ├── cpp/                               # C++ examples and samples
│   ├── gurobi/                            # Gurobi interface
│   ├── third_party_solvers/               # Wrappers for external solvers
│   ├── doxygen/                           # Documentation generation
│   └── service/                           # OR-Tools service API
├── examples/                              # End-user examples
│   ├── python/                            # Python example scripts
│   ├── cpp/                               # C++ example sources
│   ├── java/                              # Java examples
│   ├── dotnet/                            # C# examples
│   ├── flatzinc/                          # FlatZinc examples
│   ├── notebook/                          # Jupyter notebooks
│   └── contrib/                           # Community contributions
├── cmake/                                 # CMake build configuration
├── bazel/                                 # Bazel build configuration
├── makefiles/                             # Make build configuration
├── tools/                                 # Development and delivery tools
│   ├── build/                             # Build helpers (bazel2cmake, etc.)
│   ├── doc/                               # Documentation tools
│   ├── testing/                           # Testing utilities
│   └── check_python_deps.py               # Dependency checker
├── patches/                               # Third-party patches
├── CMakeLists.txt                         # CMake root config
├── BUILD.bazel                            # Bazel root config
├── Makefile                               # Make root config
├── MODULE.bazel                           # Bazel modules config
├── deps.bzl                               # Bazel dependencies
├── .pylintrc                              # Python linting rules
├── .bazelrc                               # Bazel configuration flags
├── .clang-format                          # C++ formatting rules
├── .cmake-format.py                       # CMake formatting rules
└── .github/                               # GitHub workflows and templates
```

## Directory Purposes

**ortools/base:**
- Purpose: Foundational utilities used across all components
- Contains: Logging (logging.h), memory management (strong_int.h), file I/O (file.h), timers (timer.h), containers (adjustable_priority_queue.h)
- Key files: `logging.h`, `types.h`, `base_export.h`, `timer.h`, `file.h`

**ortools/util:**
- Purpose: Shared algorithms and specialized data structures
- Contains: Sorted interval lists (sorted_interval_list.h), bitsets (bitset.h), tuple sets (tuple_set.h), randomization (random.h)
- Key files: `sorted_interval_list.h`, `bitset.h`, `hash.h`

**ortools/port:**
- Purpose: Platform and compiler abstraction
- Contains: Compiler-specific code, endianness handling, mutex abstractions
- Key files: Various platform-specific headers

**ortools/init:**
- Purpose: Library initialization and version management
- Contains: CppBridge class for setup, CppFlags structure for runtime configuration, version reporting
- Key files: `init.h`, `init.cc`

**ortools/linear_solver:**
- Purpose: Unified wrapper for LP and MIP solvers
- Contains: MPSolver interface, solver backends (Glop, CLP, CBC, CPLEX, Gurobi, SCIP, Highs, Knapsack)
- Key files: `linear_solver.h`, `solve_mp_model.h`, `model_exporter.h`

**ortools/glop:**
- Purpose: Google's Simplex-based linear programming solver
- Contains: Simplex implementation, presolve, dual feasibility
- Key files: Glop algorithms (simplex_solver.h, parameters.h)

**ortools/pdlp:**
- Purpose: Primal-Dual Linear Program solver (first-order method)
- Contains: PDLP algorithm implementation, convergence checks
- Key files: PDLP solver core

**ortools/lp_data:**
- Purpose: Data structures for linear programming models
- Contains: Sparse matrix representations, column/row definitions
- Key files: Data structure definitions

**ortools/constraint_solver:**
- Purpose: Traditional constraint programming solver
- Contains: IntVar and constraint abstractions, demons (propagators), local search, routing solver
- Key files: `constraint_solver.h`, `constraint_solveri.h`, `routing.h`, `routing_index_manager.h`

**ortools/sat:**
- Purpose: SAT solver and Constraint Programming SAT (CP-SAT)
- Contains: SAT solver core, CP-SAT with presolve/postsolve, Python bindings (cp_model.py), interval and cumulative constraints, symmetry breaking
- Key files: `cp_model_solver.h`, `cp_model.proto`, `sat_solver.h`, `python/cp_model.py`, `python/cp_model.pb2.py`

**ortools/bop:**
- Purpose: Boolean optimization (SAT-based)
- Contains: SAT-based integer programming solver for Boolean problems
- Key files: SAT wrapper for Boolean optimization

**ortools/routing:**
- Purpose: Vehicle Routing Problem solver
- Contains: Routing model, index manager, local search filters, neighborhoods (2-opt, 3-opt, etc.), callbacks
- Key files: `routing.h`, `routing_index_manager.h`, `routing_search.h`, `routing_neighborhoods.h`

**ortools/scheduling:**
- Purpose: Project scheduling algorithms
- Contains: RCPSP, job shop, resource-constrained scheduling solvers
- Key files: Scheduling-specific constraint implementations

**ortools/graph:**
- Purpose: Graph algorithms
- Contains: Shortest paths (Dijkstra, Bellman-Ford), maximum flow, minimum cost flow, linear assignment, matching algorithms, connected components
- Key files: `shortest_paths.h`, `min_cost_flow.h`, `max_flow.h`, `linear_assignment.h`, `graph.h`

**ortools/set_cover:**
- Purpose: Set cover problem solver with heuristics
- Contains: Greedy heuristics, Lagrangian relaxation, MIP-based solver
- Key files: `set_cover_model.h`, `set_cover_heuristics.h`

**ortools/packing:**
- Purpose: Bin packing and rectangle packing algorithms
- Contains: Orthogonal packing for 2D/3D problems
- Key files: Packing problem solvers

**ortools/python:**
- Purpose: Python language bindings and setup
- Contains: setup.py generation, SWIG interface files, Python-specific documentation
- Key files: `__init__.py.in`, setup files

**ortools/sat/python:**
- Purpose: High-level Python API for CP-SAT
- Contains: CpModel class (model builder), CpSolver class (solver), callback classes, solution printing utilities
- Key files: `cp_model.py`, `cp_model_helper.py`, `cp_model_test.py`

**examples/python:**
- Purpose: Demonstration of OR-Tools usage in Python
- Contains: ~80 example scripts covering different problem types (scheduling, routing, assignment, etc.)
- Key files: All .py files showing best practices for model building and solving

**ortools/java, ortools/dotnet, ortools/julia:**
- Purpose: Language-specific bindings
- Contains: SWIG wrapper files, language-specific APIs, type mappings
- Key files: Generated and hand-written wrapper code

## Key File Locations

**Entry Points:**

- `ortools/init/init.h`: C++ initialization API
- `ortools/sat/cp_model_solver.h`: CP-SAT solver entry point (C++)
- `ortools/sat/python/cp_model.py`: CP-SAT solver entry point (Python)
- `ortools/linear_solver/linear_solver.h`: LP/MIP solver entry point
- `ortools/constraint_solver/routing.h`: Vehicle routing entry point
- `ortools/graph/shortest_paths.h`: Graph algorithms entry point

**Configuration:**

- `ortools/sat/sat_parameters.proto`: SAT solver parameters
- `ortools/sat/cp_model.proto`: CP-SAT model definition
- `ortools/linear_solver/linear_solver.h`: MPSolver configuration
- `.pylintrc`: Python linting rules
- `.clang-format`: C++ code style
- `.cmake-format.py`: CMake style

**Core Logic:**

- `ortools/sat/cp_model_solver.cc`: CP-SAT main solve loop
- `ortools/sat/cp_model_presolve.cc`: CP-SAT presolve
- `ortools/sat/cp_model_postsolve.cc`: CP-SAT postsolve
- `ortools/constraint_solver/constraint_solver.cc`: Traditional CP solver
- `ortools/routing/routing.cc`: Vehicle routing implementation
- `ortools/glop/revised_simplex.cc`: Simplex algorithm

**Testing:**

- `ortools/sat/cp_model_test.py`: Python CP-SAT tests
- `examples/python/*_py_test.bintest`: Binary test specifications
- `ortools/sat/*_test.cc`: C++ unit tests

## Naming Conventions

**Files:**

- `*.h` - Header files (C++ interfaces, declarations)
- `*.cc` - Implementation files (C++ implementations)
- `*.py` - Python source files
- `*.proto` - Protocol Buffer definitions
- `*.java` - Java source files
- `*.cs` - C# source files
- `*_test.cc` - C++ unit test files
- `*_test.py` - Python unit test files
- `*.bintest` - Binary test specification (test runner config)
- `*.i` - SWIG interface files (language binding definitions)

**Directories:**

- `ortools/[solver_name]/`: Solver-specific code
- `ortools/[solver_name]/samples/`: Example code for solver
- `examples/[language]/`: Language-specific examples
- `tools/[purpose]/`: Development tools organized by purpose

## Where to Add New Code

**New Constraint Type (e.g., CustomConstraint):**
- Proto definition: `ortools/sat/cp_model.proto` (add message definition)
- C++ propagator: `ortools/sat/custom_constraint.h` and `ortools/sat/custom_constraint.cc`
- Python helper: `ortools/sat/python/cp_model.py` (add builder method)
- Tests: `ortools/sat/custom_constraint_test.cc` and corresponding Python test

**New Solver Backend (e.g., NewSolver):**
- Interface: `ortools/linear_solver/linear_solver.h` (extend factory)
- Implementation: `ortools/linear_solver/newsolver_interface.cc`
- Tests: `ortools/linear_solver/newsolver_interface.cc` with TEST sections
- Integration: Update CMakeLists.txt and BUILD.bazel files

**New Graph Algorithm:**
- Implementation: `ortools/graph/new_algorithm.h` and optionally `.cc`
- Tests: `ortools/graph/new_algorithm_test.cc`
- Examples: `examples/cpp/` or `examples/python/` for usage demo

**New Example:**
- Python: `examples/python/my_problem_sat.py` (follow naming: [problem]_[solver].py)
- C++: `examples/cpp/my_problem_sat.cc`
- Test spec: `examples/python/my_problem_sat_py_test.bintest`

**Utilities:**
- General utilities: `ortools/util/my_utility.h`
- Base utilities: `ortools/base/my_utility.h`
- Keep as single-file or pair .h/.cc based on complexity

## Special Directories

**ortools/doxygen:**
- Purpose: Doxygen configuration and documentation generation
- Generated: Yes (documentation output)
- Committed: Build files only; generated HTML not committed

**examples/notebook:**
- Purpose: Jupyter notebooks for interactive learning
- Generated: Yes (from Python examples or manual creation)
- Committed: .ipynb files committed for documentation

**bazel/, cmake/, makefiles/:**
- Purpose: Build system configuration
- Generated: No (hand-written)
- Committed: Yes (build system is part of repo)

**patches/:**
- Purpose: Patches for third-party dependencies
- Generated: No
- Committed: Yes (required for reproducible builds)

**tools/:**
- Purpose: Build and development utilities
- Generated: Some outputs (e.g., from bazel2cmake)
- Committed: Source tools committed; generated files in .gitignore

---

*Structure analysis: 2026-01-22*
