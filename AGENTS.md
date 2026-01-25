# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Engineering Trade-offs (Reminder)

### SSE boxing and trait objects

SSE boxing is a boundary choice, not a core architecture choice. Converge-core
optimizes for invariants, determinism, and compile-time guarantees. Converge-
runtime's SSE layer is an I/O adapter where runtime polymorphism and uniform
return types matter more than micro-allocations, and cost is dominated by
network I/O. Boxing stays confined to the edge; core stays zero-cost and
statically typed.

Decision principle: use trait objects only where runtime polymorphism is
required, for plugin/registry patterns where types are not known at compile
time. SSE is one of those places.

Ownership note: `Option<Box<dyn StreamingCallback>>` is better when there is
single ownership and no sharing. `Option<Arc<dyn StreamingCallback>>` is correct
when the callback must be shared across tasks or cloned into concurrent streams.

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

