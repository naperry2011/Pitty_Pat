# Bug Log

Reproducible defects identified by code review and verification.

Severity: P0 = ship-blocker / unsafe; P1 = major user-visible bug; P2 = quality issue; P3 = minor.

---

## BUG-001: `npm run lint` is broken on Next 16 (P1)

**File:** `package.json:10`

```json
"lint": "next lint"
```

**Reproduction (VERIFIED):**

```
> npm run lint
Invalid project directory provided, no such directory: ...\Pitty_Pat\lint
exit code 1
```

The `next lint` command was removed in Next 16; the CLI now parses "lint" as a project directory argument. The documented lint command in `CLAUDE.md` fails every time, and any future CI pipeline would fail at this step.

**Verification:** VERIFIED

**Fix:**
1. Change the script to `"lint": "eslint ."`.
2. Fix the ESLint config so it actually covers TypeScript (see BUG-002 companion finding F-001).

---

## BUG-002: ESLint lints zero application files (P1)

**File:** `eslint.config.mjs`

The flat config uses only `@eslint/js` with no TypeScript parser and no globs covering `.ts`/`.tsx`. In practice ESLint processes exactly 3 files: `eslint.config.mjs`, `next.config.js`, `postcss.config.js`. All source under `app/`, `components/`, `hooks/`, `lib/`, `types/` is never linted. `eslint-config-next` is installed but never referenced.

**Reproduction (VERIFIED):** `npx eslint .` exits 0 in 1.8s having checked only the 3 config files.

**Verification:** VERIFIED

**Fix:**
1. Adopt the flat `eslint-config-next` preset (already installed) or add typescript-eslint with globs for `**/*.{ts,tsx}`.
2. Re-run and triage whatever surfaces (unused imports such as `executeAITurn` in `hooks/useGameState.ts:14` would be caught immediately).

---

## BUG-003: AI difficulty is dead code; AI logic is duplicated (P1)

**File:** `hooks/useGameState.ts:171-203`, `lib/ai-player.ts:13-59`, `components/game/GameBoard.tsx:51`

```ts
// useGameState.ts AI-turn effect (simplified)
const playableCards = aiHand.filter(card => card.rank === topDiscard.rank);
if (playableCards.length > 0) {
  const cardToPlay = playableCards[Math.floor(Math.random() * playableCards.length)];
  dispatch({ type: 'PLAY_CARD', cardId: cardToPlay.id });
}
```

`GameBoard` calls `useGameState('easy')` and the hook accepts an `aiDifficulty` parameter, but the AI-turn effect implements its own random selection inline and never consults `getAIDecision`/`executeAITurn` from `lib/ai-player.ts`. The imported `executeAITurn` is unused. Net effect: the entire difficulty system (easy/medium/hard, strategic duplicate-holding) documented in `CLAUDE.md` has no runtime effect, and AI behavior changes must be made in two places.

**Verification:** STATIC-ONLY

**Fix:**
1. Replace the inline logic in the AI-turn effect with a call to `getAIDecision(state, aiDifficulty)` and dispatch based on the returned decision.
2. Remove the unused `executeAITurn` import or refactor the effect to use it.
3. Add a difficulty selector to the UI, or remove the parameter until needed.

---

## BUG-004: Empty-deck reshuffle consumes the player's turn without a draw (P2)

**File:** `lib/game-engine.ts:71-91`, `hooks/useGameState.ts:105-114`

```ts
if (state.deck.length === 0) {
  ...
  return { ...state, deck: reshuffled, discardPile: [topCard] };  // no card drawn
}
```

When the deck is empty, `drawCard` reshuffles the discard pile into a new deck and returns immediately without drawing a card or changing `turnAction`. The caller `handleDrawCard` unconditionally dispatches `END_TURN` 500ms later, so the player's turn ends without them receiving a draw. In the degenerate case (deck empty and discard pile has 1 or fewer cards) `drawCard` returns the state unchanged and the turn is still consumed. The same applies to the AI path, which also chains `END_TURN` after `DRAW_CARD`.

**Verification:** STATIC-ONLY (logic traced; not reproduced because exhausting a 42-card deck requires a long session)

**Fix:**
1. After reshuffling inside `drawCard`, continue into the draw logic instead of returning early (draw from the freshly reshuffled deck).
2. Guard `END_TURN` dispatch on whether a draw actually occurred, or move turn-advancement into the reducer.

---

## BUG-005: Timer-chained turn sequencing is race-prone (P2)

**File:** `hooks/useGameState.ts:110-113, 133-135, 171-203`

Turn progression depends on `setTimeout` chains: human play ends the turn after 100ms, human draw after 500ms, AI move fires at 1200ms with `END_TURN` 300ms later. The AI effect's cleanup clears only the outer 1200ms timer; the inner 300ms `END_TURN` timeout is never cleaned up. The effect also re-runs whenever `players` or `discardPile` change (both change after every AI dispatch) and does not check `turnAction`, so while it remains the AI's turn the effect re-arms another full AI move; correctness currently depends on the 300ms `END_TURN` firing before the re-armed 1200ms move. A dropped frame or future timing tweak can produce double moves or an `END_TURN` dispatched into the next player's turn (which would skip a turn, since the reducer's `END_TURN` advances unconditionally during play).

**Verification:** STATIC-ONLY (timing-dependent; not reproduced)

**Fix:**
1. Make turn advancement part of the reducer transitions (e.g., `PLAY_CARD`/`DRAW_CARD` set a `pendingEndTurn` consumed by a single effect), removing scattered timeouts.
2. At minimum, clean up the inner timeout and gate the AI effect on `turnAction`.

---

## BUG-006: Dead action types and unreachable phase (P3)

**File:** `types/index.ts:38-48`, `hooks/useGameState.ts:19-90`

`GameAction` declares `DEAL_CARDS`, `AI_TURN`, and `END_ROUND`, but the reducer has no cases for them; dispatching any of them silently no-ops. The `gameEnd` value of `GamePhase` is never set anywhere, so there is no match-over condition: rounds repeat indefinitely with win counters. Also `AnimationState` and `Position` types are defined but unused.

**Verification:** STATIC-ONLY

**Fix:**
1. Remove the dead action types and unused types, or implement them (e.g., `END_ROUND` for score handling, `gameEnd` for a first-to-N-wins match).

---

## BUG-007: PWA icons missing; install experience broken (P1)

**File:** `app/layout.tsx:51`, `public/manifest.json:10-23`, `public/` contents

`layout.tsx` references `/icon-192.png` (apple-touch-icon) and `manifest.json` declares `/icon-192.png` and `/icon-512.png`. The `public/` directory contains only `manifest.json`; both icons 404. Home-screen installs will show a blank/default icon and Lighthouse PWA checks fail, undercutting the app's mobile/PWA positioning.

**Verification:** VERIFIED (directory listing during build verification)

**Fix:**
1. Add `public/icon-192.png` and `public/icon-512.png` (maskable-safe).
2. Or remove the manifest icon entries and apple-touch-icon link until assets exist.

---
generated_by: codebase-audit skill v1.0
generated_on: 2026-06-10
project: C:\Users\Perry\Dropbox\PC\Documents\GitHub\Pitty_Pat
project_type: node
verification: full
---
