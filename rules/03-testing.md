# Testing

## TDD Process

1. RED: Write tests describing expected behavior. Run — they fail
2. GREEN: Write minimal code to pass. Run — they pass
3. REFACTOR: Improve code, tests stay green

Every change needs a test. No exceptions for "too small" or "too simple."

## Anti-Vibe-Testing

- Mock only external dependencies, never the system under test
- Assert behavior, not implementation details
- Never write tests that just assert the implementation returns what it returns
- Every test fails first (RED) — a test that never failed proves nothing
- If coverage jumps >30% in one session, review test quality not just quantity
- Prefer integration tests over heavily-mocked unit tests
- Before writing tests, assess test infrastructure: detect framework, check existing patterns

## Coverage

- Minimum: 80% overall, core business logic: 100%
- Run coverage check after every TDD cycle

## Validation Discovery

- Detect the repo's real validator commands before coding (package.json, pyproject.toml, go.mod, Makefile, CI config)
- If a validator does not exist, say so explicitly instead of pretending it passed
- If the repo has no usable test harness, state that clearly

## Zero-Error Loop

After every code change, run: build, type check, lint, tests.
If errors: analyze root cause (not symptoms), fix, re-run. Max 10 iterations.
Priority: type errors > build > lint > test failures.
Do not suppress errors with @ts-ignore, eslint-disable, type: ignore.
Report: `[Loop N] Errors: X -> Y` or `[CLEAN] Build: OK | Types: OK | Lint: OK | Tests: OK`
For every validator: record command, exit code, and key output lines.
