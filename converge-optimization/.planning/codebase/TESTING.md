# Testing Patterns

**Analysis Date:** 2026-01-22

## Test Framework

**Runner:**
- C++: Google Test (gtest) via `#include "gtest/gtest.h"`
- Python: absltest via `from absl.testing import absltest`
- Benchmark: Google Benchmark for performance testing (`#include "benchmark/benchmark.h"`)

**Config:**
- C++ tests integrated with CMake and Bazel build systems
- Python tests runnable via standard Python unittest runner
- CMakeLists.txt includes CTest support for orchestration
- Makefile targets: `make test` and `make test_cpp` for C++ tests

**Run Commands:**
```bash
# From Makefile
make test                 # Run all language tests
make test_cpp            # Run C++ tests only

# CMake approach
ctest                    # Run tests via CMake

# Individual test execution
./path/to/test_binary    # Direct execution
python -m pytest ortools/set_cover/python/set_cover_test.py  # Python pytest
absltest ortools/init/python/init_test.py                     # Python absltest
```

## Test File Organization

**Location:**
- Co-located with source: test files in same directory as source files
- Pattern: `module_test.cc` or `module_test.py` (test suffix)
- Example: `ortools/set_cover/assignment.h` paired with `ortools/set_cover/assignment_test.cc`

**Naming:**
- C++: `*_test.cc` files (e.g., `set_cover_test.cc`, `assignment_test.cc`)
- Python: `*_test.py` files (e.g., `set_cover_test.py`, `init_test.py`)

**Structure:**
```
ortools/
├── set_cover/
│   ├── assignment.h
│   ├── assignment.cc
│   ├── assignment_test.cc
│   ├── set_cover_model.h
│   ├── set_cover_model.cc
│   └── set_cover_test.cc
└── init/
    ├── init.h
    ├── init.cc
    └── python/
        ├── init_test.py
        └── init_doc.h
```

## Test Structure

**Suite Organization (C++):**
```cpp
#include "gtest/gtest.h"
#include "ortools/base/gmock.h"

namespace operations_research {
namespace {

TEST(SetCoverAssignment, EmbryonicModelHasZeroCost) {
  SetCoverModel model;
  model.AddEmptySubset(1);
  model.AddElementToLastSubset(0);
  SetCoverAssignment assignment(model);

  EXPECT_TRUE(assignment.CheckConsistency());
  EXPECT_EQ(assignment.cost(), 0.0);
  EXPECT_EQ(assignment.assignment(), SubsetBoolVector(1, false));
}

TEST(SetCoverAssignment, BasicModelHasCost) {
  SetCoverModel model = MakeBasicModel();
  ASSERT_EQ(model.num_subsets(), 4);
  ASSERT_EQ(model.num_elements(), 3);
  SetCoverAssignment assignment(model);

  EXPECT_TRUE(assignment.CheckConsistency());
  EXPECT_EQ(assignment.cost(), 0.0);
}

}  // namespace
}  // namespace operations_research
```

**Suite Organization (Python):**
```python
from absl.testing import absltest

class SetCoverTest(absltest.TestCase):

    def test_save_reload(self):
        model = create_knights_cover_model(10, 10)
        model.sort_elements_in_subsets()
        proto = model.export_model_as_proto()
        reloaded = set_cover.SetCoverModel()
        reloaded.import_model_from_proto(proto)

        self.assertEqual(model.num_subsets, reloaded.num_subsets)
        self.assertEqual(model.num_elements, reloaded.num_elements)

    def test_save_reload_twice(self):
        model = create_knights_cover_model(3, 3)
        inv = set_cover.SetCoverInvariant(model)
        greedy = set_cover.GreedySolutionGenerator(inv)
        self.assertTrue(greedy.next_solution())

if __name__ == "__main__":
    absltest.main()
```

**Patterns:**
- Setup: Create test fixtures in helper methods (e.g., `MakeBasicModel()`)
- Teardown: No explicit teardown needed; implicit via scope cleanup
- Assertion: EXPECT_* for non-fatal checks, ASSERT_* for fatal checks (C++)
- Assertion: `self.assertEqual()`, `self.assertTrue()` (Python)

## Mocking

**Framework:**
- C++: Google Mock (gmock) via `#include "ortools/base/gmock.h"`
- Python: Standard unittest.mock or manual test doubles

**Patterns (C++):**
```cpp
// Minimal mocking observed; most tests use real objects
// Example pattern for state validation:
SetCoverInvariant inv(&model);
CHECK(inv.CheckConsistency(CL::kFreeAndUncovered));
// Verify state after operation
EXPECT_TRUE(inv.CheckConsistency(CL::kRedundancy));
```

**Patterns (Python):**
```python
# Direct object instantiation and method calls
model = set_cover.SetCoverModel()
model.add_empty_subset(1.0)
model.add_element_to_last_subset(0)

# Assertions on state
self.assertEqual(model.num_subsets, expected_value)
```

