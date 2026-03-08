# Shared Agent Workflow

Default operating model across Converge repositories:

1. Read local `AGENTS.md` first.
2. Load only the linked deep docs needed for your current task.
3. Keep changes scoped to one task.
4. Run smallest relevant validation first, then broader checks.
5. Leave a clear handoff summary when done.

Version control:

- Prefer `jj status`, `jj diff`, `jj commit -m`, `jj git fetch`, `jj git push`
- Use git compatibility commands only when required by tooling

Validation strategy:

- Start with targeted tests/checks
- Then run repository standard lint/type/build/test checks
- Do not skip failing checks silently; report what failed and why

Quality bar:

- Favor existing patterns over introducing new abstractions
- Keep API/contract changes explicit
- Avoid unrelated cleanup in feature/fix PRs
