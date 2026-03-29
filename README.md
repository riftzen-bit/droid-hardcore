# droid-hardcore

Hardcore TDD enforcement, anti-laziness protocol, and comprehensive quality gates for [Factory Droid](https://factory.ai/). Inspired by [oh-my-opencode](https://github.com/code-yeongyu/oh-my-openagent)'s 46-hook architecture.

Compatible with Claude Code plugins.

## What it does

Every message you send gets injected with enforcement context that makes the AI:

- **Write tests FIRST** (TDD) — never skips test files, minimum 5 test cases per function
- **Detect laziness** — warns when AI skips tests, uses generic names, or claims "done" without verification
- **Auto-detect project** — language, framework, test runner, package manager
- **Block secrets** — prevents writing API keys, passwords, private keys, JWTs to files
- **Detect debug statements** — warns on `console.log`, `print()`, `fmt.Print` left in code
- **Detect AI comments** — catches "Initialize the", "Check if", "Return the" patterns
- **Write-before-read guard** — warns when editing files not read in current session
- **Empty task detection** — catches silent droid/subagent failures
- **Track tool failures** — escalates after repeated failures, suggests alternative approaches
- **Enforce pre-stop verification** — blocks completion claims without running validators
- **Context degradation warning** — warns when context is degrading after 50+ tool calls
- **Execution error detection** — catches build/test failures with zero false positives

## Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `remind.sh` | Every message | 14-section enforcement injection with zero-tolerance contract |
| `post-tool.sh` | After ALL tools (`*`) | TDD check, write-guard, debug/AI-comment detection, error detection. Uses JSON `additionalContext` so Droid actually sees warnings |
| `stop-guard.sh` | Before stopping | Pre-stop verification. Uses `stop_hook_active` to prevent infinite loop |
| `pre-write-guard.sh` | Before file writes | Secret/credential detection (AWS, OpenAI, GitHub, GitLab, Slack, JWT, private keys) |
| `safety-check.sh` | Before commands | Dangerous command blocking |
| `pre-compact.sh` | Before compaction | Recovery instructions |

## Rules (14 files)

Comprehensive coding standards: mindset, workflow, code quality, testing, safety, production readiness, frontend, self-optimization, agent discipline, notepad system, auto-continue, test enforcement, context modes, **zero-tolerance contract**.

## Key Design Decisions

1. **PostToolUse uses JSON `additionalContext`** — plain stdout only goes to transcript, not to Droid. This ensures Droid actually receives and acts on warnings.
2. **PostToolUse matcher is `*`** — fires on ALL tools (Read, Execute, Task, Grep, Glob, etc.), not just Edit/Create.
3. **Stop hook uses `stop_hook_active` check** — blocks first stop (exit 2) to force verification, allows re-fire (exit 0) to prevent infinite loop.
4. **Pre-write-guard uses python3 for regex** — avoids grep pattern escaping issues across platforms.
5. **remind.sh fires on UserPromptSubmit** — Factory injects stdout as context, so Droid sees all enforcement rules every message.

## Installation

### As a Factory Droid plugin (recommended)

```bash
git clone https://github.com/riftzen-bit/droid-hardcore.git
cd droid-hardcore
bash install.sh
```

Then restart Droid. The plugin hooks activate automatically.

### Manual installation

```bash
# Copy hooks
cp hooks/*.sh ~/.factory/hooks/
chmod +x ~/.factory/hooks/*.sh

# Copy rules
mkdir -p ~/.factory/rules
cp rules/*.md ~/.factory/rules/

# Copy AGENTS.md
cp AGENTS.md ~/.factory/AGENTS.md
```

Then configure hooks in `~/.factory/settings.json` — see `hooks/hooks.json` for the wiring format.

## Cross-platform

Works on:
- **Linux** (bash 4+)
- **macOS** (bash 3.2+) — no GNU-specific flags, uses python3 for regex
- **Windows** (Git Bash) — requires python3 in PATH

Requirements: `bash`, `python3`, `git`

## Customization

- Edit rules in `~/.factory/rules/` to match your coding standards
- Modify `AGENTS.md` for project-specific conventions
- Adjust hook strictness by editing the hook scripts

## License

MIT
