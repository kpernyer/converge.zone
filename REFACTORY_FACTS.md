# Refactory Facts

> **Distilled truths about converging flows — systems-level principles that transcend implementation.**

---

## The Core Insight

**Converging flows are not about automation. They are about structured doubt that collapses responsibly.**

Progress is measured by **reduction of ambiguity**, not by speed or steps completed.

---

## Fact 1: All Converging Flows Have Six Phases

```
Intent → Framing → Exploration → Tension → Convergence → Commitment
```

| Phase | Function |
|-------|----------|
| Intent | What outcome matters now |
| Framing | Constraints, scope, success criteria |
| Exploration | Generate hypotheses / options |
| Tension | Detect conflicts, tradeoffs, inconsistencies |
| Convergence | Resolve or rank alternatives |
| Commitment | Freeze output, move state forward |

**If any phase is missing:** The system oscillates, over-optimizes locally, or produces brittle outcomes.

---

## Fact 2: Flows Compose Recursively, Not Sequentially

```
Flow
 ├─ Sub-flow A (technical)
 ├─ Sub-flow B (business)
 ├─ Sub-flow C (human / ethical)
 └─ Arbitration flow
```

**Only unresolved tension propagates upward.**

---

## Fact 3: Three Composition Modes

| Mode | Use When |
|------|----------|
| **Parallel** | Epistemic uncertainty is high; diversity of reasoning matters |
| **Layered** | Correctness > creativity; safety or compliance matters |
| **Iterative** | Environments change; learning over time is required |

Most real systems combine all three.

---

## Fact 4: Flow Classification by Uncertainty Type

| Type | Question | Dominant Mechanism |
|------|----------|-------------------|
| **Epistemic** | What is true? | Proof / evidence coherence |
| **Pragmatic** | What works? | Constraint satisfaction / optimization |
| **Normative** | What should be done? | Narrative + justification |
| **Strategic** | What matters most? | Ranking under uncertainty |

---

## Fact 5: Tuning Order Matters

**Primary levers (in order of impact):**

1. Stop conditions (confidence thresholds, disagreement bounds, cost ceilings)
2. Tension amplification (force disagreement to surface, delay early consensus)
3. Perspective weighting (which agents/models matter when)
4. Memory injection (recency vs relevance vs reliability)
5. Commitment cost (how expensive is reversal)

**Second-order (tune last):** Temperature, token limits, prompt verbosity.

---

## Fact 6: The Five Recurring Anti-Patterns

| Pattern | Cause | Mitigation |
|---------|-------|------------|
| **Early convergence bias** | Time pressure, dominant authority | Explicit anti-convergence phases |
| **False consensus** | Outputs align, rationales diverge | Require explanation alignment, not output alignment |
| **Local optimum lock-in** | Proxy optimization | Periodic reframing flows |
| **Silent constraint dominance** | Hidden constraint dictates | Constraint surfacing as first-class flow |
| **Memory poisoning** | Irrelevant past influences current | Scoped, typed memory — not global recall |

---

## Fact 7: Reversibility Tunes Exploration Depth

| Class | Cost of Being Wrong | Exploration Depth |
|-------|---------------------|-------------------|
| Reversible | Cheap to undo | Low |
| Sticky | Some cleanup | Medium |
| Irreversible | One-way door | High |

---

## Fact 8: Human Roles Are Orthogonal

| Mode | Role |
|------|------|
| **Advisory** | Humans suggest |
| **Supervisory** | Humans approve |
| **Participatory** | Humans co-reason |
| **Sovereign** | Humans decide |

Human sovereignty overrides automation when the role is sovereign.

---

## Fact 9: CP-SAT Justification Test

Use CP-SAT **only when all four are true:**

1. Constraints are explicit
2. Variables are coupled
3. Outcome cost is material
4. Solution space is non-intuitive

**If even one is missing → CP-SAT is wasted effort.**

---

## Fact 10: The Decision Table

```
Is the problem about truth?      → Epistemic flow → fan-out → heuristics
Is the problem about choice?     → Strategic flow → ranking → humans
Is the problem about execution?  → Operational flow → rules
Is the problem about allocation? → Optimization flow → CP-SAT
```

---

## Fact 11: Agents Mirror Business Physics

Do NOT start with agents or algorithms. Start with:

```
Uncertainty × Coupling × Reversibility × Optimization pressure
```

This determines:
- Which agents are needed
- Where fan-in / fan-out occurs
- Where gates belong
- Whether CP-SAT is worth the cost

---

## Fact 12: Gates Are About Risk, Not Control

| Gate Type | Trigger |
|-----------|---------|
| Human gate | Value judgment |
| Optimization gate | Hard constraints |
| Policy gate | Compliance |
| Cost gate | Irreversibility |

---

## Fact 13: Without Taxonomy, All Problems Look Like "Reasoning"

**Without taxonomy:**
- Large models are overused
- Confidence is misplaced

**With taxonomy:**
- Cheap models handle most flows
- Humans inserted only where necessary
- Convergence quality becomes measurable

---

## Fact 14: The Meta-Flow

The system should not start with a flow. It should start with **flow selection**.

```
Intent signal detected
↓
Classify uncertainty
↓
Assess reversibility
↓
Determine human role
↓
Select convergence flow
↓
Execute flow
↓
Evaluate convergence quality
```

---

## Fact 15: The Core Truths

```gherkin
Truth: Intent must be explicit
Given no declared intent
Then convergence MUST NOT begin

Truth: Constraints precede exploration
Given exploration without surfaced constraints
Then outcomes are invalid

Truth: Tension is mandatory
Given multiple perspectives with no conflict detected
Then force contradiction search

Truth: Commitment freezes state
Given convergence is reached
Then the system must commit or explicitly defer

Truth: Early convergence is failure
Given convergence before minimum exploration depth
Then mark result as unstable

Truth: Silent authority is forbidden
Given one agent dominates without justification
Then invalidate convergence
```

---

## Final Truth

Systems that respect these facts:
- Scale better
- Fail more gracefully
- Earn trust over time

Systems that ignore them:
- Appear fast
- But drift, fracture, or hallucinate

---

## References

- `converge-business/knowledgebase/core-CONVERGING_FLOWS.md`
- `converge-business/knowledgebase/core-FLOW_TAXONOMY.md`
- `converge-business/knowledgebase/core-FLOW_TRUTHS.md`
- `converge-business/knowledgebase/core-BUSINESS_FLOWS.md`
- `converge-platform/converge-core/README.md`
- `converge-platform/converge-core/docs/ARCHITECTURE.md`
