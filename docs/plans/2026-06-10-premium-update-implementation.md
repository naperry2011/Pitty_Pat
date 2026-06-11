# Premium Update (Horizon 3) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Ship the full premium upgrade in one launch: match structure (first-to-N), difficulty setup screen, polished-playful visual system with SVG cards, Framer Motion card animations with sound, rebuilt pages, then Vercel deploy with analytics and SEO plumbing.

**Architecture:** Game logic stays in pure functions (`lib/game-engine.ts`) orchestrated by the reducer in `hooks/useGameState.ts` with the single-END_TURN-effect pattern — animations and sound are presentation-only and never a source of truth. New match state (`matchTarget`, `gameEnd` phase) is added engine-first with TDD. The setup screen lives at the page level and mounts GameBoard with chosen settings.

**Tech Stack:** Next.js 16, React 19, TypeScript strict, Tailwind 3, Vitest (+jsdom/@testing-library/react), Framer Motion (new), Vercel + @vercel/analytics (new).

**Design reference:** `docs/plans/2026-06-10-horizon3-premium-visual-design.md` — consult for intent whenever a step allows taste.

**Rules for every task:** TDD for all logic (watch the test fail first). Run `npm run lint && npm run typecheck && npm test` before every commit. Commit after every task. No em dashes in user-facing copy.

---

## Phase 1: Match engine and state

### Task 1: Add match fields to types

**Files:**
- Modify: `types/index.ts`

**Step 1:** Add `'gameEnd'` back to `GamePhase` and `matchTarget` to `GameState`:

```ts
export type GamePhase = 'waiting' | 'playing' | 'roundEnd' | 'gameEnd';

export interface GameState {
  deck: Card[];
  discardPile: Card[];
  players: Player[];
  currentPlayerIndex: number;
  phase: GamePhase;
  winner: string | null;
  turnAction: TurnAction;
  message: string;
  selectedCardId: string | null;
  matchTarget: number;   // round wins needed to win the match
}
```

**Step 2:** Run `npm run typecheck`. Expected: errors in `game-engine.ts` (createInitialGameState), `initial-state.ts`, and test helpers that build `GameState` literals — these are fixed in Tasks 2-3. Do NOT commit yet.

### Task 2: Engine support for matchTarget and gameEnd

**Files:**
- Modify: `lib/game-engine.ts` (createInitialGameState, playCard), `lib/initial-state.ts`
- Test: `lib/game-engine.test.ts`

**Step 1:** Add `matchTarget: 5` to the object in `createPlaceholderGameState()` (`lib/initial-state.ts`) and add `matchTarget` to the `makeState` helper defaults in `lib/game-engine.test.ts` (`matchTarget: 5`). Add a second param to `createInitialGameState(playerName = 'Player', matchTarget = 5)` that is stored in the returned state.

**Step 2:** Write the failing tests in `lib/game-engine.test.ts`:

```ts
describe('match structure', () => {
  test('round win below the match target ends the round only', () => {
    const state = makeState({
      matchTarget: 3,
      players: [
        { id: 'player1', name: 'Player', hand: [card('5', 'spades')], isAI: false, wins: 1 },
        { id: 'ai1', name: 'Computer', hand: [card('2', 'clubs')], isAI: true, wins: 0 },
      ],
    });
    const next = playCard(state, '5-spades');
    expect(next.phase).toBe('roundEnd');
    expect(next.players[0].wins).toBe(2);
  });

  test('reaching the match target ends the match with gameEnd', () => {
    const state = makeState({
      matchTarget: 3,
      players: [
        { id: 'player1', name: 'Player', hand: [card('5', 'spades')], isAI: false, wins: 2 },
        { id: 'ai1', name: 'Computer', hand: [card('2', 'clubs')], isAI: true, wins: 0 },
      ],
    });
    const next = playCard(state, '5-spades');
    expect(next.phase).toBe('gameEnd');
    expect(next.players[0].wins).toBe(3);
    expect(next.winner).toBe('player1');
  });

  test('createInitialGameState stores the match target', () => {
    expect(createInitialGameState('P', 10).matchTarget).toBe(10);
  });
});
```

**Step 3:** Run `npx vitest run lib/game-engine.test.ts`. Expected: FAIL (phase is `roundEnd` in the second test; matchTarget missing).

