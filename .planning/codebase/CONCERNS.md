# Codebase Concerns

**Analysis Date:** 2026-01-23

## Tech Debt

**LLM Model Integration (converge-llm):**
- Issue: Core LLM functionality contains only placeholder implementations with actual integration pending
- Files: `converge-llm/src/model.rs`, `converge-llm/src/tokenizer.rs`, `converge-llm/src/engine.rs`
- Impact: LLM module cannot perform actual inference; weight loading, tokenization, and forward passes are stubbed
- Current state:
  - Weight loading returns success without loading (`model.rs:43-61`)
  - Pretrained model loading is unimplemented (`model.rs:69-79`)
  - Forward pass returns dummy logits (`model.rs:107-129`)
  - Tokenization uses placeholder byte conversion instead of proper tiktoken integration (`tokenizer.rs:209-230`)
- Fix approach:
  1. Integrate llama-burn library for actual model loading
  2. Implement tiktoken-rs for proper tokenization
  3. Implement proper weight serialization/deserialization
  4. Add end-to-end tests with actual model files

**LoRA Weight Merging (converge-llm):**
- Issue: LoRA adapter merging is documented as incomplete and requires deeper integration
- Files: `converge-llm/src/engine.rs:982-986`
- Impact: LoRA adapters cannot be applied at runtime; only pre-merging is possible (loses hot-swap ability)
- Current limitation: llama-burn library needs modification to support runtime LoRA injection
- Fix approach:
  1. Option A: Modify llama-burn to accept LoRA weights at inference time
  2. Option B: Pre-merge LoRA weights into base model (loses dynamic capability)
  3. Option C: Implement custom forward pass that applies LoRA computations inline

**Tokenizer Estimation Issues (converge-llm):**
- Issue: Token estimation uses naive 4-chars-per-token heuristic instead of actual tokenization
- Files: `converge-llm/src/tokenizer.rs:200-204`
- Impact: Context length estimates are conservative and inaccurate; may overflow or underutilize context
- Fix approach: Use actual tokenizer before querying LLM to get precise token counts

**Model Layer Dynamism (converge-llm):**
- Issue: Transformer layer counts are hardcoded based on model family guessing
- Files: `converge-llm/src/engine.rs:573-590`
- Impact: Model configurations not loaded from actual model files; inflexible to new model sizes
- Fix approach: Load layer count from model metadata or config files

## Unfinished Core Features

**Runtime Job Tracking (converge-runtime):**
- Issue: Job status lookup and event retrieval are stubbed with TODO comments
- Files: `converge-runtime/src/grpc/server.rs:234`, `converge-runtime/src/grpc/server.rs:255`
- Impact: gRPC GetJob and GetEvents endpoints return hardcoded demo data; actual job state is not tracked
- Current behavior:
  - `get_job()` always returns status "Pending" regardless of actual job state
  - `get_events()` returns empty event list
  - No connection to job storage or event bus
- Fix approach:
  1. Implement job state persistence in SurrealDB
  2. Build event log mechanism
  3. Implement actual status lookup and event replay
  4. Add sequence-based resumption support

**SSE Control Operations (converge-runtime):**
- Issue: SSE endpoints for control operations (inject fact, approve/reject proposals) are non-functional
- Files: `converge-runtime/src/sse.rs:471`, `converge-runtime/src/sse.rs:495`, `converge-runtime/src/sse.rs:519`
- Impact: Control endpoints return success responses but don't actually modify context or proposals
- Specific gaps:
  - `inject_fact()` doesn't inject facts into context
  - `approve_proposal()` doesn't approve proposals
  - `reject_proposal()` doesn't reject proposals
- Fix approach:
  1. Connect SSE control handlers to context storage
  2. Implement proposal lifecycle management
  3. Persist control operations to event log

**Demo Mode (converge-runtime):**
- Issue: SSE streaming endpoint emits hardcoded demo events instead of real job events
- Files: `converge-runtime/src/sse.rs:331-376`
- Impact: Streaming shows synthetic demo data; actual job progress is not visible
- Current behavior: Single demo "run_status" event emitted after connection
- Fix approach:
  1. Implement actual job lookup from storage
  2. Subscribe to event bus for real-time updates
  3. Replay events since resume sequence
  4. Stream actual context entries as they arrive

**Handler Stub Methods (converge-runtime):**
- Issue: Multiple handler methods are incomplete stubs
- Files: `converge-runtime/src/handlers.rs`
- Specific stubs:
  - `ready()` (line 154): Doesn't check actual service dependencies (SurrealDB, etc.)
  - `create_job()` (line 311-318): Doesn't register agents or deserialize RootIntent properly
  - `plan_form()` (line 175-200): Returns basic response without real planning logic
  - `execute_form()` (line 238-244): Returns receipt without actual form submission
