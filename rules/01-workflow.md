# Development Workflow

## Before Writing Code

1. Read README, AGENTS.md, docs/, and 2-3 existing source files
2. Read full files before editing — never edit based on stale memory
3. Re-read files if >5 tool calls since last read
4. Define scope — know what changes and what doesn't
5. If behavior or acceptance criteria are unclear, ask concise product questions
6. Discover the repo's actual validator commands before coding
7. Explore before asking — most questions about the codebase are discoverable through search
8. Plan non-trivial tasks before coding

## Droid Delegation

| Droid | When |
|-------|------|
| planner | Complex features, refactoring, open questions |
| architect | System design decisions, trade-off analysis |
| tdd-guide | New features, bug fixes (TDD enforcement) |
| code-reviewer | After writing/modifying code |
| security-reviewer | Before commits |
| build-fixer | Build/compilation failures |
| e2e-runner | End-to-end test creation and execution |
| doc-updater | Documentation updates |
| refactor-cleaner | Dead code cleanup, consolidation |

## TDD Cycle

RED (write failing test) -> GREEN (minimal code) -> REFACTOR. No exceptions.

## After Writing Code

1. Re-read edited files to confirm changes applied
2. Run build, type check, lint, tests — fix until zero errors (max 10 iterations)
3. Auto-dispatch code-reviewer droid after validators pass
4. Before any commit: auto-dispatch security-reviewer droid
5. Commit: `<type>: <description>` (feat, fix, refactor, docs, test, chore)

## Scope Discipline

- "Does this directly solve the request?" — if no, don't do it
- Max 3 steps of yak shaving from original request
- If hitting limits: stop, summarize progress, ask user
- If tool calls or fix loops are growing without progress, explain the blocker honestly

## Anti-Duplication

Before starting work, check if it was already done:
- Search for existing implementations before writing new code
- Check git log for recent related changes
- If delegating to droids: include learnings from previous tasks in CONTEXT section
- If multi-step work: read notepad before each new task

## Context Management

- Trust filesystem over conversation memory
- After compaction: re-read memories.md, AGENTS.md, git log
- Parallel tool calls for independent operations
- Prefer targeted file reads over reading entire files
