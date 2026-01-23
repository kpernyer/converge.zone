# Test Inventory for OR-Tools Baseline

**Date:** 2026-01-22
**Purpose:** Document existing tests before Rust reimplementation

## Test Categories

### Python Tests (to be replaced)
Location: `ortools/*/python/*_test.py`

Key test files:
- `ortools/sat/python/cp_model_test.py` - CP-SAT Python API tests
- `ortools/sat/python/cp_model_helper_test.py` - Helper function tests
- `ortools/init/python/init_test.py` - Initialization tests
- `ortools/set_cover/python/set_cover_test.py` - Set cover tests
- `ortools/graph/python/*_test.py` - Graph algorithm tests

### C++ Tests (reference implementation)
Location: `ortools/*/**/*_test.cc`

These remain the ground truth for algorithm correctness:
- SAT solver core tests
- Graph algorithm tests
- Linear programming tests
- Scheduling constraint tests

## Test Execution Commands

```bash
# C++ tests (via Bazel)
bazel test //ortools/sat:all_test

# C++ tests (via CMake)
cmake --build build --target test

# Python tests (requires ortools package)
python -m pytest ortools/sat/python/cp_model_test.py
```

## Baseline Results to Capture

Before removing Python bindings, run:
1. All Python unit tests
2. All Python example scripts in `examples/python/`
3. Performance benchmarks on standard problem instances

### Standard Problem Instances

| Problem Type | Instance | Expected Result |
|-------------|----------|-----------------|
| SAT | Simple satisfiable | SAT |
| CP-SAT | N-Queens (8) | 92 solutions |
| Linear Assignment | 10x10 random | Optimal assignment |
| TSP | berlin52 | ~7542 (optimal) |
| Job Shop | ft06 | 55 (optimal makespan) |
| Set Cover | scp41 | Known optimal |

## Rust Replacement Validation

Each Rust module must pass:
1. Same output as Python for identical inputs
2. Same or better performance
3. No regressions on edge cases from C++ tests
