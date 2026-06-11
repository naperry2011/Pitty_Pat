# IMPORT_GRAPH_SUMMARY

High-level dependency structure. No circular dependencies present.

## Core Dependency Nodes

* types/index.ts — imported by all logic and most UI files (Card, GameState, GameAction)
* lib/game-engine.ts — imported by hooks/useGameState.ts, lib/ai-player.ts, components/game/GameBoard.tsx
* hooks/useGameState.ts — single state orchestrator; sole consumer entry for engine + AI in the UI layer
* contexts/CardStyleContext.tsx — imported by app/layout.tsx, Card.tsx, CardBackDesign.tsx, CardStyleSelector.tsx
* components/game/Card.tsx — shared by Hand, Deck, DiscardPile

## Dependency Direction (clean layering)

```
types/index.ts
  ↑
lib/game-engine.ts ← lib/ai-player.ts
  ↑
hooks/useGameState.ts (+ lib/initial-state.ts, lib/debug-helper.ts)
  ↑
components/game/GameBoard.tsx → Hand / Deck / DiscardPile → Card → CardBackDesign
  ↑
app/play/page.tsx
```

## Utility Modules Reused Broadly

* clsx (external) — used by all game components
* lib/debug-helper.ts — dev logging, used only by useGameState

## Potential Refactor Risk Areas

* hooks/useGameState.ts — duplicates AI decision logic inline in its AI-turn useEffect instead of using the imported executeAITurn/getAIDecision from lib/ai-player.ts; difficulty parameter is therefore unused at runtime. Changes to AI behavior must touch both places today.
* components/game/GameBoard.tsx — also imports findPlayableCards directly from the engine, so playability rules are evaluated in both UI and reducer layers.
* Timed END_TURN dispatches (setTimeout in useGameState) — turn sequencing depends on timers spread across handlers; any new action type must respect this ordering.
