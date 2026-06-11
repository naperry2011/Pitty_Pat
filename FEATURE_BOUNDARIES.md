# FEATURE_BOUNDARIES

Responsibility boundaries between components.

## Game Engine (lib/game-engine.ts)

Owns: Deck construction, shuffling, dealing, match rules (rank equality), draw/auto-play/discard rules, win detection, turn rotation
Does NOT Own: Timing, AI decisions, UI state (selection), persistence, rendering
Communicates With: types/index.ts (types only); called by useGameState, ai-player, GameBoard
Isolation Level: Strong (pure functions, no side effects)

## AI Player (lib/ai-player.ts)

Owns: AI decision selection by difficulty, strategic card choice, flavor messages
Does NOT Own: Turn scheduling/timers (lives in useGameState), state mutation dispatch
Communicates With: game-engine (rule queries + state transforms), types
Isolation Level: Strong (pure, but note useGameState currently re-implements its decision logic inline)

## Game State Hook (hooks/useGameState.ts)

Owns: gameReducer (action → state mapping), turn timing (setTimeout sequencing), AI turn automation, two-tap card selection, client-side init to avoid hydration mismatch
Does NOT Own: Game rules (delegates to engine), rendering, card style
Communicates With: game-engine, ai-player, initial-state, debug-helper; consumed only by GameBoard
Isolation Level: Moderate (couples timing + rules orchestration + UI selection state)

## Game UI (components/game/*)

Owns: Rendering of board, hands, deck, discard pile, cards; visual playability hints; round-end overlay
Does NOT Own: Game rules or state transitions (dispatches via useGameState callbacks); card style state
Communicates With: useGameState (GameBoard only), CardStyleContext (Card/CardBackDesign/CardStyleSelector), game-engine (GameBoard reads findPlayableCards for hints)
Isolation Level: Moderate

## Card Style System (contexts/CardStyleContext.tsx + CardBackDesign + CardStyleSelector)

Owns: Card-back style preference, localStorage persistence, style option rendering
Does NOT Own: Game state, card face rendering rules
Communicates With: Card.tsx (consumer), app/layout.tsx (provider mount)
Isolation Level: Strong

## Routes (app/*)

Owns: URL structure, SEO/PWA metadata, page composition
Does NOT Own: Any game logic; /play only mounts GameBoard
Communicates With: components/game (play page), CardStyleContext (layout)
Isolation Level: Strong

## Cross-Cutting

* types/index.ts — shared vocabulary for all layers; changing GameState/GameAction touches engine, hook, and UI
* app/globals.css + tailwind.config.ts — styling utilities used across all UI
