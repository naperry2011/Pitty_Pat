# Findings Register

Severity: **C**ritical / **H**igh / **M**edium / **L**ow.
Each finding: id, dimension, severity, evidence (file:line), impact, recommendation, verification label. Bugs cross-reference `bugs.md`.

---

## F-001: No working static-analysis gate (High / Operational Readiness)

**Verification:** VERIFIED

**Evidence:**
- `package.json:10`. `"lint": "next lint"` fails on Next 16 with exit code 1 (BUG-001).
- `eslint.config.mjs`. Config covers only 3 JS config files; no `.ts`/`.tsx` source is ever linted; `eslint-config-next` installed but unused (BUG-002).

**Impact:** The project effectively has zero lint coverage while appearing to have a lint setup. Defects ESLint would catch trivially (unused imports, exhaustive-deps issues in the timer-heavy hooks) ship silently. Any CI added later fails at the first step.

**Recommendation:**
1. Replace the script with `eslint .` and adopt the flat `eslint-config-next` preset or typescript-eslint.
2. Run and triage; expect hits in `hooks/useGameState.ts` (unused import, hook dependency warnings).
3. Related: F-002 (no CI to enforce it).

---

## F-002: No tests and no CI/CD (High / Operational Readiness)

**Verification:** VERIFIED

**Evidence:**
- No test directories, no `*.test.*`/`*.spec.*` files, no test script, no test framework in `package.json`.
- No `.github/workflows/`, no other CI config anywhere in the repo.

**Impact:** The core game rules in `lib/game-engine.ts` are pure functions, which are ideal unit-test targets, yet nothing protects them. Subtle rule bugs (BUG-004) and sequencing races (BUG-005) are exactly the class of defect tests would catch. With no CI, even the type checker and build are only run when someone remembers to.

**Recommendation:**
1. Add vitest plus @testing-library/react; start with `lib/game-engine.ts` (deal, canPlayCard, drawCard reshuffle path, win detection) and `lib/ai-player.ts`.
2. Add a minimal GitHub Actions workflow: install, lint, `tsc --noEmit`, test, build.
3. Gate merges to `main` on the workflow.

---

## F-003: AI difficulty system has no runtime effect (Medium / Bugs & Stability)

**Verification:** STATIC-ONLY

**Evidence:**
- `hooks/useGameState.ts:171-203`. AI-turn effect implements inline random card selection, ignoring the `aiDifficulty` parameter.
- `hooks/useGameState.ts:14`. `executeAITurn` imported, never called. `lib/ai-player.ts` is dead at runtime except as a type source.

**Impact:** A documented feature (easy/medium/hard AI, `CLAUDE.md`) does not exist in practice, and AI behavior is defined in two diverging places, doubling the cost and risk of every AI change. Cross-reference BUG-003.

**Recommendation:**
1. Route the AI-turn effect through `getAIDecision(state, aiDifficulty)`.
2. Either expose a difficulty selector in the UI or remove the parameter until a selector exists.

---

## F-004: Turn sequencing depends on uncoordinated timers (Medium / Bugs & Stability)

**Verification:** STATIC-ONLY

**Evidence:**
- `hooks/useGameState.ts:110-113, 133-135, 196-198`. `END_TURN` is dispatched from three separate `setTimeout` chains (100ms, 500ms, 300ms); the AI effect's inner timeout has no cleanup and the effect does not gate on `turnAction`.
- `lib/game-engine.ts:180-190`. `endTurn` advances unconditionally, so a stray `END_TURN` skips a player's turn.

**Impact:** Correctness depends on timer ordering rather than state transitions. Timing-dependent double moves or skipped turns are possible, and the design makes new actions hard to add safely. Cross-reference BUG-004 and BUG-005.

**Recommendation:**
1. Move turn advancement into reducer transitions; keep at most one effect that reacts to a `pendingEndTurn` flag.
2. Until then, clean up the inner timeout and gate the AI effect on `turnAction`.

---

## F-005: Dead action types, unreachable game phase, unused types (Medium / Code Quality)

**Verification:** STATIC-ONLY

**Evidence:**
- `types/index.ts:38-48`. `DEAL_CARDS`, `AI_TURN`, `END_ROUND` have no reducer cases (`hooks/useGameState.ts:19-90`); dispatching them silently no-ops.
- `types/index.ts:22`. `gameEnd` phase is never set; no match-over condition exists. `AnimationState`, `Position` unused.

**Impact:** The type system advertises capabilities the reducer does not implement, misleading future work (an `END_ROUND` dispatch would silently do nothing). Cross-reference BUG-006.

**Recommendation:**
1. Delete the dead members, or implement them (a first-to-N-wins match using `gameEnd` is the natural feature).

---

## F-006: 7 known vulnerabilities in the toolchain (Medium / Security & Compliance)

**Verification:** VERIFIED

**Evidence:**
- `npm audit`: 0 critical, 4 high (`flatted` DoS and prototype pollution, `minimatch` ReDoS), 3 moderate (`ajv`, `brace-expansion`, `postcss` <8.5.10 XSS in stringify). All transitive, all with fixes available.

