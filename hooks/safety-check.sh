#!/bin/bash
# PreToolUse hook — safety gate for Execute tool
# Cross-platform: uses python3 for regex matching

INPUT_JSON=$(cat)
COMMAND=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || echo "")

[ -z "$COMMAND" ] && exit 0

echo "$COMMAND" | python3 -c '
import sys, re
cmd = sys.stdin.read().strip()
dangerous = [
    r"rm\s+-rf\s+/\s*$",
    r"rm\s+-rf\s+~",
    r"rm\s+-rf\s+\.\s*$",
    r"chmod\s+777",
    r"mkfs\.",
    r">\s*/dev/sd",
    r"DROP\s+DATABASE",
    r"DROP\s+TABLE",
    r"TRUNCATE\s+TABLE",
    r"curl\s+.*\|\s*s?h\b",
    r"wget\s+.*\|\s*s?h\b",
]
for p in dangerous:
    if re.search(p, cmd, re.IGNORECASE):
        sys.exit(1)
sys.exit(0)
' 2>/dev/null

if [ $? -eq 1 ]; then
  cat <<EOFJ
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked: potentially dangerous command detected"
  }
}
EOFJ
fi

exit 0
