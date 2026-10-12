# Flutter Mobile App: Design

**Date:** 2026-10-11
**Status:** Approved
**Strategy:** Native Flutter app for Android and iOS alongside the existing Next.js site. Android is tested first (development is on Windows); iOS work starts when a Mac is available.

## Decisions

| Question | Decision |
|---|---|
| Web site | Keep Next.js for SEO and as the app's landing page; Flutter app lives in `mobile/` in this repo |
| Multiplayer | Not in v1; real-time friend rooms ship in v1.1 |
| Monetization | Free, no ads; cosmetic in-app purchases later (v1.1+) |
| Hype features | Unlockables and cosmetics, daily challenge and streaks, leaderboards and achievements |
| Engine | Plain Flutter (no Flame); custom card painters, `flutter_animate`, Rive/Lottie for celebrations |
| Platform order | Android first; iOS after a Mac or cloud macOS build is available |

## Architecture guardrails

- Game rules are a pure Dart port of `lib/game-engine.ts` and `lib/ai-player.ts` with test parity. Rule changes land in both until the web and app share a spec.
- State mirrors the web reducer: typed actions, `PLAY_CARD`/`DRAW_CARD` set `turnAction: waiting`, a single place dispatches `END_TURN`.
- Animations, sound, and haptics are presentation-only. They read state transitions and are never a source of truth.
- Randomness is injectable (`Random`) so shuffles, AI choices, and the daily seeded deal are testable.

## Phase 1: Port the core

1. Scaffold Flutter project at `mobile/` (Android + iOS).
2. Port types, engine, and AI to Dart with all existing tests.
3. Port the reducer/turn sequencing as a state controller.
4. Design system: coral/cream/felt/gold/ink tokens, Fredoka display font, card faces and four card backs ported from the SVG components.
5. Screens: Splash, Home, Setup (Chill/Clever/Sharp, first to 3/5/10), Game Board, Round End, Match End, Settings.
6. Motion and sound: deal, play arc, draw-flip reveal, hand reflow, confetti, existing SFX, native haptics.

## Phase 2: Hype layer (on-device, no backend)

1. Progression: coins and XP from wins, streaks, and challenges; player level.
2. Unlockables: card backs, table felts, win celebrations in a Locker screen. Ownership model designed so IAP can be added later.
3. Daily challenge: seeded deal shared by all players, daily streak, calendar, optional local notification.
4. Leaderboards and achievements: Google Play Games (Android first) and Game Center (iOS later). Plugin choice verified at implementation time.
5. Stats screen: win rate by difficulty, best streak, rounds played.

## Phase 3: Store launch

1. App icon, splash, store screenshots, preview video from the new card art.
2. Privacy policy page on the Next.js site.
3. Android: signed release, Play Console internal testing track.
4. iOS (when on a Mac): TestFlight build.
5. "Get the app" links on the site's landing, how-to-play, and rules pages.

## v1.1

- Real-time friend rooms (room codes) and emotes; backend (Supabase or Firebase) chosen at that time.
- Cosmetic IAP built on the Phase 2 ownership model.

## Owner prerequisites

- Google Play Console account (needed for Phase 3 Android).
- Apple Developer Program account and a Mac or cloud macOS builder (needed for iOS).
- Final app name and bundle ID (scaffold uses a placeholder that must be set before the first store upload).
