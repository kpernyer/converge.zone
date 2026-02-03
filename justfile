# Converge Zone - Monorepo Commands
# Run `just --list` to see all available commands
# Run `just doctor` to check your development environment

# Default: show available commands
default:
    @just --list

# =============================================================================
# Doctor - Environment Health Checks
# =============================================================================

# Check development environment health (recursive into all components)
doctor: _doctor-banner _doctor-global _doctor-components _doctor-summary

# Run doctor on a specific component
doctor-component component:
    @if [ -f "converge-{{component}}/justfile" ] || [ -f "converge-{{component}}/Justfile" ]; then \
        cd converge-{{component}} && just doctor 2>/dev/null || echo "  ⚠ No doctor recipe in converge-{{component}}"; \
    else \
        echo "  ✗ Component converge-{{component}} not found"; \
    fi

_doctor-banner:
    @echo "═══════════════════════════════════════════════════════════════════"
    @echo "  CONVERGE ZONE - DEVELOPMENT ENVIRONMENT DOCTOR"
    @echo "═══════════════════════════════════════════════════════════════════"
    @echo ""

_doctor-global:
    @echo "┌─────────────────────────────────────────────────────────────────┐"
    @echo "│  GLOBAL PREREQUISITES                                          │"
    @echo "└─────────────────────────────────────────────────────────────────┘"
    @just _check-cmd "just"     "just --version"      "https://github.com/casey/just"
    @just _check-cmd "git"      "git --version"       "https://git-scm.com"
    @just _check-cmd "docker"   "docker --version"    "https://docker.com"
    @just _check-cmd "rustc"    "rustc --version"     "https://rustup.rs"
    @just _check-cmd "cargo"    "cargo --version"     "https://rustup.rs"
    @just _check-cmd "mix"      "mix --version"       "https://elixir-lang.org/install.html"
    @just _check-cmd "bun"      "bun --version"       "https://bun.sh"
    @just _check-cmd "firebase" "firebase --version"  "npm install -g firebase-tools"
    @just _check-cmd "gh"       "gh --version"        "https://cli.github.com"
    @echo ""
    @just _check-rust-version
    @just _check-docker-running
    @just _check-git-hooks
    @just _check-env-file
    @echo ""

_doctor-components:
    #!/usr/bin/env bash
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│  COMPONENT HEALTH                                              │"
    echo "└─────────────────────────────────────────────────────────────────┘"
    for dir in converge-*/; do
        name=$(basename $dir)
        if [ -f "$dir/justfile" ] || [ -f "$dir/Justfile" ]; then
            echo ""
            echo "── $name ──"
            (cd $dir && just doctor 2>/dev/null) || echo "  ⚠ No doctor recipe"
        fi
    done
    echo ""

_doctor-summary:
    @echo "═══════════════════════════════════════════════════════════════════"
    @echo "  Doctor complete. Fix any ✗ items above."
    @echo "  Run 'just setup' to install missing tools."
    @echo "═══════════════════════════════════════════════════════════════════"

# Helper: check if command exists
_check-cmd name version_cmd install_hint:
    #!/usr/bin/env bash
    if command -v {{name}} >/dev/null 2>&1; then
        version=$({{version_cmd}} 2>&1 | head -1)
        printf "  ✓ %-12s %s\n" "{{name}}" "$version"
    else
        printf "  ✗ %-12s not found → %s\n" "{{name}}" "{{install_hint}}"
    fi

