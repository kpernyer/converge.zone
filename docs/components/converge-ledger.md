# converge-ledger

**Immutable Audit Log**

## Purpose

converge-ledger provides immutable, append-only audit logging for Converge. Every fact produced, every gate passed, every commitment made is recorded in a tamper-evident ledger that supports replay, audit, and compliance.

## Why It Matters

Commitments require accountability. When a quote binds commercial terms, when a contract creates obligations, when an approval releases funds—these acts must be:

- **Recorded**: What happened, when, by whose authority
- **Immutable**: No silent edits, no retroactive changes
- **Replayable**: Reproduce the decision from the same inputs
- **Auditable**: Third parties can verify the trail

This is not logging for debugging. This is institutional memory.

## Place in the Platform

converge-ledger sits alongside the engine as a recording layer:

```
converge-core (engine)
    ↓
    ├── Facts produced → converge-ledger (record)
    ├── Gates passed → converge-ledger (record)
    └── Commitments made → converge-ledger (record)

Later:
    Audit query → converge-ledger → Full decision trail
```

The ledger doesn't affect convergence—it observes and records. But its records become the authoritative source for "what did we decide and why?"

## Key Concepts

### Event Types

| Event | Records |
|-------|---------|
| `FactProduced` | Agent emitted a fact |
| `GatePassed` | Proposal cleared a gate |
| `GateFailed` | Proposal blocked by gate |
| `CommitmentMade` | Fact promoted to committed |
| `CorrectionEvent` | Revision with explicit diff |

### Immutability

Ledger entries are append-only:
- No updates, only new entries
- Corrections create `CorrectionEvent` with before/after
- Hash chains for tamper detection

### Replay

```rust
// Replay a decision
let trail = ledger.get_trail(commitment_id)?;
for event in trail {
    println!("{}: {} by {}", event.timestamp, event.type, event.authority);
}
```

## Governance Alignment

The ledger implements **audit by construction**:

- Every decision has a trail before it's made, not after
- CorrectionEvents prevent silent history rewriting
- Authority is recorded (who, what role, under what policy)
- Trails survive personnel changes and system updates

This is how Converge makes "can we replay and audit the decision later?" a first-class capability, not a compliance afterthought.
