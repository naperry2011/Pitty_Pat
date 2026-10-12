# Project Memory: Pitty Pat

Last updated: 2026-10-11 (end of the Flutter mobile app session)

## Current state

- **Web (Next.js):** live game + SEO pages. This session only touched it to fix a double-play bug (`PLAY_CARD` now requires `turnAction === 'draw'`) and to add `/privacy` (+ sitemap entry, `NEXT_PUBLIC_CONTACT_EMAIL`).
- **Mobile (Flutter, `mobile/`):** full single-player game for Android (iOS pending a Mac). 175 tests passing, `flutter analyze` clean. See the "Mobile App" sections of `CLAUDE.md` and `CODE_MAP.md`.
- **Plan:** `docs/plans/2026-10-11-flutter-mobile-app-design.md`. Release docs: `docs/release/` (Play Console checklist, closed-test kit, store art).

## What the app has

- Engine/AI/reducer ported 1:1 from the web (parity rule: rule changes land in both).
- Premium visuals: custom-painted cards, 6 card backs, 5 felts, 3 win celebrations; motion (deal, flights, flips, confetti), sound (mixes with music), haptics; reduced-motion support.
- Modes: solo vs 1-3 computer opponents (named personalities with chatter), daily challenge (seeded, once per day, streaks), first-run tutorial, pass-and-play for 2-4 people on one phone.
- Progression: coins, XP/levels, Locker (buy/equip), 11 achievements (ids stable for Play Games), stats screen. Debug-only "+1000 coins / +500 XP / reset" tools in Settings.
- Release prep done in-repo: app ID `com.pittypat.app`, version 1.0.0+1, bundled fonts (no runtime fetch), adaptive icon + splash, upload-key signing config (reads git-ignored `android/key.properties`), Play Store icon, feature graphic and six 1080x1920 screenshots (24-bit).

## Decisions (owner, 2026-10-11)

- Keep the web site for SEO; Flutter app lives in `mobile/` in this repo.
- Free, no ads; cosmetic IAP later (v1.1+). Online multiplayer is v1.1.
- Google Play **personal** account (12 testers x 14 days closed test applies); target audience **13+**.
- App ID `com.pittypat.app` (permanent once uploaded).
- House rule: drawing is allowed even when holding a match (web and app).
- Daily reminder notifications: postponed.
- Android first; owner tests on their own Android phone. iOS when owner is on a Mac.

## Waiting on the owner

1. Play Console account approval (personal account registered/pending).
2. Create the upload keystore + `mobile/android/key.properties` (command in `docs/release/play-console-checklist.md`, "Create the upload key"). Back up the keystore; never commit it.
3. Set `NEXT_PUBLIC_CONTACT_EMAIL` in Vercel and deploy so `/privacy` shows contact info (needed as the privacy policy URL).
4. Recruit 15-18 Android testers for the closed test (kit: `docs/release/closed-test-kit.md`), once the account is approved.
5. Phone-testing feedback on the latest build (`flutter run --release` from `mobile/`).

## Next up (suggested order)

1. Store listing copy (short + full description) for Play Console.
2. Fixes from the owner's phone testing.
3. Play Games Services integration once Console IDs exist (plugin `games_services` 5.0.x; 5.2.0 is retracted). Needs the Application ID plus achievement/leaderboard IDs.
4. v1.1: online friend rooms (backend choice: Supabase vs Firebase, still undecided); cosmetic IAP on top of the Locker's ownership model.
5. iOS on a Mac: convert `.ogg` sounds (e.g. `afconvert`), set signing, TestFlight.

## Working notes

- Emulator: `Medium_Phone_API_37.0`; adb at `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`. The owner may also use the emulator, so pause taps while Claude drives it.
- No-device layout review: `OUT_DIR=<dir> flutter test tool/render_screens.dart` (add `STORE=1` for the Play Store set, then flatten PNGs to 24-bit with PowerShell System.Drawing).
- Icons/splash/store art regenerate via `flutter test tool/render_art.dart`, then `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`.
- No Python or ffmpeg on this machine; use Dart/PowerShell for scripting.
