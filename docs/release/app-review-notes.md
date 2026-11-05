# App Review notes: Pitty Pat 1.0.0 (iOS)

Answers to App Review's Guideline 2.1 "Information Needed" request (2026-11-04). The block below goes verbatim into **App Store Connect → version → App Review Information → Notes** (limit 4,000 characters). The screen recording goes in **Attachment**.

---

```text
Thank you for reviewing Pitty Pat.

1. SCREEN RECORDING
Attached: a screen recording of the app on the iOS Simulator (iPhone 17 Pro, iOS 27.2, the latest release). I am an independent developer and do not currently own a physical iPhone, so I could not record on a device; I'm happy to provide anything else you need. The recording starts on the Home Screen, launches the app from its icon, and shows the first-run tutorial, a game against two computer opponents, the Daily Challenge, the opponent Ladder, Pass & Play, the Locker and Stats.
The app has no account registration, login or account deletion (there are no accounts), no user-generated content, and no paid content or in-app purchases.

2. PURPOSE AND AUDIENCE
Pitty Pat is a digital version of the traditional card game Pitty Pat, a quick "match the rank" game. Players match the rank of the top discard card to play from their hand; otherwise they draw, and a drawn card that matches plays itself. The first player to empty their hand wins the round.
It is for casual card-game players aged 13 and up who want a short, relaxing game they can play alone against the computer or with friends on one phone, offline, without ads or accounts.

3. HOW TO ACCESS THE MAIN FEATURES
No login, credentials or sample files are needed. Everything is available on first launch.
- Play: tap Play. The first game is a short guided tutorial; after it, choose difficulty and match length and play 1 to 3 computer opponents.
- Daily Challenge: tap the yellow Daily Challenge card on the home screen (the same deal for every player each day).
- Ladder: tap Ladder to play named opponents in order.
- Pass & Play: tap Pass & Play, enter 2 to 4 player names; hands stay hidden behind a "Pass the phone" screen between turns.
- Locker: spend coins earned in play on card backs and table colors. Coins cannot be bought.
- Stats: wins, streaks and head-to-head records.
- Settings: gear icon (sound, opponent chatter, card back, replay the tutorial, how to play).

4. EXTERNAL SERVICES
None. The app makes no network requests and uses no external services: no analytics, advertising, authentication, payment, data or AI services. All progress is stored only on the device.

5. REGIONAL DIFFERENCES
None. The app works the same in every country and region; all features and content are identical everywhere. The app is in English.

6. REGULATED INDUSTRY / THIRD-PARTY MATERIAL
Not a regulated industry. There is no real-money gambling or wagering: coins are earned only by playing, cannot be purchased and have no cash value.
Third-party material, all licensed for commercial use:
- Sound effects: "Casino Audio" by Kenney (kenney.nl), Creative Commons Zero (CC0 1.0).
- Fonts: Fredoka and Inter, SIL Open Font License 1.1.
Pitty Pat is a traditional card game; all card artwork and code are original to the developer.
```

---

## Recording (2026-11-04)

No physical iPhone was available, so the recording was made on a fresh iPhone 17 Pro simulator running iOS 27.2 with `xcrun simctl io <device> recordVideo`, starting on the Home Screen and tapping the app icon. Simulator builds are debug builds, where Settings shows the "Debug tools" card, so the video ends before Settings is opened. It was trimmed and exported at 720p (5 min 41 s, about 20 MB).

If App Review insists on a physical device, record build 2 from TestFlight on a borrowed iPhone (Control Center → Screen Recording, starting on the Home Screen) and update item 1 above.