# Helper: check Rust version meets minimum
_check-rust-version:
    #!/usr/bin/env bash
    if command -v rustc >/dev/null 2>&1; then
        version=$(rustc --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
        major=$(echo $version | cut -d. -f1)
        minor=$(echo $version | cut -d. -f2)
        if [ "$major" -gt 1 ] || ([ "$major" -eq 1 ] && [ "$minor" -ge 85 ]); then
            echo "  ✓ Rust version $version >= 1.85 (edition 2024)"
        else
            echo "  ✗ Rust version $version < 1.85 (need 1.85+ for edition 2024)"
        fi
    fi

# Helper: check Docker daemon is running
_check-docker-running:
    #!/usr/bin/env bash
    if command -v docker >/dev/null 2>&1; then
        if docker info >/dev/null 2>&1; then
            echo "  ✓ Docker daemon running"
        else
            echo "  ✗ Docker daemon not running"
        fi
    fi

# Helper: check git hooks are configured
_check-git-hooks:
    #!/usr/bin/env bash
    hooks_path=$(git config core.hooksPath 2>/dev/null || echo "")
    if [ "$hooks_path" = ".githooks" ]; then
        echo "  ✓ Git hooks configured (.githooks)"
    else
        echo "  ⚠ Git hooks not configured → run 'just setup-hooks'"
    fi

# Helper: check .env file exists
_check-env-file:
    #!/usr/bin/env bash
    if [ -f ".env" ]; then
        echo "  ✓ .env file exists"
    else
        echo "  ⚠ .env file missing → copy from .env.example"
    fi

# =============================================================================
# Setup
# =============================================================================

# Set up git hooks for all components
setup-hooks:
    git config core.hooksPath .githooks
    @echo "✓ Git hooks configured"

# Install common development tools
setup-tools:
    cargo install cargo-llvm-cov cargo-audit cargo-deny cargo-watch
    @echo "✓ Cargo tools installed"

# Install cz CLI (the workspace orchestrator)
install-cz:
    cd converge-tool && cargo install --path . --bin cz
    @echo "✓ cz installed to ~/.cargo/bin/cz"
    @echo ""
    @echo "You can now use 'cz' commands:"
    @echo "  cz doctor     - Check environment health"
    @echo "  cz bootstrap  - Set up development environment"
    @echo "  cz test       - Run tests"
    @echo "  cz up         - Start services"

# Full development setup
setup: setup-hooks setup-tools install-cz
    @echo "✓ Development environment ready"

# =============================================================================
# Recursive Commands - Run across all components
# =============================================================================

# Format all components
fmt:
    #!/usr/bin/env bash
    for dir in converge-*/; do
        if [ -f "$dir/justfile" ] || [ -f "$dir/Justfile" ]; then
            echo "Formatting $(basename $dir)..."
            (cd $dir && just fmt 2>/dev/null) || true
        fi
    done

# Check formatting across all components
fmt-check:
    #!/usr/bin/env bash
    for dir in converge-*/; do
        if [ -f "$dir/justfile" ] || [ -f "$dir/Justfile" ]; then
            echo "Checking $(basename $dir)..."
            (cd $dir && just fmt-check 2>/dev/null) || true
        fi
    done

# Run tests across all components
test:
    #!/usr/bin/env bash
    for dir in converge-*/; do
        if [ -f "$dir/justfile" ] || [ -f "$dir/Justfile" ]; then
            echo "Testing $(basename $dir)..."
            (cd $dir && just test 2>/dev/null) || true
        fi
    done

# Run CI checks across all components
ci:
    #!/usr/bin/env bash
    for dir in converge-*/; do
        if [ -f "$dir/justfile" ] || [ -f "$dir/Justfile" ]; then
            echo "CI for $(basename $dir)..."
            (cd $dir && just ci 2>/dev/null) || true
        fi
    done

# Clean all components
clean:
    #!/usr/bin/env bash
    for dir in converge-*/; do
        if [ -f "$dir/justfile" ] || [ -f "$dir/Justfile" ]; then
            echo "Cleaning $(basename $dir)..."
            (cd $dir && just clean 2>/dev/null) || true
        fi
    done

# =============================================================================
# Service Management
# =============================================================================

# Start all services (Docker Compose)
up:
    cd converge-runtime && docker compose up -d

# Stop all services
down:
    cd converge-runtime && docker compose down

# View service logs
logs service="":
    @if [ -z "{{service}}" ]; then \
        cd converge-runtime && docker compose logs -f; \
    else \
        cd converge-runtime && docker compose logs -f {{service}}; \
    fi

# Service status
ps:
    cd converge-runtime && docker compose ps

# =============================================================================
# Quick Reference
# =============================================================================

# Show component overview
components:
    @echo "Converge Zone Components:"
    @echo ""
    @echo "  Core (Rust):"
    @echo "    converge-core         Deterministic convergence engine"
    @echo "    converge-domain       Business domain models"
    @echo "    converge-llm          Reasoning kernel"
    @echo "    converge-provider     LLM provider implementations"
    @echo "    converge-runtime      HTTP/gRPC server"
    @echo "    converge-application  Distribution layer"
    @echo ""
    @echo "  Services:"
    @echo "    converge-ledger       Audit log (Elixir)"
    @echo "    converge-policy       Cedar policy engine (Rust)"
    @echo "    converge-analytics    Data analysis (Rust/Polars)"
    @echo "    converge-optimization CP-SAT optimization (Rust)"
    @echo ""
    @echo "  Mobile & Web:"
    @echo "    converge-www          Website (React/TypeScript)"
    @echo "    converge-ios          iOS SDK (Swift)"
    @echo "    converge-android      Android SDK (Kotlin)"
    @echo ""
    @echo "  Documentation:"
    @echo "    converge-business     Business docs, ADRs"
    @echo "    converge-personas     AI persona governance"
