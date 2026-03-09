# NOTE: Delegation Trait Propagation

**Status:** Next epic
**Date noted:** 2026-03-08
**Context:** Learned during converge-policy work on PKI contracts

## Problem

Delegation with PKI is fully implemented in converge-policy (Ed25519 signing,
CBOR-encoded tokens, time-bounded scoped authority) but the abstractions are
self-contained — they don't flow back into core or runtime.

For delegation to be a first-class primitive, the contract shape needs to
propagate through the stack.

## What needs to happen

### converge-traits (or converge-core)

Define the contract shape and verification trait. No crypto here — just the
interface so the engine can reason about delegated authority.

```rust
// Contract shape (fields only, no crypto)
pub struct DelegationContract {
    pub sub: String,
    pub issuer: String,
    pub delegated_authority: String,
    pub actions: Vec<String>,
    pub resource_pattern: String,
    pub max_amount: Option<i64>,
    pub nbf_epoch: i64,
    pub exp_epoch: i64,
    pub jti: String,
}

// Verification trait — implemented by converge-policy
pub trait Verifiable {
    fn verify(&self, pubkey: &[u8]) -> Result<bool>;
}
```

- Add `ContextKey::Delegation` variant so agents can access their authority scope
- Keep converge-core deterministic and crypto-free

### converge-policy

- `impl Verifiable for Delegation` (Ed25519 + CBOR — the real crypto)
- Remains the owner of signing, verification, and Cedar evaluation

### converge-runtime

- Extract delegation tokens from request headers
- Thread them into `Context` before passing to the engine
- Optionally cache/validate tokens before hitting the PDP (fast path)

## Dependency direction

```
converge-traits
  ↑            ↑
converge-core  converge-policy (impl Verifiable)
  ↑
converge-runtime (threading + transport)
```

## Key principle

Core/traits define the shape and contract. Policy owns the crypto. Runtime
handles transport. This avoids circular deps and keeps core deterministic.
