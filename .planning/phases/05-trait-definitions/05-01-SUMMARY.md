---
phase: 05-trait-definitions
plan: 01
subsystem: capability-traits
tags: [traits, llm, error, gat, async]

dependency-graph:
  requires: [04-gate-pattern]
  provides: [CapabilityError, ErrorCategory, ChatBackend, EmbedBackend, LlmBackend, LlmError]
  affects: [05-02, 05-03, converge-llm]

tech-stack:
  added: []
  patterns: [GAT-async, dyn-safe-wrappers, error-classification]

key-files:
  created:
    - converge-platform/converge-core/src/traits/error.rs
    - converge-platform/converge-core/src/traits/llm.rs
  modified:
    - converge-platform/converge-core/src/traits/mod.rs

decisions:
  - id: 05-01-01
    summary: "GAT async pattern for static dispatch"
    rationale: "Zero-cost async without proc macros or tokio dependency in core"
  - id: 05-01-02
    summary: "DynChatBackend/DynEmbedBackend for runtime polymorphism"
    rationale: "BoxFuture wrappers enable dyn Trait when needed"
  - id: 05-01-03
    summary: "LlmError implements CapabilityError"
    rationale: "Enables generic retry/circuit breaker logic"

metrics:
  duration: 6 min
  completed: 2026-01-24
---

# Phase 05 Plan 01: Error Infrastructure and LLM Traits Summary

**One-liner:** GAT async LLM traits (ChatBackend, EmbedBackend) with CapabilityError classification for zero-cost static dispatch.

## What Was Built

### 1. Error Infrastructure (traits/error.rs)

**ErrorCategory enum** with 9 classification variants:
- Timeout, RateLimit, Auth, InvalidInput, NotFound
- Conflict, Unavailable, InvariantViolation, Internal

**CapabilityError trait** providing:
- `category() -> ErrorCategory` - generic error classification
- `is_transient() -> bool` - condition may clear without request change
- `is_retryable() -> bool` - makes sense to retry given idempotency
- `retry_after() -> Option<Duration>` - suggested delay for rate limits

Key distinction: transient vs retryable are semantically different. Transient (server overloaded) is usually retryable. But conflict (optimistic locking) is retryable but not transient.

### 2. LLM Capability Traits (traits/llm.rs)

**ChatBackend trait** (GAT async pattern):
```rust
pub trait ChatBackend: Send + Sync {
    type ChatFut<'a>: Future<Output = Result<ChatResponse, LlmError>> + Send + 'a
    where
        Self: 'a;
    
    fn chat<'a>(&'a self, req: ChatRequest) -> Self::ChatFut<'a>;
}
```

**EmbedBackend trait** (same pattern):
```rust
pub trait EmbedBackend: Send + Sync {
    type EmbedFut<'a>: Future<Output = Result<EmbedResponse, LlmError>> + Send + 'a
    where
        Self: 'a;
    
    fn embed<'a>(&'a self, req: EmbedRequest) -> Self::EmbedFut<'a>;
}
```

**LlmBackend umbrella** combining both:
```rust
pub trait LlmBackend: ChatBackend + EmbedBackend {}
impl<T: ChatBackend + EmbedBackend> LlmBackend for T {}
```

**Dyn-safe wrappers** for runtime polymorphism:
- `DynChatBackend` with BoxFuture
- `DynEmbedBackend` with BoxFuture
- Blanket impls: any ChatBackend automatically implements DynChatBackend

**LlmError enum** with variants:
- RateLimited, Timeout, AuthDenied, InvalidRequest
- ModelNotFound, ContextLengthExceeded, ContentFiltered
- ProviderError, NetworkError

All variants implement CapabilityError with proper classification.

### 3. Request/Response Types

- ChatRequest, ChatMessage, ChatRole
- ChatResponse, FinishReason, TokenUsage
- EmbedRequest, EmbedResponse

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Async pattern | GAT associated types | Zero-cost, no proc macros, no tokio in core |
| Thread safety | Send + Sync required | Multi-threaded runtime support |
| Error strategy | Trait-specific with shared interface | CapabilityError enables generic handling |
| Polymorphism | Static default, Dyn wrappers when needed | Best of both worlds |

## Deviations from Plan

None - plan executed exactly as written.

Note: Plans 05-02 and 05-03 executed in parallel, resulting in interleaved commits. The mod.rs re-exports were completed by the 05-02 agent in commit 9c28e4e.

## Verification Results

All verification criteria passed:
- [x] `cargo check -p converge-core` compiles without errors
- [x] `cargo test -p converge-core` passes (24 passed, 23 ignored)
- [x] `grep "pub trait ChatBackend"` returns llm.rs
- [x] `grep "pub trait CapabilityError"` returns error.rs
- [x] `grep "impl CapabilityError for LlmError"` confirms implementation

## Files Changed

| File | Change | Lines |
|------|--------|-------|
| src/traits/error.rs | Created | +238 |
| src/traits/llm.rs | Created | +455 |
| src/traits/mod.rs | Modified | +66 (shared with 05-02) |

## Commits

| Hash | Message |
|------|---------|
| ece6cde | feat(05-01): add CapabilityError trait and ErrorCategory enum |
| dfa599d | feat(05-01): add LLM capability traits with GAT async pattern |
| 9c28e4e | feat(05-02): update traits/mod.rs with re-exports (shared) |

## Next Phase Readiness

Phase 05 continues with:
- 05-02: Recall capability traits (RecallReader, RecallWriter) - already executed in parallel
- 05-03: ExperienceStore traits (ExperienceAppender, ExperienceReplayer) - already executed in parallel

The error infrastructure and LLM traits are ready for use by converge-llm implementations.
