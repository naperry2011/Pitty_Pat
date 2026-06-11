# Horizon 3 + Premium Visual Update — Design

**Date:** 2026-06-10
**Status:** Approved
**Strategy:** Build everything, launch once (Option B). No deploy until the full upgrade is complete; first public impression is the finished premium product.

## Decisions

| Question | Decision |
|---|---|
| Visual direction | Polished playful: keep the kid-friendly identity, dramatically raise the craft |
| Scope | Full site: game board, landing page, how-to-play, rules |
| Motion | Full motion + sound: Framer Motion card animations, SFX, mobile haptics |
| Hosting / analytics | Vercel + Vercel Analytics (and Speed Insights) |
| Match structure | First-to-N round wins; selectable 3/5/10, default 5 |
| Monetization | No ads at launch; round-end interstitial reserves one clean content zone for later |

## 1. Visual system

- **Tokens** in `tailwind.config.ts` + CSS variables: palette built around coral `#FF6B6B` with a deeper coral, cream/warm-white surfaces, a warm teal-green table felt (kid-friendly, not casino), and one gold accent reserved for wins. Consistent 3-level elevation scale with warm-tinted shadows.
- **Typography:** rounded display font (Fredoka or Baloo 2) for headings/numbers + Inter for body.
- **Cards:** custom SVG faces — corner indices, correct pip layouts per rank, simple illustrated court marks for J/Q/K. The four card-back styles redrawn to match. Paper texture, edge highlight.
- **Icons:** custom SVG icon set replaces emoji in UI chrome; emoji allowed only in celebration moments.

## 2. Motion & sound

- **Framer Motion:** deal animation (deck → hands, staggered, flip on arrival); play animation (hand → discard arc, slight random landing rotation); draw animation (deck → flip reveal → auto-play arc); smooth hand reflow on card removal (layout animation); AI plays use the same animations for legibility. Win: pair pulse → redesigned confetti + gold round banner; match win gets a full celebration screen.
- **Architecture guardrail:** the reducer/single-END_TURN-effect architecture is unchanged. Animations are presentation-only, reading state transitions; turn pacing constants become animation-duration-driven so motion and state stay in sync.
- **Sound:** small CC0 SFX set (card slide, flip, shuffle, match chime, round flourish, match fanfare) via a tiny preloaded audio pool utility (no library). Haptics via `navigator.vibrate` on play/win. Mute toggle in settings footer, persisted to localStorage, sounds default ON after first interaction.
- **Accessibility:** `prefers-reduced-motion` disables travel animations.

## 3. Game features

- **Pre-game setup screen** at `/play` (and on rematch): difficulty Easy/Medium/Hard (labels "Chill / Clever / Sharp") wired to `getAIDecision`; match length 3/5/10. Both persist to localStorage; returning players skip straight to Play.
- **Match structure:** first-to-N. Score strip shows round-win pips for both players. Round end → interstitial with running score → auto-deal next round. Match end → celebration screen with final score, Rematch, Change settings.
- **State:** reintroduce `gameEnd` phase plus `matchTarget` and per-player round wins in `GameState`, implemented with reducer cases and tests (the audit removed the previous dead versions).
- **Ad slot:** the round-end interstitial reserves one content zone; nothing renders there at launch; no-ads marketing copy stays.

## 4. Pages

- **Landing:** same conversion structure, rebuilt on the new system. Hero card-fan illustration with the new SVG cards + entrance animation (replaces random floating emoji suits). Custom icons for the how-to steps.
- **How-to-play / rules:** restyle with tokens and type; content stays intact and crawlable; small inline visual aids using the new card components.
- **App shell:** new favicon, regenerated PWA icons from the final card design, OG share image, updated theme-color.

## 5. Launch checklist (after the build is complete)

1. Vercel project connected to GitHub repo (CI already gates main); production deploy.
2. Custom domain decision at launch time.
3. `@vercel/analytics` + Speed Insights.
4. `robots.txt` + `sitemap.xml` via Next metadata routes.
5. Search Console verification + sitemap submission.
6. Lighthouse pass (PWA + accessibility groundwork already done).

## 6. Testing & guardrails

- All game-logic changes (match state, `gameEnd`, setup persistence) are TDD: failing reducer/engine tests first.
- Existing 22 tests keep passing; engine API unchanged, match logic layers on top.
- Tests never depend on animation timing; animations and sound stay presentation-only.
- CI (lint, typecheck, test, build) remains the merge gate.

## Out of scope

- Multiplayer, accounts, backend of any kind.
- Ads rendering (slot reserved only).
- Tonk / portfolio game #2 (decision deferred until post-launch traffic data).
