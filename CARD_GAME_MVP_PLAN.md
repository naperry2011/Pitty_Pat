# Card Game Website MVP Plans
## Tonk • Dominoes • Pitty Pat

**Prepared for Architek Code — December 2025**

---

## Executive Summary

Three underserved card game niches with significant market opportunity. Each game targets a dedicated player base with limited quality online options, creating a clear path to organic traffic and monetization.

---

## Market Opportunity Comparison

| Factor | Tonk | Dominoes | Pitty Pat |
|--------|------|----------|-----------|
| Competition Level | Very Low | Low-Medium | Almost None |
| Search Demand | Medium | High | Low-Medium |
| Existing Quality | Poor (buggy apps) | Mediocre | Non-existent |
| Cultural Base | Strong (Black community) | Global | Regional (South US) |
| Opportunity Score | ★★★★★ | ★★★★☆ | ★★★★★ |

---

## 1. Tonk (Tunk) — Primary Recommendation

### Why Tonk?
- Extremely underserved niche — existing apps have terrible reviews (ads, bugs, crashes)
- Strong cultural relevance in Black American community (barbershops, cookouts, family gatherings)
- No dominant web player — you could own this keyword with a quality product
- Fast-paced game = more ad impressions per session
- Mobile app stores show $400K+/month revenue for similar card games

### Game Rules Reference
```
Players: 2-4
Cards: Standard 52-card deck
Deal: 5 cards each
Objective: Empty your hand or have lowest points when someone knocks

Point Values:
- Face cards (K, Q, J): 10 points
- Aces: 1 point
- Number cards: Face value

Winning Conditions:
- Tonk: 49 or 50 points on initial deal = instant win (2x payout)
- Spread out: Get rid of all cards by forming spreads
- Knock: End round when you think you have lowest points
- If knocker doesn't have lowest = knocker pays double

Spreads:
- Books: 3-4 cards of same rank (e.g., 7-7-7)
- Runs: 3+ consecutive cards in same suit (e.g., 4-5-6 of hearts)

Hitting:
- Add cards to any player's existing spreads
```

### Phase 1: Single Player MVP (Week 1-2)

**Goal:** Get something live fast to start SEO indexing

#### Core Features
- [ ] Game logic: 5-card deal, spreads (runs/sets), hitting, knocking
- [ ] Tonk detection (49/50 auto-win)
- [ ] Simple AI opponent (rule-based)
- [ ] Clean, mobile-responsive UI with card animations
- [ ] Local storage for game state persistence

#### SEO Pages
- [ ] `/how-to-play-tonk` - Comprehensive rules (2000+ words)
- [ ] `/tonk-rules` - Quick reference
- [ ] `/tonk-vs-rummy` - Comparison article
- [ ] `/tonk-strategy` - Tips and tricks

#### File Structure
```
/tonk-game
├── app/
│   ├── page.tsx                 # Main game
│   ├── how-to-play/page.tsx     # SEO content
│   ├── rules/page.tsx           # SEO content
│   └── layout.tsx
├── components/
│   ├── game/
│   │   ├── Card.tsx
│   │   ├── Hand.tsx
│   │   ├── Deck.tsx
│   │   ├── DiscardPile.tsx
│   │   ├── SpreadArea.tsx
│   │   └── GameBoard.tsx
│   ├── ui/
│   │   ├── Button.tsx
│   │   ├── Modal.tsx
│   │   └── ScoreDisplay.tsx
│   └── layout/
│       ├── Header.tsx
│       └── Footer.tsx
├── lib/
│   ├── game-logic/
│   │   ├── deck.ts              # Deck creation, shuffle
│   │   ├── scoring.ts           # Point calculation
│   │   ├── spreads.ts           # Validate runs/books
│   │   ├── ai.ts                # AI opponent logic
│   │   └── game-state.ts        # State management
│   └── utils/
│       └── storage.ts           # Local storage helpers
├── hooks/
│   ├── useGameState.ts
│   └── useAI.ts
└── types/
    └── game.ts                  # TypeScript interfaces
```

