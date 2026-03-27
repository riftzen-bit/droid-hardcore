# Droid Hardcore — Agent Guidelines

## Core Rules

### Engineering Mindset
- Understand codebase before writing code
- Analyze options -> critique -> propose plan -> wait for approval
- Ask clarifying questions about product intent, not technical choices

### TDD (MANDATORY)
RED (failing test) -> GREEN (minimal code) -> REFACTOR. No exceptions.
Coverage: 80%+ overall, 100% new code, 100% core business logic.

### Code Quality
- Reuse > extend > write new code. Simplicity first.
- Files: 200-400 lines typical, 800 max. Functions: <50 lines.
- Match project patterns exactly.

### Safety
- No hardcoded secrets. Validate user input at boundaries.
- Parameterized queries. Sanitized output.
- Verify imports/packages exist before using them.

## Git Conventions
- Commit format: `<type>: <description>` (feat, fix, refactor, docs, test, chore)
- No force push to main/master
