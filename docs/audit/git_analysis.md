# Git History Analysis

## Contributors

| Author | Email | Commits | First Commit | Last Commit |
|---|---|---|---|---|
| Perry (Nicholas Perry) | nuperry2011@gmail.com | 2 | 2026-01-23 | 2026-01-23 |

Single contributor. No collaboration history, no vendor signals. This is an internal/personal codebase.

## Commit Cadence

| Month | Commits |
|---|---|
| 2026-01 | 2 |

Both commits landed on 2026-01-23. No activity before or since (audit date 2026-06-10, roughly 4.5 months idle).

## Line-Change Distribution

| Commit | Date | Files | Insertions | Deletions | Notes |
|---|---|---|---|---|---|
| a9084c6 | 2026-01-23 | 31 | 10,110 | 0 | Initial commit, full project bootstrap |
| 075a76b | 2026-01-23 | 1 | 100 | 0 | Follow-up edit |

Total: 32 files, 10,210 insertions, 0 deletions. With 2 commits, distribution statistics are not meaningful; the history is a single bootstrap burst.

## Commit Message Quality

- a9084c6: "first commit off a long gotdamn night"
- 075a76b: "why am i up"

Both messages are informal personal commentary with no description of the change. Neither follows a conventional format (no type, scope, or intent). Acceptable for a solo prototype, but provides no historical context for review or debugging.

## Branching and Tags

- Branches: `main` (local), `origin/main`, `origin/HEAD`
- Remote: `https://github.com/naperry2011/Pitty_Pat.git`
- Merge commits: none. Linear history.
- Tags: none.
- No force-push evidence detectable from local state.

## Repo Size and Large Blobs

- Pack size: 92.12 KiB, 47 objects. Very small and healthy.
- Largest objects: `package-lock.json` (226.6 KiB, expected), `CARD_GAME_MVP_PLAN.md` (24 KiB), then ordinary source files (largest component 11.1 KiB).
- No binaries, no committed build artifacts, no oversized assets.

## .gitignore Review

Comprehensive for a Next.js project: `/node_modules`, `/.next/`, `/out/`, `/build`, `.env` and `.env*.local`, IDE folders, OS files, logs, `*.pem`, `.vercel`, `/coverage`. History confirms `node_modules`, `.next`, and build output were never committed.

Note: `tsconfig.tsbuildinfo` exists in the working tree; the ignore file covers `.tsbuildinfo` so it is not tracked.

## Hygiene Scorecard

| Dimension | Rating | Reason |
|---|---|---|
| Message quality | Poor | Two non-descriptive messages; no structure or intent |
| Cadence regularity | Fair | Single-day bootstrap burst; too little history to assess |
| Branching discipline | Good | Clean linear main; no orphaned branches |
| Tagging / releases | Poor | No tags despite version 1.0.0 in package.json |
| .gitignore coverage | Good | Comprehensive; nothing unwanted ever committed |

**Overall:** early-stage solo project with strong ignore discipline and weak commit hygiene. See `findings.md` F-009.

---
generated_by: codebase-audit skill v1.0
generated_on: 2026-06-10
project: C:\Users\Perry\Dropbox\PC\Documents\GitHub\Pitty_Pat
project_type: node
verification: full
---
