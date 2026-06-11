# Pitty Pat: Codebase Audit Report

**Prepared for:** Nicholas Perry
**Prepared by:** Claude Code (codebase-audit skill)
**Date:** 2026-06-10
**Repo:** `C:\Users\Perry\Dropbox\PC\Documents\GitHub\Pitty_Pat` at HEAD `075a76b` on branch `main`.

---

## 1. Executive Summary

Pitty Pat is a small, well-architected, client-only Next.js card game in good fundamental health: strict TypeScript compiles clean, the production build succeeds, the secret scan is spotless, and the attack surface is near zero by design. The weaknesses are not in the code that exists but in the safety net that does not: the lint gate is silently broken, there are no tests and no CI, and a handful of real gameplay defects (a dead AI difficulty system, timer-driven turn races, a turn-eating deck-reshuffle bug) have nothing standing between them and production.

Three things matter most this week.

**First, the quality gate is an illusion.** `npm run lint` fails outright on Next 16, and even the fallback ESLint config lints zero TypeScript files, so the project has never been linted. Must-do: fix the lint script and config (F-001), then add a minimal CI workflow so lint, typecheck, and build run on every push (F-002).

**Second, the game's flagship logic is partly disconnected.** The documented easy/medium/hard AI never runs; the AI-turn effect re-implements its own random play and ignores `lib/ai-player.ts` entirely (F-003). Turn sequencing rests on three uncoordinated timers (F-004), and an empty deck silently costs the player their turn (BUG-004).

**Third, the mobile/PWA promise is broken at the surface.** Both manifest icons and the apple-touch-icon are missing files (F-007), so the install experience the metadata advertises does not work.

**The recommended path is a focused weekend of foundation work (lint, CI, icons, the AI wiring) before any new feature.**

The findings register lists **12 items across 6 dimensions, with 0 Critical and 2 High severity findings**. The High items are both operational (no lint gate, no tests/CI) rather than security defects. On the positive side, the secret scan across full git history and working tree found nothing, and the codebase's layered architecture (pure engine, hook orchestration, presentational components) is clean and easy to test once a test harness exists.

The three-horizon roadmap below sequences the work: stop the bleeding within a week, stabilize within a month, and unlock the product roadmap within a quarter.

---

## 2. Findings by Dimension

Full evidence and recommendations are in [`findings.md`](findings.md).

### 2.1 Contributor Assessment

- Single contributor (Nicholas Perry), 2 commits, both on 2026-01-23; roughly 4.5 months idle since.
- Internal/personal codebase; no vendor relationship in evidence.
- 10,210 lines landed in one bootstrap burst; no collaboration history to assess.

**Assessment.** This is a solo prototype frozen at its first checkpoint. The code quality of that single burst is above average for a prototype (strict types, clean layering, thoughtful mobile UX), which suggests the constraint is time and follow-through, not capability. Everything in this report is sized for one developer working in small increments.

### 2.2 Git Hygiene & Workflow

- Message quality: Poor (two informal, non-descriptive messages) - F-009
- Cadence: Fair (single-day burst; too little history to judge)
- Branching: Good (clean linear main)
- Tagging: Poor (no tags despite v1.0.0 in package.json)
- .gitignore: Good (comprehensive; nothing unwanted ever committed)

### 2.3 Code Quality & Architecture (0 High, 2 Medium, 2 Low)

**Strengths:**
- Pure-function game engine cleanly separated from React state and presentation; no circular dependencies.
- TypeScript strict mode enabled and passing with zero errors; only 3 `any` usages, all confined to the dev logger.
- Dev logging properly gated to client-side development builds.

**Weaknesses:**
- Dead action types (`END_ROUND`, `AI_TURN`, `DEAL_CARDS`) and an unreachable `gameEnd` phase advertise capabilities the reducer does not implement (F-005).
- `tailwindcss` misplaced in production dependencies; no LICENSE file; empty author field (F-008).
- `CLAUDE.md` documents Next.js 15 while the project runs Next 16, which is exactly how the broken lint script went unnoticed (F-010).

### 2.4 Bugs & Stability (0 P0, 3 P1, 2 P2, 1 P3)

**Verification commands:** npm ci (exit 0), npm run lint (exit 1, broken script), npx eslint . (exit 0, 3 files only), npx tsc --noEmit (exit 0), npm run build (exit 0, Next 16.0.10 Turbopack, 5 static routes). Full log in [`bugs.md`](bugs.md).