**What to Mock:**
- External dependencies (file I/O, network calls)
- Third-party solver libraries (Gurobi, GLPK)
- Time-dependent operations

**What NOT to Mock:**
- Core domain objects (SetCoverModel, SetCoverInvariant)
- Algorithm implementations (GreedySolutionGenerator, SteepestSearch)
- Consistency checkers (use real invariant checking)

## Fixtures and Factories

**Test Data:**
```cpp
// C++ helper function pattern
SetCoverModel MakeBasicModel() {
  // 3 elements, 4 subsets (all of unitary cost).
  // Optimal cost: 2 (subsets #0 and #1).
  SetCoverModel model;
  model.AddEmptySubset(1);
  model.AddElementToLastSubset(0);
  model.AddEmptySubset(1);
  model.AddElementToLastSubset(1);
  model.AddElementToLastSubset(2);
  model.AddEmptySubset(1);
  model.AddElementToLastSubset(1);
  model.AddEmptySubset(1);
  model.AddElementToLastSubset(2);
  CHECK(model.ComputeFeasibility());
  return model;
}
```

```python
# Python helper function pattern
def create_initial_cover_model():
    model = set_cover.SetCoverModel()
    model.add_empty_subset(1.0)
    model.add_element_to_last_subset(0)
    model.add_empty_subset(1.0)
    model.add_element_to_last_subset(1)
    model.add_element_to_last_subset(2)
    model.add_empty_subset(1.0)
    model.add_element_to_last_subset(1)
    model.add_empty_subset(1.0)
    model.add_element_to_last_subset(2)
    return model

def create_knights_cover_model(num_rows: int, num_cols: int) -> set_cover.SetCoverModel:
    model = set_cover.SetCoverModel()
    knight_row_move = [2, 1, -1, -2, -2, -1, 1, 2]
    knight_col_move = [1, 2, 2, 1, -1, -2, -2, -1]

    for row in range(num_rows):
        for col in range(num_cols):
            model.add_empty_subset(1.0)
            model.add_element_to_last_subset(row * num_cols + col)
            # ... populate with knight moves

    return model
```

**Location:**
- Helper functions defined in same test file above test class/namespace
- Reusable fixtures shared across multiple tests
- Example: `set_cover_test.py` defines `create_initial_cover_model()` and `create_knights_cover_model()`

## Coverage

**Requirements:** Not enforced by default

**View Coverage:**
- Coverage tracking available through CMake instrumentation
- C++ tests linked with coverage flags via build configuration
- Python coverage: `pip install coverage && coverage run -m pytest`

**Strategies:**
- Focus on algorithm logic and invariant checking
- Ensure state transitions are tested (transitions between `ConsistencyLevel` values)
- Test boundary conditions and edge cases

## Test Types

**Unit Tests:**
- Scope: Single class or function
- Approach: Create minimal model, call method, verify output
- Example: `assignment_test.cc` tests `SetCoverAssignment` in isolation
- Pattern: Test creation, modification, cost computation, consistency checks

**Integration Tests:**
- Scope: Multiple components working together
- Approach: Build model, attach invariants, run solver, verify solution
- Example: `set_cover_test.cc::InitialValues` tests model → generator → invariant flow
- Pattern: Create model, instantiate invariant, run algorithm generator, validate result

**E2E Tests:**
- Framework: Not prominent; project focuses on unit and integration tests
- Approach: Would test complete solve pipelines from model creation to solution export
- Location: Typically in `examples/` directory with sample problems

## Common Patterns

**Async Testing:**
- Not applicable; codebase is primarily synchronous
- C++ uses `std::thread` minimally; no async test patterns observed

**Error Testing:**
```cpp
// C++ pattern: Verify consistency levels
DCHECK(inv()->CheckConsistency(CL::kCostAndCoverage));
inv()->Recompute(CL::kFreeAndUncovered);
EXPECT_TRUE(inv.CheckConsistency(CL::kRedundancy));

// C++ pattern: CHECK for fatal errors in tests
CHECK(model.ComputeFeasibility());
CHECK(trivial.NextSolution());
```

```python
# Python pattern: Assertions on boolean conditions
self.assertTrue(greedy.next_solution())
self.assertIsInstance(major, int)
self.assertEqual(model.num_subsets, reloaded.num_subsets)
```

**State Verification:**
- Tests commonly call `CheckConsistency()` with specific `ConsistencyLevel` enum values
- `ConsistencyLevel` values: `kInconsistent`, `kFreeAndUncovered`, `kCostAndCoverage`, `kRedundancy`
- Each level represents a different set of invariant properties to validate

**Test Helpers:**
- Classes like `KnightsCover` encapsulate complex test setup
- Helper methods return configured models or data structures
- Nested helper classes define test-specific logic (e.g., board position mapping)

---

*Testing analysis: 2026-01-22*
