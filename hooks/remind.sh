#!/bin/bash
# Enforcement hook — fires on EVERY user message
# STRONGEST enforcement system: TDD + anti-laziness + task routing + context injection
# Ported features from oh-my-claudecode + everything-claude-code + custom enhancements


# === Section 0: TDD Absolute Rules (HIGHEST PRIORITY — read first, obey always) ===
cat <<'EOF'
<tdd-enforcement>
# ABSOLUTE RULES — INJECTED EVERY MESSAGE (non-negotiable)

## Iron Law of Testing
For EVERY file you create or modify, you MUST simultaneously create/update its corresponding test file.
Source code and test code are an INSEPARABLE UNIT. Never output implementation without tests.
SKIPPING TESTS IS NEVER ACCEPTABLE — not for "simple" changes, not for config files with logic, not for "I'll add them later." NOW or NEVER.

## Required Test Cases (per function/module)
Minimum 5 test cases, 3 edge cases. ALL categories that apply:
- Happy path: normal inputs -> expected outputs
- Edge cases: empty, null, undefined, zero, NaN, max values, unicode, whitespace
- Error handling: invalid inputs throw/return proper errors
- Boundary: off-by-one, min/max limits, overflow, timeout
- Security: injection (SQL/XSS/command), auth bypass, path traversal
- Async: race conditions, concurrent access, promise rejection
- State: transitions, side effects, cleanup, memory leaks

## Anti-Vibe-Testing (tests that prove nothing are worse than no tests)
- Mock only external dependencies, NEVER the system under test
- Assert behavior, not implementation details
- Every test must fail first (RED) — a test that never failed proves nothing
- Prefer integration tests over heavily-mocked unit tests
- If coverage jumps >30% in one session without meaningful tests, you are vibe-testing

## PRE-STOP GATE (mandatory before claiming completion)
You are FORBIDDEN from stopping without this block:
---
PRE-STOP VERIFICATION:
1. Files modified/created: [list]
2. Test files created/updated: [list]
3. Edge cases covered: [list 2-3]
4. Validators run: [build/typecheck/lint/test results]
Status: [PASS/FAIL]
---
If FAIL: generate missing tests IMMEDIATELY. Do not stop.
</tdd-enforcement>
EOF

# === Section 1: Anti-laziness enforcement (CRITICAL) ===
cat <<'EOF'

<anti-laziness-protocol>
## PRE-WORK CHECKLIST (before writing ANY code)
You MUST complete these steps. Do not skip. Do not shortcut.

1. READ: Read the relevant source files. Do not guess from memory.
2. UNDERSTAND: Trace the code flow. Know what changes and what doesn't.
3. SEARCH: Search codebase for existing implementations before writing new code.
4. PLAN: For non-trivial work, outline approach before coding.
5. TEST FIRST: Write the failing test BEFORE the implementation (RED -> GREEN -> REFACTOR).

## LAZINESS DETECTION — You are being lazy if you:
- Skip creating test files ("it's just a small change")
- Write tests AFTER implementation instead of BEFORE
- Use generic test names like "should work" or "test1"
- Mock the system under test instead of testing real behavior
- Skip reading files and guess from conversation memory
- Claim "done" without running build/typecheck/lint/tests
- Write fewer than 5 test cases per function
- Skip edge cases because "happy path is enough"
- Produce tests that all pass immediately (never failed = never tested)

## CONSEQUENCES OF LAZINESS
If you skip any of the above, the post-tool hooks WILL catch you:
- Missing test file → <tdd-violation> warning injected
- console.log left in code → <debug-statement-warning> injected
- Claiming done without validators → <pre-stop-verification> blocks you

DO THE WORK. NO SHORTCUTS.
</anti-laziness-protocol>
EOF

# === Section 2: Core enforcement ===
cat <<'EOF'

<user-prompt-submit-hook>
BEFORE responding:
1. If editing a file: re-read it first (memory degrades after 5+ tool calls)
2. If claiming "done/fixed": run verification (build/test/lint) and show actual output
3. If unsure about code: read the actual file, don't guess from memory
4. Answer directly — no filler, no restating the question
5. Trust filesystem over conversation memory

MANDATORY AUTOMATION CHECKLIST:
- BEFORE coding: TDD — write failing test FIRST, then implement
- AFTER writing code: dispatch code-reviewer droid automatically
- BEFORE commits: dispatch security-reviewer droid automatically
- BEFORE claiming done: run build/typecheck/lint/tests AND show output
- WHEN delegating to droids: include TDD rules and verification in every prompt
- Handle everything end-to-end, never skip quality gates
- AUTO-CONTINUE: do NOT ask "should I proceed?" — verify and move on
- EXPLORE BEFORE ASK: search codebase first — only ask user for product intent
</user-prompt-submit-hook>
EOF