#### Core Type Definitions
```typescript
// types/game.ts

export type Suit = 'hearts' | 'diamonds' | 'clubs' | 'spades';
export type Rank = 'A' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' | '10' | 'J' | 'Q' | 'K';

export interface Card {
  id: string;
  suit: Suit;
  rank: Rank;
  faceUp: boolean;
}

export interface Spread {
  id: string;
  cards: Card[];
  type: 'book' | 'run';
  owner: string; // player id
}

export interface Player {
  id: string;
  name: string;
  hand: Card[];
  isAI: boolean;
  score: number;
}

export interface GameState {
  deck: Card[];
  discardPile: Card[];
  players: Player[];
  spreads: Spread[];
  currentPlayerIndex: number;
  phase: 'dealing' | 'playing' | 'roundEnd' | 'gameEnd';
  winner: string | null;
  turnPhase: 'draw' | 'play' | 'discard';
}

export interface GameConfig {
  playerCount: number;
  aiDifficulty: 'easy' | 'medium' | 'hard';
  winningScore: number;
}
```

#### Core Game Logic
```typescript
// lib/game-logic/deck.ts

import { Card, Suit, Rank } from '@/types/game';

const SUITS: Suit[] = ['hearts', 'diamonds', 'clubs', 'spades'];
const RANKS: Rank[] = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];

export function createDeck(): Card[] {
  const deck: Card[] = [];
  for (const suit of SUITS) {
    for (const rank of RANKS) {
      deck.push({
        id: `${rank}-${suit}`,
        suit,
        rank,
        faceUp: false
      });
    }
  }
  return deck;
}

export function shuffle(deck: Card[]): Card[] {
  const shuffled = [...deck];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
}

export function deal(deck: Card[], numCards: number): { dealt: Card[]; remaining: Card[] } {
  return {
    dealt: deck.slice(0, numCards),
    remaining: deck.slice(numCards)
  };
}
```

```typescript
// lib/game-logic/scoring.ts

import { Card, Rank } from '@/types/game';

const POINT_VALUES: Record<Rank, number> = {
  'A': 1, '2': 2, '3': 3, '4': 4, '5': 5,
  '6': 6, '7': 7, '8': 8, '9': 9, '10': 10,
  'J': 10, 'Q': 10, 'K': 10
};

export function getCardPoints(card: Card): number {
  return POINT_VALUES[card.rank];
}

export function getHandPoints(hand: Card[]): number {
  return hand.reduce((total, card) => total + getCardPoints(card), 0);
}

export function isTonk(hand: Card[]): boolean {
  const points = getHandPoints(hand);
  return points === 49 || points === 50;
}
```

```typescript
// lib/game-logic/spreads.ts

import { Card, Spread } from '@/types/game';

const RANK_ORDER = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];

export function isValidBook(cards: Card[]): boolean {
  if (cards.length < 3 || cards.length > 4) return false;
  const rank = cards[0].rank;
  return cards.every(card => card.rank === rank);
}

export function isValidRun(cards: Card[]): boolean {
  if (cards.length < 3) return false;
  
  // All same suit
  const suit = cards[0].suit;
  if (!cards.every(card => card.suit === suit)) return false;
  
  // Sort by rank
  const sorted = [...cards].sort((a, b) => 
    RANK_ORDER.indexOf(a.rank) - RANK_ORDER.indexOf(b.rank)
  );
  
  // Check consecutive
  for (let i = 1; i < sorted.length; i++) {
    const prevIndex = RANK_ORDER.indexOf(sorted[i - 1].rank);
    const currIndex = RANK_ORDER.indexOf(sorted[i].rank);
    if (currIndex !== prevIndex + 1) return false;
  }
  
  return true;
}

export function canHitSpread(spread: Spread, card: Card): boolean {
  if (spread.type === 'book') {
    return spread.cards[0].rank === card.rank && spread.cards.length < 4;
  }
  
  // For runs, check if card extends either end
  const testCards = [...spread.cards, card];
  return isValidRun(testCards);
}

export function findPossibleSpreads(hand: Card[]): Card[][] {
  const spreads: Card[][] = [];
  
  // Find books
  const byRank = new Map<string, Card[]>();
  hand.forEach(card => {
    const existing = byRank.get(card.rank) || [];
    byRank.set(card.rank, [...existing, card]);
  });
  byRank.forEach(cards => {
    if (cards.length >= 3) spreads.push(cards.slice(0, 4));
  });
  
  // Find runs (simplified - check all 3+ card combinations in same suit)
  const bySuit = new Map<string, Card[]>();
  hand.forEach(card => {
    const existing = bySuit.get(card.suit) || [];
    bySuit.set(card.suit, [...existing, card]);
  });
  bySuit.forEach(cards => {
    if (cards.length >= 3) {
      const sorted = [...cards].sort((a, b) => 
        RANK_ORDER.indexOf(a.rank) - RANK_ORDER.indexOf(b.rank)
      );
      // Find consecutive sequences
      let run: Card[] = [sorted[0]];
      for (let i = 1; i < sorted.length; i++) {
        const prevIndex = RANK_ORDER.indexOf(sorted[i - 1].rank);
        const currIndex = RANK_ORDER.indexOf(sorted[i].rank);
        if (currIndex === prevIndex + 1) {
          run.push(sorted[i]);
        } else {
          if (run.length >= 3) spreads.push([...run]);
          run = [sorted[i]];
        }
      }
      if (run.length >= 3) spreads.push([...run]);
    }
  });
  
  return spreads;
}
```

