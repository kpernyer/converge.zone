# Coding Conventions

**Analysis Date:** 2026-01-22

## Naming Patterns

**Files:**
- Header files: `.h` extension with UPPERCASE_WITH_UNDERSCORES guards (e.g., `ORTOOLS_INIT_INIT_H_`)
- Implementation files: `.cc` extension (C++ source)
- Python files: `.py` extension with snake_case names
- Test files: `_test.cc` or `_test.py` suffix (e.g., `assignment_test.cc`, `set_cover_test.py`)

**Functions:**
- C++: PascalCase (e.g., `ComputeFeasibility()`, `CheckConsistency()`, `ExportSolutionAsProto()`)
- Python: snake_case (e.g., `add_element_to_last_subset()`, `compute_feasibility()`, `check_consistency()`)
- Static/method prefix patterns: `Clear`, `Set`, `Get`, `Compute`, `Check`, `Export`, `Import`, `Load`, `Save`, `Add`

**Variables:**
- C++: snake_case (e.g., `num_subsets`, `subset_costs`, `consistency_level_`)
- Python: snake_case (e.g., `num_rows`, `num_cols`, `knight_row_move`)
- Member variables: trailing underscore in C++ (e.g., `model_`, `cost_`, `constraint_`)

**Types:**
- Classes: PascalCase (e.g., `SetCoverModel`, `SetCoverAssignment`, `SetCoverInvariant`)
- Type aliases: PascalCase (e.g., `SubsetBoolVector`, `SubsetIndex`, `Cost`)
- Constants: UPPERCASE_WITH_UNDERSCORES (e.g., `kNotFound`, `kMaxPossibleCost`)
- Enums: values use `k` prefix (e.g., `kFreeAndUncovered`, `kCostAndCoverage`, `kRedundancy`)

## Code Style

**Formatting:**
- C++: Google C++ style via `.clang-format` with BasedOnStyle:Google
- Pointer alignment: DerivePointerAlignment set to false; PointerAlignment set to Left
- Java: Google Java style
- C#: Microsoft style with NamespaceIndentation: None
- Protocol Buffers: Google style

**Linting:**
- Python: pylint via `.pylintrc` with:
  - Max line length: 100 characters
  - Max module lines: 1000
  - Max nested blocks: 5
  - Good variable names: `i,j,k,x,y,z,t,ex,Run,_`
  - Naming conventions enforced for args, variables, classes, methods, constants

## Import Organization

**Order:**
1. Standard library includes (`#include <cstdint>`, `#include <string>`, `#include <vector>`)
2. Third-party libraries (`#include "absl/..."`)
3. Local OR-Tools headers (`#include "ortools/..."`)

**Path Aliases:**
- C++: `namespace operations_research { ... }` wraps implementation
- Python: Imports use relative paths from `ortools` package (e.g., `from ortools.set_cover.python import set_cover`)

**Spacing:**
- Groups separated by blank lines in C++
- Local project headers at end of include block

## Error Handling

**Patterns:**
- C++: Mixed approach using:
  - `CHECK()` and `DCHECK()` for preconditions and debug assertions
  - `absl::Status` and `absl::StatusOr<T>` for recoverable errors (e.g., `LoadGurobiDynamicLibrary()` returns `absl::Status`)
  - Return value patterns: bool for success/failure, explicit status types for complex operations
  - `ABSL_MUST_USE_RESULT` attribute on critical methods to enforce error checking
- Python: Exceptions via standard Python exception handling with assertions
- No return-code swallowing allowed; errors must be explicitly handled or propagated

## Logging

**Framework:** Abseil logging (`absl::log`) and Google logging

**Patterns:**
- `LOG(INFO)` for informational messages
- `LOG(ERROR)` for error conditions
- `DVLOG(1)`, `DVLOG(2)` for debug verbosity levels
- `LOG(FATAL)` for unrecoverable errors (terminates program)
- Logging configuration via `CppBridge::InitLogging()` in C++
- Python uses standard `print()` and `absl.testing` logging

**Usage in tests:**
- Test setup/teardown may log informational messages
- Assertions use `assert` statements in Python
- C++ tests use `LOG(INFO)` for intermediate results

## Comments

**When to Comment:**
- Explain non-obvious algorithm logic
- Document assumptions about invariants (e.g., "There is a 1:1 mapping between elements and subsets")
- Mark temporary workarounds with `TODO(user):` or `FIXME` tags
- Explain complex transformations or state changes

**JSDoc/TSDoc:**
- Not applicable; project uses C++ and Python primarily
- C++ uses brief `/** ... */` comments above public methods and classes
- Python docstrings follow standard format with module-level documentation

**Format Examples:**
```cpp
// Brief comment explaining logic.
//
// Longer explanation if needed.
```

```python
"""One-line docstring."""
# Inline comment for complex logic
```

## Function Design

**Size:**
- Prefer functions under 50-100 lines (guided by pylint max_statements: 50)
- Break down large functions into smaller helper methods

**Parameters:**
- Maximum 5 parameters per function (pylint max-args: 5)
- Use const references for complex objects in C++
- Use type hints in Python for clarity

**Return Values:**
- Single return point preferred but not enforced
- Use status enums for multiple failure modes (e.g., `ConsistencyLevel` enum for validation levels)
- Return values checked explicitly; no silent failures

## Module Design

**Exports:**
- C++: Public interfaces defined in `.h` files under `namespace operations_research`
- Python: Modules expose classes and functions directly; use `from ortools.module import Class`
- Private implementation hidden in `.cc` files or unnamed namespaces

**Barrel Files:**
- C++ headers sometimes aggregate related components
- Example: `assignment.h` exposes `SetCoverAssignment` class

**Encapsulation:**
- Private members use `private:` section
- Protected members for subclass access
- Public methods prefixed with documentation

---

*Convention analysis: 2026-01-22*
