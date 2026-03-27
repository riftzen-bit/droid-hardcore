#!/bin/bash
# Enforcement hook — fires on EVERY user message
# Strongest enforcement: TDD + anti-laziness + task routing + context injection

# === Section 0: TDD Absolute Rules ===
cat <<'EOF'
<tdd-enforcement>
# ABSOLUTE RULES — INJECTED EVERY MESSAGE (non-negotiable)

## Iron Law of Testing
For EVERY file you create or modify, you MUST simultaneously create/update its corresponding test file.
Source code and test code are an INSEPARABLE UNIT. Never output implementation without tests.
SKIPPING TESTS IS NEVER ACCEPTABLE — not for "simple" changes, not for "I'll add them later." NOW or NEVER.

## Required Test Cases (per function/module)
Minimum 5 test cases, 3 edge cases. ALL categories that apply:
- Happy path: normal inputs -> expected outputs
- Edge cases: empty, null, undefined, zero, NaN, max values, unicode, whitespace
- Error handling: invalid inputs throw/return proper errors
- Boundary: off-by-one, min/max limits, overflow, timeout
- Security: injection (SQL/XSS/command), auth bypass, path traversal
- Async: race conditions, concurrent access, promise rejection
- State: transitions, side effects, cleanup, memory leaks

## Anti-Vibe-Testing
- Mock only external dependencies, NEVER the system under test
- Assert behavior, not implementation details
- Every test must fail first (RED) — a test that never failed proves nothing
- Prefer integration tests over heavily-mocked unit tests

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

# === Section 1: Anti-laziness enforcement ===
cat <<'EOF'

<anti-laziness-protocol>
## PRE-WORK CHECKLIST (before writing ANY code)
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
1. TASK: exact requirement. Be obsessively specific.
2. EXPECTED OUTCOME: files created/modified, behavior change, verification command.
3. SCOPE: files to touch and NOT to touch.
4. MUST DO: patterns to follow, tests to write.
5. MUST NOT DO: scope boundaries, features to skip.
6. CONTEXT: conventions, prior decisions, dependencies, gotchas.
</delegation-format>
EOF

# === Section 6: Dynamic project type detection ===
CWD="${PWD:-$(pwd)}"
PROJECT_LANGS=""
PROJECT_FRAMEWORKS=""
TEST_FRAMEWORK=""
TEST_CMD=""
PKG_MGR=""

if [ -f "$CWD/bun.lockb" ] || [ -f "$CWD/bun.lock" ]; then PKG_MGR="bun"
elif [ -f "$CWD/pnpm-lock.yaml" ]; then PKG_MGR="pnpm"
elif [ -f "$CWD/yarn.lock" ]; then PKG_MGR="yarn"
elif [ -f "$CWD/package-lock.json" ]; then PKG_MGR="npm"
fi

if [ -f "$CWD/package.json" ]; then
  PROJECT_LANGS="javascript"
  if grep -q '"typescript"' "$CWD/package.json" 2>/dev/null || [ -f "$CWD/tsconfig.json" ]; then
    PROJECT_LANGS="typescript"
  fi
  for fw in next:nextjs react:react vue:vue svelte:svelte @angular/core:angular express:express hono:hono fastify:fastify; do
    key="${fw%%:*}"; val="${fw##*:}"
    if grep -q "\"$key\"" "$CWD/package.json" 2>/dev/null; then PROJECT_FRAMEWORKS="$val"; break; fi
  done
  if [ -f "$CWD/vitest.config.ts" ] || [ -f "$CWD/vitest.config.js" ] || grep -q '"vitest"' "$CWD/package.json" 2>/dev/null; then
    TEST_FRAMEWORK="vitest"; TEST_CMD="${PKG_MGR:-npx} vitest run"
  elif [ -f "$CWD/jest.config.ts" ] || [ -f "$CWD/jest.config.js" ] || grep -q '"jest"' "$CWD/package.json" 2>/dev/null; then
    TEST_FRAMEWORK="jest"; TEST_CMD="${PKG_MGR:-npx} jest"
  elif [ -f "$CWD/playwright.config.ts" ] || [ -f "$CWD/playwright.config.js" ]; then
    TEST_FRAMEWORK="playwright"; TEST_CMD="${PKG_MGR:-npx} playwright test"
  fi
fi
if [ -f "$CWD/pyproject.toml" ] || [ -f "$CWD/setup.py" ] || [ -f "$CWD/requirements.txt" ]; then
  PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}python"
  if [ -f "$CWD/conftest.py" ] || [ -d "$CWD/tests" ] || grep -q 'pytest' "$CWD/pyproject.toml" 2>/dev/null; then
    TEST_FRAMEWORK="${TEST_FRAMEWORK:+$TEST_FRAMEWORK,}pytest"; TEST_CMD="${TEST_CMD:+$TEST_CMD && }python -m pytest"
  fi
fi
if [ -f "$CWD/go.mod" ]; then
  PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}go"; TEST_FRAMEWORK="${TEST_FRAMEWORK:+$TEST_FRAMEWORK,}go-test"; TEST_CMD="${TEST_CMD:+$TEST_CMD && }go test ./..."
