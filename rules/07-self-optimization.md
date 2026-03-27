# Self-Optimization

## Improvement Loop

After significant tasks: Reflect -> Abstract pattern -> Write to rules/memories/AGENTS.md.

## Promotion Thresholds

- Memory used 2+ times -> promote to rules/
- Rule >50 lines -> split into rule + reference doc
- Workflow succeeds 3+ times -> create skill
- Memories 30+ entries -> consolidate, archive stale

## Feedback Integration

When user corrects approach:
1. Note the correction in memories.md immediately (include WHY + HOW TO APPLY)
2. Check for contradicting rules — update if needed
3. Never repeat same mistake

## Config Health (silent check at session start)

- AGENTS.md <100 lines, rules <600 lines total
- No duplicate rules or stale counts across files
- Always-loaded config <15% of context window

## Anti-Degradation

- Every rule: concrete, verifiable, actionable
- Every line must pass: "Would removing this cause specific mistakes?"
- Remove rules that haven't prevented a real mistake

## Context Management

- Trust filesystem over conversation memory
- After compaction: re-read memories.md, AGENTS.md, git log
- Use Spec Mode for complex features to prevent costly false starts

## Token Efficiency

- Lead with the answer, skip filler
- Don't restate what the user said
- Use parallel tool calls for independent operations
- One targeted search beats three broad searches
