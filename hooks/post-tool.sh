#!/bin/bash
# PostToolUse hook — auto-review + TDD enforcement + code quality after file edits
# Checks: self-review, test file existence, console.log detection, format suggestion, UI verification
# Also: bash history, tool call counting, tool failure tracking reset

INPUT_JSON=$(cat)

TOOL_NAME=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_name",""))' 2>/dev/null || echo "")
TOOL_OUTPUT=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_output","")[:500])' 2>/dev/null || echo "")

# === Tool call counter (increment on every tool use) ===
COUNTER_FILE="$HOME/.factory/.session-tool-count"
if [ -f "$COUNTER_FILE" ]; then
  COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
  echo $((COUNT + 1)) > "$COUNTER_FILE"
else
  echo "1" > "$COUNTER_FILE"
fi

# === Tool failure tracking: reset on success ===
FAILURE_FILE="$HOME/.factory/.last-tool-error.json"
IS_ERROR=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin); print("true" if d.get("tool_error") else "false")' 2>/dev/null || echo "false")
if [ "$IS_ERROR" = "true" ]; then
  # Track failure
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
    echo "<tool-failure-escalation>"
    echo "Tool '$TOOL_NAME' has failed ${NEW_COUNT}x. STOP retrying the same approach."
    echo "Try: different arguments, alternative tool, or break the task into smaller steps."
    echo "</tool-failure-escalation>"
  fi
else
  # Success: reset failure tracker
  rm -f "$FAILURE_FILE" 2>/dev/null
fi

case "$TOOL_NAME" in
  Edit|Create|ApplyPatch)
    FILE_PATH=$(echo "$INPUT_JSON" | python3 -c 'import json,sys; d=json.load(sys.stdin).get("tool_input",{}); print(d.get("file_path",d.get("path","")))' 2>/dev/null || echo "")

    # Auto-review reminder
    cat <<'EOF'
