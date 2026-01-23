# Phase 1: CI Foundation - Research

**Researched:** 2026-01-23
**Domain:** cargo-deny, CI pipeline configuration, dependency policy documentation
**Confidence:** HIGH

## Summary

Phase 1 establishes the enforcement infrastructure that prevents dependency drift in converge-core. The phase requires three deliverables: a deny.toml configuration that blocks forbidden dependencies (tokio, reqwest, rayon, rand, sha2, hex, axum, burn, polars), a PURITY.md contract document defining allowed/forbidden boundaries, and CI integration via GitHub Actions.

cargo-deny v0.19.0 is the current stable version (January 2026). The `[bans]` section supports denying specific crates with `use-instead` suggestions and `reason` documentation. Denied crates are blocked whether they appear as direct dependencies or transitive dependencies from other packages. The existing deny.toml in converge-runtime provides a template but lacks the `deny = [...]` field needed for dependency blocking.

**Primary recommendation:** Create deny.toml in converge-platform/converge-core with explicit deny list, configure cargo-deny-action@v2 in CI workflow to fail on forbidden dependencies, and write PURITY.md as the authoritative contract.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| cargo-deny | 0.19.0 | Dependency linting and banning | Official Embark Studios tool, widely adopted in Rust ecosystem |
| cargo-deny-action | v2.0.15 | GitHub Actions integration | Official action, bundles cargo-deny 0.19.0 |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| cargo-audit | latest | Security vulnerability scanning | Already in converge-runtime CI, complementary |
| cargo-deny advisories | built-in | Security advisory checks | Included in cargo-deny check |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| cargo-deny | Manual grep in CI | cargo-deny handles transitive deps, versions, detailed output |
| deny.toml | Cargo.toml workspace patch | Patches require extra packages; deny.toml blocks cleanly |

**Installation:**
```bash
# Local development
cargo install --locked cargo-deny

# CI (via action)
uses: EmbarkStudios/cargo-deny-action@v2
```

## Architecture Patterns

### Recommended File Structure
```
converge-platform/
├── converge-core/
│   ├── Cargo.toml        # Dependencies to validate
│   ├── deny.toml         # cargo-deny configuration
│   └── PURITY.md         # Contract document
├── .github/
│   └── workflows/
│       └── ci.yml        # cargo-deny step
└── Cargo.toml            # Workspace root
```

### Pattern 1: Deny List with Documentation
**What:** Each banned crate includes a reason and suggested alternative
**When to use:** Always - makes policy self-documenting
**Example:**
```toml
# Source: https://embarkstudios.github.io/cargo-deny/checks/bans/cfg.html
[bans]
deny = [
    { crate = "tokio", reason = "async runtime violates purity", use-instead = "define async traits in capability crates" },
    { crate = "reqwest", reason = "HTTP client violates I/O-free constraint", use-instead = "converge-runtime" },
    { crate = "rayon", reason = "parallelism is runtime concern", use-instead = "converge-runtime" },
    { crate = "rand", reason = "randomness violates determinism", use-instead = "dev-dependencies or converge-runtime" },
    { crate = "sha2", reason = "hashing is implementation detail", use-instead = "define Fingerprint trait" },
    { crate = "hex", reason = "only needed for sha2", use-instead = "remove with sha2" },
    { crate = "axum", reason = "HTTP server violates purity" },
    { crate = "burn", reason = "ML runtime violates purity" },
    { crate = "polars", reason = "data processing runtime violates purity" },
]
```

### Pattern 2: Strict Duplicate Detection
**What:** Deny multiple versions of the same crate
**When to use:** For pure crates to minimize bloat
**Example:**
```toml
[bans]
multiple-versions = "deny"
```

### Pattern 3: CI Fail-Fast
**What:** cargo-deny-action fails the build immediately on violations
**When to use:** For blocking enforcement (not warnings)
**Example:**
```yaml
# Source: https://github.com/EmbarkStudios/cargo-deny-action
- name: Run cargo deny
  uses: EmbarkStudios/cargo-deny-action@v2
  with:
    command: check bans
    arguments: --all-features
    manifest-path: ./converge-core/Cargo.toml
```

