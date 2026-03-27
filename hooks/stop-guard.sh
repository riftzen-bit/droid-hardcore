#!/bin/bash
# Stop hook — pre-stop verification + failure summary + session stats
# Fires when the agent is about to finish responding

# === PRE-STOP VERIFICATION ===
cat <<'EOF'
<pre-stop-verification>
MANDATORY BEFORE STOPPING — Did you complete ALL of these?

1. FILES: List every file you modified/created this session
2. TESTS: For each source file, confirm its test file exists and is updated
3. EDGE CASES: Name 2-3 edge cases you tested
4. VALIDATORS: Show output of build/typecheck/lint/test commands
5. STATUS: PASS (all above done) or FAIL (must fix before stopping)

If you modified source code but skipped tests: you are NOT done.
If you claimed "done" without running validators: you are NOT done.
Generate missing work NOW — do not respond to user until gates pass.
</pre-stop-verification>
EOF

# === Tool failure summary ===
FAILURE_FILE="$HOME/.factory/.last-tool-error.json"
if [ -f "$FAILURE_FILE" ]; then
  RETRY_COUNT=$(python3 -c "import json; print(json.load(open('$FAILURE_FILE')).get('retry_count',0))" 2>/dev/null || echo "0")
  if [ "$RETRY_COUNT" -ge 3 ] 2>/dev/null; then
    TOOL=$(python3 -c "import json; print(json.load(open('$FAILURE_FILE')).get('tool','unknown'))" 2>/dev/null || echo "unknown")
    echo "<unresolved-failures>"
    echo "WARNING: Tool '$TOOL' failed ${RETRY_COUNT}x this session without resolution."
    echo "Mention this to the user — don't silently ignore repeated failures."
    echo "</unresolved-failures>"
  fi
fi

# === Session stats ===
COUNTER_FILE="$HOME/.factory/.session-tool-count"
if [ -f "$COUNTER_FILE" ]; then
  TOOL_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
  echo "<session-stats>Tool calls this session: $TOOL_COUNT</session-stats>"
  # Reset counter for next session
  rm -f "$COUNTER_FILE" 2>/dev/null
fi

# Clean up failure file at end of session
rm -f "$FAILURE_FILE" 2>/dev/null
