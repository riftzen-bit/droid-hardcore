# Safety & Dependencies

## Security Checklist (before any commit)

- No hardcoded secrets (API keys, passwords, tokens)
- All user inputs validated at system boundaries
- SQL injection prevention (parameterized queries)
- XSS prevention (sanitized HTML output)
- CSRF protection enabled
- Error messages don't leak sensitive data
- Use environment variables or secret managers for secrets

## Verify Before Import

- Confirm packages exist on their registry (npm, PyPI, crates.io)
- Confirm API/function exists in the installed version
- If uncertain, read documentation or source code first
- "Module not found" or "property does not exist" errors are hallucination signals

## Dependency Rules

- Use package manager CLI — never edit lock files directly
- Before adding: check exists, maintained, >1000 weekly downloads
- Check license compatibility (GPL/AGPL infects project)
- Check version compatibility with existing dependencies
- In monorepos: install at the correct level, no circular workspace deps
- Check the project's actual build tool before writing config

Common deprecated packages to avoid: moment.js -> date-fns/dayjs, request -> fetch/undici, enzyme -> @testing-library/react, node-sass -> sass, tslint -> eslint+typescript-eslint.

## Data Correctness

- Timestamps: UTC, ISO 8601 with timezone offset, convert local only at display
- Money: integer cents, not floating point (0.1 + 0.2 !== 0.3)
- Strings: UTF-8 everywhere, length != visible character count
- Use locale-aware formatting for display (dates, numbers, currency)
- Check project's target language version before using new features

## Code Originality

- Rewrite patterns in your own style rather than copying large blocks verbatim
- Do not strip or modify license headers from copied code
- Verify source license permits derivative works when adapting code
