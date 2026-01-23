#!/usr/bin/env bash
# check-duplicate-modules.sh - Detect duplicate module names across crates
#
# Prevents accidental module shadowing like having backend.rs in both
# converge-core and converge-llm. Re-export shims must be explicitly marked.
#
# Exit codes:
#   0 = no duplicates (or only allowed re-exports)
#   1 = duplicate modules found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Module names that are allowed to exist in multiple crates
# Add entries here for intentional re-export shims
# Note: Domain packs intentionally share module names (solver.rs, invariants.rs)
# since they're namespaced by their parent module (packs::meeting_scheduler::solver etc.)
ALLOWED_DUPLICATES="mod.rs lib.rs main.rs tests.rs test.rs types.rs error.rs prelude.rs solver.rs invariants.rs"

# Crates to check (relative to project root)
# Add more crate paths as the workspace grows
CRATES="src ortools-sys/src"
# Future crates:
# converge-llm/src
# converge-backend/src

echo "=== Duplicate Module Check ==="
echo ""

# Temp file for collecting module locations
TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

for crate in $CRATES; do
    crate_path="$PROJECT_ROOT/$crate"
    if [[ ! -d "$crate_path" ]]; then
        echo -e "${YELLOW}Skipping non-existent crate: $crate${NC}"
        continue
    fi

    # Find all .rs files and extract module names
    find "$crate_path" -name "*.rs" -type f 2>/dev/null | while read -r file; do
        module_name=$(basename "$file")

        # Skip allowed duplicates
        skip=false
        for allowed in $ALLOWED_DUPLICATES; do
            if [[ "$module_name" == "$allowed" ]]; then
                skip=true
                break
            fi
        done
        if $skip; then
            continue
        fi

        rel_path="${file#$PROJECT_ROOT/}"

        # Check if this module is marked as a re-export shim
        if grep -q "// REEXPORT-SHIM" "$file" 2>/dev/null; then
            continue
        fi

        # Output: module_name|path
        echo "${module_name}|${rel_path}"
    done
done > "$TEMP_FILE"

# Check for duplicates
DUPLICATES=0
echo "Checking for duplicate module names..."
echo ""

# Get unique module names that appear more than once
if [[ -s "$TEMP_FILE" ]]; then
    dup_modules=$(cut -d'|' -f1 "$TEMP_FILE" | sort | uniq -d)

    for module_name in $dup_modules; do
        if [[ -z "$module_name" ]]; then
            continue
        fi

        echo -e "${RED}DUPLICATE:${NC} $module_name"
        echo "  Found in multiple locations:"

        # Get all locations for this module
        grep "^${module_name}|" "$TEMP_FILE" | while IFS='|' read -r _ loc; do
            echo "    - $loc"
        done

        echo ""
        echo "  Resolution options:"
        echo "    1. Rename one of the modules to be more specific"
        echo "    2. If intentional re-export, add '// REEXPORT-SHIM' comment to the shim file"
        echo "    3. Add '$module_name' to ALLOWED_DUPLICATES in this script"
        echo ""
        DUPLICATES=$((DUPLICATES + 1))
    done
fi

echo ""
echo "=== Summary ==="
if [[ $DUPLICATES -eq 0 ]]; then
    echo -e "${GREEN}No duplicate modules found.${NC}"
    exit 0
else
    echo -e "${RED}Found $DUPLICATES module name collision(s).${NC}"
    echo ""
    echo "Duplicate module names can cause confusion and import conflicts."
    echo "Each module should have a unique, descriptive name within the workspace."
    exit 1
fi