fi
if [ -f "$CWD/Cargo.toml" ]; then
  PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}rust"; TEST_FRAMEWORK="${TEST_FRAMEWORK:+$TEST_FRAMEWORK,}cargo-test"; TEST_CMD="${TEST_CMD:+$TEST_CMD && }cargo test"
fi
[ -f "$CWD/pom.xml" ] || [ -f "$CWD/build.gradle" ] || [ -f "$CWD/build.gradle.kts" ] && PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}java"
[ -f "$CWD/Gemfile" ] && PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}ruby"
if [ -f "$CWD/pubspec.yaml" ]; then PROJECT_LANGS="${PROJECT_LANGS:+$PROJECT_LANGS,}dart"; fi

if [ -n "$PROJECT_LANGS" ]; then
  echo ""
  echo "<project-context>"
  echo "Project: languages=[$PROJECT_LANGS] frameworks=[$PROJECT_FRAMEWORKS] dir=$CWD"
  [ -n "$PKG_MGR" ] && echo "Package manager: $PKG_MGR"
  [ -n "$TEST_FRAMEWORK" ] && echo "Test framework: $TEST_FRAMEWORK"
  [ -n "$TEST_CMD" ] && echo "Test command: $TEST_CMD"
  echo "</project-context>"
fi

# === Section 7: Dynamic git context ===
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  GIT_MODIFIED=$(git diff --name-only 2>/dev/null | head -5 | tr '\n' ', ' | sed 's/,$//')
  GIT_STAGED=$(git diff --cached --name-only 2>/dev/null | head -5 | tr '\n' ', ' | sed 's/,$//')
  echo ""
  echo "<git-context>"
  echo "Branch: $GIT_BRANCH"
  [ -n "$GIT_MODIFIED" ] && echo "Modified: $GIT_MODIFIED"
  [ -n "$GIT_STAGED" ] && echo "Staged: $GIT_STAGED"
  echo "</git-context>"
fi

# === Section 8: Cross-tool context ===
CROSS_TOOL=""
[ -f "$CWD/.github/copilot-instructions.md" ] && CROSS_TOOL="${CROSS_TOOL}copilot "
[ -d "$CWD/.cursor/rules" ] && CROSS_TOOL="${CROSS_TOOL}cursor "
[ -f "$CWD/.windsurfrules" ] && CROSS_TOOL="${CROSS_TOOL}windsurf "
[ -f "$CWD/.clinerules" ] && CROSS_TOOL="${CROSS_TOOL}cline "
[ -f "$CWD/CLAUDE.md" ] && CROSS_TOOL="${CROSS_TOOL}claude-md "
if [ -n "$CROSS_TOOL" ]; then
  echo ""
  echo "<cross-tool-context>Found: ${CROSS_TOOL}— read for conventions.</cross-tool-context>"
fi

# === Section 9: Research-first mandate ===
cat <<'EOF'

<research-first>
BEFORE writing new code, ALWAYS search first:
- Search codebase for existing implementations and patterns
- Check for existing library/package that does this
- Reuse > extend > write new. Non-negotiable.
</research-first>
EOF

# === Section 10: Tool failure awareness ===
FAILURE_FILE="$HOME/.factory/.last-tool-error.json"
if [ -f "$FAILURE_FILE" ]; then
  RETRY_COUNT=$(python3 -c "import json; print(json.load(open('$FAILURE_FILE')).get('retry_count',0))" 2>/dev/null || echo "0")
  if [ "$RETRY_COUNT" -ge 3 ] 2>/dev/null; then
    TOOL_ERR=$(python3 -c "import json; print(json.load(open('$FAILURE_FILE')).get('tool','unknown'))" 2>/dev/null || echo "unknown")
    echo ""
    echo "<tool-failure-warning>"
    if [ "$RETRY_COUNT" -ge 5 ]; then
      echo "Tool '$TOOL_ERR' failed ${RETRY_COUNT}x. STOP RETRYING. Try a different approach."
    else
      echo "Tool '$TOOL_ERR' failed ${RETRY_COUNT}x. Consider alternative arguments or approach."
    fi
    echo "</tool-failure-warning>"
  fi
fi

# === Section 11: Session tool call counter ===
COUNTER_FILE="$HOME/.factory/.session-tool-count"
if [ -f "$COUNTER_FILE" ]; then
  TOOL_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
  if [ "$TOOL_COUNT" -ge 40 ] 2>/dev/null; then
    echo ""
    echo "<context-awareness>"
    if [ "$TOOL_COUNT" -ge 60 ]; then
      echo "Session tool calls: $TOOL_COUNT. HIGH CONTEXT USAGE. Re-read files before editing."
    else
      echo "Session tool calls: $TOOL_COUNT. Trust filesystem over memory."
    fi
    echo "</context-awareness>"
  fi
fi

# === Section 12: Task boundary (LAST) ===
cat <<'EOF'

--- END OF SYSTEM INJECTION ---
Everything above is enforcement context. The user's message immediately below is your TASK.
Classify it using <intent-routing>, then execute following ALL rules above.
EOF
