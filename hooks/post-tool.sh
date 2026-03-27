#!/bin/bash
# PostToolUse hook — auto-review + TDD enforcement + code quality
# Cross-platform: works on Linux, macOS, Windows (Git Bash)

INPUT_JSON=$(cat)
TOOL_NAME=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_name",""))' 2>/dev/null || echo "")

# Tool call counter
COUNTER_FILE="$HOME/.factory/.session-tool-count"
if [ -f "$COUNTER_FILE" ]; then
  COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
  echo $((COUNT + 1)) > "$COUNTER_FILE" 2>/dev/null
else
  echo "1" > "$COUNTER_FILE" 2>/dev/null
fi

# Tool failure tracking (structured only, no false positives)
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
  python3 -c "import json; json.dump({'tool':'$TOOL_NAME','retry_count':$NEW_COUNT},open('$FAILURE_FILE','w'))" 2>/dev/null
  if [ "$NEW_COUNT" -ge 5 ] 2>/dev/null; then
    echo "<tool-failure-escalation>Tool '$TOOL_NAME' failed ${NEW_COUNT}x. STOP retrying. Try a different approach.</tool-failure-escalation>"
  fi
else
  rm -f "$FAILURE_FILE" 2>/dev/null
fi

case "$TOOL_NAME" in
  Edit|Create|ApplyPatch|Write)
    FILE_PATH=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin).get("tool_input",{}); print(d.get("file_path",d.get("path","")))' 2>/dev/null || echo "")

    cat <<'EOF'
<post-edit-review>
File modified. Self-review:
- Re-read the file to verify correctness
- Check for typos, logic errors, missing imports
</post-edit-review>
EOF

    # Console.log / debug statement detection
    if [ -f "$FILE_PATH" ]; then
      case "$FILE_PATH" in
        *.ts|*.tsx|*.js|*.jsx)
          CONSOLE_LINES=$(grep -n 'console\.\(log\|debug\)' "$FILE_PATH" 2>/dev/null | head -3)
          if [ -n "$CONSOLE_LINES" ]; then
            echo "<debug-statement-warning>"
            echo "console.log/debug found in $FILE_PATH:"
            echo "$CONSOLE_LINES"
            echo "Remove before committing."
            echo "</debug-statement-warning>"
          fi
          ;;
        *.py)
          PRINT_LINES=$(grep -n '^\s*print(' "$FILE_PATH" 2>/dev/null | head -3)
          [ -n "$PRINT_LINES" ] && echo "<debug-statement-warning>print() in $FILE_PATH: $PRINT_LINES</debug-statement-warning>"
          ;;
      esac
    fi

    # Auto-format suggestion
    CWD="${PWD:-$(pwd)}"
    case "$FILE_PATH" in
      *.ts|*.tsx|*.js|*.jsx|*.css|*.scss)
        if [ -f "$CWD/biome.json" ] || [ -f "$CWD/biome.jsonc" ]; then
          echo "<format-suggestion>Consider: npx biome check --write $FILE_PATH</format-suggestion>"
        elif [ -f "$CWD/.prettierrc" ] || [ -f "$CWD/.prettierrc.json" ] || [ -f "$CWD/prettier.config.js" ]; then
          echo "<format-suggestion>Consider: npx prettier --write $FILE_PATH</format-suggestion>"
        fi
        ;;
    esac

    # TDD enforcement: check for corresponding test file
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
              for p in "$DIR/$NAME.test.$EXT" "$DIR/$NAME.spec.$EXT" "$DIR/$NAME.test.ts" "$DIR/$NAME.test.tsx" "$DIR/__tests__/$NAME.test.$EXT"; do
                [ -f "$p" ] && FOUND_TEST=true && break
              done ;;
            py)
              for p in "$DIR/test_$NAME.py" "$DIR/${NAME}_test.py" "$DIR/tests/test_$NAME.py" "$DIR/../tests/test_$NAME.py"; do
                [ -f "$p" ] && FOUND_TEST=true && break
              done ;;
            go) [ -f "$DIR/${NAME}_test.go" ] && FOUND_TEST=true ;;
            rs) grep -q '#\[cfg(test)\]' "$FILE_PATH" 2>/dev/null && FOUND_TEST=true ;;
            java|kt) TEST_PATH=$(echo "$FILE_PATH" | sed 's|/src/main/|/src/test/|'); [ -f "$TEST_PATH" ] && FOUND_TEST=true ;;
          esac

          if [ "$FOUND_TEST" = false ]; then
            echo "<tdd-violation>"
            echo "WARNING: No test file found for: $FILE_PATH"
            echo "IRON LAW: Every source file MUST have a corresponding test file."
            echo "ACTION REQUIRED: Create the test file BEFORE continuing."
            echo "</tdd-violation>"
          fi
          ;;
      esac
    fi

    # UI file verification
    case "$FILE_PATH" in
      *.tsx|*.jsx|*.vue|*.svelte|*.css|*.scss|*.html)
        echo "<post-ui-change>UI file modified. Visually verify the rendered output.</post-ui-change>" ;;
    esac
    ;;
esac

exit 0
