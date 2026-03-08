# Governance Architecture

How Converge enforces authority, gates decisions, and delegates trust.

## The Problem

An AI agent says "approve this $200k commitment." Who authorized it? Under what
policy? Can you prove it? Can you revoke it?

Converge answers these questions with three components working together:

```
converge-personas          converge-policy            converge-ledger
(who you are)        →     (what you can do)    →     (what you did)
                                ↑
                          delegation tokens
                        (temporary elevation)
```

## Components

### converge-personas — Identity & Role Definitions

Defines the 24 agent personas, their authority tiers, and team membership.
Personas are governance configurations, not personalities.

**Authority tiers:**

| Tier | Meaning | Team |
|------|---------|------|
| Blocking-by-Policy | Can unilaterally block promotion | Core (6 personas) |
| Escalating | Can escalate to block | Extended |
| Advisory | Can suggest, cannot block | Extended |

**What it provides:**
- Persona profiles with domain expertise, constraints, framing rules
- Eval prompts for development-time validation (run against Claude)
- Gate suite definitions (pr-merge, release-candidate, deploy, etc.)
- Entity data (entities.json) describing who belongs to which team

**What it does NOT provide:**
- Runtime policy evaluation (that's converge-policy)
- Its own Cedar engine (consolidation target — see below)

### converge-policy — Policy Decision Point (PDP)

A stateless Cedar-based HTTP service that answers one question: **allow or deny?**

**Two evaluation paths:**

1. **Policy path** — Cedar ABAC evaluation against authority rules
2. **Delegation path** — Signed capability token verification (fast path)

**Runtime authority levels:**

| Level | Can Do |
|-------|--------|
| advisory | Propose (capped amounts) |
| participatory | Propose, validate, advance with gates |
| supervisory | Propose, validate, promote, commit (with human approval) |
| sovereign | Everything autonomously |

**API surface:**

| Endpoint | Purpose |
|----------|---------|
| `POST /decide` | Evaluate policy or delegation token |
| `POST /issue-delegation` | Mint a scoped, time-limited capability token |
| `GET /pubkey` | Retrieve verification key |

### converge-ledger — Audit Trail

Every decision, delegation, and gate result is recorded with the persona identity
that produced it. The ledger makes governance provable after the fact.

## Delegation: Temporary Agent Elevation

The key pattern for autonomous agent work. An agent with `advisory` authority
needs to perform a `validate` action (which requires `supervisory`). Instead of
blocking on a human, a supervisor can pre-authorize the work:

```
Supervisor                    converge-policy                Agent
    |                              |                           |
    |-- POST /issue-delegation --> |                           |
    |   sub: "analyst-agent"       |                           |
    |   authority: supervisory     |                           |
    |   actions: [validate]        |                           |
    |   resource: "flow:quote-*"   |                           |
    |   max_amount: 50000          |                           |
    |   exp: +2h                   |                           |
    |                              |                           |
    |<-- delegation_b64 ---------- |                           |
    |                              |                           |
    |-- hand token to agent -------|-------------------------> |
    |                              |                           |
    |                              | <-- POST /decide -------- |
    |                              |     delegation_b64        |
    |                              |     action: validate      |
    |                              |     resource: flow:quote-1|
    |                              |                           |
    |                              | --- allow ------------->  |
```

**Delegation scoping:**

| Scope | How |
|-------|-----|
| Time | `nbf_epoch` / `exp_epoch` — token valid only in window |
| Actions | `actions: [validate]` — only listed actions allowed |
| Resources | `resource_pattern: "flow:quote-*"` — prefix matching |
| Amount | `max_amount: 50000` — spending cap |
| Identity | `sub: "analyst-agent"` — only this agent can use it |

**Security properties:**
- Ed25519 signed, CBOR encoded — tamper-proof
- Time-windowed — auto-expires
- Non-transferable — bound to subject
- Auditable — delegation + usage recorded in ledger

## Consolidation Plan

converge-personas currently embeds its own Cedar engine (cedar-policy 4.8.2)
for gate authorization. This should be consolidated into converge-policy.

### Current State (Dual Cedar)

```
converge-personas/strategic/validator/
  cedar/policies/foundation.cedar        ← gate authorization rules
  cedar/policies/authority-rules.cedar   ← team-based restrictions
  cedar/schema.cedarschema               ← formal schema
  src/policy_engine.rs                   ← embedded Cedar evaluator

converge-policy/rust-pdp-cedar/
  policies/policy.cedar                  ← flow authorization rules
  src/main.rs                            ← Cedar + HTTP service
```

### Target State (Single PDP)

```
converge-policy/
  policies/
    flow-authority.cedar                 ← agent actions on flows
    gate-authority.cedar                 ← persona approvals on gates
    delegation.cedar                     ← delegation constraints
  schema/
    converge.cedarschema                 ← unified schema (v4.8.2)
  src/
    main.rs                              ← single HTTP service

converge-personas/
  personas/                              ← unchanged: role definitions
  evals/                                 ← unchanged: eval prompts
  entities.json                          ← consumed by converge-policy
  (no more Cedar engine)
```

### Migration Steps

1. **Upgrade converge-policy to Cedar 4.8.2** — adopt external schema, validation
2. **Port gate policies** — move foundation.cedar and authority-rules.cedar into converge-policy
3. **Unify entity model** — merge Agent::Persona (flows) and User/Team/Gate (personas) into one schema
4. **Add gate endpoints** — extend `/decide` to handle gate evaluation requests
5. **Remove embedded Cedar from converge-personas** — validator calls converge-policy HTTP API instead
6. **Add delegation-for-gates** — allow temporary gate approval elevation via delegation tokens

### Unified Authority Model

| Authority | Flow Actions | Gate Actions |
|-----------|-------------|--------------|
| advisory | propose (capped) | evaluate (with evidence) |
| participatory | propose, validate | evaluate, approve (if elevated) |
| supervisory | propose, validate, promote, commit (human) | evaluate, approve, create override |
| sovereign | all | all |

Delegation tokens work across both domains — a supervisory agent can delegate
gate approval authority to a participatory agent for a specific release window.

## Design Principles

1. **Explicit over implicit** — every decision has a traceable policy evaluation
2. **Deny by default** — no action is allowed without a matching permit rule
3. **Forbid wins** — Cedar's forbid-overrides-permit prevents escalation bypasses
4. **Least privilege** — agents get advisory; elevation requires delegation
5. **Time-bounded trust** — delegations expire; standing authority is minimal
6. **Auditable** — every allow/deny, every delegation mint/use, goes to the ledger
