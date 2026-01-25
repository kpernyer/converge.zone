# converge-policy

Converge Policy is a Cedar-first Policy Decision Point (PDP) used as a
deterministic **Policy/Authority Gate** inside Converge flows. It evaluates
explicit, auditable facts and returns a allow/deny decision with traceable
reasoning.

## Responsibilities

- Evaluate policy constraints for commitments (Quote, Spend, Access).
- Issue short-lived, signed capability tokens for fast-path decisions.
- Provide a minimal, deterministic decision surface for the runtime.

## Non-responsibilities

- It does not own business context or truth promotion.
- It does not perform agent orchestration or workflow logic.
- It does not replace Converge runtime gates; it implements one of them.