### Anti-Patterns to Avoid
- **continue-on-error: true** on deny check: Makes enforcement advisory-only. Existing converge-runtime CI has this - must not replicate.
- **Empty deny list with TODO**: Creates false sense of security. Better to not have deny.toml than have one that permits everything.
- **Checking only on PR, not push**: Allows direct pushes to bypass enforcement.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Check if dependency exists | grep Cargo.lock | cargo-deny check bans | Transitive deps, version matching |
| Document dependency policy | Comments in Cargo.toml | PURITY.md contract | Central source of truth, version-controlled |
| Advisory scanning | Manual CVE checks | cargo-deny check advisories | Automated, up-to-date rustsec database |
| License compliance | Manual review | cargo-deny check licenses | Automated, configurable allow-list |

**Key insight:** cargo-deny already handles the hard cases (transitive dependencies, version constraints, feature flags). Reimplementing this logic in shell scripts creates maintenance burden and misses edge cases.

## Common Pitfalls

### Pitfall 1: Path Dependencies Not Checked
**What goes wrong:** cargo-deny does not apply bans to path dependencies by default
**Why it happens:** Path dependencies are local workspace members, often intentionally different
**How to avoid:** Use `workspace = true` in `[bans]` section or run deny on the specific crate
**Warning signs:** Deny passes but `cargo tree -p converge-core | grep tokio` shows violations

### Pitfall 2: Feature-Gated Dependencies Missed
**What goes wrong:** Dependency only pulled in with specific features, deny.toml only checks default
**Why it happens:** Default `cargo deny check` doesn't enable all features
**How to avoid:** Use `--all-features` argument or configure `[graph] all-features = true`
**Warning signs:** CI passes but `cargo build --all-features` pulls forbidden deps

### Pitfall 3: Transitive Dependencies Through Allowed Crates
**What goes wrong:** Allowed crate (e.g., serde) pulls in forbidden transitive dep
**Why it happens:** cargo-deny deny list applies to ALL occurrences, but new versions of allowed crates may add deps
**How to avoid:** Regular `cargo update` in CI with deny check catches new transitives
**Warning signs:** Working build suddenly fails deny after version bump

### Pitfall 4: PURITY.md Drifts From deny.toml
**What goes wrong:** Policy document and enforcement disagree
**Why it happens:** Updated one but not the other
**How to avoid:** CI step that validates PURITY.md lists match deny.toml (can be simple grep comparison)
**Warning signs:** PURITY.md says "allowed: X" but deny.toml has X in deny list

## Code Examples

Verified patterns from official sources:

### Complete deny.toml for converge-core
```toml
# Source: https://embarkstudios.github.io/cargo-deny/checks/bans/cfg.html
# cargo-deny configuration for converge-core purity enforcement

[graph]
all-features = true

[advisories]
db-path = "~/.cargo/advisory-db"
db-urls = ["https://github.com/rustsec/advisory-db"]
unmaintained = "warn"
yanked = "warn"

[licenses]
allow = [
    "MIT",
    "Apache-2.0",
    "Apache-2.0 WITH LLVM-exception",
    "BSD-2-Clause",
    "BSD-3-Clause",
    "ISC",
    "Zlib",
    "0BSD",
    "Unicode-DFS-2016",
    "Unicode-3.0",
    "CC0-1.0",
    "MPL-2.0",
]
unlicensed = "deny"
confidence-threshold = 0.8

[bans]
multiple-versions = "deny"
wildcards = "deny"
deny = [
    # Async runtimes - violate purity
    { crate = "tokio", reason = "async runtime violates I/O-free purity constraint" },
    { crate = "async-std", reason = "async runtime violates purity" },
    { crate = "async-trait", reason = "async macro implies async runtime" },

    # HTTP/Network - violate I/O-free constraint
    { crate = "reqwest", reason = "HTTP client violates I/O-free constraint", use-instead = "converge-runtime" },
    { crate = "hyper", reason = "HTTP library violates I/O-free constraint" },
    { crate = "axum", reason = "HTTP server violates I/O-free constraint", use-instead = "converge-runtime" },

    # Parallelism - runtime concern
    { crate = "rayon", reason = "parallelism is runtime concern", use-instead = "converge-runtime" },

    # Randomness - violates determinism
    { crate = "rand", reason = "randomness violates determinism constraint", use-instead = "trait abstraction" },
    { crate = "rand_core", reason = "randomness violates determinism" },

    # Hashing - implementation detail
    { crate = "sha2", reason = "hashing is implementation detail", use-instead = "Fingerprint trait" },
    { crate = "hex", reason = "encoding for sha2, remove together" },

    # ML/Data runtimes - violate purity
    { crate = "burn", reason = "ML runtime violates purity" },
    { crate = "polars", reason = "data processing runtime violates purity" },
    { crate = "ndarray", reason = "numerical computing implies runtime" },
]

[sources]
unknown-registry = "deny"
unknown-git = "deny"
allow-registry = ["https://github.com/rust-lang/crates.io-index"]
```

