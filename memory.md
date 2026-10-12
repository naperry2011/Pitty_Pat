# Project Memory: Pitty Pat

Last updated: 2026-10-11 (end of the computer-play session: difficulty, play styles, ladder, font fix)

## Current state

- **Web (Next.js):** live game + SEO pages. 45 Vitest tests passing, typecheck and lint clean. Shares the rule changes from this session: difficulty as miss chance, dead-round redeal, new difficulty blurbs. Earlier: double-play fix (`PLAY_CARD` requires `turnAction === 'draw'`) and `/privacy` (+ sitemap entry, `NEXT_PUBLIC_CONTACT_EMAIL`).
- **Mobile (Flutter, `mobile/`):** full single-player game for Android (iOS pending a Mac). 215 tests passing, `flutter analyze` clean. Release build verified on the emulator 2026-10-11. See the "Mobile App" sections of `CLAUDE.md` and `CODE_MAP.md`.
- **Plan:** `docs/plans/2026-10-11-flutter-mobile-app-design.md`. Release docs: `docs/release/` (Play Console checklist, closed-test kit, store art).

## What the app has

- Engine/AI/reducer ported 1:1 from the web (parity rule: rule changes land in both).
- Premium visuals: custom-painted cards, 6 card backs, 5 felts, 3 win celebrations; motion (deal, flights, flips, confetti), sound (mixes with music), haptics; reduced-motion support.
- Modes: solo vs 1-3 computer opponents (named personalities with chatter, play styles and taglines), the opponent ladder, daily challenge (seeded, once per day, streaks), first-run tutorial, pass-and-play for 2-4 people on one phone.
- Progression: coins, XP/levels, Locker (buy/equip), 15 achievements (ids stable for Play Games), stats screen with head-to-head records. Debug-only "+1000 coins / +500 XP / reset" tools in Settings.
- Release prep done in-repo: app ID `com.pittypat.app`, version 1.0.0+1, bundled fonts (weighted `Fredoka`/`Inter` families in `pubspec.yaml`, no font package), adaptive icon + splash, upload-key signing config (reads git-ignored `android/key.properties`), Play Store icon, feature graphic and six 1080x1920 screenshots (24-bit).

## Decisions (owner, 2026-10-11)

- Keep the web site for SEO; Flutter app lives in `mobile/` in this repo.
- Free, no ads; cosmetic IAP later (v1.1+). Online multiplayer is v1.1.
- Google Play **personal** account (12 testers x 14 days closed test applies); target audience **13+**.
- App ID `com.pittypat.app` (permanent once uploaded).
- House rule: drawing is allowed even when holding a match (web and app).
- Daily reminder notifications: postponed.
- Android first; owner tests on their own Android phone. iOS when owner is on a Mac.

## Focus change (owner, 2026-10-11)

Public release and online features are **on hold**. The priority is the single-player game against the computer. The app is installed by sideloading (`flutter run --release` or a debug/release APK); the debug-key fallback is fine for that, so the upload keystore is not needed yet.

## Next up (suggested order)

