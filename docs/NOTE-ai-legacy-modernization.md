# AI-Assisted Legacy Modernization: Not Just Greenfield

## The Misconception

People claim AI-assisted coding is only for greenfield. They picture:

```
take a giant legacy system → ask an LLM to rewrite it wholesale → hope for equivalence
```

That is reckless. But that is not the only way, and not the serious way.

**AI is not just for writing new code. It is an accelerator for system comprehension, interface discovery, behavioral extraction and controlled replacement.**

## The Three Activities People Collapse Into One

1. **Understanding the old system**
2. **Specifying what must remain true**
3. **Replacing pieces safely**

AI is useful in all three. The reason people think it's only good for greenfield is that greenfield removes the hardest part: legacy ambiguity. Not because AI cannot help there, but because ambiguity is where bad engineers panic.

## The Correct Modernization Path

```
source code available? → mine behavior from code
only APIs available?   → infer behavior from inputs/outputs
instrument if possible → observe boundaries and side effects
record real usage      → capture actual system behavior
build tests            → freeze expected behavior
run A/B or shadow mode → let old system teach new system
replace gradually
```

This is less "rewrite from scratch" and more: **extract the living specification from the running organism.**

The truth in legacy systems lives in code, runtime behavior, logs, side effects, user habits, and downstream dependencies. Usually the documentation is false, incomplete or obsolete.

## Why AI Is Particularly Useful in Brownfield Work

### 1. Codebase Digestion

LLMs are extremely good at summarizing modules, tracing dependencies, explaining control flow, identifying dead code, suggesting domain boundaries, generating architecture maps.

A legacy rewrite begins with understanding. This is one of the highest leverage areas for AI.

### 2. Behavioral Inference

If you do not have source, AI can still analyze API contracts, test traces, logs, error patterns, screen flows, database mutations. This is reverse engineering by observation.

### 3. Test Generation

One of the strongest uses. AI can help generate golden tests, regression suites, negative tests, fuzz tests, property-based tests, contract tests.

**The true barrier to rewrite is not coding speed. It is confidence.**

### 4. Translation Across Abstractions

Legacy systems embed business rules in ugly places: stored procedures, COBOL branches, JSP pages, config files, batch jobs. AI extracts these into clearer forms:

```
if customer type = X and region = Y and date < Z, apply rule Q
```

That is the beginning of a portable specification.

## The Correct Modernization Principle

Do not rewrite "the system." Rewrite:

- A capability
- A bounded context
- An interface surface
- A decision engine
- A workflow
- A reporting path

Large rewrites fail when framed as total replacement. They succeed when framed as **progressive behavioral capture plus staged substitution.**

```
understand → observe → constrain → replicate → verify → cut over
```

## Source Available vs Source Unavailable

### Source Available

Static analysis, dependency graphing, semantic search, architecture reconstruction, invariant mining, test generation from code paths. Already enough to move much faster than classic teams.

### Only APIs Available

Treat the old system as a black box: contract discovery, exploratory query generation, negative and adversarial testing, property testing, response classification, state transition discovery.

Many legacy systems are better approached as black boxes because the source is so misleading that runtime behavior matters more.

## Shadow Mode: The Crucial Idea

Enter a period where the real system trains the new — not "train" in the narrow ML sense, but:

- Exposing edge cases
- Comparing outputs
- Learning real production distributions
- Capturing tacit business behavior
- Discovering hidden dependencies

The old system becomes the oracle. Once confidence increases, the new system becomes authoritative.

## Capture Invariants, Not Just Outputs

What many rewrites miss — you should capture invariants:

- Totals must balance
- No duplicate payment IDs
- Order state cannot jump from pending to refunded without paid
- Shipping date cannot precede order date
- Discount cannot exceed list price
- A user cannot access another tenant's data

**Invariants are more durable than copied implementation details.** AI can help extract likely invariants from code, logs and domain language, but the team must validate them.

## Why People Say "Greenfield Only"

1. **They equate coding with typing** — in legacy work, the hard part is understanding behavior
2. **They don't trust LLMs with ambiguity** — the answer is test harnesses, instrumentation and staged rollout, not avoidance
3. **They've seen naive rewrite failures** — reacting to bad rewrites, not the actual method
4. **They lack a systems migration playbook** — without observability, contracts, tests and shadowing, brownfield feels dangerous
5. **They assume big-bang** — that assumption kills many good ideas

## Don't Rebuild the Past — Rebuild the Capability

### Legacy Systems Contain Three Kinds of Behavior

| Kind | Examples | Action |
|------|----------|--------|
| **Essential behavior** | Placing orders, tracking shipments, calculating prices, managing contracts | Must survive |
| **Historical artifacts** | Batch jobs for slow databases, complex caching, strange UI flows from old hardware, duplicated logic | Should disappear |
| **Dead/unused behavior** | Features nobody uses, integrations with defunct systems, forgotten flags | Should not be rebuilt |

### The Design Center

The design center should not be old system behavior. It should be **user jobs to be done.**

```
understand user goals
→ identify core workflows
→ prioritize highest-value ones
→ implement those first
```

Not: clone the legacy system.

### The Principle

**Preserve outcomes, not mechanisms.**

Old system: 17-step workflow, multiple tables, nightly batch reconciliation.
Outcome: customer receives correct invoice.

The new system only needs to guarantee the outcome.

## System Replacement Is a Journey

Healthy modernization:

```
capture core workflows
→ deliver early improvements
→ observe real usage
→ evolve architecture
→ expand coverage
```

This allows the system to **converge toward real needs** instead of reproducing historical assumptions.

## Connection to Converge Architecture

The Converge pattern naturally supports this philosophy:

- **Agents propose** — AI discovers behavior, suggests specifications
- **Facts accumulate** — behavioral invariants captured as system truth
- **Authority validates** — team confirms which behaviors are essential
- **System evolves** — architecture discovers better processes over time

The invariant capture idea maps directly to Converge's invariant enforcement. Shadow mode maps to Converge's append-only context where old and new behaviors coexist until convergence.

## The Summary

**Greenfield is where AI looks flashy. Brownfield is where it becomes economically serious.**

```
AI-assisted legacy modernization =
  accelerated comprehension
+ behavior extraction
+ test creation
+ invariant capture
+ controlled substitution
+ shadow execution
+ progressive cutover
```

The mental model is not "AI rewrites legacy code." It is: **AI helps extract, verify and replace legacy behavior.**

Or shortest: **Don't rebuild the past. Rebuild the capability and let the system evolve around real user work.**