<post-edit-review>
File modified. Self-review checklist:
- Re-read the edited file to verify correctness
- Check for typos, logic errors, missing imports
- Would a senior engineer approve this diff?
</post-edit-review>
EOF

    # === Console.log / debug statement detection ===
    case "$FILE_PATH" in
      *.ts|*.tsx|*.js|*.jsx)
        if [ -f "$FILE_PATH" ]; then
          CONSOLE_LINES=$(grep -n 'console\.\(log\|debug\|info\|warn\|error\)' "$FILE_PATH" 2>/dev/null | grep -v '// eslint-disable' | grep -v 'logger\.' | head -5)
          if [ -n "$CONSOLE_LINES" ]; then
            echo "<debug-statement-warning>"
            echo "console.log/debug statements found in $FILE_PATH:"
            echo "$CONSOLE_LINES"
            echo "Remove before committing unless intentional logging."
            echo "</debug-statement-warning>"
          fi
        fi
        ;;
      *.py)
        if [ -f "$FILE_PATH" ]; then
          PRINT_LINES=$(grep -n '^\s*print(' "$FILE_PATH" 2>/dev/null | grep -v '# noqa' | head -5)
          if [ -n "$PRINT_LINES" ]; then
            echo "<debug-statement-warning>"
            echo "print() statements found in $FILE_PATH:"
            echo "$PRINT_LINES"
            echo "Use logging module instead, or remove before committing."
            echo "</debug-statement-warning>"
          fi
        fi
        ;;
      *.go)
        if [ -f "$FILE_PATH" ]; then
          FMT_LINES=$(grep -n 'fmt\.Print' "$FILE_PATH" 2>/dev/null | head -5)
          if [ -n "$FMT_LINES" ]; then
            echo "<debug-statement-warning>"
            echo "fmt.Print statements found in $FILE_PATH:"
            echo "$FMT_LINES"
            echo "Use structured logging instead."
            echo "</debug-statement-warning>"
          fi
        fi
        ;;
    esac

    # === Auto-format suggestion ===
    CWD=$(pwd)
    case "$FILE_PATH" in
      *.ts|*.tsx|*.js|*.jsx|*.css|*.scss|*.json)
        if [ -f "$CWD/biome.json" ] || [ -f "$CWD/biome.jsonc" ]; then
          echo "<format-suggestion>Consider running: npx biome check --write $FILE_PATH</format-suggestion>"
        elif [ -f "$CWD/.prettierrc" ] || [ -f "$CWD/.prettierrc.json" ] || [ -f "$CWD/.prettierrc.js" ] || [ -f "$CWD/prettier.config.js" ] || [ -f "$CWD/prettier.config.mjs" ]; then
          echo "<format-suggestion>Consider running: npx prettier --write $FILE_PATH</format-suggestion>"
        fi
        ;;
    esac

    # === TDD ENFORCEMENT: Check for corresponding test file ===
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
              for pattern in \
                "$DIR/$NAME.test.$EXT" \
                "$DIR/$NAME.spec.$EXT" \
                "$DIR/$NAME.test.ts" \
                "$DIR/$NAME.test.tsx" \
                "$DIR/$NAME.spec.ts" \
                "$DIR/$NAME.spec.tsx" \
                "$DIR/__tests__/$NAME.$EXT" \
                "$DIR/__tests__/$NAME.test.$EXT" \
                "$DIR/../__tests__/$NAME.test.$EXT" \
                "$DIR/../tests/$NAME.test.$EXT"; do
                if [ -f "$pattern" ]; then
                  FOUND_TEST=true
                  break
                fi
              done
              ;;
            py)
              for pattern in \
                "$DIR/test_$NAME.py" \
                "$DIR/${NAME}_test.py" \
                "$DIR/tests/test_$NAME.py" \
                "$DIR/../tests/test_$NAME.py" \
                "$DIR/tests/${NAME}_test.py"; do
                if [ -f "$pattern" ]; then
                  FOUND_TEST=true
                  break
                fi
              done
              ;;
            go)
              if [ -f "$DIR/${NAME}_test.go" ]; then
                FOUND_TEST=true
              fi
              ;;
            rs)
              if grep -q '#\[cfg(test)\]' "$FILE_PATH" 2>/dev/null || [ -f "$DIR/../tests/$NAME.rs" ]; then
                FOUND_TEST=true
              fi
              ;;
            java|kt)
              TEST_PATH=$(echo "$FILE_PATH" | sed 's|src/main|src/test|')
              if [ -f "$TEST_PATH" ]; then
                FOUND_TEST=true
              fi
              ;;
          esac

          if [ "$FOUND_TEST" = false ]; then
            cat <<EOFWARN
<tdd-violation>
WARNING: No test file found for: $FILE_PATH
IRON LAW: Every source file MUST have a corresponding test file.
ACTION REQUIRED: Create the test file BEFORE continuing to the next task.
Expected locations (pick one):
EOFWARN
            case "$EXT" in
              ts|tsx|js|jsx)
                echo "  - $DIR/$NAME.test.$EXT"
                echo "  - $DIR/__tests__/$NAME.test.$EXT"
                ;;
              py)
                echo "  - $DIR/test_$NAME.py"
                echo "  - $DIR/tests/test_$NAME.py"
                ;;
              go)
                echo "  - $DIR/${NAME}_test.go"
                ;;
              java|kt)
                echo "  - $(echo "$FILE_PATH" | sed 's|src/main|src/test|')"
                ;;
              rs)
                echo "  - Add #[cfg(test)] mod tests { } inline"
                echo "  - $DIR/../tests/$NAME.rs"
                ;;
            esac
            echo "</tdd-violation>"
          fi
          ;;
        *) ;;
      esac
    fi

    # UI file screenshot reminder
    case "$FILE_PATH" in
      *.tsx|*.jsx|*.vue|*.svelte|*.css|*.scss|*.html)
        cat <<'EOF'
<post-ui-change>
UI file modified. Visually verify the rendered output before continuing.
</post-ui-change>
EOF
        ;;
    esac
    ;;

esac

exit 0
