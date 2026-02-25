# AGENTS.md - Agent Collaboration Guide

This repository uses a **tool-agnostic agent workflow** and **Jujutsu (jj) on top of git**.

## Version Control (jj + git)

Use `jj` for day-to-day local operations and `jj git ...` for remotes:

```bash
jj status
jj diff
jj commit -m "message"
jj git fetch
jj rebase -d main@origin
jj git push
```

Git remains the interoperability layer (hosting, remotes, CI). Repos should be initialized in colocated mode with `jj git init`.

## Work Tracking (Tool-Agnostic)

Use the team's current tracker (GitHub Issues, Jira, Linear, etc.) or a repo-local `TASKS.md` when no external tracker exists.

Minimum task record:
- stable identifier or clear title
- status (`todo`, `in_progress`, `blocked`, `done`)
- owner (`human` or `agent`)
- next action / unblocker
- handoff note when pausing work

## Agent Collaboration Standard

This workflow applies to any coding agent (Claude, Codex, Gemini, Cursor, local scripts, etc.):

1. Read `AGENTS.md`, `README.md`, and relevant contracts before editing.
2. Keep changes scoped to one task and make task state visible in the tracker or `TASKS.md`.
3. Run targeted validation commands and record results.
4. Hand off with changed files, commands run, results, blockers, and next steps.
5. End the session only after `jj git push` succeeds.

## Session Completion Checklist

```bash
jj git fetch
jj rebase -d main@origin
# run tests/lints as appropriate
# update tracker or TASKS.md with status + handoff
jj git push
jj status
```
