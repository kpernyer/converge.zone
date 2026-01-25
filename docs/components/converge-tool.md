# converge-tool

**CLI Tooling and Utilities**

## Purpose

converge-tool provides command-line utilities for development, debugging, and operations with Converge. It includes tools for inspecting contexts, validating flows, testing agents, and managing configurations.

## Why It Matters

Operating systems need operator tools. converge-tool provides:

- **Inspection**: Examine context state, fact histories, gate results
- **Validation**: Check flow definitions, agent contracts, invariant consistency
- **Testing**: Run agents in isolation, inject test facts, verify outputs
- **Configuration**: Manage provider settings, persona bindings, policy versions

These tools make Converge observable and debuggable, not a black box.

## Place in the Platform

converge-tool operates alongside the main application:

```
converge-application (user-facing CLI)
    │
    └── converge-tool  ←── Operator utilities
         │
         ├── Inspect contexts
         ├── Validate flows
         ├── Test agents
         └── Manage config
```

While converge-application is for running flows, converge-tool is for understanding and maintaining them.

## Key Commands

| Command | Purpose |
|---------|---------|
| `converge-tool inspect` | Examine context state |
| `converge-tool validate` | Check flow definitions |
| `converge-tool test-agent` | Run agent in isolation |
| `converge-tool config` | Manage configurations |

## Governance Alignment

Operator tools support institutional reliability:

- **Transparency**: Inspect what the system decided and why
- **Validation**: Catch flow errors before production
- **Testing**: Verify agents meet contracts
- **Configuration**: Ensure correct policy bindings

This is how Converge maintains "can we replay and audit the decision later?" in practice.