### Phase 2: Multiplayer & Accounts (Week 3-4)

#### Features
- [ ] WebSocket-based real-time multiplayer (Socket.io)
- [ ] User accounts (email or social login via Clerk/NextAuth)
- [ ] Public lobbies + private rooms (shareable links)
- [ ] Basic leaderboard and player stats
- [ ] In-game chat (emoji reactions minimum)

#### Additional File Structure
```
├── app/
│   ├── api/
│   │   ├── auth/[...nextauth]/route.ts
│   │   ├── games/route.ts
│   │   └── socket/route.ts
│   ├── lobby/page.tsx
│   ├── room/[id]/page.tsx
│   └── profile/page.tsx
├── lib/
│   ├── socket/
│   │   ├── client.ts
│   │   └── events.ts
│   └── db/
│       ├── schema.ts
│       └── queries.ts
└── server/
    └── socket-server.ts
```

#### Socket Events
```typescript
// lib/socket/events.ts

export const SOCKET_EVENTS = {
  // Room management
  JOIN_ROOM: 'join_room',
  LEAVE_ROOM: 'leave_room',
  ROOM_UPDATE: 'room_update',
  
  // Game actions
  GAME_START: 'game_start',
  DRAW_CARD: 'draw_card',
  DISCARD_CARD: 'discard_card',
  PLAY_SPREAD: 'play_spread',
  HIT_SPREAD: 'hit_spread',
  KNOCK: 'knock',
  
  // State sync
  GAME_STATE: 'game_state',
  TURN_CHANGE: 'turn_change',
  ROUND_END: 'round_end',
  
  // Chat
  CHAT_MESSAGE: 'chat_message',
  EMOJI_REACTION: 'emoji_reaction'
} as const;
```

### Phase 3: Monetization (Week 5+)

- [ ] Google AdSense integration (interstitial between games)
- [ ] Remove ads with one-time $4.99 purchase or subscription
- [ ] Virtual currency + cosmetics (card backs, table themes, avatars)
- [ ] Daily tournaments with prizes

---

## 2. Dominoes — High Volume Opportunity

### Why Dominoes?
- Global appeal — played worldwide (Latin America, Caribbean, Europe, Africa)
- Higher search volume than Tonk, but competition still relatively low
- Top sites only get 50-60K monthly visits — room for a quality competitor
- Multiple game variants = more content pages = more SEO surface area

### Game Rules Reference (Draw Dominoes)
```
Players: 2-4
Tiles: Standard double-six set (28 tiles)
Deal: 7 tiles each (2 players) or 5 tiles (3-4 players)

Objective: Be first to empty your hand or have lowest pip count

Gameplay:
1. Highest double starts (or random if no doubles)
2. Match a tile to either open end of the layout
3. If you can't play, draw from boneyard until you can (or it's empty)
4. First to play all tiles wins the round
5. Winner scores total pips remaining in opponents' hands
6. First to 100/150/200 points wins the game

Variants:
- Block: No drawing, just pass if you can't play
- All Fives (Muggins): Score points during play when ends sum to multiple of 5
```

### Phase 1: Core Game MVP (Week 1-2)

#### Features
- [ ] Draw Dominoes variant (most popular)
- [ ] Standard 28-tile double-six set logic
- [ ] Drag-and-drop tile placement with snap-to-grid
- [ ] AI opponent with adjustable difficulty
- [ ] Score tracking to configurable target

