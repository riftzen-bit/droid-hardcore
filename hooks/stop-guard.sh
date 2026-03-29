#!/bin/bash
# Stop hook — pre-stop verification + session cleanup
# First fire: blocks (exit 2) to force verification
# Re-fire: allows stop (exit 0) to prevent infinite loop via stop_hook_active

INPUT_JSON=$(cat)

STOP_ACTIVE=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("stop_hook_active", False))' 2>/dev/null || echo "False")

MSG="PRE-STOP VERIFICATION: List files modified, confirm tests exist, show validator output, confirm no regressions. Status: PASS or FAIL."

# Tool failure summary
FAILURE_FILE="$HOME/.factory/.last-tool-error.json"
if [ -f "$FAILURE_FILE" ]; then
  RETRY_COUNT=$(python3 -c "import json; print(json.load(open('$FAILURE_FILE')).get('retry_count',0))" 2>/dev/null || echo "0")
  if [ "$RETRY_COUNT" -ge 3 ] 2>/dev/null; then
    TOOL=$(python3 -c "import json; print(json.load(open('$FAILURE_FILE')).get('tool','unknown'))" 2>/dev/null || echo "unknown")
    MSG="${MSG} UNRESOLVED: Tool '${TOOL}' failed ${RETRY_COUNT}x."
  fi
fi

# Session stats
COUNTER_FILE="$HOME/.factory/.session-tool-count"
if [ -f "$COUNTER_FILE" ]; then
  TOOL_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
  MSG="${MSG} Session: ${TOOL_COUNT} tool calls."
  rm -f "$COUNTER_FILE" 2>/dev/null
fi

# Clean up session tracking files
rm -f "$FAILURE_FILE" 2>/dev/null
rm -f "$HOME/.factory/.session-read-files" 2>/dev/null

# Prevent infinite loop: if stop hook already fired once, let Droid stop
if [ "$STOP_ACTIVE" = "True" ] || [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

# First fire: block and show verification reminder
echo "$MSG" >&2
exit 2