**Step 4:** Implement in `playCard`'s win branch: after computing the incremented `wins`, set `phase: winner.wins >= state.matchTarget ? 'gameEnd' : 'roundEnd'` and the message to `` `${winner.name} wins the match!` `` vs `` `${winner.name} wins the round!` ``.

**Step 5:** Run `npx vitest run` and `npm run typecheck`. Expected: all pass, no type errors anywhere.

**Step 6:** Commit: `feat: first-to-N match structure in game engine`

### Task 3: Hook support for match settings and rematch

**Files:**
- Modify: `hooks/useGameState.ts`
- Test: `hooks/useGameState.test.tsx`

**Step 1:** Write failing tests:

```ts
test('passes the match target into the initial game state', () => {
  const { result } = renderHook(() => useGameState('easy', 3));
  expect(result.current.gameState.matchTarget).toBe(3);
});

test('handleNewGame resets wins for a rematch', () => {
  const { result } = renderHook(() => useGameState('easy', 3));
  act(() => { result.current.handleNewGame(); });
  expect(result.current.gameState.players[0].wins).toBe(0);
});
```

**Step 2:** Run `npx vitest run hooks`. Expected: FAIL (`matchTarget` is 5; signature has one param).

**Step 3:** Implement: `useGameState(aiDifficulty: AIDifficulty = 'easy', matchTarget = 5)`. Change `START_GAME` to carry it: action becomes `{ type: 'START_GAME'; matchTarget: number }` in `types/index.ts`; reducer case returns `createInitialGameState('Player', action.matchTarget)`. The mount effect and `handleNewGame` dispatch `{ type: 'START_GAME', matchTarget }`. Gate the AI effect and end-turn effect on `phase === 'playing'` (already true — `gameEnd` is therefore inert for them automatically).

**Step 4:** Run `npx vitest run && npm run lint && npm run typecheck`. Expected: all green.

**Step 5:** Commit: `feat: match target and rematch flow in useGameState`

---

## Phase 2: Settings persistence and setup screen

### Task 4: Settings utility

**Files:**
- Create: `lib/settings.ts`
- Test: `lib/settings.test.ts`

**Step 1:** Failing test (jsdom provides localStorage):

```ts
import { describe, test, expect, beforeEach } from 'vitest';
import { loadSettings, saveSettings, DEFAULT_SETTINGS } from './settings';

beforeEach(() => localStorage.clear());

describe('settings', () => {
  test('returns defaults when nothing is stored', () => {
    expect(loadSettings()).toEqual(DEFAULT_SETTINGS);
  });
  test('round-trips saved settings', () => {
    saveSettings({ difficulty: 'hard', matchTarget: 10, soundMuted: true });
    expect(loadSettings()).toEqual({ difficulty: 'hard', matchTarget: 10, soundMuted: true });
  });
  test('ignores corrupt or invalid stored values', () => {
    localStorage.setItem('gameSettings', '{"difficulty":"impossible","matchTarget":7}');
    expect(loadSettings()).toEqual(DEFAULT_SETTINGS);
  });
});
```

**Step 2:** Run `npx vitest run lib/settings.test.ts`. Expected: FAIL (module not found).

**Step 3:** Implement `lib/settings.ts`:

```ts
import { AIDifficulty } from './ai-player';

export interface GameSettings {
  difficulty: AIDifficulty;
  matchTarget: 3 | 5 | 10;
  soundMuted: boolean;
}

export const DEFAULT_SETTINGS: GameSettings = { difficulty: 'easy', matchTarget: 5, soundMuted: false };
const KEY = 'gameSettings';
const DIFFICULTIES = ['easy', 'medium', 'hard'];
const TARGETS = [3, 5, 10];

export function loadSettings(): GameSettings {
  if (typeof window === 'undefined') return DEFAULT_SETTINGS;
  try {
    const raw = JSON.parse(localStorage.getItem(KEY) ?? '');
    if (DIFFICULTIES.includes(raw.difficulty) && TARGETS.includes(raw.matchTarget)) {
      return { ...DEFAULT_SETTINGS, ...raw };
    }
  } catch { /* fall through to defaults */ }
  return DEFAULT_SETTINGS;
}

export function saveSettings(settings: GameSettings) {
  localStorage.setItem(KEY, JSON.stringify(settings));
}
```

**Step 4:** Run the test. Expected: PASS. **Step 5:** Commit: `feat: persisted game settings utility`

### Task 5: Setup screen and page orchestration

**Files:**
- Create: `components/game/SetupScreen.tsx`
- Modify: `app/play/page.tsx`, `components/game/GameBoard.tsx`

