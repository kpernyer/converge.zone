# converge-personas

**AI Persona Definitions**

## Purpose

converge-personas defines the identity, constraints, and behavioral boundaries for AI agents within Converge. Personas are not "personalities"—they are governance configurations that specify what an agent is authorized to do, how it should frame its outputs, and what constraints bind its behavior.

## Why It Matters

"AI agent" is dangerously vague. An agent without bounds is a liability. Personas make agent behavior:

- **Bounded**: What domains can this agent operate in?
- **Authorized**: What actions require escalation?
- **Consistent**: How does this agent frame uncertainty?
- **Auditable**: What identity appears in the audit trail?

Personas turn "the AI said" into "the Strategic Analyst agent, operating under Policy v2.3, with Advisory authority, said."

## Place in the Platform

converge-personas provides configuration for agents across the platform:

```
converge-personas  ←── Persona definitions (YAML + Rust)
    ↓
converge-domain (agents adopt personas)
    ↓
converge-llm (personas shape prompts)
    ↓
converge-ledger (personas appear in audit)
```

When a StrategicInsightAgent runs, it doesn't just "use Claude." It operates as a defined persona with explicit constraints.

## Key Concepts

### Persona Components

| Component | Purpose |
|-----------|---------|
| Identity | Name, role, domain expertise |
| Authority | Advisory, Supervisory, Participatory, Sovereign |
| Constraints | What topics are off-limits |
| Framing | How to express uncertainty, dissent |
| Policy Binding | Which policy version applies |

### Authority Levels

| Level | Meaning |
|-------|---------|
| Advisory | Can suggest, cannot commit |
| Supervisory | Can approve within bounds |
| Participatory | Part of human decision process |
| Sovereign | Full autonomous authority (rare) |

### Example Persona

```yaml
persona: strategic_analyst
identity:
  role: "Strategic Analyst"
  domain: ["market_analysis", "competitive_intelligence"]
authority: advisory
constraints:
  - "No pricing recommendations without human review"
  - "Flag uncertainty above 30%"
framing:
  uncertainty: "explicit_confidence_intervals"
  dissent: "structured_counterargument"
policy: "enterprise_v2.3"
```

## Governance Alignment

Personas implement **human roles as authority semantics**:

- Agents don't freelance; they operate within defined roles
- Authority levels determine what gates require human approval
- Constraints are enforced, not suggested
- Audit trails include persona identity

This is how Converge answers "who can authorize this commitment?"—not with a user checkbox, but with institutional role design.
