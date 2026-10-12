# Google Play Console Checklist: Pitty Pat (Android)

**Prepared:** 2026-10-11
**Scope:** Developer account, app creation, signing, testing tracks, Play Games Services (leaderboards + achievements), store listing, and the path to production.
**Owner key:** **You** = steps only the account holder can do (payment, identity, legal, Console clicks). **Claude** = code and config I do in the repo once you hand over the values.

Facts marked *(verified)* were checked against Google's live documentation on 2026-10-11 (sources at the bottom). Items marked *(confirm in Console)* are standard practice I could not pin to a current Google page; double-check them on screen.

---

## 0. Decisions to make first

- [x] **Account type: Personal** (decided 2026-10-11). The closed-test rule below applies; see `closed-test-kit.md`.
  - Personal accounts created after Nov 13, 2023 must run a **closed test with at least 12 testers opted in for 14 consecutive days** before Production unlocks *(verified)*. A tester who opts out and back in restarts their 14 days *(verified)*.
  - Organization accounts are not covered by that personal-account rule on Google's page *(verified that the rule is scoped to personal accounts)*. Organization registration typically needs a D-U-N-S number for the business *(confirm in Console; not on the page I checked)*. If you have a business entity (e.g. Architek Code), this can save the 14-day wait.
- [x] **Final application ID: `com.pittypat.app`** (decided 2026-10-11; set in Android and as the iOS bundle ID). It must match exactly across the app, Play Console, and the Play Games OAuth credential *(verified)*, and it cannot be changed after the first upload *(standard Play behavior; confirm in Console)*.
- [x] **Target audience: 13+** (decided 2026-10-11). The web brand is kid-friendly, but declaring children under 13 in the target audience puts the app under the **Families policy**: only approved SDKs, no mandatory sign-in through non-approved services, neutral age screen for mixed audiences *(verified)*. I could not confirm whether Play Games Services is on the approved list for child-directed apps. **Recommendation:** target 13+ (Pitty Pat's real audience is teens and adults), keep the store listing family-friendly but not child-directed. Misrepresenting the audience can get the app removed *(verified)*.

## 1. Developer account (You)

- [ ] Register at play.google.com/console. One-time **US$25** fee; prepaid cards not accepted *(verified)*.
- [ ] Be 18+; have a government ID and a credit card in your legal name ready for identity verification. The fee is not refunded if verification fails *(verified)*.
- [ ] Personal accounts: verify access to an Android device using the **Play Console mobile app** *(verified)*.
- [ ] Set the public developer name and contact email (shown on the store listing).

## 2. Create the app (You)

- [ ] **Create app** > name "Pitty Pat", default language, **Game** (not app), **Free**. Declaring it a game is required for Play Games Services *(verified)*.
- [ ] Accept the Developer Program Policies and US export law declarations.
- [ ] Turn on **Play App Signing** (default for new apps). Google holds the app signing key; you upload with an upload key.

## 3. Signing and release build (Claude, with one input from You)

- [ ] **You:** pick a strong keystore password and tell me where you want the upload keystore stored (never in the repo, ideally in a password manager backup too). Losing it means a key reset request to Google.
- [x] **Claude:** Gradle `signingConfigs.release` reads `android/key.properties` (git-ignored); falls back to the debug key until it exists.
- [ ] **You:** create the upload keystore and `key.properties` (commands in "Create the upload key" below).
- [x] **Claude:** `applicationId` `com.pittypat.app`, label "Pitty Pat", version `1.0.0+1`.
- [x] **Claude:** Fredoka + Inter bundled in `assets/google_fonts` (SHA-256 verified against google_fonts), runtime fetching off, OFL licenses registered.
- [x] **Claude:** adaptive app icon + splash generated from the card art (`tool/render_art.dart`).
- [ ] **Claude:** build the bundle: `flutter build appbundle --release`. Target SDK is already 36, which meets Play's requirement for new apps from Aug 31, 2026 *(verified)*.

## 4. Policy and listing forms (You, Claude drafts the text)

- [x] **Claude:** `/privacy` page added to the Next.js site (and sitemap).
- [ ] **You:** set `NEXT_PUBLIC_CONTACT_EMAIL` in Vercel (the contact line is hidden until set), deploy, and use `<site>/privacy` as the privacy policy URL. Needed for the Data safety form and Play Games.
- [ ] **Data safety form.** Draft answers: no data collected by the app itself (profile, coins, stats stored on-device only); Play Games sign-in is handled by Google. Revisit when Play Games and any analytics are added.
- [ ] **Content rating (IARC questionnaire).** Card game, no real-money betting, no purchasable chance items. Answer the simulated-gambling question carefully (coins are earned, not bought).
- [ ] **Target audience and content** (see decision in section 0).
- [ ] **Ads declaration:** No ads.
- [ ] **App access:** all features available without login.
- [ ] **Store listing:** short description (80 chars), full description, app icon, feature graphic, phone screenshots *(confirm sizes in Console; commonly 512x512 icon and 1024x500 feature graphic)*. Claude can produce the screenshots from the emulator and draft the copy.

## 5. Play Games Services (You in Console, Claude in code)

Order matters. Steps follow Google's setup guide *(verified)*.

- [ ] **Google Cloud project:** create one (or let Play Console create it) and enable the Games API (`games.googleapis.com`).
- [ ] **Play Console > Grow users > Play Games Services > Setup and management > Configuration:** choose "No, my game doesn't use Google APIs", enter "Pitty Pat", **Create**.
- [ ] **Properties:** display name (required for testing) and description matching the store listing.
- [ ] **OAuth consent screen** (Google Cloud): scopes `games`, `games_lite`, `drive.appdata` (none need verification). Make it available to everyone the game is available to; publish it before the game goes public *(verified)*.
- [ ] **Credentials > Add credential > Android**, name it "Pitty Pat", **Create OAuth client** in Google Cloud with the **package name** and **SHA-1**:
  - Release: SHA-1 from Play Console > **App integrity > App signing**.
  - Debug: from `keytool -list -v -keystore C:\Users\<you>\.android\debug.keystore` (Claude can pull this).
  - Google recommends **two credentials** (release + debug), same package name *(verified)*. A wrong SHA-1 or package name breaks sign-in.
- [ ] **Copy the Application ID** (the "Project ID" digits under the game name) and send it to Claude.
- [ ] **Testers tab:** add your own Google account (the SDK won't work for you otherwise) and testers' emails; access can take a couple of hours *(verified)*. Or add the internal/closed **release tracks** so all track testers get access.
- [ ] **Achievements:** create the 10 below. Google's quality checklist requires **at least 10 visible (revealed) achievements**, so set all of them to *Revealed* *(verified)*. Each needs a name, description, icon, and points; points total is capped at 1000 *(verified)*. Claude can generate the 10 icons.

  | Code id | Name | Description | Coins in app |
  |---|---|---|---|
  | `first_win` | First Pat | Win your first match | 25 |
  | `sharp_win` | Sharp Shooter | Beat the Sharp computer in a match | 25 |
  | `sweep` | Clean Sweep | Win a match of 3+ rounds without losing one | 50 |
  | `streak_3` | On a Roll | Win 3 matches in a row | 25 |
  | `streak_10` | Unstoppable | Win 10 matches in a row | 100 |
  | `rounds_50` | Card Shark | Win 50 rounds | 50 |
  | `daily_first` | Daily Dealer | Complete a daily challenge | 25 |
  | `daily_streak_7` | Week of Pats | Complete the daily challenge 7 days in a row | 100 |
  | `level_5` | Rising Star | Reach level 5 | 25 |
  | `collector` | Collector | Own 8 cosmetics | 50 |

- [ ] **Leaderboards** (proposed; tell me if you want different ones):
  - *Best win streak* (integer, higher is better)
  - *Matches won on Sharp* (integer, higher is better)
  - *Daily challenge streak* (integer, higher is better)
- [ ] Send Claude the generated **achievement and leaderboard IDs**.
- [ ] **Claude:** add the Flutter plugin (`games_services`, latest stable 5.0.x; 5.2.0 is retracted, so don't use it), `android/app/src/main/res/values/games-ids.xml`, manifest `meta-data`, optional sign-in (never required to play), and report unlocks/scores from the existing profile events.
- [ ] **At launch:** publish the Play Games Services configuration (**Publish Game**) **before** publishing the app, or non-testers get errors *(verified)*.

## 6. Testing tracks (You + Claude)

- [ ] **Internal testing:** upload the first `.aab`, add yourself and up to a handful of testers, install from the Play link, and test Play Games sign-in end to end.
- [ ] **Closed testing** (personal accounts): recruit **12+ real testers** (friends, family, the Pitty Pat crowd) who stay opted in for **14 consecutive days** *(verified)*. Ask them to actually play: the production application asks about tester engagement and feedback *(verified)*.
- [ ] Collect feedback (a simple Google Form works) and ship at least one update during the test. You'll describe what changed.

## 7. Apply for production (You)

The application has three sections *(verified)*:
- [ ] **Closed test:** how recruiting went, how testers engaged (did they use all features), what feedback you got and how.
- [ ] **The game:** target audience, value proposition, estimated first-year installs.
- [ ] **Readiness:** what you changed based on testing and how you decided it was ready.

## 8. Launch day

- [ ] Publish Play Games configuration first, then the production release (staged rollout optional).
- [ ] Add "Get it on Google Play" buttons to the website's landing, how-to-play and rules pages (Claude).
- [ ] Update `memory.md` / Notion with the final app ID, Play Games IDs, and keystore location (not the password).

---

## What I need from you, in order

1. Account type decision, then register and verify (sections 0 and 1).
2. Final package name and the target-audience decision.
3. Create the app in Console (section 2).
4. Keystore password and storage location (section 3).
5. OK to download and bundle the font files.
6. Play Games Application ID, then the achievement and leaderboard IDs (section 5).

## Sources

- [App testing requirements for new personal developer accounts](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en) (Play Console Help)
- [Get started with Play Console / developer account requirements](https://support.google.com/googleplay/android-developer/answer/6112435?hl=en) (Play Console Help)
- [Target API level requirements](https://developer.android.com/google/play/requirements/target-sdk) (Android Developers)
- [Set up Play Games Services](https://developer.android.com/games/pgs/console/setup?hl=en) (Android Developers)
- [Achievements](https://developer.android.com/games/pgs/achievements) and [Quality checklist for Play Games Services](https://developer.android.com/games/pgs/quality?hl=en) (Android Developers)
- [Google Play Families policies](https://support.google.com/googleplay/android-developer/answer/9893335?hl=en) (Play Console Help)
- [games_services on pub.dev](https://pub.dev/packages/games_services)

---

## Create the upload key (You, about 2 minutes)

Run in a terminal from `mobile/android`. `keytool` ships with Android Studio's JDK (`<Android Studio>\jbr\bin\keytool.exe` if it isn't on your PATH). It prompts for a password and your name; store the password in your password manager.

```bash
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then create `mobile/android/key.properties` (git-ignored) with:

```
storePassword=<the password you chose>
keyPassword=<the same password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

Back up `upload-keystore.jks` somewhere safe outside the repo. Then `flutter build appbundle --release` produces the file to upload.