**Step 1:** Build `SetupScreen` (client component): difficulty picker with labels Chill (easy) / Clever (medium) / Sharp (hard), match-length picker 3/5/10, big Play button. Props: `initial: GameSettings`, `onStart(settings: GameSettings)`. Selecting Play calls `saveSettings` then `onStart`. Style with existing utilities for now (premium pass comes in Phase 3).

**Step 2:** Rework `app/play/page.tsx` into a client component that owns `const [settings, setSettings] = useState<GameSettings | null>(null)`; on mount, if a stored `gameSettings` exists, you still show the setup screen but pre-filled (returning players get one tap on Play). Render `SetupScreen` when waiting, else `<GameBoard settings={settings} onChangeSettings={() => setSettings(null)} />`.

**Step 3:** `GameBoard` accepts `settings: GameSettings` and `onChangeSettings: () => void`; calls `useGameState(settings.difficulty, settings.matchTarget)`. Add the `gameEnd` screen: final score, gold "You win the match!" or "Computer wins the match!", buttons Rematch (`handleNewGame`) and Change settings (`onChangeSettings`). Round-end keeps the existing Play Again (RESTART_GAME) plus round-win pips in the score strip: render `matchTarget` dots per player, filled per `wins`.

**Step 4:** Verify manually: `preview_start` the dev server, choose Sharp + first-to-3, play a round, confirm pips fill and rematch resets. Run `npm run lint && npm run typecheck && npm test`.

**Step 5:** Commit: `feat: setup screen, difficulty selection, and match UI`

---

## Phase 3: Visual system

### Task 6: Design tokens and fonts

**Files:**
- Modify: `tailwind.config.ts`, `app/globals.css`, `app/layout.tsx`

**Step 1:** Tokens in `tailwind.config.ts` theme.extend.colors (keep existing names working during migration, add the new system):

```ts
coral: { DEFAULT: '#FF6B6B', deep: '#E84855' },
cream: '#FFF8F0',
felt: { DEFAULT: '#2E9E8F', deep: '#1F7A6D' },
gold: '#F4B942',
ink: '#2D3142',
```

Elevation utilities in `globals.css`: `.shadow-card` (0 2px 8px rgba(45,49,66,.12)), `.shadow-raised` (0 6px 20px rgba(45,49,66,.16)), `.shadow-floating` (0 12px 32px rgba(45,49,66,.22)).

**Step 2:** Fonts in `app/layout.tsx` via `next/font/google`: `Fredoka` (variable `--font-display`) + keep Inter (`--font-sans`); wire into Tailwind `fontFamily: { display: ['var(--font-display)'], sans: ['var(--font-sans)'] }`. Apply `font-display` to h1/score numerals.

**Step 3:** Update the game table surface (`.game-table` in globals.css) to the felt gradient; update `themeColor` in layout viewport to the new coral. Build and eyeball with preview. Commit: `feat: premium design tokens and typography`

### Task 7: SVG card faces

**Files:**
- Create: `components/game/CardFace.tsx`
- Modify: `components/game/Card.tsx`
- Test: `components/game/CardFace.test.tsx`

**Step 1:** Failing test first:

```tsx
import { render } from '@testing-library/react';
import CardFace from './CardFace';

test('renders the correct number of pips for number cards', () => {
  const { container } = render(<CardFace rank="7" suit="clubs" />);
  expect(container.querySelectorAll('[data-pip]')).toHaveLength(7);
});
test('renders corner indices with rank text', () => {
  const { getAllByText } = render(<CardFace rank="Q" suit="hearts" />);
  expect(getAllByText('Q').length).toBeGreaterThanOrEqual(2);
});
```

**Step 2:** Run, watch fail. **Step 3:** Implement `CardFace` as a single SVG (`viewBox="0 0 250 350"`): white rounded rect with 1px edge highlight, two corner indices (rank above suit glyph, bottom-right rotated 180), and a pip area driven by a layout map — columns x = 70/125/180, rows y = 70/125/175/225/280; define `PIP_LAYOUTS: Record<Rank, [number, number][]>` matching real playing cards for A and 2-10; J/Q/K render a large display letter in `gold` with a simple crown (K), tiara (Q), or feather (J) path above it. Hearts/diamonds use `#E84855`, clubs/spades use `#2D3142`. Each pip element gets `data-pip`.