#### Core Type Definitions
```typescript
// types/domino.ts

export interface Tile {
  id: string;
  left: number;  // 0-6 pips
  right: number; // 0-6 pips
  isDouble: boolean;
}

export interface LayoutNode {
  tile: Tile;
  orientation: 'horizontal' | 'vertical';
  position: { x: number; y: number };
  connections: {
    left?: string;
    right?: string;
    top?: string;
    bottom?: string;
  };
}

export interface DominoGameState {
  boneyard: Tile[];
  layout: LayoutNode[];
  openEnds: number[]; // Available numbers to match
  players: DominoPlayer[];
  currentPlayerIndex: number;
  scores: Record<string, number>;
  targetScore: number;
  variant: 'draw' | 'block' | 'allFives';
}

export interface DominoPlayer {
  id: string;
  name: string;
  hand: Tile[];
  isAI: boolean;
}
```

#### File Structure
```
/dominoes-game
├── app/
│   ├── page.tsx
│   ├── how-to-play/page.tsx
│   ├── variants/
│   │   ├── draw/page.tsx
│   │   ├── block/page.tsx
│   │   └── all-fives/page.tsx
│   └── layout.tsx
├── components/
│   ├── game/
│   │   ├── Tile.tsx
│   │   ├── Hand.tsx
│   │   ├── Boneyard.tsx
│   │   ├── Layout.tsx
│   │   └── GameBoard.tsx
│   └── ui/
├── lib/
│   ├── game-logic/
│   │   ├── tiles.ts
│   │   ├── layout.ts
│   │   ├── scoring.ts
│   │   ├── ai.ts
│   │   └── variants/
│   │       ├── draw.ts
│   │       ├── block.ts
│   │       └── allFives.ts
│   └── utils/
└── types/
    └── domino.ts
```

### Phase 2: Variants & Multiplayer (Week 3-4)

- [ ] Add Block Dominoes variant
- [ ] Add All Fives (Muggins) — scoring on multiples of 5
- [ ] 2-4 player multiplayer support
- [ ] Partner play mode (2v2)
- [ ] Real-time game rooms with invite links

### Phase 3: Regional & Monetization (Week 5+)

- [ ] Regional variants: Mexican Train, Cuban Dominoes
- [ ] Language localization (Spanish, Portuguese priority)
- [ ] Premium tile sets and table designs
- [ ] Tournament system

---

## 3. Pitty Pat — Untapped Blue Ocean

### Why Pitty Pat?
- Virtually NO online competition — first mover advantage
- Popular in Southern United States, especially among older demographics
- Simple rules = easy to build, easy to learn, broad appeal
- Could dominate this keyword within months
- Natural cross-promotion with Tonk (same demographic)

### Game Rules Reference
```
Players: 2-4
Cards: Standard 52-card deck
Deal: 5 cards each

Objective: Be first to discard all cards by matching ranks

Gameplay:
1. Flip top card of stock to start discard pile
2. On your turn:
   - If you have a card matching the rank of the top discard, 
     play it (discard your matching card)
   - If not, draw from stock
   - If drawn card matches, play it immediately
   - If not, it goes to discard pile (now the new top card)
3. First player to empty their hand wins

That's it! Super simple.
```

### Phase 1: Single Player MVP (Week 1)

**This is the simplest of the three games — can be built in days**

#### Features
- [ ] 5 cards dealt to each player
- [ ] Match by rank mechanic
- [ ] Draw from stock or match discard
- [ ] First player to empty hand wins
- [ ] Basic AI opponent

#### Core Type Definitions
```typescript
// types/pittyPat.ts

// Can reuse Card types from Tonk
import { Card, Suit, Rank } from './game';

export interface PittyPatGameState {
  deck: Card[];
  discardPile: Card[];
  players: PittyPatPlayer[];
  currentPlayerIndex: number;
  phase: 'playing' | 'roundEnd' | 'gameEnd';
  winner: string | null;
}

export interface PittyPatPlayer {
  id: string;
  name: string;
  hand: Card[];
  isAI: boolean;
  wins: number;
}
```

