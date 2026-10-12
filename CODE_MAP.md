# CODE_MAP

Feature-oriented map of the Pitty_Pat repository (Next.js 16 App Router, React 19, TypeScript, Tailwind CSS).

## Game Engine (Core Rules)

Category: Service (pure logic)

Primary Files:

* lib/game-engine.ts — deck creation, shuffle, deal, canPlayCard, playCard, drawCard, endTurn, isDeadRound, createInitialGameState
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

* lib/ai-player.ts — getAIDecision, executeAITurn, MISS_CHANCE (difficulty = chance to overlook a held match: easy 35%, medium 12%, hard 0%), personality messages

Supporting Files:

* lib/game-engine.ts (findPlayableCards, drawCard, playCard, endTurn)

External Integrations:

* None

Entry Points:

* Consumed by the AI-turn useEffect in hooks/useGameState.ts

## Game State Orchestration

Category: UI / State

Primary Files:

* hooks/useGameState.ts — useReducer-based game state, action handlers (draw, play, two-tap select), AI turn automation via useEffect timers, dead-round redeal at END_TURN (DEAD_ROUND_MESSAGE)

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

* components/game/GameBoard.tsx — main composition: hands, deck, discard, messages, round-end UI; a dead-round redeal replays the deal animation
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

## Mobile App (Flutter, Android + iOS)

Category: Separate client in `mobile/` (Dart). Ports the web engine 1:1; rule changes land in both.

Primary Files:

* mobile/lib/game/models.dart - PlayingCard, Player, GameState (copyWith), enums; card ids match the web (`A-hearts`)
* mobile/lib/game/game_engine.dart - port of lib/game-engine.ts (injectable `Random` for seeded deals; isDeadRound)
* mobile/lib/game/ai_player.dart - port of lib/ai-player.ts (getAIDecision, sealed AIPlay/AIDraw, missChanceByDifficulty; optional missChance override for opponent play styles)
* mobile/lib/game/game_reducer.dart - typed actions + pure reducer (port of gameReducer; PlayCard gated on turnAction; EndTurn redeals a dead round)
* mobile/lib/game/game_controller.dart - ChangeNotifier port of useGameState: single EndTurn source, AI move timer, two-tap; styles (opponent name -> PlayStyle) set each AI seat's miss chance and think delay
* mobile/lib/game/timing.dart - endTurnDelay / aiThinkDelay / dealStagger (mirrors lib/timing.ts)

UI:

* mobile/lib/screens/ - home_screen, setup_screen, game_screen (board, round banner, match dialog), settings_sheet
* mobile/lib/cards/ - card_face, card_back (CustomPainter ports of the SVGs), suit_shapes (vector suits), playing_card_view
* mobile/lib/game_ui/ - table_pieces (hand/deck/discard), transitions (state diff -> sound + motion), flying_card, confetti
* mobile/lib/theme/ - tokens (colors, shadows) and app_theme (Fredoka + Inter, weighted families declared in pubspec.yaml)
* mobile/lib/widgets/ - felt_table, playful_button, playful_background, win_pips

Supporting Files:

* mobile/lib/settings/settings_store.dart - difficulty, matchTarget, soundMuted, cardBack via shared_preferences; SettingsScope
* mobile/lib/audio/sound_effects.dart - audioplayers SFX pool (mixes with other audio) + HapticFeedback; `defaultSoundPlayer` test seam
* mobile/assets/sounds/ - Kenney Casino Audio (CC0), copied from public/sounds

External Integrations:

* shared_preferences, audioplayers (fonts are bundled files, no font package)

Entry Points:

* mobile/lib/main.dart - loads settings, locks portrait, PittyPatApp (theme injectable for tests)

Tests:

* mobile/test/ - engine/AI/controller parity tests, card art, settings, transitions, screen flows (fake_async, recording SoundPlayer)

Progression and cosmetics (Phase 2, on-device):

