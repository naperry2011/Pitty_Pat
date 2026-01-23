# 🎴 Pitty Pat!

**The Super Fun Card Matching Game**

A fast-paced, colorful card game built for players of all ages. Match cards, beat the computer, and empty your hand to win!

![Next.js](https://img.shields.io/badge/Next.js-16-black?style=flat-square&logo=next.js)
![React](https://img.shields.io/badge/React-19-61DAFB?style=flat-square&logo=react)
![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?style=flat-square&logo=typescript)
![Tailwind CSS](https://img.shields.io/badge/Tailwind-3-38B2AC?style=flat-square&logo=tailwind-css)

---

## 🎮 How to Play

| Step | Action |
|:----:|--------|
| 1️⃣ | Look at the **top card** on the discard pile |
| 2️⃣ | Got a matching rank? **Tap it twice** to play! |
| 3️⃣ | No match? **Tap the deck** to draw a card |
| 4️⃣ | First to **empty their hand** wins! 🏆 |

---

## ✨ Features

- 🃏 **Classic Pitty Pat rules** - Easy to learn, fun to master
- 🤖 **Play vs Computer** - AI opponent with smart card choices
- 📱 **Mobile-first design** - Touch-friendly with tap-to-play controls
- 🎨 **Customizable card backs** - Pick your favorite style
- 🎉 **Win celebrations** - Confetti when you win!
- ⚡ **No account needed** - Just open and play

---

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Start the game
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) and start playing!

---

## 🛠️ Tech Stack

- **Framework:** Next.js 16 with App Router
- **UI:** React 19 + Tailwind CSS
- **Language:** TypeScript
- **State:** useReducer + Context API

---

## 📁 Project Structure

```
├── app/                  # Next.js pages
│   ├── page.tsx          # Home screen
│   ├── play/             # Game screen
│   └── how-to-play/      # Instructions
├── components/game/      # Game UI components
│   ├── GameBoard.tsx     # Main game layout
│   ├── Card.tsx          # Card component
│   ├── Hand.tsx          # Player hand
│   └── Deck.tsx          # Draw pile
├── hooks/
│   └── useGameState.ts   # Game state management
├── lib/
│   ├── game-engine.ts    # Core game rules
│   └── ai-player.ts      # Computer opponent logic
└── types/
    └── index.ts          # TypeScript definitions
```

---

## 🎯 Game Rules

- Each player gets **5 cards**
- Match the **rank** (number) of the top discard card
- If you can't match, **draw from the deck**
- Drawn cards that match are played automatically
- **Empty your hand** before the computer to win!

---

## 📜 License

MIT

---

<p align="center">
  Made with ❤️ for card game lovers
</p>
