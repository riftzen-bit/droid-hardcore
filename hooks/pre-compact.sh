#!/bin/bash
# PreCompact hook — recovery instructions before context compaction

cat <<'EOF'
<pre-compact-recovery>
CONTEXT COMPACTION IMMINENT:

AFTER compaction, IMMEDIATELY:
1. Re-read project AGENTS.md and any active config files
2. Run: git status && git log --oneline -5
3. Re-read any files you were actively editing
4. Check active TODO items and resume work

Do not trust conversation memory after compaction. Trust only the filesystem.
</pre-compact-recovery>
EOF
