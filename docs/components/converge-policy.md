# converge-policy

Converge Policy is the single Cedar-based Policy Decision Point (PDP) for
Converge. It evaluates explicit, auditable facts and returns allow/deny
decisions with traceable reasoning.

See [Governance Architecture](../GOVERNANCE_ARCHITECTURE.md) for how this fits
with converge-personas and converge-ledger.

## Responsibilities

- Evaluate authority constraints for agent actions on flows (propose, validate,
  commit, promote, advance_phase).
- Evaluate gate authorization for persona approvals (PR merge, release, deploy).
- Issue short-lived, signed delegation tokens for temporary agent elevation.
- Provide a minimal, deterministic decision surface for the runtime.

## Non-responsibilities

- It does not own persona definitions or role profiles (that's converge-personas).
- It does not own business context or truth promotion.
- It does not perform agent orchestration or workflow logic.

## Place in the Platform

```
converge-personas  →  entity definitions (who, what team, what authority)
    ↓
converge-policy    →  Cedar PDP (allow/deny decisions + delegation tokens)
    ↓
converge-runtime   →  calls /decide before executing agent actions
    ↓
converge-ledger    →  records every decision for audit
```

## API Surface

| Endpoint | Purpose |
|----------|---------|
| `POST /decide` | Evaluate policy (Cedar) or verify delegation token |
| `POST /issue-delegation` | Mint a scoped, time-limited capability token |
| `GET /pubkey` | Retrieve Ed25519 verification key |

## Key Concepts

### Two Evaluation Paths

1. **Policy path** — full Cedar ABAC evaluation against authority rules
2. **Delegation path** — signed capability token verification (fast, no Cedar)

### Authority Levels

| Level | Meaning |
|-------|---------|
| advisory | Can suggest, cannot commit |
| participatory | Part of human decision process |
| supervisory | Can approve within bounds, commit with human approval |
| sovereign | Full autonomous authority (rare) |

### Delegation Tokens

Ed25519-signed, CBOR-encoded capability tokens that temporarily elevate an
agent's authority. Scoped by time, actions, resources, and spending caps.

Use case: a supervisory agent delegates `validate` authority to an advisory
agent for 2 hours on a specific flow, with a $50k spending cap.

## Governance Alignment

converge-policy is the enforcement layer for Converge's institutional design.
Personas define roles; policy enforces them. Every agent action passes through
`/decide` before execution — no shortcuts, no bypasses.