# === Section 3: Droid roster ===
cat <<'EOF'

<droid-roster>
SPECIALIST DROIDS — delegate aggressively:
+----------------------+------------------------------------------+
| Droid                | Capabilities                             |
+----------------------+------------------------------------------+
| planner              | Complex features, implementation plans   |
| architect            | System design, ADRs, trade-off analysis  |
| tdd-guide            | TDD enforcement, test-first workflow     |
| code-reviewer        | Quality, security, performance reviews   |
| security-reviewer    | OWASP Top 10, injection, secrets scan    |
| build-fixer          | Build/compilation error resolution       |
| python-reviewer      | PEP 8, type hints, Django/FastAPI        |
| go-reviewer          | Idiomatic Go, concurrency, error handling|
| database-reviewer    | PostgreSQL, schema design, indexes       |
| e2e-runner           | Playwright E2E testing, Page Object Model|
| doc-updater          | Documentation, codemaps, architecture    |
| refactor-cleaner     | Dead code cleanup, consolidation         |
| worker               | General-purpose task delegation          |
+----------------------+------------------------------------------+
</droid-roster>
EOF

# === Section 4: Intent routing ===
cat <<'EOF'

<intent-routing>
CLASSIFY BEFORE ACTING — adapt depth to complexity:
Trivial  (<10 lines, 1 file)  -> do directly, no planning
Simple   (1-2 files, clear)   -> 1-2 questions max, then execute
Medium   (3-5 files, scoped)  -> brief plan, validate approach, execute
Complex  (5+ files, arch)     -> full plan with user review first
Research (unclear path)        -> investigate, propose options, then plan
Default: Simple unless evidence says otherwise.
</intent-routing>
EOF

# === Section 5: Delegation format ===
cat <<'EOF'

