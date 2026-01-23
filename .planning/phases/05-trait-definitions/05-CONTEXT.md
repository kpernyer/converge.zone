# Phase 5: Trait Definitions - Context

## Implementation Decisions

### Trait Granularity

**LLM Capabilities — Split traits:**
- `ChatBackend` — chat completions
- `EmbedBackend` — embeddings
- `CompletionBackend` — text completion (if needed)
- Optional umbrella: `trait LlmBackend: ChatBackend + EmbedBackend {}`

**Rationale:** Many providers support only subset of capabilities. Split makes boundaries explicit and enforceable. Prevents runtime "not supported" errors for core plumbing.

**Recall (Semantic Memory) — Split by authority:**
- `RecallReader` — `query()` for read-only contexts (validation, audit, replay)
- `RecallWriter` — `store()`, `delete()` for mutation
- Optional umbrella: `trait Recall: RecallReader + RecallWriter {}`

**Rationale:** Read vs write is a governance boundary. Many contexts should be read-only.

**ExperienceStore (Event Sourcing) — Split by operation:**
- `ExperienceAppender` — `append(batch)` append-only events
- `ExperienceReplayer` — `replay(range)` streaming replay
- Optional: `ExperienceSnapshotter` — `snapshot()` capability layered on top
- Optional: `ExperienceSnapshotReader` — `load_snapshot()`

**Rationale:** Append authority is a hard governance boundary. Replay is needed for audit, debugging, deterministic re-execution.

**Validator/Promoter — Keep separate:**
- `Validator` — validates `Proposal<Draft>` → `Proposal<Validated>`
- `Promoter` — promotes `Proposal<Validated>` → `Fact`

**Rationale:** Validation and promotion have different trust and authority. Separation preserves type-state chain and enables human approval gates.

### Async Model

**Strategy:** Sync methods returning futures (no tokio in core)
- **Default:** GAT associated types for zero-cost static dispatch
- **When needed:** BoxFuture wrappers for `dyn Trait` / runtime polymorphism

```rust
// Static dispatch (preferred)
trait ChatBackend {
    type ChatFut<'a>: Future<Output = Result<ChatResp, LlmError>> + Send + 'a
    where Self: 'a;

    fn chat<'a>(&'a self, req: ChatReq) -> Self::ChatFut<'a>;
}

// Dyn-safe wrapper (when needed)
trait DynChatBackend: Send + Sync {
    fn chat(&self, req: ChatReq) -> BoxFuture<'_, Result<ChatResp, LlmError>>;
}
```

**Thread Safety:** Required `Send + Sync` on all capability boundary traits
- Enables multi-threaded runtimes
- Prevents future fragmentation
- Implementors use `Arc<Mutex<...>>` for non-thread-safe state

**No async_trait as default:** Avoid proc-macro dependency in contract layer

### Error Type Strategy

**Scope:** Trait-specific errors with shared classification interface

```rust
// Each capability has its own error type
pub enum LlmError { RateLimited { retry_after: Duration }, Timeout, AuthDenied, ... }
pub enum RecallError { IndexUnavailable, DimensionMismatch, ... }
pub enum StoreError { Conflict, SerializationFailed, ... }

// All implement shared classification trait
pub trait CapabilityError: std::error::Error {
    fn category(&self) -> ErrorCategory;
    fn is_transient(&self) -> bool;
    fn is_retryable(&self) -> bool;
    fn retry_after(&self) -> Option<Duration>;
}
```

**ErrorCategory (shared enum):**
- `Timeout`, `RateLimit`, `Auth`, `InvalidInput`, `NotFound`, `Conflict`, `Unavailable`, `InvariantViolation`, `Internal`

**Semantics:**
- `is_transient()` = underlying condition may clear without changing request
- `is_retryable()` = sensible to retry given typical idempotency

### Deprecation Approach

**Message Style:** Actionable with migration path
```rust
#[deprecated(
    since = "2.0",
    note = "Use converge-llm::ChatBackend instead. See BOUNDARY.md"
)]
pub struct LegacyLlmBackend { ... }
```

**Required elements in note:**
1. What to use instead (exact path)
2. Where to read migration guide (BOUNDARY.md)

**Warning Level:** Deny in CI only
- Warnings visible locally during development
- CI enforces: `RUSTFLAGS="-D deprecated"`
- No `#[allow(deprecated)]` in core

**BOUNDARY.md Structure:**

1. **Canonical table (normative):**

| Trait | Owner | Implementor(s) | Status | Replaces | Notes |
|-------|-------|----------------|--------|----------|-------|
| ChatBackend | converge-core | converge-llm | Stable | LlmBackend::chat | GAT async |
| EmbedBackend | converge-core | converge-llm | Stable | LlmBackend::embed | Dim constraints |
| RecallReader | converge-core | converge-recall-* | Experimental | Recall::query | Read-only |
| RecallWriter | converge-core | converge-recall-* | Experimental | Recall::store | Idempotent |

2. **Prose per capability (explanatory):**
- Intent of capability
- Invariants enforced
- Migration notes and examples

## Deferred Ideas

None captured during discussion.

## Open Questions

1. **Specific method signatures** — Exact parameters for each trait method (deferred to research/planning)
2. **Error variant completeness** — Full list of error variants per capability (deferred to research)
3. **GAT stabilization** — Confirm GAT patterns work with current Rust version

---
*Created: 2026-01-23*
*Phase: 05-trait-definitions*
