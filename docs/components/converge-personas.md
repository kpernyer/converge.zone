# converge-personas

**Agent Identity & Governance Roles**

## Purpose

converge-personas defines the identity, constraints, and behavioral boundaries
for AI agents within Converge. Personas are governance configurations that
specify what an agent is authorized to do, how it should frame its outputs, and
what constraints bind its behavior.

See [Governance Architecture](../GOVERNANCE_ARCHITECTURE.md) for how this fits
with converge-policy and converge-ledger.

## Why It Matters

"AI agent" is dangerously vague. An agent without bounds is a liability. Personas
make agent behavior:

- **Bounded**: What domains can this agent operate in?
- **Authorized**: What actions require escalation?
- **Consistent**: How does this agent frame uncertainty?
- **Auditable**: What identity appears in the audit trail?

Personas turn "the AI said" into "the Strategic Analyst agent, operating under
Policy v2.3, with Advisory authority, said."

## Place in the Platform

```
converge-personas  ←── Persona definitions + entity data
    ↓
converge-policy (entities.json → Cedar PDP evaluation)
    ↓
converge-domain (agents adopt personas)
    ↓
converge-llm (personas shape prompts)
    ↓
converge-ledger (personas appear in audit)
```

## What It Contains

| Directory | Purpose |
|-----------|---------|
| `personas/` | 24 role profiles with audit prompts |
| `evals/` | Lightweight validation prompts for Claude |
| `contracts/` | Phase responsibility contracts (RACI) |
| `schemas/` | JSON Schema for gate execution, escalation packets |
| `entities.json` | Cedar entity data consumed by converge-policy |

## What It Does NOT Contain

Policy evaluation. converge-personas defines *who* agents are; converge-policy
decides *what they can do*. There is no embedded Cedar engine here.

## Key Concepts

### Authority Tiers

| Tier | Meaning | Team |
|------|---------|------|
| Blocking-by-Policy | Can unilaterally block promotion | Core (6) |
| Escalating | Can escalate to block | Extended |
| Advisory | Can suggest, cannot block | Extended |

### Core Team (6 personas)

System Architect, QA Engineer, Security Auditor, Founder, Legal Counsel,
Ethics & Safety Officer.

### Eval Suites

| Suite | When | Blocking? |
|-------|------|-----------|
| pr-merge | Before PR merge | Medium risk |
| release-candidate | Before RC tag | High risk |
| release-critical | Release approval | Blocking |
| deploy | Before production | High risk |

## Governance Alignment

Personas implement **human roles as authority semantics**:

- Agents don't freelance; they operate within defined roles
- Authority tiers map to converge-policy's Cedar rules
- Constraints are enforced at the PDP, not suggested
- Audit trails include persona identity via converge-ledger
