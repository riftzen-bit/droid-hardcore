#!/bin/bash
# PostToolUse hook — comprehensive post-tool enforcement system
# CRITICAL: Uses JSON additionalContext output so Droid ACTUALLY sees warnings
# (plain stdout only goes to transcript in Factory, not to Droid)
#
# Features: self-review, TDD enforcement, debug detection, AI comment detection,
#   write-guard tracking, empty response detection, tool failure escalation,
#   context degradation warnings, UI verification

INPUT_JSON=$(cat)

TOOL_NAME=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_name",""))' 2>/dev/null || echo "")
TOOL_OUTPUT=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_output","")[:500])' 2>/dev/null || echo "")

WARNINGS=""
add_warning() {
  WARNINGS="${WARNINGS}${1}\n"
}

# === Tool call counter ===
COUNTER_FILE="$HOME/.factory/.session-tool-count"
if [ -f "$COUNTER_FILE" ]; then
  COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
  echo $((COUNT + 1)) > "$COUNTER_FILE"
else
  echo "1" > "$COUNTER_FILE"
fi

# === Tool failure tracking ===
FAILURE_FILE="$HOME/.factory/.last-tool-error.json"
IS_ERROR=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print("true" if d.get("tool_error") else "false")' 2>/dev/null || echo "false")
if [ "$IS_ERROR" = "true" ]; then
  PREV_TOOL=$(python3 -c "import json; print(json.load(open('$FAILURE_FILE')).get('tool',''))" 2>/dev/null || echo "")
  if [ "$PREV_TOOL" = "$TOOL_NAME" ]; then
    PREV_COUNT=$(python3 -c "import json; print(json.load(open('$FAILURE_FILE')).get('retry_count',0))" 2>/dev/null || echo "0")
    NEW_COUNT=$((PREV_COUNT + 1))
  else
    NEW_COUNT=1
  fi
  python3 -c "
import json
with open('$FAILURE_FILE','w') as f:
    json.dump({'tool':'$TOOL_NAME','retry_count':$NEW_COUNT},f)
" 2>/dev/null
  if [ "$NEW_COUNT" -ge 5 ] 2>/dev/null; then
    add_warning "TOOL FAILURE ESCALATION: '$TOOL_NAME' failed ${NEW_COUNT}x. STOP retrying same approach. Try different arguments, alternative tool, or break task into smaller steps."
  fi
else
  rm -f "$FAILURE_FILE" 2>/dev/null
fi

# === Write-Before-Read Guard: track reads ===
READ_TRACKER="$HOME/.factory/.session-read-files"
case "$TOOL_NAME" in
  Read)
    READ_PATH=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin).get("tool_input",{}); print(d.get("file_path",d.get("path","")))' 2>/dev/null || echo "")
    if [ -n "$READ_PATH" ]; then
      echo "$READ_PATH" >> "$READ_TRACKER" 2>/dev/null
    fi
    ;;
esac

# === Empty Task Response Detection ===
case "$TOOL_NAME" in
  Task)
    if [ -z "$TOOL_OUTPUT" ] || [ "$TOOL_OUTPUT" = "null" ] || [ "$TOOL_OUTPUT" = "{}" ]; then
      add_warning "EMPTY TASK: Droid/subagent returned empty response. Task may have failed silently. Retry with more context or do it directly."
    fi
    ;;
esac

