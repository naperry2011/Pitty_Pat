# Dependency Inventory

Package manager: npm (`package-lock.json`). Node project, Next.js App Router.

## Production Dependencies

| Package | Declared | Resolved | Purpose | Flag |
|---|---|---|---|---|
| clsx | ^2.1.1 | 2.1.1 | Conditional className composition | OK |
| next | ^16.0.10 | 16.0.10 | Framework (App Router, build) | Docs mismatch, see below |
| react | ^19.2.3 | 19.2.3 | UI rendering | OK |
| react-dom | ^19.2.3 | 19.2.3 | DOM renderer | OK |
| tailwindcss | ^3.4.19 | 3.4.19 | Utility CSS framework | Misplaced: build-time tool listed as a production dependency |

## Dev Dependencies

| Package | Declared | Resolved | Purpose |
|---|---|---|---|
| @eslint/eslintrc | ^3.3.3 | 3.3.3 | ESLint config compatibility loader |
| @eslint/js | ^9.39.2 | 9.39.2 | ESLint core JS rules |
| @types/node | ^25.0.2 | 25.0.2 | Node type definitions |
| @types/react | ^19.2.7 | 19.2.7 | React type definitions |
| @types/react-dom | ^19.2.3 | 19.2.3 | React DOM type definitions |
| autoprefixer | ^10.4.23 | 10.4.23 | CSS vendor prefixing |
| eslint | ^9.39.2 | 9.39.2 | Linter |
| eslint-config-next | ^16.0.10 | 16.0.10 | Next.js lint preset (installed but unused, see findings.md F-001) |
| globals | ^17.1.0 | 17.1.0 | Global identifiers for ESLint |
| postcss | ^8.5.6 | 8.5.6 | CSS pipeline |
| typescript | ^5.9.3 | 5.9.3 | Compiler (strict mode on) |

## Constraint Quality

- All constraints use caret ranges; nothing unpinned (`*`/`latest`) and nothing pre-1.0. Reasonable for an app with a lockfile.
- Documentation mismatch: `CLAUDE.md` describes "Next.js 15" while package.json declares and installs Next 16.0.10 (README correctly says 16). See findings.md F-010.
- `tailwindcss` belongs in devDependencies; styles compile at build time.

## Outdated Packages (`npm outdated`, exit 1 = drift exists)

| Package | Current | Latest | Gap |
|---|---|---|---|
| next | 16.0.10 | 16.2.9 | Minor |
| react / react-dom | 19.2.3 | 19.2.7 | Patch |
| tailwindcss | 3.4.19 | 4.3.0 | Major (v4 is a breaking redesign; v3 remains supported) |
| eslint | 9.39.2 | 10.4.1 | Major |
| @eslint/js | 9.39.2 | 10.0.1 | Major |
| typescript | 5.9.3 | 6.0.3 | Major |
| eslint-config-next | 16.0.10 | 16.2.9 | Minor |
| Others (@types/*, autoprefixer, postcss, globals, @eslint/eslintrc) | - | - | Patch/minor only |

## Vulnerability Scan (`npm audit`)

- Total: 7 vulnerabilities (0 critical, 4 high, 3 moderate) across 434 scanned packages (86 prod, 312 dev, 60 optional). All transitive; fixes available for all.
- High: `flatted` <=3.4.1 (DoS via recursion, prototype pollution), `minimatch` ReDoS (ESLint dependency chain).
- Moderate: `ajv` ReDoS, `brace-expansion` DoS, `postcss` <8.5.10 XSS via unescaped `</style>` in stringify (in the build chain).
- All sit in the dev/build toolchain, not in shipped client code, so runtime exposure is low; still worth clearing. See findings.md F-006.

## Notable Absences

- Test framework: none (no jest, vitest, testing-library, playwright, cypress)
- Error/crash reporting: none (no Sentry or equivalent)
- Analytics: none (notable given the SEO/traffic thesis in `CARD_GAME_MVP_PLAN.md`)
- Formatter: no prettier
- Git hooks: no husky/lint-staged
- No backend-related packages needed (client-only app); their absence is correct

## Metadata

- License: ISC declared in package.json; no LICENSE file in the repo.
- Author field: empty.
- private: true; version 1.0.0.

---
generated_by: codebase-audit skill v1.0
generated_on: 2026-06-10
project: C:\Users\Perry\Dropbox\PC\Documents\GitHub\Pitty_Pat
project_type: node
verification: full
---