* mobile/lib/profile/player_profile.dart - PlayerProfile (coins, xp, per-difficulty stats, win streaks, owned cosmetics, daily days, achievements); validated JSON at prefs key `profile.v1`
* mobile/lib/profile/profile_store.dart - pure applyRound / applyMatch / applyPurchase + ProfileStore (ChangeNotifier, injectable clock) + ProfileScope
* mobile/lib/profile/progression.dart - level curve (xpForLevel 0/100/300/600...) and matchReward (difficulty x length; daily flat)
* mobile/lib/profile/daily.dart - dateKey, dailySeed (yyyymmdd), current/best daily streak
* mobile/lib/profile/achievements.dart - 15 local achievements with stable ids (map to Play Games / Game Center later)
* mobile/lib/cosmetics/catalog.dart - card backs, FeltStyle, CelebrationStyle with price + minLevel; equipped items live in GameSettings, ownership in the profile (main.dart unequipUnowned)
* mobile/lib/screens/ - locker_screen (buy/equip), daily_screen (streak + month calendar), stats_screen; GameScreen.daily = 1 round vs Sharp seeded by date, pays once per day

Tutorial, tables and personalities:

* mobile/lib/game/tutorial.dart - rigged first-run hand (tutorialGameState) + state-derived coaching (tutorialHint); GameScreen.tutorial never records stats
* mobile/lib/game/game_engine.dart - createInitialGameState(opponentNames:) supports 1-3 computer opponents (2-4 players; the web stays 1v1); StartGame rematch keeps the table
* mobile/lib/game/personalities.dart - 9-character roster (3 per difficulty) with tagline + PlayStyle, pickOpponents, pure reactionFor(transition) -> speech line
* mobile/lib/game/play_style.dart - PlayStyle (base miss, thinkDelay, Trait: closer/coasts/focused/steadies/tilts) and missChanceFor(state, player)
* mobile/lib/screens/game_screen.dart - opponent seat row (avatar, pips, overlapped hand), speech bubbles via CompositedTransformFollower above the felt, coach bubble in tutorial mode
* mobile/tool/render_screens.dart - renders screens to PNG without a device (layout review; STORE=1 renders the 1080x1920 Play Store set into docs/release/store/screenshots)
* mobile/test/screens/large_text_test.dart - every screen at 1.3x and 2x system text on 360x640 and 411x914 (game board caps text at 1.3x)

Pass-and-play (2-4 people, one phone):

* mobile/lib/game/game_engine.dart - createTableState(seats:) for any mix of humans/computers (Seat = (name, isAI)); createInitialGameState delegates to it
* mobile/lib/game/game_reducer.dart - StartGame keeps every seat; RestartRound(starter:) picks who moves first
* mobile/lib/game/game_controller.dart - tapCard reads the current player's hand; nextRound(starter:)
* mobile/lib/screens/pass_play_setup_screen.dart - table size, remembered names (resolvePassNames: trimmed, capped at 12, unique), match length
* mobile/lib/screens/game_screen.dart - GameScreen.passAndPlay: viewer = whoever revealed last, "Pass the phone to" cover (_PassCover) before each human turn, seats in turn order after the viewer, winner-after rotation, never records to the profile

Ladder and head to head (single-player progression):

* mobile/lib/profile/ladder.dart - ladderOrder (9 roster names, Chill to Sharp), ladderMatchTarget (3), ladderBonus(rung)
* mobile/lib/profile/player_profile.dart - RivalRecord; PlayerProfile.rivals (name -> played/won) and ladderCleared (JSON keys `rivals`, `ladder`)
* mobile/lib/profile/profile_store.dart - applyMatch updates rivals for non-daily matches and advances the ladder only on a win at the next rung (MatchSummary.ladderBonus)
* mobile/lib/screens/ladder_screen.dart - reversed list (first rung at the bottom), cleared / next / locked rungs; opened from Home
* mobile/lib/screens/game_screen.dart - GameScreen.ladder(rung:) seats that opponent 1v1; "Back to ladder" pops
* mobile/lib/screens/stats_screen.dart - Head to head panel