#### Core Game Logic
```typescript
// lib/pitty-pat/game-logic.ts

import { Card, PittyPatGameState } from '@/types/pittyPat';

export function canPlayCard(card: Card, topDiscard: Card): boolean {
  return card.rank === topDiscard.rank;
}

export function findPlayableCards(hand: Card[], topDiscard: Card): Card[] {
  return hand.filter(card => canPlayCard(card, topDiscard));
}

export function playTurn(
  state: PittyPatGameState, 
  action: 'play' | 'draw', 
  cardId?: string
): PittyPatGameState {
  const currentPlayer = state.players[state.currentPlayerIndex];
  const topDiscard = state.discardPile[state.discardPile.length - 1];
  
  if (action === 'play' && cardId) {
    // Play matching card
    const cardIndex = currentPlayer.hand.findIndex(c => c.id === cardId);
    if (cardIndex === -1) return state;
    
    const card = currentPlayer.hand[cardIndex];
    if (!canPlayCard(card, topDiscard)) return state;
    
    const newHand = [...currentPlayer.hand];
    newHand.splice(cardIndex, 1);
    
    // Check for win
    if (newHand.length === 0) {
      return {
        ...state,
        players: state.players.map((p, i) => 
          i === state.currentPlayerIndex ? { ...p, hand: newHand } : p
        ),
        discardPile: [...state.discardPile, card],
        phase: 'roundEnd',
        winner: currentPlayer.id
      };
    }
    
    // Continue game
    return {
      ...state,
      players: state.players.map((p, i) => 
        i === state.currentPlayerIndex ? { ...p, hand: newHand } : p
      ),
      discardPile: [...state.discardPile, card],
      currentPlayerIndex: (state.currentPlayerIndex + 1) % state.players.length
    };
  }
  
  if (action === 'draw') {
    // Draw from deck
    if (state.deck.length === 0) {
      // Reshuffle discard pile (keep top card)
      const topCard = state.discardPile[state.discardPile.length - 1];
      const reshuffled = shuffle(state.discardPile.slice(0, -1));
      state = { ...state, deck: reshuffled, discardPile: [topCard] };
    }
    
    const drawnCard = state.deck[0];
    const newDeck = state.deck.slice(1);
    
    // If drawn card matches, play it immediately
    if (canPlayCard(drawnCard, topDiscard)) {
      return {
        ...state,
        deck: newDeck,
        discardPile: [...state.discardPile, drawnCard],
        currentPlayerIndex: (state.currentPlayerIndex + 1) % state.players.length
      };
    }
    
    // Otherwise, discard it and it becomes the new top
    return {
      ...state,
      deck: newDeck,
      discardPile: [...state.discardPile, drawnCard],
      currentPlayerIndex: (state.currentPlayerIndex + 1) % state.players.length
    };
  }
  
  return state;
}
```

### Phase 2: Polish & Multiplayer (Week 2-3)

- [ ] 2-4 player multiplayer
- [ ] Quick match system (instant pairing)
- [ ] Private game rooms for friends/family
- [ ] Sound effects and satisfying animations
- [ ] Win streaks and achievements

---

## 4. Recommended Tech Stack

| Layer | Technology | Why |
|-------|------------|-----|
| Frontend | Next.js 14 + React | SEO-friendly, fast, great DX |
| Styling | Tailwind CSS | Rapid UI development |
| Game Rendering | Canvas API or Phaser.js | Smooth card animations |
| Real-time | Socket.io / Liveblocks | Multiplayer game state sync |
| Backend | Node.js + Express (or Next API routes) | JavaScript everywhere |
| Database | PostgreSQL (Supabase) or MongoDB | User data, stats, leaderboards |
| Auth | Clerk / NextAuth / Supabase Auth | Quick setup, social login |
| Hosting | Vercel (frontend) + Railway (backend) | Free tier friendly, scales |
| Payments | Stripe | Industry standard |

### Package.json Template
```json
{
  "name": "card-games",
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "socket": "ts-node server/socket-server.ts"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "socket.io": "^4.7.0",
    "socket.io-client": "^4.7.0",
    "@clerk/nextjs": "^4.0.0",
    "zustand": "^4.4.0",
    "framer-motion": "^10.16.0"
  },
  "devDependencies": {
    "typescript": "^5.2.0",
    "@types/react": "^18.2.0",
    "@types/node": "^20.0.0",
    "tailwindcss": "^3.3.0",
    "autoprefixer": "^10.4.0",
    "postcss": "^8.4.0"
  }
}
```

---

## 5. SEO Strategy

