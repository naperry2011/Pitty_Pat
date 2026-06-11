# ENTRY_POINTS

All execution entry points. This is a client-rendered Next.js App Router app; routes under `app/` are the only entry points. No API routes, workers, CLIs, or cron jobs exist.

## Root Layout

Path: app/layout.tsx
Responsibility: HTML shell, SEO/PWA metadata, viewport config, mounts CardStyleProvider
Invokes: contexts/CardStyleContext.tsx (provider)
Depends On: app/globals.css, public/manifest.json

## Landing Page (/)

Path: app/page.tsx
Responsibility: Marketing/hero page with animated floating cards; links to /play
Invokes: next/link navigation
Depends On: Tailwind utilities in app/globals.css

## Game Page (/play)

Path: app/play/page.tsx
Responsibility: Hosts the playable game
Invokes: components/game/GameBoard.tsx
Depends On: hooks/useGameState.ts → lib/game-engine.ts, lib/ai-player.ts

## How To Play Page (/how-to-play)

Path: app/how-to-play/page.tsx
Responsibility: Static tutorial content with SEO metadata
Invokes: next/link
Depends On: None beyond layout

## Rules Page (/rules)

Path: app/rules/page.tsx
Responsibility: Static rules content with SEO metadata
Invokes: next/link
Depends On: None beyond layout

## Build/Dev Commands

* `npm run dev` — Next.js dev server (localhost:3000)
* `npm run build` / `npm run start` — production build/serve
* `npm run lint` — ESLint
