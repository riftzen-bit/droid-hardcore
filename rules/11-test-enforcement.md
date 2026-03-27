# Test Enforcement — Absolute Rules

## Iron Law
Every source file MUST have a corresponding test file. No exceptions.
Source code and test code are an inseparable unit.

## Required Test Cases (per function/module)
Minimum 5 test cases, 3 edge cases. ALL applicable categories:

| Category | What to test |
|----------|-------------|
| Happy path | Normal inputs produce expected outputs |
| Edge cases | empty, null, undefined, zero, NaN, max values, unicode, whitespace |
| Error handling | Invalid inputs throw/return proper errors |
| Boundary | Off-by-one, min/max limits, overflow, timeout |
| Security | Injection (SQL/XSS/command), auth bypass, path traversal |
| Async | Race conditions, concurrent access, promise rejection |
| State | Transitions, side effects, cleanup, memory leaks |
| Regression | Exact scenario that caused the bug being fixed |

## Test File Location Conventions

| Language | Source | Test |
|----------|--------|------|
| TS/JS | `src/foo.ts` | `src/foo.test.ts` or `src/__tests__/foo.test.ts` |
| Python | `src/foo.py` | `tests/test_foo.py` or `src/test_foo.py` |
| Go | `pkg/foo.go` | `pkg/foo_test.go` |
| Rust | `src/foo.rs` | inline `#[cfg(test)]` or `tests/foo.rs` |
| Java/Kotlin | `src/main/.../Foo.java` | `src/test/.../FooTest.java` |

## Anti-Vibe-Testing
- Mock only external dependencies, NEVER the system under test
- Assert behavior, not implementation details
- Every test must fail first (RED) — a test that never failed proves nothing
- If coverage jumps >30% in one session, review test quality not just quantity
- Prefer integration tests over heavily-mocked unit tests

## Coverage Targets
- Overall: 80% minimum
- New code: 100%
- Core business logic: 100%

## Continuous Self-Check Protocol
- ON RESUME: "System Check: Verifying test coverage constraints."
- DURING WORK: Validate architecture is testable at every step
- BEFORE STOP: Output PRE-STOP VERIFICATION block (files, tests, edge cases, validator results, PASS/FAIL)
- If FAIL: fix immediately, do not stop
