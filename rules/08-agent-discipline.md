# Droid Delegation & Intent Routing

## Structured Delegation

When delegating to droids, structure prompts with relevant sections:

1. **TASK**: Quote exact requirement. Be obsessively specific.
2. **EXPECTED OUTCOME**: Files created/modified, behavior change, verification command.
3. **SCOPE**: Files/areas to touch and NOT to touch.
4. **MUST DO**: Patterns to follow, tests to write.
5. **MUST NOT DO**: Scope boundaries, features to skip, files to leave alone.
6. **CONTEXT**: Conventions, prior decisions, dependencies, gotchas.

Skip sections that don't apply. A 3-line task doesn't need 6 sections.
Include TDD rules and verification commands when delegating coding work.

## Intent Classification

Classify before acting — adapt depth to complexity:

| Type | Signal | Approach |
|------|--------|----------|
| Trivial | Single file, <10 lines, clear fix | Do directly, no planning |
| Simple | 1-2 files, clear scope | 1-2 questions max, then execute |
| Medium | 3-5 files, scoped feature | Brief plan, validate approach, execute |
| Complex | 5+ files, architectural impact | Full plan with user review first |
| Research | Goal exists, path unclear | Investigate, propose options, then plan |

Default: Simple unless evidence says otherwise. Don't over-plan trivial work.

## Search Discipline

When searching codebase:
- Analyze intent before searching: what specifically needs to be found?
- Launch 3+ parallel searches on first action when scope is broad
- Return absolute paths with relevance reason
- Find ALL relevant matches, not just the first one
- If search results are insufficient, broaden with alternative terms

## Cross-Tool Project Context

When entering a repo, check for instruction files from other AI tools:
- `.cursor/rules/` — Cursor rules (project conventions)
- `.github/copilot-instructions.md` — GitHub Copilot instructions
- `.windsurfrules` — Windsurf rules
- `.clinerules` — Cline rules
- `CLAUDE.md` — Claude Code instructions
- `AGENTS.md` at project root — may contain project-specific droid context