1. Done 2026-10-11: AI difficulty levels are now genuinely different. Previously all three played identically (every playable card shares the top discard's rank, so card choice never mattered). Playing a match always beats drawing (drawing never shrinks a hand), so difficulty = chance the AI overlooks a match and draws instead: Chill 35%, Clever 12%, Sharp 0% (`MISS_CHANCE` / `missChance` in the AI files). Web + app, with tests.
   - Same session, new rule (owner decision): a **dead round** (every rank still held has no copy left in the deck or discard pile, e.g. 4 players each holding one King) is redealt at END_TURN with no score; the next player in turn starts. `isDeadRound` in both engines; message "No one can match. Redealing!" triggers the deal animation/shuffle on both platforms.
2. Done 2026-10-11 (app only; the web has one "Computer"): each roster opponent has a `PlayStyle` (`mobile/lib/game/play_style.dart`): base miss rate, think delay, and a trait. Rosie: closer (never misses on 2 or fewer cards). Pops: slow (1.9s), 40%. Lulu: fast, coasts (+20% miss while leading). Marcus: focused (never misses while someone is on one card). Auntie Bev: steadies (never misses while trailing). Theo: fast, tilts (+20% while trailing). Dee/Jada/Vince: never miss; differ in pace only. Tier averages stay within 0.03 of the difficulty rate (tested). `GameController(styles:)` keys styles by opponent name; unlisted seats use the table difficulty.
   - Taglines (owner-approved): each `Personality` has a `tagline` (max 15 chars, tested; that's what fits at a 4-player table on a 360px phone) shown under the opponent's name at the table.
3. Done 2026-10-11 (app only), owner picks: **Ladder** (`profile/ladder.dart`, `screens/ladder_screen.dart`, Home button): the 9 opponents in order Chill to Sharp, 1v1 first to 3; beat the next rung to unlock the one above; replays allowed but only the next rung pays `ladderBonus` (25 + 15 x rung). **Head to head**: `PlayerProfile.rivals` (name -> played/won) updated by every non-daily solo match (a win beats everyone at the table; a loss counts against each), shown on Stats. Profile JSON gained `rivals` and `ladder` (additive, still schema v1). 4 new achievements (15 total): `ladder_chill`, `ladder_clever`, `ladder_top`, `rivals_all`. `render_screens.dart` now also renders `ladder` and `stats`.
4. Fixes found on the emulator (2026-10-11): (a) bold text rendered light on devices because `google_fonts` registers each weight as its own family (`Fredoka_regular`) and the theme handed out the regular one, so `fontWeight: w700/w800` had no bold file; fixed by declaring the bundled files as weighted families in `pubspec.yaml`, using `Fredoka`/`Inter` in `buildAppTheme`, and removing the package (`test/theme_test.dart` guards it; `render_screens.dart` now uses the real theme). (b) Setup option tiles had uneven heights when a description wrapped; rows are now equal height. (c) Difficulty blurbs changed to "Misses plays" / "Rarely slips" / "Never misses" (web + app). Sweep covered home, tutorial, setup, game, settings sheet, ladder, stats, locker, daily; not yet seen on a device: the match-over screen.
   - Still open: the owner's own phone testing. Taste calls left as-is: "Level 1" on Stats uses regular weight; Home chip reads "1 Level".

## On hold (resume only when the owner asks)

- Play Console: account approval, upload keystore + `mobile/android/key.properties` (command in `docs/release/play-console-checklist.md`), closed test (`docs/release/closed-test-kit.md`), store listing copy, `NEXT_PUBLIC_CONTACT_EMAIL` in Vercel for `/privacy`.
- Play Games Services (plugin `games_services` 5.0.x; 5.2.0 is retracted). Needs the Application ID plus achievement/leaderboard IDs.
- v1.1: online friend rooms (backend choice: Supabase vs Firebase, undecided); cosmetic IAP on top of the Locker's ownership model.
- iOS on a Mac: convert `.ogg` sounds (e.g. `afconvert`), set signing, TestFlight.

## Working notes

- Emulator: `Medium_Phone_API_37.0`; adb at `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`. The owner may also use the emulator, so pause taps while Claude drives it.
- No-device layout review: `OUT_DIR=<dir> flutter test tool/render_screens.dart` (add `STORE=1` for the Play Store set, then flatten PNGs to 24-bit with PowerShell System.Drawing).
- Icons/splash/store art regenerate via `flutter test tool/render_art.dart`, then `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`.
- No Python or ffmpeg on this machine; use Dart/PowerShell for scripting.

## Lessons learned

- Test renders can hide device-only font problems: `render_screens.dart` used to register its own weighted families, so its PNGs looked right while the device faked bold. Renders now use `buildAppTheme()`; still spot-check on the emulator after theme or font changes.
- Pitty Pat has one real decision (play a match vs draw), and playing always wins on tempo. Any "smarter AI" idea that holds back matches makes it weaker; difficulty and personality can only shape how often and when the AI overlooks a match, and its pace.
