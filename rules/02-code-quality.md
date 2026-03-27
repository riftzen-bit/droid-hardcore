# Code Quality

## Read and Match Before Writing

1. Find related files/modules in the codebase
2. Search for existing similar code — reuse over rewrite
3. Match project naming, structure, import style, error handling

Priority: use existing code > extend existing code > write new code (last resort).

## Simplicity

- Start with simplest approach. Add complexity only with evidence
- No abstractions until pattern repeats 3+ times
- No features, refactors, or improvements beyond what was asked
- No docstrings/comments/type annotations on unchanged code
- No error handling for scenarios that can't happen
- Three similar lines > premature abstraction

## Immutability

Prefer immutable patterns: return new objects rather than mutating in place. Prevents hidden side effects, enables safe concurrency.

## File Organization

- 200-400 lines typical, 800 max per file
- Functions under 50 lines, no deep nesting (>4 levels)
- Organize by feature/domain, not by type

## Error Handling

Check which pattern the project uses and use the same everywhere. Do not mix patterns.

## Configuration

- Load config from environment variables or config files, not hardcoded values
- Validate env vars at startup with schema validation
- One centralized config module — import it everywhere
- Secrets: never log, never include in error responses, never commit

## API Consistency

When adding endpoints, read 3+ existing endpoints and match: URL naming, HTTP methods, request/response format, pagination, auth pattern, error format.

## Dependency Direction

Dependencies flow one direction (DAG). If A imports B and B imports A, extract shared code to a third module.

## Anti-Patterns

Before editing, check for these AI-generated code smells:
- **Scope creep**: "Does this change solve ONLY the request?" — check references against scope
- **Premature abstraction**: "Does this pattern repeat 3+ times?" — if no, keep it inline
- **Over-validation**: 15 error checks for 3 inputs is a smell — match existing error handling
- **Documentation bloat**: Added JSDoc/comments everywhere? Match existing doc style, not more
- **Invented patterns**: Using a new pattern when the codebase has an existing one? Use existing
