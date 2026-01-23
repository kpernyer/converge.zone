# External Integrations

**Analysis Date:** 2026-01-22

## APIs & External Services

**Third-Party Mathematical Solvers:**
- Gurobi - Mixed integer programming solver
  - SDK/Client: Dynamic loading via `ortools/third_party_solvers/gurobi_environment.h`
  - Integration: C++ wrapper in `ortools/linear_solver/proto_solver/gurobi_proto_solver.h`
  - Auth: License file detection (GUROBI_HOME environment variable or standard paths)
  - Status: Optional, loaded at runtime if available

- CPLEX (IBM) - Mixed integer programming solver
  - SDK/Client: Dynamic loading via wrapper
  - Integration: Linear solver wrapper integration
  - Auth: License environment variable
  - Status: Optional, commercial solver

- Xpress (FICO) - Mixed integer programming solver
  - SDK/Client: Dynamic loading via `ortools/third_party_solvers/xpress_environment.h`
  - Integration: C++ wrapper in `ortools/linear_solver/`
  - Auth: License environment variable
  - Status: Optional, commercial solver

- GLPK (GNU) - Open source LP/MIP solver
  - SDK/Client: Static/dynamic linking
  - Integration: `ortools/third_party_solvers/glpk/`
  - Version: 5.0
  - Status: Open source, optional

- HiGHS - Open source LP/MIP solver
  - SDK/Client: Bazel dependency (`highs v1.11.0`)
  - Integration: Proto solver wrapper in `ortools/linear_solver/proto_solver/`
  - Status: Included in standard build

- SCIP - Mixed integer and constraint programming solver
  - SDK/Client: Bazel dependency (`scip v9.2.3`)
  - Integration: Available via linear solver interface
  - Status: Included in standard build

- CBC/Clp/CoinUtils (COIN-OR) - Open source optimization suite
  - SDK/Client: Dependencies in module registry
  - Integration: Linear solver wrapper
  - Versions: CBC 2.10.12, Clp 1.17.10, CoinUtils 2.11.12
  - Status: Optional

- Soplex - LP solver
  - SDK/Client: Bazel dependency
  - Version: v8.0.0
  - Status: Optional

**Programming Language APIs:**
- Python API - Via pybind11 bindings
  - Modules: `ortools.init`, `ortools.algorithms`, `ortools.bop`, `ortools.glop`, `ortools.graph`, `ortools.gscip`, `ortools.constraint_solver`, `ortools.linear_solver`, `ortools.math_opt`, `ortools.pdlp`, `ortools.sat`, `ortools.scheduling`, `ortools.set_cover`, `ortools.util`, `ortools.service`
  - Published to: PyPI as `ortools`

- Java API - Via SWIG bindings and pom.xml configuration
  - Published to: Maven Central as `com.google.ortools:ortools-java`
  - Supported in samples: `examples/java/`

- C# / .NET API - Via SWIG bindings and .csproj configuration
  - Published to: NuGet as `Google.OrTools`
  - Supported in samples: `examples/dotnet/`

- Go API - Minimal support
  - Module: `github.com/google/or-tools`
  - Dependencies: glog, protobuf
  - Status: Experimental/limited

- C++ API - Native, header-based
  - Headers in: `ortools/*/` directories

## Data Storage

**Databases:**
- None directly integrated - OR-Tools is a solver library, not a persistent data store
- Users integrate with external databases as needed

**File Storage:**
- Protobuf-based serialization for models - `ortools/service/v1/mathopt/` defines proto messages
- No built-in cloud storage integration
- Local filesystem only for reading/writing models

**Caching:**
- None - stateless solver operations

## Authentication & Identity

**Auth Provider:**
- None for public APIs
- Commercial solver integration (Gurobi, CPLEX, Xpress) uses:
  - Environment variables for license paths
  - License file detection via home directory or GUROBI_HOME
  - Dynamic loading prevents failures if license unavailable

**Service Integration:**
- MathOpt Service (via Protocol Buffers) - `ortools/service/v1/mathopt/`
  - Defines service request/response messages in proto format
  - Can be exposed via gRPC or other transport
  - Not bound to specific auth mechanism

## Monitoring & Observability

**Error Tracking:**
- None integrated - uses standard C++ exceptions and absl::Status
- Python bindings expose exceptions back to Python layer
- Go module exposes via standard error handling

