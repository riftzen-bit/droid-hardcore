#!/bin/bash
# PreToolUse hook — blocks secrets leakage in file writes
# Cross-platform: uses python3 for regex (no GNU grep -P dependency)

INPUT_JSON=$(cat)
TOOL_NAME=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_name",""))' 2>/dev/null || echo "")

case "$TOOL_NAME" in
  Edit|Create|ApplyPatch|Write) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin).get("tool_input",{}); print(d.get("file_path",d.get("path","")))' 2>/dev/null || echo "")

# Block writes to sensitive files
case "$FILE_PATH" in
  */.env|*/.env.local|*/.env.production|*/.env.staging|*/credentials.json|*/.ssh/*|*/.gnupg/*|*/.npmrc|*/.pypirc|*/.netrc)
    cat <<EOFJ
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked write to sensitive file: $FILE_PATH"
  }
}
EOFJ
    exit 0
    ;;
esac

# Check for hardcoded secrets using python3 (portable across Linux/macOS/Windows)
CONTENT=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin).get("tool_input",{}); print(d.get("content","") + "\n" + d.get("new_string","") + "\n" + d.get("new_str",""))' 2>/dev/null || echo "")

echo "$CONTENT" | python3 -c '
import sys, re
content = sys.stdin.read()
patterns = [
    r"AKIA[0-9A-Z]{16}",
    r"sk-[a-zA-Z0-9]{32,}",
    r"ghp_[a-zA-Z0-9]{36}",
    r"glpat-[a-zA-Z0-9_\-]{20}",
    r"xox[bpras]-[a-zA-Z0-9\-]+",
    r"-----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----",
    r"password\s*[:=]\s*[\"'"'"'][^\"'"'"']{8,}",
]
for p in patterns:
    if re.search(p, content, re.IGNORECASE):
        sys.exit(1)
sys.exit(0)
' 2>/dev/null

if [ $? -eq 1 ]; then
  cat <<EOFJ
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked: content appears to contain hardcoded secrets or credentials"
  }
}
EOFJ
fi

exit 0
