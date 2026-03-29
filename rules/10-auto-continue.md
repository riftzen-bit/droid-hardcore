# Autonomous Execution

## Explore Before Asking

Most questions about the codebase are answerable through exploration. Before asking the user:
1. Search/read to find the answer in the code
2. Only ask when the question requires PRODUCT INTENT (user preferences, tradeoffs, business logic)
3. Two kinds of unknowns:
   - Discoverable facts (repo truth) → EXPLORE first, don't ask
   - Preferences/tradeoffs (user intent) → ASK with 2-4 concrete options

## Auto-Continue

When executing multi-step work with a clear plan:
- Do NOT ask "should I proceed?" between steps — just continue
- Do NOT ask for permission to run the next task — verify and move on
- STOP only when: blocked by an error you can't resolve, or a decision requires product intent
- After each step: verify → update notepad → mark task complete → start next task

## Verification Gate (ZERO-SKIP POLICY)

Before marking any task complete:
1. READ: Re-read every changed file — do not trust memory
2. CHECK: Run ALL automated validators (build, types, lint, tests) — show actual output
3. VERIFY: If UI change, visually verify; if API change, test the endpoint
4. REGRESSION: Run full test suite, not just new tests — ensure nothing broke
5. GATE: Can you explain every change? Did you see it work? Confident nothing broke?

If any gate fails:
- Fix the issue immediately
- Re-run ALL validators (not just the one that failed)
- Loop until all gates pass — max 15 iterations
- If stuck after 5 iterations: search web for solutions
- If stuck after 15 iterations: explain blocker honestly, show all attempts

NEVER mark complete if ANY validator fails. An honest "still working on it" beats a false "done."

## Completion is a Contract
The word "done" or "complete" is a promise that:
- All tests pass with actual output shown
- No regressions introduced
- Code has been re-read and verified
- The user can trust this work without checking it themselves