**Headline bugs:**
- BUG-001 (P1, VERIFIED): `npm run lint` fails on Next 16.
- BUG-002 (P1, VERIFIED): ESLint lints zero application files.
- BUG-003 (P1, STATIC-ONLY): AI difficulty is dead code; AI logic duplicated between `hooks/useGameState.ts` and `lib/ai-player.ts`.
- BUG-004 (P2, STATIC-ONLY): empty-deck reshuffle consumes the player's turn without a draw.
- BUG-005 (P2, STATIC-ONLY): turn sequencing rests on uncoordinated setTimeout chains; double-move and skipped-turn windows exist.
- BUG-007 (P1, VERIFIED): PWA icons missing.

### 2.5 Security & Compliance (0 Critical, 0 High, 1 Medium)

- F-006 (Medium, VERIFIED): 7 npm audit vulnerabilities (4 high, 3 moderate), all transitive and all in the dev/build chain; fixes available.
- F-011 (Low, STATIC-ONLY): pinch-zoom disabled in the viewport config; an accessibility regression for a product aimed at all ages.
- F-012 (Informational, VERIFIED): secret scan clean across full history; no auth, no network calls, no PII anywhere; only persistence is one cosmetic localStorage key. The security posture is strong because the surface barely exists.

### 2.6 Operational Readiness (0 Critical, 2 High, 1 Medium)

- F-001 (High): no working static-analysis gate.
- F-002 (High): no tests, no CI/CD, no deploy configuration in the repo.
- F-007 (Medium): PWA install experience broken (missing icons).

---

## 3. Three-Horizon Roadmap

### Horizon 1: Stop the Bleeding (this week)

| # | Item | Severity | Owner |
|---|---|---|---|
| H1-1 | Fix lint script (`eslint .`) and extend config to cover .ts/.tsx; triage results | High (F-001) | Developer |
| H1-2 | Add GitHub Actions workflow: install, lint, tsc, build | High (F-002) | Developer |
| H1-3 | Add the two PWA icon assets | Medium (F-007) | Developer |
| H1-4 | Run `npm audit fix`; verify build | Medium (F-006) | Developer |

### Horizon 2: Stabilize (this month)

| # | Item | Severity |
|---|---|---|
| H2-1 | Add vitest; unit-test `lib/game-engine.ts` (deal, match, reshuffle, win) and `lib/ai-player.ts` | High (F-002) |
| H2-2 | Wire the AI effect through `getAIDecision`; delete the inline duplicate | Medium (F-003) |
| H2-3 | Fix the empty-deck reshuffle turn loss | Medium (BUG-004) |
| H2-4 | Move turn advancement into reducer transitions; remove scattered timeouts | Medium (F-004) |
| H2-5 | Remove or implement dead action types and `gameEnd`; update CLAUDE.md to Next 16 | Medium/Low (F-005, F-010) |
| H2-6 | Re-enable pinch zoom; metadata cleanup (author, LICENSE, tailwind placement) | Low (F-011, F-008) |

### Horizon 3: Build Forward (this quarter)

| # | Item |
|---|---|
| H3-1 | Deploy; submit sitemap to Search Console; add lightweight analytics |
| H3-2 | Difficulty selector UI and first-to-N match mode (uses the now-live AI and `gameEnd`) |
| H3-3 | Retention basics: local stats, streaks, sound |
| H3-4 | Decide the portfolio question (Tonk next?) based on traffic data |

---

## 4. Forward Look

This audit focuses on the engineering foundation. For a forward-looking read of what this project is trying to be (an SEO-first niche card game portfolio per the in-repo `CARD_GAME_MVP_PLAN.md`), where it is versus where it should be, and what's next, see [`product_strategy.md`](product_strategy.md).

The condensed answer to "what comes after the audit fixes":

1. Deploy and instrument: the entire product thesis is organic search traffic, and nothing today measures or even receives it.
2. Make the AI difficulty and a first-to-N match structure real; they are the replay value of a single-player game and most of the code already exists.
3. If traffic validates the thesis, build Tonk (the plan's own primary recommendation) from this codebase as a template, extracting the card-game core into a shared library.

---

## Appendices

- [Findings Register](findings.md)
- [Git Analysis](git_analysis.md)
- [Dependency Inventory](dependencies.md)
- [Bug Log](bugs.md)
- [Architecture & Implementation](architecture_and_implementation.md)
- [Product Strategy](product_strategy.md)
- Pre-existing index files at repo root: `CODE_MAP.md`, `ENTRY_POINTS.md`, `DATA_FLOW.md`, `FEATURE_BOUNDARIES.md`, `IMPORT_GRAPH_SUMMARY.md`

---
generated_by: codebase-audit skill v1.0
generated_on: 2026-06-10
project: C:\Users\Perry\Dropbox\PC\Documents\GitHub\Pitty_Pat
project_type: node
verification: full
---