- Impact: API endpoints return plausible but non-functional responses
- Fix approach: Implement proper business logic for each handler

**Graph Matching (converge-optimization):**
- Issue: Bipartite matching algorithms are completely unimplemented
- Files: `converge-optimization/src/graph/matching.rs:8-23`
- Impact: Graph optimization features unavailable; uses `todo!()` macro
- Fix approach: Implement Hopcroft-Karp algorithm and maximum cardinality matching

**Android Model Deserialization (converge-android):**
- Issue: Behavior store cannot deserialize persisted events
- Files: `converge-android/app/src/main/java/zone/converge/android/ml/BehaviorStore.kt:127`
- Impact: Action event history is lost; pattern learning cannot retrieve historical data
- Current state: Always returns empty list (line 124-130)
- Fix approach: Implement proper JSON/Protobuf serialization for ActionEvent

**Android gRPC Stub (converge-android):**
- Issue: gRPC client uses placeholder instead of generated stubs
- Files: `converge-android/app/src/main/java/zone/converge/android/grpc/ConvergeClient.kt:187`
- Impact: gRPC communication is non-functional
- Fix approach: Compile proto files and use generated stubs

## Known Bugs

**Remote Connection Unimplemented (converge-remote):**
- Bug: gRPC reconnection logic is not actually implemented
- Symptoms: Connection manager claims to reconnect but doesn't attempt actual gRPC connection
- Files: `converge-remote/src/connection.rs:79`
- Current behavior: Simulates reconnection with backoff, then returns success
- Impact: Connection failures don't actually attempt to restore gRPC stream
- Workaround: Falls back to REST after 3 simulated attempts
- Fix approach: Implement actual gRPC client reconnection logic

**Test Panics (converge-remote):**
- Bug: Multiple test functions use panic! in assertions instead of proper error handling
- Symptoms: Test failures cause process panic instead of test failure
- Files: `converge-remote/src/main.rs:954-1156` (multiple panic! calls)
- Specific issues:
  - Line 954: `panic!("Expected NumberValue")`
  - Line 965, 976, 987, 998, 1009, 1020, etc.: Similar panics on value type checks
- Impact: Tests cannot be used in CI/CD without process crash risk
- Fix approach: Replace panics with proper assertions (assert!, expect error handling, or test framework assertions)

**Test Unwraps (converge-remote):**
- Bug: Test code uses `.unwrap()` calls that can panic
- Symptoms: Invalid test data causes panic instead of test failure
- Files: `converge-remote/src/streaming.rs:305-328` (multiple unwrap calls in tests)
- Impact: Tests are fragile to malformed responses
- Fix approach: Use `.expect()` with context or `?` operator for propagation

## Security Considerations

**API Key Exposure Risk (converge-runtime):**
- Risk: Environment file contains multiple API key types for LLM providers (Anthropic, OpenAI, Google, Mistral, etc.)
- Files: `converge-runtime/.env.example`
- Current mitigation:
  - Uses `.env.example` template (good)
  - Documented to never commit actual `.env` file
  - Instructions to copy and edit file
- Recommendations:
  1. Add `.env` to `.gitignore` (check if already present)
  2. Consider using secrets management (HashiCorp Vault, AWS Secrets Manager)
  3. Add CI/CD check to prevent .env commits
  4. Consider environment-specific secret injection in deployment
  5. Document which keys are required vs optional

**gRPC Authentication (converge-runtime):**
- Risk: gRPC endpoints appear to have no authentication
- Files: `converge-runtime/src/grpc/server.rs`
- Impact: Any client can invoke control operations (inject facts, approve proposals, create jobs)
- Current state: Capability negotiation exists but no auth checks in handlers
- Recommendations:
  1. Implement mTLS for gRPC server
  2. Add bearer token validation
  3. Implement rate limiting per device/client
  4. Add audit logging for all control operations
  5. Consider device registration/pairing flow

**SSE Authentication (converge-runtime):**
- Risk: SSE endpoints expose job status and events without authentication
- Files: `converge-runtime/src/sse.rs`
- Impact: Any client can subscribe to any job and see all context entries
- Recommendations:
  1. Add device_id validation/registration
  2. Implement session tokens for streaming
  3. Add permission checks for multi-tenant scenarios
  4. Log all streaming connections

**Secrets in Default Config:**
- Risk: Multiple `.env.example` files list provider endpoints and key formats
- Files: `converge-www/.env.example`, `converge-application/.env.example`, `converge-runtime/.env.example`
- Impact: Attackers can identify API patterns and key formats
- Recommendations: Document that .env files should never be committed, and consider removing from repository if already committed

