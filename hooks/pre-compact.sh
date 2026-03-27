#!/bin/bash
# PreCompact hook — preserve critical state and inject recovery instructions

cat <<'EOF'
<pre-compact-recovery>
CONTEXT COMPACTION IMMINENT — Save state now, recover after:

BEFORE compaction:
1. Note current task progress and any in-flight work
2. Record any important decisions made in this session
3. Note which files are actively being edited

AFTER compaction, IMMEDIATELY:
1. Re-read ~/.factory/AGENTS.md — core identity and rules
2. Re-read ~/.factory/memories.md — user preferences and feedback
3. Run: git status && git log --oneline -5 — re-orient to repo state
4. Re-read any files you were actively editing
5. Check active TODO items and resume work

CRITICAL: Do not trust conversation memory after compaction.
Trust only the filesystem. Re-read everything before continuing.
</pre-compact-recovery>
EOF
