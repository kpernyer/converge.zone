# Phase 5: Trait Definitions - Research

**Researched:** 2026-01-24
**Domain:** Rust trait design, async patterns, capability boundaries
**Confidence:** HIGH

## Summary

This phase defines capability boundary traits for converge-core. The research focused on:
1. Current state of the traits/ module (Executor, Randomness, Fingerprint already exist)
2. Existing implementations to deprecate (LlmProvider in llm.rs, LlmBackend in backend.rs, ExperienceStore in experience_store.rs)
3. GAT patterns for async trait signatures (stable since Rust 1.65)
4. Error type design following the CapabilityError pattern from CONTEXT.md
5. Module organization for the split traits decided in CONTEXT.md

The codebase already has established patterns in `src/traits/mod.rs` that should be followed. The existing `LlmBackend` trait in `backend.rs` and `LlmProvider` trait in `llm.rs` represent different abstraction levels - both need deprecation. The `ExperienceStore` trait in `experience_store.rs` and validation patterns in `validation.rs`/`gates/promotion.rs` provide models for the new traits.

**Primary recommendation:** Define traits in `src/traits/` following the existing pattern (signatures only, comprehensive docs, `Send + Sync` bounds), then deprecate existing implementations with actionable messages pointing to BOUNDARY.md.

## Standard Stack

The established patterns for this domain:

### Core
| Pattern | Location | Purpose | Why Standard |
|---------|----------|---------|--------------|
| Capability trait pattern | `traits/mod.rs` | Interface-only traits with `Send + Sync` | Already established in Phase 2 |
| GAT async pattern | Rust 1.65+ | Zero-cost async without proc macros | Decided in CONTEXT.md |
| Error enums with classification | `backend.rs`, `experience_store.rs` | Typed errors with `is_retryable()` | Established pattern in codebase |

### Supporting
| Pattern | Location | Purpose | When to Use |
|---------|----------|---------|-------------|
| Builder pattern | `recall.rs`, `gates/validation.rs` | Ergonomic configuration | Policy/query types |
| ValidationToken (forgery prevention) | `gates/validation.rs` | `pub(crate)` ZST for proof types | Validation/promotion boundary |
| Type-state pattern | `gates/promotion.rs` | Draft -> Validated -> Fact | Proposal lifecycle |

### Patterns from CONTEXT.md Decisions
| Decision | Pattern |
|----------|---------|
| Split traits | `ChatBackend + EmbedBackend`, `RecallReader + RecallWriter`, etc. |
| GAT associated types | `type ChatFut<'a>: Future<...> + Send + 'a where Self: 'a` |
| BoxFuture for dyn | `DynChatBackend` wrapper for runtime polymorphism |
| Trait-specific errors | `LlmError`, `RecallError`, `StoreError` with shared `CapabilityError` |

## Architecture Patterns

### Recommended traits/ Module Structure
```
src/traits/
├── mod.rs              # Re-exports all traits (exists, extend)
├── executor.rs         # Executor trait (already defined in mod.rs)
├── randomness.rs       # Randomness trait (already defined in mod.rs)
├── fingerprint.rs      # Fingerprint trait (already defined in mod.rs)
├── llm.rs              # ChatBackend, EmbedBackend, CompletionBackend, LlmBackend umbrella
├── recall.rs           # RecallReader, RecallWriter, Recall umbrella
├── store.rs            # ExperienceAppender, ExperienceReplayer, ExperienceSnapshotter
├── validator.rs        # Validator trait
├── promoter.rs         # Promoter trait
└── error.rs            # CapabilityError trait + ErrorCategory enum
```