### GitHub Actions CI Step
```yaml
# Source: https://github.com/EmbarkStudios/cargo-deny-action
# Add to .github/workflows/ci.yml

  deny:
    name: Dependency Policy
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check dependency policy
        uses: EmbarkStudios/cargo-deny-action@v2
        with:
          command: check bans licenses sources
          arguments: --all-features
          manifest-path: ./converge-core/Cargo.toml
```

### PURITY.md Contract Structure
```markdown
# converge-core Purity Contract

## ALLOWED Dependencies

These dependencies are permitted in converge-core:

| Crate | Version | Purpose | Justification |
|-------|---------|---------|---------------|
| thiserror | 2 | Error derivation | Zero-cost, compile-time only |
| serde | 1 | Serialization traits | Trait-only, no I/O |
| serde_json | 1 | JSON serialization | Required for stable wire format |
| tracing | 0.1 | Logging facade | Facade only, no subscriber |
| strum | 0.26 | Enum derives | Compile-time only |

## FORBIDDEN Dependencies

These dependencies MUST NOT appear in converge-core (enforced by deny.toml):

| Crate | Reason | Alternative |
|-------|--------|-------------|
| tokio, async-std | Async runtime violates purity | Define async traits, implement in runtime crates |
| reqwest, hyper, axum | HTTP/I/O violates purity | converge-runtime |
| rayon | Parallelism is runtime concern | converge-runtime |
| rand | Randomness violates determinism | Trait abstraction |
| sha2, hex | Hashing is implementation detail | Fingerprint trait |
| burn, polars | ML/data processing is runtime | Capability crates |

## Enforcement

- `cargo deny check` MUST pass with zero violations
- CI blocks PRs that add forbidden dependencies
- Any exception requires RFC process and PURITY.md amendment
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual Cargo.toml review | cargo-deny automation | 2019 | Catches transitive deps |
| cargo-deny-action@v1 | cargo-deny-action@v2 | 2024 | Simplified inputs, better defaults |
| cargo-deny 0.14 | cargo-deny 0.19.0 | 2026-01 | workspace crate controls, SARIF output |

**Deprecated/outdated:**
- `cargo-deny-action@v1`: Still works but v2 has cleaner interface
- `bans.deny` with simple strings: Works but object form with reason/use-instead is preferred

## Open Questions

Things that couldn't be fully resolved:

1. **Workspace-level vs crate-level deny.toml**
   - What we know: deny.toml can live at workspace root or crate level
   - What's unclear: Whether converge-core needs separate deny.toml or can use workspace
   - Recommendation: Create crate-level deny.toml in converge-core for explicit scope

2. **PURITY.md location**
   - What we know: Contract document should be version-controlled
   - What's unclear: Whether in converge-core/ or converge-platform/ root
   - Recommendation: converge-core/PURITY.md since it's the crate's contract

3. **Synchronization validation**
   - What we know: PURITY.md and deny.toml can drift
   - What's unclear: Best automated validation approach
   - Recommendation: Start manual, add CI script in later phase if drift occurs

## Sources

### Primary (HIGH confidence)
- [cargo-deny documentation](https://embarkstudios.github.io/cargo-deny/) - configuration reference
- [cargo-deny-action v2.0.15](https://github.com/EmbarkStudios/cargo-deny-action) - GitHub Actions setup
- [cargo-deny bans configuration](https://embarkstudios.github.io/cargo-deny/checks/bans/cfg.html) - deny field options

### Secondary (MEDIUM confidence)
- [Reth project deny.toml](https://github.com/paradigmxyz/reth/blob/main/deny.toml) - real-world example
- Existing converge-runtime/deny.toml - baseline template

### Tertiary (LOW confidence)
- None - all findings verified against official documentation

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - cargo-deny is well-documented, version verified
- Architecture: HIGH - deny.toml structure is explicit in docs
- Pitfalls: MEDIUM - based on GitHub issues and common patterns
- Code examples: HIGH - based on official documentation and templates

**Research date:** 2026-01-23
**Valid until:** 2026-03-23 (60 days - cargo-deny is stable)
