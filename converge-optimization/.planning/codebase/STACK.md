# Technology Stack

**Analysis Date:** 2026-01-22

## Languages

**Primary:**
- C++ 17 (Linux/macOS, MSVC), C++ 20 (Windows) - Core solver implementation, main library
- C - External solver integration (Gurobi, CPLEX, Xpress, GLPK, HiGHS, SCIP, CBC/Clp/CoinUtils)
- Python 3.9+ - Language bindings and API wrappers
- Java - Language bindings
- C# (.NET) - Language bindings
- FlatZinc - Constraint programming format support
- Go 1.22.2 - Limited support (glog, protobuf)

**Secondary:**
- CMake 3.24+ - Build configuration
- Bazel - Build orchestration (with Bzlmod)
- Make - Legacy build system

## Runtime

**Environment:**
- C++ Standard Library (C++17/20 depending on platform)
- Python 3.9, 3.10, 3.11, 3.12, 3.13, 3.14 (primary for wrapper)
- Java Runtime (for Java bindings)
- .NET Runtime (for C# bindings)

**Package Manager:**
- Bazel with Bzlmod (primary) - manages all dependencies
- pip (Python distribution via setuptools)
- Maven (Java samples)
- NuGet (C# distribution)
- Go modules (go.mod/go.sum for Go minimal support)

**Lockfile:**
- MODULE.bazel (Bazel dependency manifest, Bzlmod format)
- go.mod/go.sum (Go dependency lock)
- Python dependencies resolved via CMake/Bazel pybind11 bindings

## Frameworks

**Core Solvers:**
- CP-SAT (Constraint Programming SAT solver) - `ortools/sat/`
- Glop (Simplex-based LP solver) - `ortools/glop/`
- PDLP (First-order LP solver) - `ortools/pdlp/`
- Constraint Programming Solver - `ortools/constraint_solver/`
- Routing Solver - `ortools/routing/`
- Graph Algorithms - `ortools/graph/`
- Linear Solver (wrapper interface) - `ortools/linear_solver/`

**Wrapper Frameworks:**
- pybind11 (v2.13.6) - C++/Python bindings
- pybind11_abseil (v202402.0) - Abseil support for Python bindings
- pybind11_protobuf - Protobuf support for Python bindings
- SWIG (v4.3.0) - Legacy C++/Java and C++/C# bindings

**Protocol & Serialization:**
- Protocol Buffers (protobuf v32.0) - Model and API serialization
- gRPC (via protobuf) - Service definitions in `ortools/service/v1/`

**Testing:**
- GoogleTest (v1.17.0) - Unit testing framework
- Google Benchmark (v1.9.2) - Performance benchmarking

**Build/Dev:**
- CMake 3.24+ - CMake-based build system (`cmake/` directory)
- Bazel (with rules_cc, rules_java, rules_python, rules_proto) - Hermetic build
- SWIG - C++ wrapper generation

## Key Dependencies

**Critical:**
- Abseil-cpp (20250814.1) - String utilities, status handling, containers
- Protobuf (v33.1, also v32.0 for Bazel) - Model serialization and gRPC definitions
- RE2 (2025-08-12) - Regular expression matching
- Eigen (3.4.0) - Linear algebra (used in solvers)

**Infrastructure:**
- bzip2 (1.0.8.bcr.2) - Compression library
- zlib (1.3.1.bcr.7) - Compression/decompression
- googletest (v1.17.0) - Testing framework
- google_benchmark (1.9.2) - Benchmarking

**Solvers (Optional):**
- GLPK (5.0) - GNU Linear Programming Kit
- HiGHS (v1.12.0) - LP and MIP solver
- SCIP (v10.0.0) - Constraint Integer Programming
- CBC/Clp/CoinUtils (COIN-OR suite) - Mixed integer programming
- Gurobi (v10.0 headers) - Commercial MIP solver (optional, dynamic loading)
- CPLEX - Commercial solver (optional, dynamic loading)
- Xpress - Commercial solver (optional, dynamic loading)
- Soplex (v8.0.0) - LP solver (optional)

**Python Dependencies (from `setup.py.in`):**
- absl-py >= 2.0.0 - Abseil Python library
- numpy >= 2.0.2 - Numerical arrays
- pandas >= 2.0.0 - Data structures
- protobuf >= 6.33.1,<6.34 - Protocol buffers for Python
- typing-extensions >= 4.12 - Type hints
- immutabledict >= 3.0.0 - Immutable dictionary implementation

**Go Dependencies:**
- github.com/golang/glog v1.2.4 - Logging
- google.golang.org/protobuf v1.36.5 - Protocol buffers

## Configuration

**Environment:**
- Bazel configuration: `.bazelrc` with platform-specific settings
- Platform-specific compiler flags defined in `.bazelrc`:
  - Linux: C++17, -Wno-sign-compare, -Wno-range-loop-construct
  - macOS: C++17, macOS 10.15 minimum deployment target, -Wno-dangling-field
  - Windows: C++20, enable runfiles symlink tree
- Python version pinned to 3.12 in MODULE.bazel: `DEFAULT_PYTHON = "3.12"`
- CI/CD config: `.bazelrc` with `ci` config for continuous integration builds

**Build:**
- CMakeLists.txt - Main CMake orchestration
- cmake/ - CMake modules and helpers
- MODULE.bazel - Bazel dependency manifest using Bzlmod
- BUILD.bazel - Package-level build definitions
- bazel/ - Bazel-specific build rules and CI documentation
- makefiles/ - Legacy Makefile build system

**Python Build:**
- setup.py.in - Template for Python setuptools packaging
- Generated from CMake template with version substitution
- Binary distribution (has_ext_modules=True) for compiled C++ extensions

## Platform Requirements

**Development:**
- Ubuntu 18.04 LTS+ (64-bit)
- macOS Mojave+ with Xcode 9.x+ (64-bit)
- Windows with Visual Studio 2022+ (64-bit)
- FreeBSD support (tested)
- CMake 3.24+ or Bazel for building
- SWIG (optional, for legacy C++/Java bindings)
- C++ compiler with C++17 support minimum
- Python 3.9+ (for Python bindings)
- Java 11+ (for Java bindings)
- .NET 7+ (for C# bindings)

**Production:**
- Published to PyPI for Python wheels (pre-built binaries for multiple platforms)
- Published to Maven Central for Java (`com.google.ortools:ortools-java`)
- Published to NuGet for .NET (`Google.OrTools`)
- Docker images available in multiple variants:
  - Ubuntu (base)
  - Alpine Linux (lightweight)
  - Debian, Fedora, Rocky Linux, openSUSE, Arch Linux
  - System deps (uses system package manager)
  - GLOP standalone variant
  - Web variant (for emscripten compilation)
- Standalone C++ library distribution via GitHub releases
- Wheels support: Linux (x86_64, aarch64), macOS (Intel/ARM64), Windows (x86_64)

---

*Stack analysis: 2026-01-22*