### Pattern 1: GAT Async Trait (Static Dispatch)
**What:** Associated type with lifetime parameter for zero-cost async
**When to use:** Default for all capability traits
**Source:** [Rust GAT Stabilization Blog](https://blog.rust-lang.org/2022/10/28/gats-stabilization.html)
```rust
// From CONTEXT.md decision
pub trait ChatBackend: Send + Sync {
    type ChatFut<'a>: Future<Output = Result<ChatResponse, LlmError>> + Send + 'a
    where
        Self: 'a;

    fn chat<'a>(&'a self, req: ChatRequest) -> Self::ChatFut<'a>;
}
```

### Pattern 2: Dyn-Safe Wrapper (Runtime Polymorphism)
**What:** BoxFuture wrapper for `dyn Trait` usage
**When to use:** When runtime polymorphism needed (routing, heterogeneous backends)
```rust
// From CONTEXT.md decision
pub trait DynChatBackend: Send + Sync {
    fn chat(&self, req: ChatRequest) -> BoxFuture<'_, Result<ChatResponse, LlmError>>;
}

// Blanket impl for easy conversion
impl<T: ChatBackend> DynChatBackend for T {
    fn chat(&self, req: ChatRequest) -> BoxFuture<'_, Result<ChatResponse, LlmError>> {
        Box::pin(ChatBackend::chat(self, req))
    }
}
```

### Pattern 3: Error Classification Trait
**What:** Shared interface for capability errors enabling generic retry/circuit breaker logic
**When to use:** All capability error types
```rust
// From CONTEXT.md decision
pub trait CapabilityError: std::error::Error + Send + Sync {
    fn category(&self) -> ErrorCategory;
    fn is_transient(&self) -> bool;
    fn is_retryable(&self) -> bool;
    fn retry_after(&self) -> Option<Duration>;
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ErrorCategory {
    Timeout,
    RateLimit,
    Auth,
    InvalidInput,
    NotFound,
    Conflict,
    Unavailable,
    InvariantViolation,
    Internal,
}
```

### Pattern 4: Split Traits with Umbrella
**What:** Fine-grained traits combined via supertraits
**When to use:** When capabilities have different authority/governance boundaries
```rust
// From CONTEXT.md decision
pub trait RecallReader: Send + Sync {
    type QueryFut<'a>: Future<Output = Result<Vec<RecallCandidate>, RecallError>> + Send + 'a
    where
        Self: 'a;

    fn query<'a>(&'a self, query: RecallQuery) -> Self::QueryFut<'a>;
}

pub trait RecallWriter: Send + Sync {
    type StoreFut<'a>: Future<Output = Result<(), RecallError>> + Send + 'a
    where
        Self: 'a;

    fn store<'a>(&'a self, record: RecallRecord) -> Self::StoreFut<'a>;
    fn delete<'a>(&'a self, id: &'a str) -> Self::StoreFut<'a>;
}

// Umbrella for convenience
pub trait Recall: RecallReader + RecallWriter {}
impl<T: RecallReader + RecallWriter> Recall for T {}
```

### Anti-Patterns to Avoid
- **async_trait macro in core:** Adds proc-macro dependency, prefer GATs
- **impl blocks in core:** Core defines interfaces only, implementations in capability crates
- **Non-Send futures:** All futures must be `Send` for multi-threaded runtimes
- **Monolithic traits:** Split by authority boundary (read/write, chat/embed)
- **Forgetting deprecation note:** Always include migration path in deprecated attribute

## Don't Hand-Roll

Problems with existing solutions in the codebase:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Async trait signatures | Custom future types | GAT pattern from CONTEXT.md | Established pattern, stable since Rust 1.65 |
| Error classification | Ad-hoc match statements | `CapabilityError` trait | Enables generic retry/circuit breaker |
| Validation proof | Bare structs | `ValidationToken` ZST pattern | Prevents forgery (from `gates/validation.rs`) |
| Deprecation messages | Generic "deprecated" | Actionable note with path + BOUNDARY.md | User must know what to use instead |

**Key insight:** The codebase already has well-established patterns. Follow `traits/mod.rs` for trait structure, `gates/validation.rs` for proof types, and `backend.rs` for error classification.

## Common Pitfalls

### Pitfall 1: Forgetting `where Self: 'a` on GAT
**What goes wrong:** Compiler error about lifetime not living long enough
**Why it happens:** GAT needs explicit lifetime bound to relate to `&self`
**How to avoid:** Always include `where Self: 'a` on GAT declarations
**Warning signs:** "lifetime may not live long enough" errors

### Pitfall 2: Non-actionable deprecation messages
**What goes wrong:** Users see deprecation warning but don't know what to do
**Why it happens:** Missing migration path in the `note` field
**How to avoid:** Always include: (1) what to use instead, (2) link to BOUNDARY.md
**Warning signs:** Deprecation messages without "Use X instead" or "See Y"
**Source:** [Rust Reference - Diagnostics](https://doc.rust-lang.org/reference/attributes/diagnostics.html)

### Pitfall 3: Deprecated attribute on trait impls does nothing
**What goes wrong:** `#[deprecated]` on impl item produces no warning
**Why it happens:** Known Rust limitation - deprecated on trait impls is ineffective
**How to avoid:** Deprecate the struct/type, not the impl block
**Warning signs:** No warnings despite deprecated attribute on impl
**Source:** [Rust Issue #51470](https://github.com/rust-lang/rust/issues/51470)

### Pitfall 4: Missing Send + Sync bounds
**What goes wrong:** Can't use trait objects in async runtimes
**Why it happens:** Forgot to add bounds to trait definition
**How to avoid:** All capability traits require `: Send + Sync`
**Warning signs:** "the trait bound X: Send is not satisfied"

### Pitfall 5: Impl blocks in converge-core
**What goes wrong:** Core becomes coupled to specific implementations
**Why it happens:** Convenience of keeping impl near trait
**How to avoid:** Traits only in core, impls in capability crates
**Warning signs:** Non-mock impl blocks in converge-core for capability traits

## Code Examples

Verified patterns from official sources and codebase:

### Existing Trait Pattern (from traits/mod.rs)
```rust
// Source: converge-platform/converge-core/src/traits/mod.rs
/// Abstracts parallel or sequential execution strategy.
pub trait Executor: Send + Sync {
    fn execute_parallel<T, F, R>(&self, items: &[T], f: F) -> Vec<R>
    where
        T: Sync,
        F: Fn(&T) -> R + Send + Sync,
        R: Send;
}
```

### New Trait Pattern (from CONTEXT.md decision)
```rust
// ChatBackend with GAT async pattern
pub trait ChatBackend: Send + Sync {
    /// Associated future type for chat completions
    type ChatFut<'a>: Future<Output = Result<ChatResponse, LlmError>> + Send + 'a
    where
        Self: 'a;

    /// Send a chat request
    fn chat<'a>(&'a self, req: ChatRequest) -> Self::ChatFut<'a>;
}

// EmbedBackend with GAT async pattern
pub trait EmbedBackend: Send + Sync {
    /// Associated future type for embeddings
    type EmbedFut<'a>: Future<Output = Result<EmbedResponse, LlmError>> + Send + 'a
    where
        Self: 'a;

    /// Generate embeddings for input
    fn embed<'a>(&'a self, req: EmbedRequest) -> Self::EmbedFut<'a>;
}

// Umbrella trait for convenience
pub trait LlmBackend: ChatBackend + EmbedBackend {}
impl<T: ChatBackend + EmbedBackend> LlmBackend for T {}
```

### Deprecation Pattern (from Rust Reference)
```rust
// Source: https://doc.rust-lang.org/reference/attributes/diagnostics.html
#[deprecated(
    since = "2.0.0",
    note = "Use converge_core::traits::ChatBackend instead. See BOUNDARY.md for migration guide."
)]
pub trait LlmProvider: Send + Sync {
    // ... existing signatures ...
}
```

### Error Type Pattern (adapted from backend.rs + CONTEXT.md)
```rust
// Trait-specific error
#[derive(Debug, Clone)]
pub enum LlmError {
    RateLimited { retry_after: Duration },
    Timeout { elapsed: Duration, deadline: Duration },
    AuthDenied { message: String },
    InvalidRequest { message: String },
    ProviderError { message: String },
    NetworkError { message: String },
}

impl std::error::Error for LlmError {}

impl CapabilityError for LlmError {
    fn category(&self) -> ErrorCategory {
        match self {
            Self::RateLimited { .. } => ErrorCategory::RateLimit,
            Self::Timeout { .. } => ErrorCategory::Timeout,
            Self::AuthDenied { .. } => ErrorCategory::Auth,
            Self::InvalidRequest { .. } => ErrorCategory::InvalidInput,
            Self::ProviderError { .. } => ErrorCategory::Internal,
            Self::NetworkError { .. } => ErrorCategory::Unavailable,
        }
    }

    fn is_transient(&self) -> bool {
        matches!(
            self,
            Self::RateLimited { .. } | Self::Timeout { .. } | Self::NetworkError { .. }
        )
    }

    fn is_retryable(&self) -> bool {
        self.is_transient()
    }

    fn retry_after(&self) -> Option<Duration> {
        match self {
            Self::RateLimited { retry_after } => Some(*retry_after),
            _ => None,
        }
    }
}
```

## Existing Implementations to Deprecate

Based on codebase analysis, these items need `#[deprecated]` attributes:

### llm.rs
| Item | Type | Replacement | Notes |
|------|------|-------------|-------|
| `LlmProvider` | trait | `ChatBackend` | Old provider abstraction |
| `LlmRequest` | struct | `ChatRequest` | Request type for chat |
| `LlmResponse` | struct | `ChatResponse` | Response type for chat |
| `LlmError` | enum | `traits::LlmError` | Keep, but move to traits/error.rs |
| `MockProvider` | struct | Test utilities crate | Keep for testing backward compat |

### backend.rs
| Item | Type | Replacement | Notes |
|------|------|-------------|-------|
| `LlmBackend` (existing) | trait | `traits::LlmBackend` (new umbrella) | Unified backend interface |
| `BackendError` | enum | `traits::LlmError` or `CapabilityError` | Consider keeping, implements CapabilityError |

### experience_store.rs
| Item | Type | Replacement | Notes |
|------|------|-------------|-------|
| `ExperienceStore` | trait | `ExperienceAppender + ExperienceReplayer` | Split per CONTEXT.md |
| `ExperienceStoreError` | enum | `StoreError` | Rename to match pattern |

### recall.rs
| Item | Type | Replacement | Notes |
|------|------|-------------|-------|
| (No trait exists) | - | `RecallReader + RecallWriter` | Types exist, trait to be defined |

### validation.rs / gates/
| Item | Type | Replacement | Notes |
|------|------|-------------|-------|
| `ValidationAgent` | struct | Keep, uses `Validator` trait | Concrete agent, not trait |
| Validation types | - | `Validator` trait | New trait wraps existing patterns |

## BOUNDARY.md Content

BOUNDARY.md should contain per CONTEXT.md decision:

### Required Sections

1. **Canonical Table (Normative)**
```markdown
| Trait | Owner | Implementor(s) | Status | Replaces | Notes |
|-------|-------|----------------|--------|----------|-------|
| ChatBackend | converge-core | converge-llm | Stable | LlmProvider, LlmBackend::execute | GAT async |
| EmbedBackend | converge-core | converge-llm | Stable | backend::LlmBackend | Dim constraints |
| RecallReader | converge-core | converge-recall-* | Experimental | (new) | Read-only |
| RecallWriter | converge-core | converge-recall-* | Experimental | (new) | Idempotent |
| ExperienceAppender | converge-core | converge-store-* | Experimental | ExperienceStore::append_event | Append-only |
| ExperienceReplayer | converge-core | converge-store-* | Experimental | ExperienceStore::query_events | Streaming |
| Validator | converge-core | converge-core | Stable | ValidationAgent | Type-state |
| Promoter | converge-core | converge-core | Stable | PromotionGate | Type-state |
```

2. **Per-Capability Sections** (explanatory prose)
- Intent of capability
- Invariants enforced
- Migration notes and examples

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| async_trait macro | GAT associated types | Rust 1.65 (Nov 2022) | Zero-cost async, no proc macro |
| Monolithic LlmBackend | Split ChatBackend + EmbedBackend | Phase 5 | Fine-grained authority |
| Single ExperienceStore | Appender + Replayer + Snapshotter | Phase 5 | Governance boundaries |

**Deprecated/outdated:**
- `async_trait` crate: Unnecessary now that GATs are stable
- Boxing futures by default: Use GATs for static dispatch, BoxFuture only when dyn-safety needed

## Open Questions

Things resolved by CONTEXT.md decisions:

1. **Method signatures** - Exact parameters deferred to implementation
   - What we know: GAT pattern, split traits decided
   - What's unclear: Exact request/response types for each method
   - Recommendation: Model on existing types in `recall.rs`, `backend.rs`

2. **Error variant completeness** - Deferred to implementation
   - What we know: CapabilityError trait pattern decided
   - What's unclear: Full list of variants per error type
   - Recommendation: Start with variants from existing errors, extend as needed

## Sources

### Primary (HIGH confidence)
- converge-core/src/traits/mod.rs - Existing trait patterns
- converge-core/src/backend.rs - LlmBackend and error patterns
- converge-core/src/experience_store.rs - ExperienceStore trait
- converge-core/src/gates/validation.rs - ValidationToken forgery prevention
- converge-core/src/gates/promotion.rs - Type-state promotion pattern
- [Rust Reference - Diagnostics](https://doc.rust-lang.org/reference/attributes/diagnostics.html) - Deprecated attribute spec
- [Rust GAT Stabilization](https://blog.rust-lang.org/2022/10/28/gats-stabilization.html) - GAT patterns

### Secondary (MEDIUM confidence)
- [GAT Design Patterns](https://rust-lang.github.io/generic-associated-types-initiative/design_patterns.html) - Use cases
- [Rust Issue #51470](https://github.com/rust-lang/rust/issues/51470) - Deprecated on impl limitation

### Tertiary (LOW confidence)
- None - all findings verified with official sources

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - based on existing codebase patterns
- Architecture: HIGH - decisions locked in CONTEXT.md
- Pitfalls: HIGH - verified with official Rust documentation
- Deprecation: HIGH - verified with Rust Reference

**Research date:** 2026-01-24
**Valid until:** 60 days (stable domain, decisions locked)