**Step 4:** Swap `Card.tsx` face-up rendering to `<CardFace rank suit />` (keep size classes on the wrapper). **Step 5:** Tests + preview screenshot of /play to verify all ranks look right (deal a few hands). Commit: `feat: SVG card faces`

### Task 8: Card backs and icon set

**Files:**
- Modify: `components/game/CardBackDesign.tsx`
- Create: `components/ui/Icon.tsx`

Redraw the four back styles as SVG patterns on the new palette (classic: coral lattice + gold center crest with "PP"; geometric: teal/cream triangles; gradient: coral-to-purple with subtle star field; minimal: cream with single coral pip border). Create `Icon.tsx` exporting small SVG icons used in chrome: `home`, `settings`, `sound-on`, `sound-off`, `trophy`, `cards`, `arrow-down`. Replace emoji in GameBoard header/buttons/hints with icons (celebration emoji may stay in win screens). Update `scripts/generate-icons.ps1`'s output by exporting the new classic back design as the PWA icon (or regenerate to match, Task 14). Verify in preview; run gates; commit: `feat: premium card backs and UI icon set`

---

## Phase 4: Motion and sound

### Task 9: Framer Motion install and timing constants

**Files:**
- Create: `lib/timing.ts`
- Modify: `hooks/useGameState.ts`, `package.json`

**Step 1:** `npm install framer-motion`. **Step 2:** Create `lib/timing.ts`:

```ts
export const TIMING = {
  endTurnDelay: 400,   // ms between an action resolving and the turn passing
  aiThinkDelay: 1200,  // ms before the AI acts
  dealStagger: 80,     // ms between dealt cards
  cardTravel: 0.45,    // s, hand -> discard
} as const;
```

Replace the literal `400` and `1200` in `useGameState.ts` with `TIMING.endTurnDelay` / `TIMING.aiThinkDelay`. Run `npm test` (hook tests still pass — they advance fake timers past these values). Commit: `chore: framer-motion + shared timing constants`

### Task 10: Card travel and deal animations

**Files:**
- Modify: `components/game/Hand.tsx`, `components/game/DiscardPile.tsx`, `components/game/GameBoard.tsx`, `components/game/Card.tsx`

**Step 1:** Wrap each hand card and the top ~3 discard cards in `motion.div` with `layoutId={card.id}` inside a shared `<LayoutGroup>` in GameBoard. When a card moves from a hand array to the discard array, Framer animates it across automatically. Transition: `{ type: 'spring', stiffness: 300, damping: 28 }`; give discard cards `rotate: (hashOf(card.id) % 13) - 6` degrees for the messy-pile look (hash from char codes — deterministic, render-pure).

**Step 2:** Deal-in animation: hand cards get `initial={{ opacity: 0, y: isPlayerHand ? -120 : 120, scale: 0.6 }}` `animate={{ opacity: 1, y: 0, scale: 1 }}` with per-index `delay: i * TIMING.dealStagger / 1000` on first mount of a round (key the Hand by a round counter so re-deals re-trigger).

**Step 3:** Respect reduced motion: `const reduce = useReducedMotion()` from framer-motion; when true, pass `transition={{ duration: 0 }}`.

**Step 4:** Existing tests must stay green (they assert state, not animation). Verify visually in preview: play a card, draw a card, win a round; confirm cards travel, AI plays are visible, nothing desyncs. Commit: `feat: card travel and deal animations`

### Task 11: Win sequences

**Files:**
- Modify: `components/game/GameBoard.tsx`, `app/globals.css`

Round-end: gold banner with spring entrance, refreshed confetti (new palette, mixed shapes; deterministic per-index as now). Match-end (`gameEnd`): full-screen overlay — trophy icon, final pip score, big display-type headline, Rematch / Change settings buttons, denser confetti. Reserve the ad slot: a visually-empty `<div data-slot="round-end" className="min-h-24" />` inside the round-end interstitial. Verify both screens in preview (set first-to-3 to reach gameEnd fast). Commit: `feat: round and match win sequences`

### Task 12: Sound and haptics

**Files:**
- Create: `lib/sound.ts`, `public/sounds/` (6 files), test `lib/sound.test.ts`
- Modify: `components/game/GameBoard.tsx`, `hooks/useGameState.ts` (no — keep sound out of the hook; trigger from GameBoard effects watching state), `components/game/SetupScreen.tsx`

