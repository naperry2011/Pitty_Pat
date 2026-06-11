# CODE_MAP

Feature-oriented map of the Pitty_Pat repository (Next.js 15 App Router, React 19, TypeScript, Tailwind CSS).

## Game Engine (Core Rules)

Category: Service (pure logic)

Primary Files:

* lib/game-engine.ts — deck creation, shuffle, deal, canPlayCard, playCard, drawCard, endTurn, createInitialGameState
* types/index.ts — Card, Player, GameState, GameAction, GamePhase, TurnAction types

Supporting Files:

* lib/initial-state.ts — SSR placeholder state (hydration-safe)
* lib/debug-helper.ts — dev-only state logging

External Integrations:

* None (pure functions, no I/O)

Entry Points:

* Consumed by hooks/useGameState.ts

## AI Player

Category: Service (decision logic)

Primary Files:

* lib/ai-player.ts — getAIDecision, executeAITurn, difficulty levels (easy/medium/hard), personality messages

Supporting Files:

* lib/game-engine.ts (findPlayableCards, drawCard, playCard, endTurn)

External Integrations:

* None

Entry Points:

* Consumed by hooks/useGameState.ts (note: AI turn logic is also duplicated inline in the useGameState AI-turn useEffect)

## Game State Orchestration

Category: UI / State

Primary Files:

* hooks/useGameState.ts — useReducer-based game state, action handlers (draw, play, two-tap select), AI turn automation via useEffect timers

Supporting Files:

* lib/initial-state.ts
* lib/debug-helper.ts

External Integrations:

* None

Entry Points:

* Consumed by components/game/GameBoard.tsx

## Game UI

Category: UI

Primary Files:

* components/game/GameBoard.tsx — main composition: hands, deck, discard, messages, round-end UI
* components/game/Hand.tsx — player/AI hand rendering
* components/game/Card.tsx — single card (face/back rendering)
* components/game/Deck.tsx — draw pile
* components/game/DiscardPile.tsx — discard pile

Supporting Files:

* app/globals.css — felt texture, card shadows, custom utilities
* tailwind.config.ts — custom colors and animations

External Integrations:

* None

Entry Points:

* app/play/page.tsx

## Card Style Customization

Category: UI / State

Primary Files:

* contexts/CardStyleContext.tsx — CardStyleProvider, useCardStyle, localStorage persistence (classic/geometric/gradient/minimal)
* components/game/CardBackDesign.tsx — card back visual variants
* components/game/CardStyleSelector.tsx — style picker UI

External Integrations:

* localStorage (browser)

Entry Points:

* Provider mounted in app/layout.tsx

## Static / Marketing Pages

Category: UI

Primary Files:

* app/page.tsx — landing page (client component, animated hero)
* app/how-to-play/page.tsx — tutorial page (server component, SEO metadata)
* app/rules/page.tsx — rules page (server component, SEO metadata)
* app/layout.tsx — RootLayout: metadata, viewport, PWA tags, CardStyleProvider

Supporting Files:

* public/manifest.json — PWA manifest

## Configuration

Category: Infra

Primary Files:

* next.config.js
* tailwind.config.ts
* tsconfig.json — strict mode, `@/` path alias
* eslint.config.mjs
* postcss.config.js
