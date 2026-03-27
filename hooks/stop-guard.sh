#!/bin/bash
# Stop hook — pre-stop verification + failure summary + session stats

cat <<'EOF'
<pre-stop-verification>
MANDATORY BEFORE STOPPING:
1. FILES: List every file you modified/created
2. TESTS: For each source file, confirm test file exists and updated
3. EDGE CASES: Name 2-3 edge cases tested
4. VALIDATORS: Show build/typecheck/lint/test output
5. STATUS: PASS or FAIL

If FAIL: fix now, do not stop.
</pre-stop-verification>
EOF

FAILURE_FILE="$HOME/.factory/.last-tool-error.json"
if [ -f "$FAILURE_FILE" ]; then
  RETRY_COUNT=$(python3 -c "import json; print(json.load(open('$FAILURE_FILE')).get('retry_count',0))" 2>/dev/null || echo "0")
  if [ "$RETRY_COUNT" -ge 3 ] 2>/dev/null; then
    TOOL=$(python3 -c "import json; print(json.load(open('$FAILURE_FILE')).get('tool','unknown'))" 2>/dev/null || echo "unknown")
    echo "<unresolved-failures>Tool '$TOOL' failed ${RETRY_COUNT}x without resolution.</unresolved-failures>"
  fi
fi

COUNTER_FILE="$HOME/.factory/.session-tool-count"
if [ -f "$COUNTER_FILE" ]; then
  echo "<session-stats>Tool calls: $(cat "$COUNTER_FILE" 2>/dev/null || echo 0)</session-stats>"
  rm -f "$COUNTER_FILE" 2>/dev/null
fi
rm -f "$FAILURE_FILE" 2>/dev/null

exit 0