**Logs:**
- absl logging (from absl-cpp dependency) - uses absl::LOG
- Python logging via absl-py
- Go logging via github.com/golang/glog
- Solver-specific output:
  - GLOP: solver output configurable via parameters
  - CP-SAT: logging to stdout via cpp_model.py parameters
  - Commercial solvers: output to console by default, configurable

**Metrics:**
- Google Benchmark (v1.9.2) - Performance benchmarking framework
- Solver statistics exposed via solution callbacks
- MIP solver node counts and timing information

## CI/CD & Deployment

**Hosting:**
- GitHub releases - raw binaries and source distributions
- PyPI - Python wheels (linux x86_64/aarch64, macOS Intel/ARM64, Windows x86_64)
- Maven Central - Java releases
- NuGet - .NET packages
- Docker Hub - Pre-built Docker images for multiple distributions

**CI Pipeline:**
- GitHub Actions (`.github/workflows/`)
- Multiple build configurations:
  - Bazel builds (Linux, macOS, Windows, aarch64)
  - CMake builds (Linux, macOS, Windows, with multiple variants)
  - Docker builds (Alpine, Debian, Fedora, Rocky Linux, openSUSE, Arch Linux, FreeBSD)
  - Language-specific: Python, Java, C#, C++, dotnet
  - Solver combinations: with/without Gurobi, CBC, GLPK, SCIP, etc.
- Platform coverage:
  - Linux (x86_64, aarch64)
  - macOS (Intel, ARM64)
  - Windows (x86_64)
  - FreeBSD

**Build Artifacts:**
- Docker container registries (GCR implied by Dockerfiles)
- GitHub releases with prebuilt binaries
- PyPI wheels
- Maven artifacts
- NuGet packages

## Environment Configuration

**Required env vars:**
- `GUROBI_HOME` (optional) - Path to Gurobi installation
- `PYTHONPATH` (optional) - For Python module discovery
- Standard compiler environment variables (CC, CXX, CFLAGS, etc.)

**Optional env vars:**
- Solver-specific configuration via command-line parameters in API calls
- CMake build options:
  - `BUILD_CXX` - Build C++ library (default: ON)
  - `BUILD_PYTHON` - Build Python bindings (default: OFF)
  - `BUILD_JAVA` - Build Java bindings (default: OFF)
  - `BUILD_DOTNET` - Build C# bindings (default: OFF)
  - `BUILD_FLATZINC` - FlatZinc support (default: ON)
  - `BUILD_MATH_OPT` - MathOpt component (default: ON)
  - `BUILD_SAMPLES` - Build examples (default: ON)

**Solver feature flags (Bazel):**
- `--with_bop` - Enable BOP solver
- `--with_cbc` - Enable CBC solver
- `--with_clp` - Enable CLP solver
- `--with_cp_sat` - Enable CP-SAT solver
- `--with_cplex` - Enable CPLEX (requires CPLEX SDK)
- `--with_glop` - Enable GLOP solver
- `--with_glpk` - Enable GLPK solver
- `--with_highs` - Enable HiGHS solver
- `--with_pdlp` - Enable PDLP solver
- `--with_scip` - Enable SCIP solver
- `--with_xpress` - Enable Xpress solver

**Secrets location:**
- License files for commercial solvers (Gurobi, CPLEX, Xpress)
- No built-in secrets management - users manage via environment

## Webhooks & Callbacks

**Incoming:**
- None - OR-Tools is a solver library, not a service

**Outgoing:**
- Solution callbacks available in C++ API:
  - CP-SAT solver: `solution_callback` parameter for receiving intermediate solutions
  - Routing solver: custom local search callback support
- Python callbacks wrap C++ callback interfaces via pybind11
- Used for monitoring solve progress and early termination

**Protobuf Service Definitions:**
- MathOpt service proto definitions in `ortools/service/v1/mathopt/`:
  - `model.proto` - Model definition
  - `parameters.proto` - Solver parameters
  - `result.proto` - Solver results
  - `solution.proto` - Solution format
  - `solver_resources.proto` - Resource definitions
- Can be compiled to gRPC stubs for custom service implementations
- No official managed service endpoint (users can deploy their own gRPC services)

---

*Integration audit: 2026-01-22*
