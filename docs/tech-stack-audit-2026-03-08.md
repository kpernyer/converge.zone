# Tech Stack Audit - 2026-03-08

Scope: all top-level `converge-*` projects plus root manifests in this workspace.

## Baseline by platform

- Rust services/apps: Rust 2024, `rust-version = 1.85`, `thiserror = 2`
- Web apps/functions: TypeScript + Vite + Bun package manager
- Android: Kotlin + Gradle
- iOS: Swift Package Manager
- Ledger: Elixir/Mix
- Business infra: Nix (`flake.nix`)

## Project inventory

| Project | Primary manifest(s) | Stack classification | Status |
| --- | --- | --- | --- |
| converge-analytics | `Cargo.toml` | Rust | aligned |
| converge-android | `build.gradle.kts`, `settings.gradle.kts` | Kotlin/Gradle | aligned |
| converge-application | `Cargo.toml`, `formfiller/Cargo.toml`, `university-course-application/Cargo.toml` | Rust | aligned (updated in this sweep) |
| converge-business | `flake.nix`, `presentations/investor-deck/package.json` | Nix + Web | partial (investor deck is separate web stack) |
| converge-domain | `Cargo.toml` | Rust | aligned |
| converge-ios | `Package.swift` | Swift/SPM | aligned |
| converge-knowledge | `Cargo.toml` | Rust | aligned |
| converge-ledger | `mix.exs` | Elixir/Mix | aligned |
| converge-llm | `Cargo.toml` | Rust | aligned |
| converge-optimization | `Cargo.toml`, `ortools-sys/Cargo.toml` | Rust | exception (Rust 2021 / 1.75 baseline) |
| converge-personas | `strategic/validator/Cargo.toml` | Rust | aligned (unused dep removed) |
| converge-policy | `rust-pdp-cedar/Cargo.toml` | Rust | partial (manifest aligned; code still legacy) |
| converge-provider | `Cargo.toml`, `provider-mcp/Cargo.toml` | Rust | aligned |
| converge-remote | `Cargo.toml` | Rust | aligned |
| converge-runtime | `Cargo.toml` | Rust | aligned |
| converge-tool | `Cargo.toml` | Rust | aligned |
| converge-www | `package.json`, `functions/package.json` | Web/Bun | aligned (Bun scripts + package manager markers) |

## Changes applied in this sweep

1. Updated Rust baseline in leaf apps:
   - `converge-application/formfiller/Cargo.toml`
   - `converge-application/university-course-application/Cargo.toml`
2. Aligned Rust error stack:
   - `converge-policy/rust-pdp-cedar/Cargo.toml` (`thiserror = "2"`)
3. Removed unused direct dependency:
   - `converge-personas/strategic/validator/Cargo.toml` (removed `itertools`)
4. Aligned web package manager usage:
   - `converge-www/package.json` (`packageManager`)
   - `converge-www/functions/package.json` (Bun scripts + `packageManager`)
   - `converge-www/Justfile` (`bun.lock`/`bun.lockb` check)

## Remaining exceptions and follow-up

1. `converge-optimization` stays on Rust 2021/1.75 and should be treated as an explicit compatibility exception unless upgraded deliberately.
2. `converge-policy/rust-pdp-cedar` fails `cargo check` due Cedar API drift in source code; this is a code-level modernization task, not a manifest-level dependency issue.
3. `converge-business/presentations/investor-deck` remains an independent React 18/npm deck and can be migrated separately if full web-stack unification is desired.

