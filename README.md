# droid-hardcore

Hardcore TDD enforcement, anti-laziness protocol, and comprehensive quality gates for [Factory Droid](https://factory.ai). Features ported from [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) and [everything-claude-code](https://github.com/affaan-m/everything-claude-code).

Compatible with Claude Code plugins.

## What it does

Every message you send gets injected with enforcement context that makes the AI:

- **Write tests FIRST** (TDD) — never skips test files, minimum 5 test cases per function
- **Detect laziness** — warns when AI skips tests, uses generic names, or claims "done" without verification
- **Auto-detect project** — language, framework, test runner, package manager
- **Block secrets** — prevents writing API keys, passwords, private keys to files
- **Block dangerous commands** — prevents `rm -rf /`, `DROP TABLE`, pipe-to-shell
- **Detect debug statements** — warns on `console.log`, `print()`, `fmt.Print` left in code
- **Track tool failures** — escalates after repeated failures, suggests alternative approaches
- **Enforce pre-stop verification** — blocks completion claims without running validators
- **Context awareness** — warns when context is degrading after many tool calls

## Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `remind.sh` | Every message | 12-section enforcement injection |
| `post-tool.sh` | After file edits | TDD check, console.log detection, format suggestion |
| `stop-guard.sh` | Before stopping | Pre-stop verification gate |
| `pre-write-guard.sh` | Before file writes | Secret/credential detection |
| `safety-check.sh` | Before commands | Dangerous command blocking |
| `pre-compact.sh` | Before compaction | Recovery instructions |

## Rules (13 files)

Comprehensive coding standards covering: mindset, workflow, code quality, testing, safety, production readiness, frontend, self-optimization, agent discipline, notepad system, auto-continue, test enforcement, and context modes.

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
cp rules/*.md ~/.factory/rules/

# Copy AGENTS.md
cp AGENTS.md ~/.factory/AGENTS.md
```

Then configure hooks in `~/.factory/settings.json` — see `hooks/hooks.json` for the wiring format.

### As a Droid marketplace plugin

```bash
droid plugin marketplace add https://github.com/riftzen-bit/droid-hardcore
droid plugin install droid-hardcore@droid-hardcore
```

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