<delegation-format>
STRUCTURED DELEGATION — 6-section prompt for every droid:
1. TASK: exact requirement (quote user's words). Be obsessively specific.
2. EXPECTED OUTCOME: files created/modified, behavior change, verification command.
3. SCOPE: files to touch and NOT to touch.
4. MUST DO: patterns to follow, tests to write, notepad entries.
5. MUST NOT DO: scope boundaries, features to skip, files to leave alone.
6. CONTEXT: conventions, prior decisions, dependencies, gotchas.
Skip sections that don't apply. Include TDD rules + verification commands for coding work.
</delegation-format>
EOF

# === Section 6: Dynamic project type detection ===
CWD=$(pwd)
PROJECT_LANGS=""
PROJECT_FRAMEWORKS=""
TEST_FRAMEWORK=""
TEST_CMD=""
PKG_MGR=""

# Detect package manager
if [ -f "$CWD/bun.lockb" ] || [ -f "$CWD/bun.lock" ]; then
  PKG_MGR="bun"
elif [ -f "$CWD/pnpm-lock.yaml" ]; then
  PKG_MGR="pnpm"
elif [ -f "$CWD/yarn.lock" ]; then
  PKG_MGR="yarn"
elif [ -f "$CWD/package-lock.json" ]; then
  PKG_MGR="npm"
fi

# JS/TS detection
if [ -f "$CWD/package.json" ]; then
  PROJECT_LANGS="javascript"
  if grep -q '"typescript"' "$CWD/package.json" 2>/dev/null || [ -f "$CWD/tsconfig.json" ]; then
    PROJECT_LANGS="typescript"
  fi
  if grep -q '"next"' "$CWD/package.json" 2>/dev/null; then
    PROJECT_FRAMEWORKS="nextjs"
  elif grep -q '"react"' "$CWD/package.json" 2>/dev/null; then
    PROJECT_FRAMEWORKS="react"
  elif grep -q '"vue"' "$CWD/package.json" 2>/dev/null; then
    PROJECT_FRAMEWORKS="vue"
  elif grep -q '"svelte"' "$CWD/package.json" 2>/dev/null; then
    PROJECT_FRAMEWORKS="svelte"
  elif grep -q '"@angular/core"' "$CWD/package.json" 2>/dev/null; then
    PROJECT_FRAMEWORKS="angular"
  elif grep -q '"express"' "$CWD/package.json" 2>/dev/null; then
    PROJECT_FRAMEWORKS="express"
  elif grep -q '"hono"' "$CWD/package.json" 2>/dev/null; then
    PROJECT_FRAMEWORKS="hono"
  elif grep -q '"fastify"' "$CWD/package.json" 2>/dev/null; then
    PROJECT_FRAMEWORKS="fastify"
  fi
  # Test framework detection
  if [ -f "$CWD/vitest.config.ts" ] || [ -f "$CWD/vitest.config.js" ] || [ -f "$CWD/vitest.config.mts" ] || grep -q '"vitest"' "$CWD/package.json" 2>/dev/null; then
    TEST_FRAMEWORK="vitest"
    TEST_CMD="${PKG_MGR:-npx} vitest run"
  elif [ -f "$CWD/jest.config.ts" ] || [ -f "$CWD/jest.config.js" ] || [ -f "$CWD/jest.config.mjs" ] || grep -q '"jest"' "$CWD/package.json" 2>/dev/null; then
    TEST_FRAMEWORK="jest"
    TEST_CMD="${PKG_MGR:-npx} jest"
  elif [ -f "$CWD/playwright.config.ts" ] || [ -f "$CWD/playwright.config.js" ]; then
    TEST_FRAMEWORK="playwright"
    TEST_CMD="${PKG_MGR:-npx} playwright test"
  elif [ -f "$CWD/.mocharc.yml" ] || [ -f "$CWD/.mocharc.json" ] || grep -q '"mocha"' "$CWD/package.json" 2>/dev/null; then
    TEST_FRAMEWORK="mocha"
    TEST_CMD="${PKG_MGR:-npx} mocha"
  fi
fi

# Python detection
if [ -f "$CWD/pyproject.toml" ] || [ -f "$CWD/setup.py" ] || [ -f "$CWD/requirements.txt" ]; then
  PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}python"
  if [ -f "$CWD/conftest.py" ] || [ -d "$CWD/tests" ] || grep -q 'pytest' "$CWD/pyproject.toml" 2>/dev/null; then
    TEST_FRAMEWORK="${TEST_FRAMEWORK:+$TEST_FRAMEWORK,}pytest"
    TEST_CMD="${TEST_CMD:+$TEST_CMD && }python -m pytest"
  fi
  if grep -q 'django' "$CWD/pyproject.toml" 2>/dev/null || grep -q 'django' "$CWD/requirements.txt" 2>/dev/null; then
    PROJECT_FRAMEWORKS="${PROJECT_FRAMEWORKS:+$PROJECT_FRAMEWORKS,}django"
  elif grep -q 'fastapi' "$CWD/pyproject.toml" 2>/dev/null || grep -q 'fastapi' "$CWD/requirements.txt" 2>/dev/null; then
    PROJECT_FRAMEWORKS="${PROJECT_FRAMEWORKS:+$PROJECT_FRAMEWORKS,}fastapi"
  elif grep -q 'flask' "$CWD/pyproject.toml" 2>/dev/null || grep -q 'flask' "$CWD/requirements.txt" 2>/dev/null; then
    PROJECT_FRAMEWORKS="${PROJECT_FRAMEWORKS:+$PROJECT_FRAMEWORKS,}flask"
  fi
fi

# Go detection
if [ -f "$CWD/go.mod" ]; then
  PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}go"
  TEST_FRAMEWORK="${TEST_FRAMEWORK:+$TEST_FRAMEWORK,}go-test"
  TEST_CMD="${TEST_CMD:+$TEST_CMD && }go test ./..."
fi

# Rust detection
if [ -f "$CWD/Cargo.toml" ]; then
  PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}rust"
  TEST_FRAMEWORK="${TEST_FRAMEWORK:+$TEST_FRAMEWORK,}cargo-test"
  TEST_CMD="${TEST_CMD:+$TEST_CMD && }cargo test"
fi

# Java/Kotlin detection
if [ -f "$CWD/pom.xml" ] || [ -f "$CWD/build.gradle" ] || [ -f "$CWD/build.gradle.kts" ]; then
  if [ -f "$CWD/build.gradle.kts" ]; then
    PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}kotlin"
  else
    PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}java"
  fi
fi

# Ruby detection
if [ -f "$CWD/Gemfile" ]; then
  PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}ruby"
fi

# Dart/Flutter detection
if [ -f "$CWD/pubspec.yaml" ]; then
  PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}dart"
  if grep -q 'flutter' "$CWD/pubspec.yaml" 2>/dev/null; then
    PROJECT_FRAMEWORKS="${PROJECT_FRAMEWORKS:+$PROJECT_FRAMEWORKS,}flutter"
  fi
fi

if [ -n "$PROJECT_LANGS" ]; then
  echo ""
  echo "<project-context>"
  echo "Project type: languages=[$PROJECT_LANGS] frameworks=[$PROJECT_FRAMEWORKS] dir=$CWD"
  [ -n "$PKG_MGR" ] && echo "Package manager: $PKG_MGR"
  [ -n "$TEST_FRAMEWORK" ] && echo "Test framework: $TEST_FRAMEWORK"
  [ -n "$TEST_CMD" ] && echo "Test command: $TEST_CMD"
  echo "</project-context>"
