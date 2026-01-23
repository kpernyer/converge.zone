# ortools-sys

FFI bindings to Google OR-Tools C++ library.

## Status

**Work in Progress** - The FFI framework is in place but requires API tuning for the specific OR-Tools version. Use the native Rust implementations in `converge-optimization` instead.

## Native Rust Alternatives

The main `converge-optimization` crate provides pure Rust implementations for:

- **Assignment**: Hungarian O(n³) and Auction algorithms
- **Graph**: Dijkstra, Max Flow (Push-Relabel), Min Cost Flow
- **Knapsack**: 0-1 knapsack with dynamic programming
- **Scheduling**: Interval feasibility, disjunctive scheduling
- **Set Cover**: Greedy algorithm

These native implementations are recommended for most use cases.

## Building FFI (when complete)

Requires OR-Tools to be built first:

```bash
# In repo root
cmake -S . -B build -DBUILD_DEPS=ON
cmake --build build -j$(nproc)

# Build Rust with FFI
cargo build --features ffi
```

## Architecture

- `wrapper.h` - C-compatible API header
- `wrapper.cc` - C++ implementation wrapping OR-Tools
- `src/lib.rs` - Rust FFI bindings and safe wrappers
- `build.rs` - Build script for compiling wrapper

## Why C Wrapper?

OR-Tools is a C++ library with heavy template usage. The C wrapper provides:

1. Stable ABI for Rust FFI
2. Opaque pointer types for memory safety
3. Simplified API surface

## Algorithms Targeted for FFI

- CP-SAT solver (constraint programming)
- GLOP/CBC/SCIP (linear/mixed-integer programming)
- Vehicle Routing Problem solver

These complex solvers benefit from OR-Tools' mature C++ implementations.
