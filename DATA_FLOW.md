# DATA_FLOW

System-level data movement. All flows are in-browser; there is no backend, database, or network I/O.

## Game Initialization

Source: app/play/page.tsx mount
Transport: React render
Processor: useGameState → SSR placeholder (lib/initial-state.ts) → post-mount dispatch START_GAME → lib/game-engine.ts createInitialGameState (shuffle + deal)
Storage: React useReducer state (in-memory)
Downstream Consumers: GameBoard → Hand / Deck / DiscardPile / Card

## Player Turn (Play Card)

Source: Card tap in Hand
Transport: Callback props (handleCardTap → two-tap select → handlePlayCard)
Processor: gameReducer (PLAY_CARD) → lib/game-engine.ts playCard → win check → END_TURN (timed dispatch)
Storage: useReducer state
Downstream Consumers: GameBoard re-render, message banner, round-end overlay

## Player Turn (Draw Card)

Source: Deck tap
Transport: handleDrawCard callback
Processor: gameReducer (DRAW_CARD) → lib/game-engine.ts drawCard (auto-play if match, else discard; reshuffle discard into deck when empty) → END_TURN (timed dispatch)
Storage: useReducer state
Downstream Consumers: GameBoard re-render

## AI Turn

Source: useEffect in hooks/useGameState.ts watching currentPlayerIndex/phase
Transport: setTimeout (1200ms think delay) → dispatch
Processor: inline playable-card check → PLAY_CARD or DRAW_CARD → END_TURN (300ms delay). (lib/ai-player.ts contains a parallel decision path imported but the effect implements its own logic.)
Storage: useReducer state
Downstream Consumers: GameBoard re-render

## Card Style Preference

Source: CardStyleSelector tap
Transport: Context setter (useCardStyle)
Processor: CardStyleContext handleSetCardBackStyle
Storage: localStorage key `cardBackStyle`; React Context state
Downstream Consumers: Card → CardBackDesign (read on every card-back render; restored from localStorage on mount)

## Debug Logging (dev only)

Source: every gameReducer action
Transport: function call
Processor: lib/debug-helper.ts logGameState
Storage: browser console
Downstream Consumers: None
