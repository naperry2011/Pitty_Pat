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
- Tests live next to their modules (`lib/*.test.ts`, `hooks/*.test.tsx`) and run with Vitest (jsdom)

### Component Structure
```
RootLayout (CardStyleProvider)
  └── GameBoard (useGameState hook)
      ├── Hand (player & AI)
      ├── Deck
      ├── DiscardPile
      └── CardStyleSelector
```

### Key Files
| File | Purpose |
|------|---------|
| `types/index.ts` | All type definitions (Card, Player, GameState, GameAction) |
| `lib/game-engine.ts` | Core game logic - modify for rule changes |
| `lib/ai-player.ts` | AI behavior - modify for difficulty adjustments |
| `hooks/useGameState.ts` | State management - modify for new game actions |
| `components/game/GameBoard.tsx` | Main UI composition |
| `tailwind.config.ts` | Custom colors, animations (poker table effects) |
| `app/globals.css` | Custom CSS utilities (felt texture, card shadows) |

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
