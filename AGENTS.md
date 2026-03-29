# Droid Hardcore — Agent Guidelines

## Core Rules

### Engineering Mindset
- Understand codebase before writing code
- Analyze options -> critique -> propose plan -> wait for approval
- Ask clarifying questions about product intent, not technical choices

### TDD (MANDATORY)
RED (failing test) -> GREEN (minimal code) -> REFACTOR. No exceptions.
Coverage: 80%+ overall, 100% new code, 100% core business logic.

IRON LAW: Every source file MUST have a corresponding test file.
Tests are written FIRST, not after implementation.

### Code Quality
- Reuse > extend > write new code. Simplicity first.
- Files: 200-400 lines typical, 800 max. Functions: <50 lines.
- Match project patterns exactly. No unnecessary abstractions.

### Safety
- No hardcoded secrets. Validate user input at boundaries.
- Parameterized queries. Sanitized output.
- Verify imports/packages exist before using them.

### Production
- Check loops for N+1, O(n^2), unbounded queries.
- External services: timeouts, retries with backoff, circuit breakers.
- Every listener/timer/connection has matching cleanup.

## Automated Workflow
1. Every message: enforcement hook injects TDD + anti-laziness + routing
2. Every file edit: post-tool hook checks TDD, debug statements, AI comments
3. Every file write: pre-write guard blocks secrets leakage
4. Before stopping: stop-guard forces verification checklist

## Zero Tolerance Contract
- "Done" = VERIFIED with proof. Not "I wrote code." Not "I think it works."
- Full context BEFORE coding: read everything relevant, scan the codebase
- Zero regressions: re-test EVERYTHING after every fix
- Persistence: loop fixes until resolved. Search web if stuck. Never give up early.
- Honest: a truthful "still working" beats a false "done" every time.

## Git Conventions
- Commit format: `<type>: <description>` (feat, fix, refactor, docs, test, chore)
- No force push to main/master
