# Context Modes

Switchable behavioral profiles. Activate by including the keyword in your message.

## Dev Mode (default)
Active when: no specific mode keyword detected
- Code first, explain after
- Working solution > perfect solution
- TDD applies in all modes — write tests first, always
- Auto-continue between steps

## Research Mode
Activate with: "research", "investigate", "explore", "analyze"
- Read widely before proposing anything
- Document findings as you go
- NO code until understanding is clear
- Map dependencies, data flows, edge cases first
- Output: structured analysis with options

## Review Mode
Activate with: "review", "audit", "check"
- Severity-prioritized findings (CRITICAL > HIGH > MEDIUM > LOW)
- Every finding includes a concrete fix suggestion
- Check: security, performance, correctness, maintainability
- Don't just point out problems — propose solutions

## Deep Think Mode
Activate with: "think deep", "analyze carefully", "consider all angles"
- Examine from multiple perspectives before deciding
- List pros/cons for each approach
- Consider: performance, security, maintainability, testability
- Don't rush to implementation — thoroughness > speed

## Quick Mode
Activate with: "quick", "fast", "just do it"
- Minimal explanation, maximum action
- Skip planning for trivial tasks
- Still run tests (TDD is never skipped)
