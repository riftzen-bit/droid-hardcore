#!/bin/bash
# PreToolUse hook — security guard for file edits
# Blocks secrets leakage and dangerous patterns in file writes

INPUT_JSON=$(cat)
TOOL_NAME=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_name",""))' 2>/dev/null || echo "")

case "$TOOL_NAME" in
  Edit|Create|ApplyPatch|Write) ;;
  *) exit 0 ;;
esac

CONTENT=$(echo "$INPUT_JSON" | python3 -c '
import json,sys
d = json.load(sys.stdin).get("tool_input",{})
c = d.get("content","") + "\n" + d.get("new_str","") + "\n" + d.get("new_string","")
print(c)
' 2>/dev/null || echo "")

FILE_PATH=$(echo "$INPUT_JSON" | python3 -c '
import json,sys
d = json.load(sys.stdin).get("tool_input",{})
print(d.get("file_path", d.get("path", "")))
' 2>/dev/null || echo "")

# Block writing to sensitive files
case "$FILE_PATH" in
  */.env|*/.env.local|*/.env.production|*/.env.staging|*/credentials.json|*/.ssh/*|*/.gnupg/*)
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

# Check for hardcoded secrets using python3 (avoids shell pattern escaping issues)
echo "$CONTENT" | python3 -c '
import sys, re, json

content = sys.stdin.read()
patterns = [
    r"AKIA[0-9A-Z]{16}",
    r"sk-[a-zA-Z0-9]{32,}",
    r"ghp_[a-zA-Z0-9]{30,}",
    r"gho_[a-zA-Z0-9]{30,}",
    r"github_pat_[a-zA-Z0-9]{22,}",
    r"glpat-[a-zA-Z0-9_\-]{20}",
    r"xox[bpras]-[a-zA-Z0-9\-]+",
    r"BEGIN.*PRIVATE KEY",
    r"password\s*[:=]\s*['\\''\"][^'\\''\"]{8,}",
    r"secret\s*[:=]\s*['\\''\"][^'\\''\"]{8,}",
    r"token\s*[:=]\s*['\\''\"][^'\\''\"]{20,}",
    r"eyJ[a-zA-Z0-9_\-]{20,}\.[a-zA-Z0-9_\-]{20,}",
]

for p in patterns:
    if re.search(p, content, re.IGNORECASE):
        result = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": "Blocked: content appears to contain hardcoded secrets or credentials"
            }
        }
        print(json.dumps(result))
        sys.exit(0)
' 2>/dev/null

exit 0