**Impact:** All sit in the dev/build chain rather than shipped client code, so user-facing exposure is low; the `postcss` issue touches the build pipeline. Leaving known-vulnerable ranges in the lockfile invites drift and noise in any future automated scanning.

**Recommendation:**
1. Run `npm audit fix`; verify build and lint still pass.
2. Re-run `npm audit` and record the residual, if any.

---

## F-007: PWA install experience is broken (Medium / Operational Readiness)

**Verification:** VERIFIED

**Evidence:**
- `public/` contains only `manifest.json`; `app/layout.tsx:51` and `public/manifest.json:10-23` reference `/icon-192.png` and `/icon-512.png`, which 404.

**Impact:** The app presents itself as installable (manifest, apple-web-app meta, standalone display) but installs produce blank icons and PWA audits fail. This directly undercuts the mobile-first positioning. Cross-reference BUG-007.

**Recommendation:**
1. Add the two icon assets (maskable-safe) or remove the references until assets exist.
2. Run a Lighthouse PWA pass after fixing.

---

## F-008: Package metadata and placement issues (Low / Code Quality)

**Verification:** VERIFIED

**Evidence:**
- `package.json:24`. `tailwindcss` in `dependencies`; it is a build-time tool.
- `package.json:17-18`. Empty `author`; ISC license declared but no LICENSE file exists in the repo.

**Impact:** Cosmetic for a private app, but the dependency misplacement inflates the production dependency surface and the missing LICENSE file leaves reuse terms ambiguous.

**Recommendation:**
1. Move `tailwindcss` (and arguably `autoprefixer`/`postcss` siblings already in dev) to devDependencies.
2. Fill `author`; add a LICENSE file or drop the license field.

---

## F-009: Commit hygiene below collaboration standard (Low / Git Hygiene)

**Verification:** VERIFIED

**Evidence:**
- Full history is 2 commits dated 2026-01-23 with messages "first commit off a long gotdamn night" and "why am i up". No tags despite version 1.0.0.

**Impact:** No practical impact at current scale; becomes a real cost the moment a second contributor or a release process appears.

**Recommendation:**
1. Adopt descriptive commit messages going forward; tag releases (v1.0.0 exists in package.json but not in git).

---

## F-010: Documentation drift on framework version (Low / Code Quality)

**Verification:** VERIFIED

**Evidence:**
- `CLAUDE.md` states "Next.js 15"; `package.json:21` declares `next ^16.0.10` and the build runs Next 16.0.10 (Turbopack). `README.md` correctly says 16.

**Impact:** Misleads AI-assisted and human contributors about which framework APIs and behaviors apply (the broken `next lint` script, F-001, is a direct consequence of a Next 16 behavior change).

**Recommendation:**
1. Update `CLAUDE.md` to Next.js 16 and re-verify its build commands against the actual scripts.

---

## F-011: Pinch-zoom disabled (Low / Security & Compliance, accessibility)

**Verification:** STATIC-ONLY

**Evidence:**
- `app/layout.tsx:8-15`. Viewport sets `maximumScale: 1, userScalable: false`.

**Impact:** Blocks zoom for low-vision users, failing WCAG 2.1 SC 1.4.4 expectations for a product explicitly aimed at "players of all ages". Some browsers ignore the directive, but the intent should be fixed at the source.

**Recommendation:**
1. Remove `userScalable: false` and `maximumScale: 1`; mobile double-tap-zoom issues are better handled with `touch-action` CSS on game surfaces.

---

## F-012: Positive observations (Informational)

**Verification:** VERIFIED

- Secret scan of full history and working tree: clean. No tokens, keys, or sensitive files ever committed.
- `npx tsc --noEmit`: zero errors under `strict: true`.
- `npm run build`: succeeds on Next 16.0.10; all 5 routes prerender as static content.
- No auth, no network calls, no PII: the only persistence is a cosmetic `localStorage` key (`cardBackStyle`, `contexts/CardStyleContext.tsx:19-28`). Attack surface is minimal by construction.
- Production logging is correctly gated: `lib/debug-helper.ts:3` wraps all console output in a client-side `NODE_ENV === 'development'` check; no stray console calls elsewhere.
- Clean layered architecture (pure engine, hook orchestration, presentational components) documented in the repo's own `CODE_MAP.md` and `FEATURE_BOUNDARIES.md`.

---

## Severity Summary

| Severity | Count | IDs |
|---|---|---|
| Critical | 0 | - |
| High | 2 | F-001, F-002 |
| Medium | 5 | F-003, F-004, F-005, F-006, F-007 |
| Low | 4 | F-008, F-009, F-010, F-011 |
| Informational | 1 | F-012 |

---
generated_by: codebase-audit skill v1.0
generated_on: 2026-06-10
project: C:\Users\Perry\Dropbox\PC\Documents\GitHub\Pitty_Pat
project_type: node
verification: full
---