## Performance Bottlenecks

**Blocking Engine Execution (converge-runtime):**
- Problem: Engine run spawned as blocking task without timeout or cancellation
- Files: `converge-runtime/src/handlers.rs:308-322`
- Cause: `spawn_blocking()` without timeout can hang indefinitely if engine loops
- Impact: Slow requests block Tokio runtime; no request timeout protection
- Fix approach:
  1. Add timeout wrapper around blocking task
  2. Implement job cancellation mechanism
  3. Use `tokio::time::timeout()` to limit execution time
  4. Return HTTP 408 on timeout

**Inefficient Behavior Pattern Storage (converge-android):**
- Problem: Action events stored in SharedPreferences as delimited strings instead of database
- Files: `converge-android/app/src/main/java/zone/converge/android/ml/BehaviorStore.kt`
- Cause: Strings parsed line-by-line in loops (lines 56-76, 84-89)
- Impact: O(n) string parsing on every query; doesn't scale beyond 1000 events
- Current limits: `maxEvents = 1000`, `maxSequenceLength = 50`
- Fix approach:
  1. Use Room database instead of SharedPreferences
  2. Implement indexed queries for action transitions
  3. Pre-compute patterns instead of parsing on demand

**Hardcoded Iteration Limits:**
- Problem: Graph matching algorithms have placeholder implementations with no scaling analysis
- Files: `converge-optimization/src/graph/matching.rs`
- Impact: Unknown performance characteristics; no scalability testing
- Fix approach: Implement algorithms with documented complexity analysis

## Fragile Areas

**Model Configuration Management (converge-llm):**
- Files: `converge-llm/src/model.rs`, `converge-llm/src/engine.rs`
- Why fragile:
  - Model sizes guessed from family name and tokenizer hash (lines 577-589)
  - No config file loading
  - Hardcoded layer counts for specific models only
  - Adding new model requires code changes
- Safe modification:
  1. Load config from JSON/YAML file
  2. Query model metadata instead of guessing
  3. Version model configs separately from code
  4. Add schema validation for model configs
- Test coverage: No tests for model configuration loading

**Context Injection (converge-runtime):**
- Files: `converge-runtime/src/sse.rs:460-478`
- Why fragile:
  - No validation of fact keys or values
  - No duplicate detection
  - No type checking for injected facts
  - Idempotency key generated but not checked
- Safe modification:
  1. Validate fact schema before injection
  2. Check idempotency key for deduplication
  3. Implement conflict resolution
  4. Add audit trail
- Test coverage: No tests for SSE control operations

**Tokenization Fallback (converge-llm):**
- Files: `converge-llm/src/tokenizer.rs`
- Why fragile:
  - Byte-to-token conversion is naive (line 213)
  - Handles only ASCII, not UTF-8 properly
  - No fallback error handling
- Safe modification:
  1. Add UTF-8 validation
  2. Implement proper tokenizer with fallback
  3. Add test cases for multilingual text
  4. Cache tokenization results
- Test coverage: Basic tests exist but no multilingual tests

## Scaling Limits

**Job State Storage (converge-runtime):**
- Current capacity: Single-instance SurrealDB without sharding
- Limit: Likely breaks when storing > 100k job snapshots (1 per cycle per job)
- Problem: Composite document IDs (line 334: `format!("{}_{:04}", job_id, cycle)`) limit cycles to 9999
- Scaling path:
  1. Implement database sharding by job_id
  2. Use timestamp-based IDs instead of cycle numbers
  3. Implement archival for old snapshots
  4. Add indexes on job_id and timestamp

**Behavior Pattern Learning (converge-android):**
- Current capacity: 1000 events max, 50-item action sequences
- Limit: At 10 events/day, only ~100 days of history; sequence learning plateaus
- Scaling path:
  1. Move to local SQLite database with better indexing
  2. Implement incremental pattern computation
  3. Add time-window based pattern erosion
  4. Consider cloud-side pattern aggregation

**LLM Context Length (converge-llm):**
- Current capacity: Depends on actual model (estimated 2k-128k tokens)
- Limit: Token estimation is conservative; actual usage will hit limits
- Scaling path:
  1. Implement sliding window for long contexts
  2. Add hierarchical summarization
  3. Implement retrieval-augmented generation (RAG)
  4. Support model switching for different context lengths

## Dependencies at Risk

