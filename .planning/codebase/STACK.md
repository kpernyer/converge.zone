# Technology Stack

**Analysis Date:** 2026-01-23

## Languages

**Primary:**
- Rust 1.85 - Core platform, analytics, optimization, LLM inference, runtime, CLI tools
- TypeScript 5.8 - Web frontend (React), Firebase Cloud Functions, configuration
- JavaScript/Node 20 - Firebase functions, build tooling

**Secondary:**
- Swift - iOS mobile platform (`/Users/kpernyer/repo/converge.zone/converge-ios`)
- Kotlin - Android mobile platform (`/Users/kpernyer/repo/converge.zone/converge-android`)
- Gherkin - Test specifications

## Runtime

**Environment:**
- Node.js 20 - Firebase Cloud Functions, web tooling
- Rust 1.85 - Backend services, analytics, LLM

**Package Managers:**
- npm 10+ (Node) - For `converge-www` and Cloud Functions
- Cargo (Rust) - All Rust crates and workspace
- Bun (optional) - Used in build scripts (`bun run` in package.json)
- Swift Package Manager - iOS build
- Gradle - Android build

**Lockfiles:**
- package-lock.json present in `converge-www/` and `converge-www/functions/`
- Cargo.lock generated for Rust workspace

## Frameworks

**Frontend:**
- React 19.2 - UI framework (`converge-www`)
- React Router 7.12 - Client-side routing
- Vite 6.3 - Build tool and dev server
- TypeScript 5.8 - Type safety

**Backend/Runtime:**
- Axum 0.7 - HTTP web framework (`converge-runtime`)
- Tonic 0.11 - gRPC server framework (`converge-runtime`, `converge-remote`)
- Tower/Tower-HTTP 0.5 - Middleware and request handling
- Tokio 1 (full features) - Async runtime across all Rust services

**LLM & ML:**
- Burn 0.20 - Neural network framework (`converge-llm`, `converge-analytics`)
- Polars 0.51 - Data processing and analysis (`converge-analytics`)
- Llama-burn - LLaMA inference via Tracel-AI (`converge-llm`)
- Tiktoken-rs 0.5 - Token encoding for LLM (`converge-llm`)
- FastEmbed 4.0 - Semantic embeddings (optional feature) (`converge-llm`)

**Optimization:**
- OR-Tools subset (Rust reimplementation) - Constraint programming (`converge-optimization`)
- Varisat - SAT solver (optional) (`converge-optimization`)
- Petgraph 0.7 - Graph algorithms
- Rayon 1.10 - Parallelism

**Testing & Development:**
- Vitest or Jest - JavaScript/TypeScript testing
- Criterion 0.5 - Rust benchmarking (`converge-analytics`, `converge-optimization`)
- Proptest 1.5 - Property-based testing (Rust)
- Mockall 0.13 - Mocking library (Rust tests)

**Serialization & Config:**
- Serde 1.0 - Serialization framework (Rust)
- Serde_json 1.0 - JSON handling
- Zod 4.3 - TypeScript schema validation (`converge-www`)
- YAML support (serde_yaml) - Configuration files
- TOML parsing - Cargo configuration

**Markdown & Content:**
- Marked 17.0 - Markdown parsing (`converge-www`)
- Gray-matter 4.0 - YAML front-matter parsing (`converge-www`)
- DOMPurify 3.3 - HTML sanitization (`converge-www`)

## Key Dependencies

**Critical Core:**
- `converge-core` 0.6.2 - Private proprietary kernel (compiled library only, published from `converge-platform/converge-core`)
- `converge-provider` 0.2.4 - LLM provider interface and implementations
- `converge-domain` 0.2.4 - Domain entity definitions
- `converge-tool` 0.2.1 - Gherkin specification validation

**API & Integration:**
- `firebase-admin` 12.0 - Firebase admin SDK for Node.js (`converge-www/functions`)
- `firebase-functions` 5.0 - Cloud Functions framework
- `resend` 6.7 - Email delivery service (`converge-www/functions`)
- `reqwest` 0.12 - HTTP client (blocking and async) - Used across Rust services for API calls
- `gherkin` 0.14 - Gherkin parser for test specifications (`converge-tool`)

**Observability & Logging:**
- `tracing` 0.1 - Distributed tracing framework (all services)
- `tracing-subscriber` 0.3 - Logging subscriber and filters
- `sentry` 0.34 - Error tracking (optional, `converge-runtime`)
- `metrics` 0.22 - Prometheus metrics (optional, `converge-runtime`)
- `opentelemetry` 0.21 - Distributed tracing (optional, `converge-runtime`)

**Error Handling:**
- `thiserror` 2.0 - Error type derivation (Rust)
- `anyhow` 1.0 - Error context (Rust)

**Cryptography & Hashing:**
- `sha2` 0.10 - SHA-256 hashing
- `blake3` 1.5 - Blake3 hashing (`converge-llm`)
- `hex` 0.4 - Hex encoding

**Data Processing:**
- `ndarray` 0.17 - Numerical arrays (`converge-analytics`, `converge-llm`)
- `rand` 0.8 - Random number generation
- `proptest` 1.5 - Property-based testing
- `bincode` 2.0-rc3 - Binary serialization (`converge-analytics`)

**Platform-Specific:**
- Strum 0.26 - Enum derives (Rust)
- Chrono 0.4 - Date/time handling
- UUID 1.0 - Unique identifier generation
- Hostname 0.4 - System hostname retrieval

## Configuration

**Environment:**
- `.env` files for local development (gitignored)
- `.env.example` templates for setup instructions
- `firebase.json` - Firebase Hosting and Functions configuration
- `tsconfig.json` - TypeScript compiler options (ES2022 target)

**Build Configuration:**
- `Cargo.toml` - Rust workspace and member configurations
- `package.json` - npm scripts for frontend and functions
- `vite.config.ts` - Vite bundler configuration (implied)
- `vitest.config.ts` or `jest.config.js` - Test runner setup (implied from scripts)

**Linting & Formatting:**
- ESLint 9.28 - JavaScript/TypeScript linting
- Prettier 3.5 - Code formatting
- Rust clippy lints enforced via workspace (`all` and `pedantic` levels with explicit allows)

## Platform Requirements

**Development:**
- Rust 1.85+ with Cargo
- Node.js 20
- TypeScript 5.8
- Git (with hooks in `.githooks/`)
- macOS (Darwin) development environment

**Production:**
- Firebase Hosting (for web frontend)
- Google Cloud Platform (Firestore, Cloud Functions)
- HTTP/2 support for gRPC communication
- Container runtime (Docker) for deployments (Dockerfiles present in `converge-ledger/` and `converge-runtime/`)

---

*Stack analysis: 2026-01-23*