fi

# === Section 7: Dynamic git context ===
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  GIT_MODIFIED=$(git diff --name-only 2>/dev/null | head -5)
  GIT_STAGED=$(git diff --cached --name-only 2>/dev/null | head -5)

  echo ""
  echo "<git-context>"
  echo "Branch: $GIT_BRANCH"
  if [ -n "$GIT_MODIFIED" ]; then
    echo "Modified: $GIT_MODIFIED"
  fi
  if [ -n "$GIT_STAGED" ]; then
    echo "Staged: $GIT_STAGED"
  fi
  echo "</git-context>"
fi

# === Section 8: Cross-tool context ===
CROSS_TOOL=""
[ -f "$CWD/.github/copilot-instructions.md" ] && CROSS_TOOL="${CROSS_TOOL}copilot-instructions "
[ -d "$CWD/.cursor/rules" ] && CROSS_TOOL="${CROSS_TOOL}cursor-rules "
[ -f "$CWD/.windsurfrules" ] && CROSS_TOOL="${CROSS_TOOL}windsurfrules "
[ -f "$CWD/.clinerules" ] && CROSS_TOOL="${CROSS_TOOL}clinerules "
[ -f "$CWD/CLAUDE.md" ] && CROSS_TOOL="${CROSS_TOOL}claude-md "

if [ -n "$CROSS_TOOL" ]; then
  echo ""
  echo "<cross-tool-context>"
  echo "Found: $CROSS_TOOL— read these for project conventions before coding."
  echo "</cross-tool-context>"
fi

# === Section 9: Notepad continuation ===
if [ -d "$CWD/.droids/notepads" ] && [ "$(ls -A "$CWD/.droids/notepads" 2>/dev/null)" ]; then
  echo ""
  echo "<notepad-continuation>"
  echo "Active notepads found in .droids/notepads/. Read them before starting work."
  NOTEPADS=$(ls "$CWD/.droids/notepads" 2>/dev/null | head -3)
  if [ -n "$NOTEPADS" ]; then
    echo "Topics: $NOTEPADS"
  fi
  echo "</notepad-continuation>"
fi

# === Section 10: Research-first mandate ===
cat <<'EOF'

<research-first>
BEFORE writing new code, ALWAYS search first:
- Search codebase: existing implementations, similar patterns, utility functions
- Check: is there an existing library/package that does this?
- Reuse > extend > write new. This order is non-negotiable.
</research-first>
EOF

# === Section 11: Tool failure awareness ===
FAILURE_FILE="$HOME/.factory/.last-tool-error.json"
if [ -f "$FAILURE_FILE" ]; then
  RETRY_COUNT=$(python3 -c "import json; print(json.load(open('$FAILURE_FILE')).get('retry_count',0))" 2>/dev/null || echo "0")
  if [ "$RETRY_COUNT" -ge 3 ] 2>/dev/null; then
    TOOL_NAME_ERR=$(python3 -c "import json; print(json.load(open('$FAILURE_FILE')).get('tool','unknown'))" 2>/dev/null || echo "unknown")
    echo ""
    echo "<tool-failure-warning>"
    echo "Tool '$TOOL_NAME_ERR' has failed ${RETRY_COUNT}x consecutively."
    if [ "$RETRY_COUNT" -ge 5 ]; then
      echo "STOP RETRYING. Try a completely different approach."
    else
      echo "Consider: different arguments, alternative tool, or breaking the task down."
    fi
    echo "</tool-failure-warning>"
  fi
fi

# === Section 12: Session tool call counter ===
COUNTER_FILE="$HOME/.factory/.session-tool-count"
if [ -f "$COUNTER_FILE" ]; then
  TOOL_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
  if [ "$TOOL_COUNT" -ge 40 ] 2>/dev/null; then
    echo ""
    echo "<context-awareness>"
    echo "Session tool calls: $TOOL_COUNT. Context may be degrading."
    if [ "$TOOL_COUNT" -ge 60 ]; then
      echo "HIGH CONTEXT USAGE. Re-read active files before editing. Consider compaction."
    else
      echo "Re-read files before editing if unsure. Trust filesystem over memory."
    fi
    echo "</context-awareness>"
  fi
fi

# === Section 13: TASK MARKER (must be LAST section) ===
# Mark where user's task begins. Do NOT echo the prompt (Factory shows it separately after).
cat <<'EOF'

--- END OF SYSTEM INJECTION ---
Everything above is enforcement context. The user's message immediately below is your TASK.
Classify it using <intent-routing>, then execute following ALL rules above.
EOF