### Target Keywords

#### Tonk
- `play tonk online` / `tonk card game` / `tonk game free`
- `how to play tonk` / `tonk rules` / `tonk vs rummy`
- `tunk card game` / `knock rummy online`

#### Dominoes
- `play dominoes online free` / `dominoes game`
- `all fives dominoes` / `muggins dominoes`
- `mexican train online` / `block dominoes`

#### Pitty Pat
- `play pitty pat online` / `pitty pat card game`
- `pitty pat rules` / `how to play pitty pat`
- `pitty pat game free` — **you could rank #1 for all of these**

### Content Pages to Create

Each game should have:
1. **Rules page** (2000+ words, comprehensive)
2. **Quick start guide** (500 words, scannable)
3. **Strategy guide** (1500+ words)
4. **History/origin article** (1000 words)
5. **Comparison articles** (e.g., "Tonk vs Gin Rummy")
6. **FAQ page** (structured data for rich snippets)

### Technical SEO Checklist
- [ ] Semantic HTML5 structure
- [ ] Schema.org GamePlay markup
- [ ] Open Graph tags for social sharing
- [ ] Sitemap.xml with all game/content pages
- [ ] Core Web Vitals optimization (LCP < 2.5s)
- [ ] Mobile-first responsive design

---

## 6. Monetization Breakdown

| Revenue Stream | Difficulty | Timeline | Potential |
|----------------|------------|----------|-----------|
| Display Ads (AdSense) | Easy | Day 1 | $2-5 RPM |
| Premium Ad Networks (Mediavine) | Medium | 50K+ visits/mo | $10-20 RPM |
| Remove Ads Purchase | Easy | Week 2 | $3-5 one-time |
| Cosmetics/Themes | Medium | Month 2 | $1-3 each |
| Tournament Entry | Hard (legal) | Month 3+ | 10-20% rake |
| VIP Subscription | Medium | Month 2 | $5-10/month |

---

## 7. Realistic Revenue Projections

### Month 1-3 (Building & Indexing)
- Traffic: 500-2,000 visits/month
- Revenue: $10-50/month (mostly ads)
- Focus: SEO content, bug fixes, user feedback

### Month 4-6 (Growth Phase)
- Traffic: 5,000-15,000 visits/month
- Revenue: $100-500/month
- Focus: Multiplayer features, community building

### Month 7-12 (Scaling)
- Traffic: 25,000-100,000 visits/month
- Revenue: $500-3,000/month
- Focus: Premium networks, mobile app, multiple games

### Year 2+ (Mature)
- Traffic: 100,000+ visits/month
- Revenue: $3,000-10,000+/month
- Note: The $20K/month sites have been doing this 5+ years with multiple properties

---

## 8. Recommended Launch Order

### Option A: Maximum Speed
1. **Week 1-2:** Pitty Pat MVP (simplest game)
2. **Week 3-4:** Add Tonk (same infrastructure)
3. **Month 2:** Add Dominoes
4. **Month 3:** Multiplayer for all three

### Option B: Quality Focus
1. **Month 1:** Tonk MVP with multiplayer
2. **Month 2:** Polish + monetization
3. **Month 3:** Add second game

---

## 9. Key Success Factors

- **Mobile-first design** — 70%+ of game traffic is mobile
- **Fast load times** — under 3 seconds or users bounce
- **No forced signup** — let people play immediately
- **Ad placement balance** — don't be like competitors with 10 popups
- **Community building** — Discord server, social features
- **Patience with SEO** — organic traffic takes 3-6 months

---

## 10. Quick Commands Reference

```bash
# Create new Next.js project
npx create-next-app@latest tonk-game --typescript --tailwind --app

# Install dependencies
npm install socket.io socket.io-client zustand framer-motion

# Run development server
npm run dev

# Build for production
npm run build
```

---

## Notes for Claude Code

When implementing these games, prioritize:

1. **Game logic first** — Make sure the rules are rock solid before UI
2. **State management** — Use Zustand for clean game state
3. **Animation** — Framer Motion for card movements
4. **Mobile responsiveness** — Test on phone viewport constantly
5. **SEO pages** — Create content pages early for indexing

The games share a lot of infrastructure (card rendering, multiplayer, auth), so build Tonk or Pitty Pat first and reuse components.

---

*Last updated: December 2025*