**llama-burn Integration (converge-llm):**
- Risk: Critical dependency is not actually integrated; only referenced
- Files: `converge-llm/src/model.rs:21-22` (commented out)
- Impact: Core LLM functionality blocked by this integration
- Status: Requires active llama-burn project compatibility
- Migration plan: If llama-burn stalls, consider:
  1. candle-llm (Hugging Face maintained)
  2. mistral-rs (more stable for inference)
  3. vLLM binding (production-proven inference engine)
  4. ONNX runtime (universal model format)

**tiktoken-rs Dependency (converge-llm):**
- Risk: Tokenization placeholder has no actual tiktoken-rs integration
- Files: `converge-llm/src/tokenizer.rs:210, 223`
- Impact: Accurate tokenization unavailable
- Migration plan: If tiktoken-rs unavailable:
  1. Use bpe crate (basic implementation)
  2. Call OpenAI tokenizer API (external dependency)
  3. Implement simple BPE locally for Llama models
  4. Use SentencePiece directly if model supports it

**Burn Framework Stability (converge-llm):**
- Risk: Uses Burn as core ML framework; still evolving with API changes
- Impact: Frequent updates may break compatibility
- Recommendations:
  1. Pin Burn to specific versions
  2. Subscribe to breaking change notifications
  3. Regular compatibility testing
  4. Consider ONNX as alternative for stability

## Missing Critical Features

**Deterministic Mode (converge-runtime):**
- Feature: Documented in capabilities but not implemented
- Files: `converge-runtime/src/sse.rs:402` ("determinism_mode_available: true")
- Problem: Code advertises feature it doesn't have
- Impact: Clients may expect deterministic execution from non-deterministic engine
- Fix: Either implement determinism or change capability flag

**Multi-tenancy (converge-runtime):**
- Feature: Not implemented; single global context
- Impact: Cannot isolate multiple users/tenants; data leakage risk
- Problem areas:
  - No tenant_id in job creation
  - No permission checks in handlers
  - Shared SSE state across all clients
- Fix approach:
  1. Add tenant_id to all requests
  2. Implement tenant isolation in database
  3. Add permission checks to all APIs
  4. Scope SSE connections by tenant

**Job Cancellation (converge-runtime):**
- Feature: No way to stop a running job
- Impact: Runaway jobs consume CPU indefinitely
- Current state: `spawn_blocking()` has no cancellation token
- Fix approach:
  1. Use CancellationToken for background tasks
  2. Expose cancel endpoint in API
  3. Clean up resources on cancellation
  4. Implement grace period before force-kill

**Distributed Execution (converge-runtime):**
- Feature: Engine runs only on single machine
- Impact: Cannot scale horizontally; limited by single CPU
- Current architecture: Monolithic blocking task per request
- Scaling requirements:
  1. Split engine work into distributed tasks
  2. Use message queue for job coordination
  3. Implement worker pool for scaling
  4. Add result caching/memoization

## Test Coverage Gaps

**LLM Module Integration Tests:**
- What's not tested: Actual model loading, weight management, forward passes
- Files: `converge-llm/src/model.rs`, `converge-llm/src/engine.rs`
- Risk: Cannot verify model integration works until runtime
- Problem: Placeholders mean integration tests would fail immediately
- Priority: High - blocks entire LLM functionality
- Recommendation: Add integration tests with real model files (or mocked weights)

**gRPC Control Flow:**
- What's not tested: Job creation → job execution → event streaming → job completion
- Files: `converge-runtime/src/grpc/server.rs`, `converge-runtime/src/handlers.rs`
- Risk: Control flow bugs won't be caught until user integration
- Problem: Stubbed implementations mean tests would show false positives
- Priority: High - core execution path untested
- Recommendation: Implement integration tests with mock SurrealDB

**SSE Reconnection Scenarios:**
- What's not tested: Streaming recovery, sequence-based resume, event replay
- Files: `converge-remote/src/connection.rs`
- Risk: Network failures not properly handled in production
- Problem: Connection manager doesn't actually attempt reconnection
- Priority: High - affects mobile reliability
- Recommendation: Add chaos testing for connection failures

**Android Offline Mode:**
- What's not tested: Local behavior storage, action history recovery
- Files: `converge-android/app/src/main/java/zone/converge/android/ml/BehaviorStore.kt`
- Risk: Offline app state not verified
- Problem: Deserialization is stubbed (line 127)
- Priority: Medium - affects user experience
- Recommendation: Add tests for SharedPreferences serialization/deserialization

**Form Execution Pipeline:**
- What's not tested: Form plan → approval → execution → receipt
- Files: `converge-runtime/src/handlers.rs` (lines 175-244)
- Risk: Form submission flow not end-to-end validated
- Problem: All handlers are basic stubs without business logic
- Priority: Medium - business critical feature untested
- Recommendation: Implement full pipeline tests with validation logic

---

*Concerns audit: 2026-01-23*