**Step 1:** Source CC0 sounds from Kenney's "Casino Audio" pack (kenney.nl/assets/casino-audio): card slide, card flip, shuffle, chip/chime for match, plus two short jingles for round/match win. Save as `public/sounds/{slide,flip,shuffle,match,round-win,match-win}.ogg` (convert to ogg+mp3 dual source only if needed; modern browsers all play ogg — verify in preview on the user's browser, fall back to mp3 if not).

**Step 2:** TDD the mute logic only (audio playback itself is untestable in jsdom): `lib/sound.ts` exports `playSound(name)`, `setMuted(boolean)`, `isMuted()` persisting `soundMuted` through the settings utility; test that `playSound` is a no-op when muted (inject/spy on an internal `Audio` factory).

**Step 3:** Implement: lazy `Audio` pool keyed by name, volume 0.5, `play()` wrapped in try/catch (autoplay policies), `navigator.vibrate?.(15)` alongside play/match sounds, no-op on server. Wire triggers in GameBoard `useEffect`s watching `discardPile.length` (slide), `phase` transitions (round-win / match-win), and deal (shuffle). Mute toggle button (sound-on/off icon) in the settings footer.

**Step 4:** Gates + preview verification with sound on. Commit: `feat: game sound effects and haptics`

---

## Phase 5: Pages and app shell

### Task 13: Landing page rebuild

**Files:**
- Modify: `app/page.tsx`

Rebuild on the new system, same structure and copy intent: hero = fanned arc of 5 `CardFace` cards (motion entrance, slight stagger), display-type headline, Play CTA; how-to-play steps with `Icon` components instead of numbered emoji circles; fun-facts row restyled on cream cards; remove the floating emoji suits and the `mounted` gate (no longer needed once randomness is gone). Keep both Play CTAs and the footer. Verify with preview screenshot at mobile and desktop widths. Commit: `feat: premium landing page`

### Task 14: Content pages and app shell

**Files:**
- Modify: `app/how-to-play/page.tsx`, `app/rules/page.tsx`, `app/layout.tsx`, `public/manifest.json`, `scripts/generate-icons.ps1`
- Create: `app/icon.svg` (favicon), `public/og-image.png`

Restyle the two content pages with tokens/typography; add one inline visual aid each using `CardFace` (e.g., a matching-pair illustration). Content and headings stay intact for SEO. New favicon from the classic card-back crest; regenerate `icon-192/512.png` to match the new design; create a 1200x630 OG image (card fan + wordmark on coral) and reference it in `metadata.openGraph.images`. Update manifest `background_color`/`theme_color` to the new palette. Commit: `feat: premium content pages and app shell assets`

---

## Phase 6: Launch

### Task 15: SEO plumbing

**Files:**
- Create: `app/robots.ts`, `app/sitemap.ts`

Next metadata routes: `robots.ts` allowing all + sitemap reference; `sitemap.ts` listing `/`, `/play`, `/how-to-play`, `/rules` with the production URL from `const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL ?? 'https://<decided-at-launch>'`. Add `metadataBase` in layout. Commit: `feat: robots and sitemap metadata routes`

### Task 16: Analytics

**Files:**
- Modify: `app/layout.tsx`, `package.json`

`npm install @vercel/analytics @vercel/speed-insights`; render `<Analytics />` and `<SpeedInsights />` at the end of body. They no-op locally. Commit: `feat: Vercel analytics and speed insights`

### Task 17: Deploy and verify

1. Full local gate: `npm run lint && npm run typecheck && npm test && npm run build`.
2. Push to GitHub; confirm CI green.
3. Deploy to Vercel (connect repo via vercel.com or the Vercel MCP tools; framework auto-detects). Set `NEXT_PUBLIC_SITE_URL` to the production URL; redeploy.
4. Decide/attach custom domain (user decision at this step).
5. Verify production: play a full first-to-3 match on mobile and desktop; check sounds, animations, PWA install with the new icons.
6. Search Console: verify the property, submit `/sitemap.xml`.
7. Run Lighthouse against production (`npx lighthouse <url>`); expect strong PWA/accessibility/SEO scores; fix anything below 90 before announcing.

---

## Verification (end-to-end)

- `npm run lint && npm run typecheck && npm test && npm run build` all green; CI green on GitHub.
- Manual: setup screen → Sharp + first-to-3 → win a match → rematch → change settings; sounds + mute toggle; reduced-motion honored (toggle in OS/devtools); landing, how-to-play, rules render the new system; Lighthouse ≥ 90 across categories on production.
