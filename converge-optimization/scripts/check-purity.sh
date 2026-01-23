#!/usr/bin/env bash
# check-purity.sh - Enforce converge-core purity constraints
#
# From JOBS.md: converge-core is the constitution, not the government.
# It must remain pure, portable, and axiomatic.
#
# converge-core IS:
#   - Axioms as types and invariants
#   - The proposal → validation → promotion lifecycle
#   - Minimal interfaces/traits that other crates implement
#   - Portable provenance and trace semantics (shape only)
#
# converge-core IS NOT:
#   - An execution engine for LLMs or solvers
#   - A prompt stack, model router, embedder, recall provider, or backend implementation
#   - A runtime (servers, network, docker, k8s, gRPC, HTTP)
#   - A storage layer (DB drivers, vector DB clients, file persistence)
#
# Exit codes:
#   0 = clean
#   1 = violations found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CORE_SRC="$PROJECT_ROOT/src"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

VIOLATIONS=0

echo "=== Converge-Core Purity Check ==="
echo "Scanning: $CORE_SRC"
echo ""

# Function to check for forbidden patterns in source
check_forbidden() {
    local pattern="$1"
    local description="$2"
    local files

    files=$(grep -rln "$pattern" "$CORE_SRC" --include="*.rs" 2>/dev/null || true)

    if [[ -n "$files" ]]; then
        echo -e "${RED}VIOLATION:${NC} $description"
        echo "  Pattern: $pattern"
        echo "  Files:"
        while IFS= read -r file; do
            local rel_path="${file#$PROJECT_ROOT/}"
            local line_nums
            line_nums=$(grep -n "$pattern" "$file" | head -5 | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
            echo "    - $rel_path (lines: $line_nums)"
        done <<< "$files"
        echo ""
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
}

# Function to check Cargo.toml dependencies
check_cargo_deps() {
    local cargo_file="$PROJECT_ROOT/Cargo.toml"

    # Forbidden dependencies per JOBS.md
    # Network/Runtime: tokio, reqwest, axum, tonic, prost, hyper
    # ML Frameworks: burn, llama-burn, fastembed
    # Data Processing: polars, arrow
    # Databases: lancedb, surrealdb, sqlx, diesel, postgres, rusqlite
    local forbidden_deps=(
        # Network and async runtimes
        "tokio"
        "async-std"
        "reqwest"
        "hyper"
        "axum"
        "tonic"
        "prost"
        "tower"
        "warp"
        "actix"
        # ML frameworks (belong in converge-llm/analytics)
        "burn"
        "llama-burn"
        "fastembed"
        "candle"
        "ort"
        "tract"
        # Data processing (belong in converge-analytics)
        "polars"
        "arrow"
        "datafusion"
        # Databases and storage (belong in providers/runtime)
        "lancedb"
        "surrealdb"
        "sqlx"
        "diesel"
        "rusqlite"
        "mongodb"
        "redis"
        "sea-orm"
    )

    echo "Checking Cargo.toml for forbidden dependencies..."

    for dep in "${forbidden_deps[@]}"; do
        # Check if dependency exists (with various formats)
        if grep -qE "^${dep}(\s*=|\s*\{)" "$cargo_file" 2>/dev/null; then
            # Check if it's optional
            local dep_line
            dep_line=$(grep -A5 "^${dep}" "$cargo_file" | head -6 || true)
            if ! echo "$dep_line" | grep -q "optional\s*=\s*true"; then
                echo -e "${RED}VIOLATION:${NC} Forbidden non-optional dependency: $dep"
                echo "  File: Cargo.toml"
                echo "  Note: This dependency violates core purity. Move to appropriate crate."
                echo ""
                VIOLATIONS=$((VIOLATIONS + 1))
            else
                echo -e "${YELLOW}WARNING:${NC} Optional forbidden dependency: $dep"
                echo "  Ensure feature-gated and not used in core paths."
                echo ""
            fi
        fi
    done
}

# ============================================
# NETWORK AND HTTP CHECKS
# ============================================
echo "--- Checking for HTTP client imports ---"
check_forbidden "use reqwest" "HTTP client (reqwest) not allowed in core"
check_forbidden "reqwest::" "HTTP client (reqwest) not allowed in core"
check_forbidden "use hyper" "HTTP library (hyper) not allowed in core"
check_forbidden "hyper::" "HTTP library (hyper) not allowed in core"

echo "--- Checking for web framework imports ---"
check_forbidden "use axum" "Web framework (axum) not allowed in core"
check_forbidden "axum::" "Web framework (axum) not allowed in core"
check_forbidden "use warp" "Web framework (warp) not allowed in core"
check_forbidden "use actix" "Web framework (actix) not allowed in core"

echo "--- Checking for gRPC/protobuf imports ---"
check_forbidden "use tonic" "gRPC (tonic) not allowed in core"
check_forbidden "tonic::" "gRPC (tonic) not allowed in core"
check_forbidden "use prost" "Protobuf (prost) not allowed in core"
check_forbidden "prost::" "Protobuf (prost) not allowed in core"

# ============================================
# ASYNC RUNTIME CHECKS
# ============================================
echo "--- Checking for async runtime imports ---"
check_forbidden "use tokio" "Async runtime (tokio) not allowed in core"
check_forbidden "tokio::" "Async runtime (tokio) not allowed in core"
check_forbidden "use async_std" "Async runtime (async-std) not allowed in core"
check_forbidden "async_std::" "Async runtime (async-std) not allowed in core"

# ============================================
# ML FRAMEWORK CHECKS
# ============================================
echo "--- Checking for ML framework imports ---"
check_forbidden "use burn" "ML framework (burn) not allowed in core - use converge-analytics"
check_forbidden "burn::" "ML framework (burn) not allowed in core"
check_forbidden "use fastembed" "Embedding library not allowed in core - use converge-llm"
check_forbidden "fastembed::" "Embedding library not allowed in core"
check_forbidden "use candle" "ML framework (candle) not allowed in core"
check_forbidden "candle::" "ML framework (candle) not allowed in core"

# ============================================
# DATA PROCESSING CHECKS
# ============================================
echo "--- Checking for data processing imports ---"
check_forbidden "use polars" "Data processing (polars) not allowed in core - use converge-analytics"
check_forbidden "polars::" "Data processing (polars) not allowed in core"
check_forbidden "use arrow" "Data processing (arrow) not allowed in core"
check_forbidden "arrow::" "Data processing (arrow) not allowed in core"

# ============================================
# DATABASE/STORAGE CHECKS
# ============================================
echo "--- Checking for database imports ---"
check_forbidden "use surrealdb" "Database client not allowed in core - use providers"
check_forbidden "surrealdb::" "Database client not allowed in core"
check_forbidden "use lancedb" "Vector DB client not allowed in core - use providers"
check_forbidden "lancedb::" "Vector DB client not allowed in core"
check_forbidden "use sqlx" "Database library not allowed in core"
check_forbidden "sqlx::" "Database library not allowed in core"
check_forbidden "use diesel" "ORM not allowed in core"
check_forbidden "diesel::" "ORM not allowed in core"

# ============================================
# FILESYSTEM AND I/O CHECKS
# ============================================
echo "--- Checking for filesystem operations ---"
# Allow std::path (types only) but deny std::fs (operations)
check_forbidden "use std::fs" "Filesystem operations not allowed in core"
check_forbidden "std::fs::" "Filesystem operations not allowed in core"
check_forbidden "File::open" "File operations not allowed in core"
check_forbidden "File::create" "File operations not allowed in core"
check_forbidden "read_to_string" "File operations not allowed in core"
check_forbidden "write_all" "File write operations not allowed in core"

echo "--- Checking for environment variable access ---"
check_forbidden "std::env::var" "Environment variable access not allowed in core"
check_forbidden "env::var(" "Environment variable access not allowed in core"

# ============================================
# IMPLEMENTATION PATTERN CHECKS
# ============================================
echo "--- Checking for implementation leakage patterns ---"
# These patterns suggest execution logic that doesn't belong in core
check_forbidden "impl.*LlmBackend" "LLM backend implementation not allowed in core - define trait only"
check_forbidden "impl.*RecallProvider" "Recall provider implementation not allowed in core - define trait only"
check_forbidden "impl.*EmbeddingProvider" "Embedding provider implementation not allowed in core - define trait only"
check_forbidden "async fn.*execute" "Async execution not allowed in core - core is sync and pure"
check_forbidden "\.send\(\)\.await" "Network calls not allowed in core"
check_forbidden "\.fetch\(\)\.await" "Network fetches not allowed in core"

# ============================================
# CARGO.TOML DEPENDENCY CHECK
# ============================================
echo "--- Checking Cargo.toml dependencies ---"
check_cargo_deps

echo ""
echo "=== Summary ==="
if [[ $VIOLATIONS -eq 0 ]]; then
    echo -e "${GREEN}All purity checks passed.${NC}"
    echo ""
    echo "converge-core remains pure:"
    echo "  - No async runtimes (tokio, async-std)"
    echo "  - No HTTP/gRPC (reqwest, hyper, axum, tonic)"
    echo "  - No ML frameworks (burn, fastembed, candle)"
    echo "  - No data processing (polars, arrow)"
    echo "  - No databases (surrealdb, lancedb, sqlx)"
    echo "  - No filesystem operations (std::fs)"
    echo ""
    echo "\"converge-core is the constitution, not the government.\""
    exit 0
else
    echo -e "${RED}Found $VIOLATIONS purity violation(s).${NC}"
    echo ""
    echo "converge-core must be pure (from JOBS.md):"
    echo ""
    echo "  ALLOWED: thiserror, tracing, serde, serde_json, small pure libs"
    echo ""
    echo "  FORBIDDEN:"
    echo "    - Network/Runtime: tokio, reqwest, axum, tonic, prost"
    echo "    - ML Frameworks: burn, fastembed, candle (→ converge-llm/analytics)"
    echo "    - Data Processing: polars, arrow (→ converge-analytics)"
    echo "    - Databases: surrealdb, lancedb, sqlx (→ providers/runtime)"
    echo "    - Filesystem: std::fs (→ providers)"
    echo ""
    echo "Rule: If a module implies execution, I/O, network, model inference,"
    echo "      or persistence, it does not belong in core."
    exit 1
fi
