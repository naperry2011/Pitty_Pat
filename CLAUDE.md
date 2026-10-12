# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
npm install          # Install dependencies
npm run dev          # Start dev server at localhost:3000
npm run build        # Production build
npm run start        # Run production server
npm run lint         # Run ESLint
npm run typecheck    # TypeScript check (tsc --noEmit)
npm run test         # Run unit tests (Vitest)
```

## Tech Stack

- **Next.js 16** with App Router and React 19
- **TypeScript** (strict mode enabled)
- **Tailwind CSS** for styling
- Path aliases configured: use `@/` for imports (e.g., `@/components/game/Card`)

## Architecture

### State Management
- Game state managed via `useReducer` in `hooks/useGameState.ts`
- Card styling preferences in React Context (`contexts/CardStyleContext.tsx`) with localStorage persistence
- Client-side initialization pattern used to avoid hydration mismatches (SSR placeholder state replaced after mount)

### Core Logic Separation
- `lib/game-engine.ts` - Pure functions for game rules: shuffle, deal, canPlayCard, playCard, drawCard, endTurn
- `lib/ai-player.ts` - AI decision-making with difficulty levels (easy/medium/hard); the hook's AI turn effect calls `getAIDecision`
- `hooks/useGameState.ts` - State orchestration, reducer, and side effects (AI turn automation)
- Turn sequencing: `PLAY_CARD`/`DRAW_CARD` set `turnAction: 'waiting'`; a single effect in `useGameState` dispatches `END_TURN`. Do not dispatch `END_TURN` from handlers.
- Tests live next to their modules (`lib/*.test.ts`, `hooks/*.test.tsx`, `components/**/*.test.tsx`) and run with Vitest (jsdom)
- Animations (framer-motion) and sound are presentation-only: they read state transitions in GameBoard effects and are never a source of truth

### Component Structure
```
RootLayout (CardStyleProvider, Analytics)
  └── PlayPage (settings state: null → SetupScreen, set → GameBoard)
      ├── SetupScreen (difficulty Chill/Clever/Sharp, match length 3/5/10)
      └── GameBoard (useGameState(difficulty, matchTarget))
          ├── Hand (player & AI) → Card → CardFace (SVG faces) / CardBackDesign (SVG backs)
          ├── Deck
          ├── DiscardPile
          ├── WinPips (round-win score), roundEnd banner, gameEnd dialog
          └── CardStyleSelector + mute toggle (Help & Settings footer)
```

### Key Files
| File | Purpose |
|------|---------|
| `types/index.ts` | All type definitions (Card, Player, GameState incl. matchTarget, GameAction) |
| `lib/game-engine.ts` | Core game logic - modify for rule changes (incl. match win → gameEnd) |
| `lib/ai-player.ts` | AI behavior - modify for difficulty adjustments |
| `lib/settings.ts` | Persisted game settings (difficulty, matchTarget, soundMuted) |
| `lib/sound.ts` | Sound effects + haptics (mute persisted via settings; UI triggers live in GameBoard effects only) |
| `lib/timing.ts` | Shared timing constants (endTurnDelay, aiThinkDelay, dealStagger) |
| `hooks/useGameState.ts` | State management - modify for new game actions |
| `components/game/GameBoard.tsx` | Main UI composition, animation/sound trigger effects |
| `components/game/CardFace.tsx` | SVG playing-card faces (pure; authentic pip layouts) |
| `components/ui/Icon.tsx` | Chrome icon set (typed name union) |
| `tailwind.config.ts` | Design tokens (coral/cream/felt/gold/ink, shadow-card/raised/floating, font-display) |
| `app/globals.css` | Custom CSS utilities (felt gradient table, confetti, reduced-motion guards) |

## Conventions

- Mark components with `'use client'` when using hooks or Context
- Card IDs follow format: `${rank}-${suit}` (e.g., "A-hearts", "10-spades")
- Game state transitions dispatch through the reducer with typed `GameAction`
- Use `useEffect` for client-side state initialization to prevent hydration errors
- Debug logging available via `lib/debug-helper.ts` (development only)

## Game Rules Summary

- 2 players (human vs AI), 5 cards dealt each
- Match the rank of top discard card to play, otherwise draw
- Drawn card auto-plays if it matches, otherwise goes to discard
- First to empty hand wins the round
- Matches are first-to-N round wins (N = 3/5/10 from the setup screen); reaching N sets phase `gameEnd` (Rematch / Change settings)
- `PLAY_CARD` is only accepted while `turnAction === 'draw'` (no second play during the end-turn delay)

## Mobile App (`mobile/`, Flutter)

Native Android + iOS client alongside the web app. Plan: `docs/plans/2026-10-11-flutter-mobile-app-design.md`. Android is tested first (dev machine is Windows); iOS waits for a Mac.

```bash
cd mobile
flutter pub get
flutter analyze                  # Lints (must be clean)
flutter test                     # Unit + widget tests
flutter run -d emulator-5554     # Run on the Android emulator (Medium_Phone_API_37.0)
flutter build apk --debug        # Debug APK
```

- **Parity rule:** `mobile/lib/game/` is a 1:1 Dart port of `lib/game-engine.ts`, `lib/ai-player.ts` and the `useGameState` reducer. Any rule change lands in both, with tests on both sides.
- **Turn sequencing** mirrors the web: `DrawCard`/`PlayCard` set `turnAction: waiting`; only `GameController._scheduleEffects` dispatches `EndTurn`.
- **Randomness is injectable** (`Random` params) so deals, AI choices and seeded daily challenges are testable.
- **Presentation-only layers:** `game_ui/transitions.dart` diffs consecutive states to pick sound cues and card flights; animations, sound and haptics never feed back into game state. All motion is skipped when `MediaQuery.disableAnimations` is set.
- **State and DI:** built-in `ChangeNotifier` + `InheritedNotifier` (`SettingsScope`); no state-management package. Tests inject the theme (`PittyPatApp(theme:)`), the controller (`GameScreen(controller:)`) and sounds (`defaultSoundPlayer`).
- **Card art** is `CustomPainter` on a 240x360 design canvas (same coordinates as the web SVGs). Suits are vector paths, not glyphs, because Android can render suit characters as emoji.
- **Audio** uses a game audio context that mixes with other apps (no audio focus); `.ogg` assets work on Android only and must be converted (e.g. `afconvert`) before iOS.
- **App-only features (not on the web):** first-run tutorial (`tutorialDone` setting), 2-4 player tables (`opponents` setting, table-size reward multiplier), named opponents with optional chatter (`chatter` setting). The shared rules are unchanged; drawing is allowed even when holding a match (owner decision, 2026-10-11).
- **Layout review without a device:** `OUT_DIR=<dir> flutter test tool/render_screens.dart` renders key screens with the bundled fonts.
- **Release setup:** application ID `com.pittypat.app` (permanent once uploaded). Fonts are bundled in `assets/google_fonts` with runtime fetching off (release builds have no INTERNET permission). Upload signing reads git-ignored `android/key.properties`. Icons/splash/store art are rendered by `tool/render_art.dart` (see `docs/release/`).
