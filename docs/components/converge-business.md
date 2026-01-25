# converge-business

**Business Documentation and Strategy**

## Purpose

converge-business contains the non-code assets that define Converge as a business: strategy documents, knowledgebase articles, positioning materials, and institutional design documentation. It's the "why" behind the "what."

## Why It Matters

Converge is not just code; it's a thesis about how businesses should make commitments. That thesis needs documentation:

- **Knowledgebase**: Deep explanations of concepts, patterns, decisions
- **Strategy**: Market positioning, competitive analysis, roadmap
- **Architecture Decisions**: ADRs explaining why, not just what
- **Collaboration Guides**: How to work with the platform

This is where "Converge is a business operating system" gets explained, not just asserted.

## Place in the Platform

converge-business informs all other components:

```
converge-business  ←── Strategy, knowledgebase, positioning
    ↓
    ├── converge-core (implements the thesis)
    ├── converge-domain (encodes business logic)
    ├── converge-www (communicates the value)
    └── All components (follow the architecture)
```

Code implements; business documents explain why that implementation exists.

## Key Contents

| Content | Purpose |
|---------|---------|
| `/knowledgebase` | Deep concept explanations |
| `/strategy` | Market positioning and roadmap |
| `/adr` | Architecture Decision Records |
| `/collaboration` | Working with Converge |

## Knowledgebase Topics

- **Convergence Theory**: Why fixed-point iteration matters
- **Gate Patterns**: How gates enforce governance
- **Promotion Semantics**: Proposal → Validated → Committed
- **Uncertainty Taxonomy**: Epistemic, ontological, ambiguity
- **Human Roles**: Advisory, Supervisory, Participatory, Sovereign

## Governance Alignment

converge-business is itself governed:

- **Versioned**: Documents track releases
- **Reviewed**: Changes go through approval
- **Authoritative**: The knowledgebase is the source of truth

This ensures that the explanation of Converge is as reliable as the implementation—institutional design expressed in documentation, not just code.