# === File Edit/Create checks ===
case "$TOOL_NAME" in
  Edit|Create|ApplyPatch|Write)
    FILE_PATH=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin).get("tool_input",{}); print(d.get("file_path",d.get("path","")))' 2>/dev/null || echo "")

    # Write-before-read check (Edit only)
    if [ "$TOOL_NAME" = "Edit" ] && [ -n "$FILE_PATH" ]; then
      WAS_READ=false
      if [ -f "$READ_TRACKER" ] && grep -qF "$FILE_PATH" "$READ_TRACKER" 2>/dev/null; then
        WAS_READ=true
      fi
      if [ "$WAS_READ" = false ]; then
        add_warning "WRITE GUARD: Editing $FILE_PATH without reading it first this session. Re-read to avoid stale edits."
      fi
    fi

    add_warning "POST-EDIT: Re-read the edited file to verify correctness. Check for typos, logic errors, missing imports."

    # Debug statement detection
    case "$FILE_PATH" in
      *.ts|*.tsx|*.js|*.jsx)
        if [ -f "$FILE_PATH" ]; then
          CONSOLE_LINES=$(grep -n 'console\.\(log\|debug\|info\|warn\|error\)' "$FILE_PATH" 2>/dev/null | grep -v '// eslint-disable' | grep -v 'logger\.' | head -3)
          [ -n "$CONSOLE_LINES" ] && add_warning "DEBUG STATEMENTS in $FILE_PATH: $CONSOLE_LINES — Remove before committing."
        fi
        ;;
      *.py)
        if [ -f "$FILE_PATH" ]; then
          PRINT_LINES=$(grep -n '^\s*print(' "$FILE_PATH" 2>/dev/null | grep -v '# noqa' | head -3)
          [ -n "$PRINT_LINES" ] && add_warning "DEBUG STATEMENTS in $FILE_PATH: $PRINT_LINES — Use logging module instead."
        fi
        ;;
      *.go)
        if [ -f "$FILE_PATH" ]; then
          FMT_LINES=$(grep -n 'fmt\.Print' "$FILE_PATH" 2>/dev/null | head -3)
          [ -n "$FMT_LINES" ] && add_warning "DEBUG STATEMENTS in $FILE_PATH: $FMT_LINES — Use structured logging."
        fi
        ;;
    esac

    # AI Comment Pattern Detection
    if [ -f "$FILE_PATH" ]; then
      AI_COMMENTS=$(grep -nE '//\s*(Initialize|Check if|Loop through|Handle the|Process the|Set up the|Create a new|Update the|Get the|Return the|Define the|Configure the|Validate the|Parse the|Import necessary|Export the|Declare|Iterate over|Ensure that|Fetch the|Calculate the|Convert the|Append the|Remove the|Sort the|Filter the|Map the|Reduce the|Increment|Decrement)' "$FILE_PATH" 2>/dev/null | head -3)
      if [ -z "$AI_COMMENTS" ]; then
        AI_COMMENTS=$(grep -nE '#\s*(Initialize|Check if|Loop through|Handle the|Process the|Set up the|Create a new|Update the|Get the|Return the|Define the|Configure the|Validate the|Parse the|Import necessary|Export the|Iterate over|Ensure that|Fetch the|Calculate the|Convert the|Append the|Remove the|Sort the|Filter the|Reduce the|Increment|Decrement)' "$FILE_PATH" 2>/dev/null | head -3)
      fi
      [ -n "$AI_COMMENTS" ] && add_warning "AI COMMENTS in $FILE_PATH: $AI_COMMENTS — Remove obvious WHAT comments, keep WHY comments."
    fi

    # TDD ENFORCEMENT
    IS_TEST=false
    case "$FILE_PATH" in
      *.test.*|*.spec.*|*__tests__/*|*_test.go|*_test.py|test_*|*Test.java|*_test.rs) IS_TEST=true ;;
    esac

    if [ "$IS_TEST" = false ]; then
      case "$FILE_PATH" in
        *.ts|*.tsx|*.js|*.jsx|*.py|*.go|*.rs|*.java|*.kt|*.rb|*.dart)
          DIR=$(dirname "$FILE_PATH")
          BASENAME=$(basename "$FILE_PATH")
          NAME="${BASENAME%.*}"
          EXT="${BASENAME##*.}"
          FOUND_TEST=false

          case "$EXT" in
            ts|tsx|js|jsx)
              for pattern in "$DIR/$NAME.test.$EXT" "$DIR/$NAME.spec.$EXT" "$DIR/$NAME.test.ts" "$DIR/$NAME.test.tsx" "$DIR/$NAME.spec.ts" "$DIR/$NAME.spec.tsx" "$DIR/__tests__/$NAME.$EXT" "$DIR/__tests__/$NAME.test.$EXT" "$DIR/../__tests__/$NAME.test.$EXT" "$DIR/../tests/$NAME.test.$EXT"; do
                [ -f "$pattern" ] && FOUND_TEST=true && break
              done
              ;;
            py)
              for pattern in "$DIR/test_$NAME.py" "$DIR/${NAME}_test.py" "$DIR/tests/test_$NAME.py" "$DIR/../tests/test_$NAME.py"; do
                [ -f "$pattern" ] && FOUND_TEST=true && break
              done
              ;;
            go) [ -f "$DIR/${NAME}_test.go" ] && FOUND_TEST=true ;;
            rs) grep -q '#\[cfg(test)\]' "$FILE_PATH" 2>/dev/null && FOUND_TEST=true; [ -f "$DIR/../tests/$NAME.rs" ] && FOUND_TEST=true ;;
            java|kt) [ -f "$(echo "$FILE_PATH" | sed 's|src/main|src/test|')" ] && FOUND_TEST=true ;;
          esac

          [ "$FOUND_TEST" = false ] && add_warning "TDD VIOLATION: No test file for $FILE_PATH. Create test BEFORE continuing. Expected: $DIR/$NAME.test.$EXT"
          ;;
      esac
    fi

    # UI file verification
    case "$FILE_PATH" in
      *.tsx|*.jsx|*.vue|*.svelte|*.css|*.scss|*.html)
        add_warning "UI CHANGE: Visually verify the rendered output before continuing."
        ;;
    esac
    ;;

  Execute)
    HAS_ERROR=false
    if echo "$TOOL_OUTPUT" | grep -qE '(ERR!|SyntaxError|TypeError|ReferenceError|ModuleNotFoundError|ImportError|ENOENT|EPERM|segfault|panic:)' 2>/dev/null; then
      HAS_ERROR=true
    elif echo "$TOOL_OUTPUT" | grep -qE '(^error |^Error:|FAILED|FATAL|Traceback \(most recent|compile error|build failed)' 2>/dev/null; then
      HAS_ERROR=true
    elif echo "$TOOL_OUTPUT" | grep -qE '(exited with code [1-9]|exit status [1-9]|non-zero exit)' 2>/dev/null; then
      HAS_ERROR=true
    fi
    [ "$HAS_ERROR" = true ] && add_warning "EXECUTION ERROR detected. Analyze root cause, fix, and re-run. Search web if stuck after 2-3 attempts."
    ;;
esac

# === Context Degradation Warning ===
if [ -f "$COUNTER_FILE" ]; then
  CURRENT_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
  if [ "$CURRENT_COUNT" -ge 80 ] 2>/dev/null; then
    add_warning "CONTEXT CRITICAL: $CURRENT_COUNT tool calls. Re-read ALL active files before any edit. Trust filesystem only."
  elif [ "$CURRENT_COUNT" -ge 50 ] 2>/dev/null; then
    add_warning "CONTEXT WARNING: $CURRENT_COUNT tool calls. Memory may be stale. Re-read files before editing."
  fi
fi

# === OUTPUT: JSON additionalContext so Droid sees warnings ===
if [ -n "$WARNINGS" ]; then
  ESCAPED=$(printf '%s' "$WARNINGS" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo '""')
  cat <<EOFJ
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": $ESCAPED
  }
}
EOFJ
fi

exit 0
