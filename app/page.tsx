'use client';

import Link from 'next/link';
import { useState, useEffect } from 'react';

// Floating card animation component
// Position and duration derive deterministically from the index so render stays pure.
function FloatingCard({ suit, delay, left, seed }: { suit: string; delay: number; left: number; seed: number }) {
  const suitColors: Record<string, string> = {
    '♥': 'text-red-500',
    '♦': 'text-orange-500',
    '♣': 'text-emerald-600',
    '♠': 'text-indigo-600'
  };

  return (
    <div
      className={`absolute text-4xl sm:text-5xl opacity-20 animate-float ${suitColors[suit]}`}
      style={{
        left: `${left}%`,
        top: `${10 + ((seed * 137) % 61)}%`,
        animationDelay: `${delay}s`,
        animationDuration: `${3 + ((seed * 53) % 21) / 10}s`
      }}
    >
      {suit}
    </div>
  );
}

export default function Home() {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    // Hydration gate: the floating cards render only on the client.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMounted(true);
  }, []);

  const suits = ['♥', '♦', '♣', '♠'];
  const floatingCards = mounted
    ? Array.from({ length: 12 }, (_, i) => ({
        suit: suits[i % 4],
        delay: i * 0.5,
        left: (i * 8) + 2,
        seed: i + 1
      }))
    : [];

  return (
    <main className="min-h-screen playful-bg relative overflow-hidden">
      {/* Floating background cards */}
      {floatingCards.map((card, i) => (
        <FloatingCard key={i} {...card} />
      ))}

      {/* Main content */}
      <div className="relative z-10 min-h-screen flex flex-col items-center justify-center px-4 py-8 safe-area-top safe-area-bottom">
        {/* Hero Section */}
        <div className="text-center mb-8">
          {/* Animated cards icon */}
          <div className="flex justify-center gap-2 mb-4">
            <div className="w-12 h-16 sm:w-16 sm:h-20 bg-gradient-to-br from-red-500 to-red-600 rounded-xl shadow-lg transform -rotate-12 border-2 border-white flex items-center justify-center">
              <span className="text-white text-2xl sm:text-3xl">♥</span>
            </div>
            <div className="w-12 h-16 sm:w-16 sm:h-20 bg-gradient-to-br from-white to-gray-100 rounded-xl shadow-lg transform rotate-6 border-2 border-gray-200 flex items-center justify-center -ml-4">
              <span className="text-indigo-600 text-2xl sm:text-3xl">♠</span>
            </div>
            <div className="w-12 h-16 sm:w-16 sm:h-20 bg-gradient-to-br from-orange-400 to-orange-500 rounded-xl shadow-lg transform -rotate-6 border-2 border-white flex items-center justify-center -ml-4">
              <span className="text-white text-2xl sm:text-3xl">♦</span>
            </div>
          </div>

          {/* Title */}
          <h1 className="text-5xl sm:text-7xl font-black text-transparent bg-clip-text bg-gradient-to-r from-coral via-purple-500 to-indigo-600 mb-3">
            Pitty Pat!
          </h1>
          <p className="text-xl sm:text-2xl text-gray-600 font-medium">
            The Super Fun Card Game! 🎉
          </p>
        </div>

        {/* Play Button */}
        <Link
          href="/play"
          className="group mb-10 px-10 py-5 bg-gradient-to-r from-coral to-pink-500 text-white text-2xl sm:text-3xl font-bold rounded-3xl shadow-xl hover:shadow-2xl transform hover:scale-105 active:scale-95 transition-all duration-200 flex items-center gap-3"
        >
          <span>Play Now!</span>
          <span className="text-3xl sm:text-4xl group-hover:animate-bounce">🎮</span>
        </Link>

        {/* How to Play Section */}
        <div className="w-full max-w-md bg-white/90 backdrop-blur-sm rounded-3xl shadow-xl p-6 sm:p-8 mb-8">
          <h2 className="text-2xl sm:text-3xl font-bold text-gray-800 text-center mb-6 flex items-center justify-center gap-2">
            <span>📖</span>
            <span>How to Play</span>
          </h2>

          <div className="space-y-4">
            {/* Rule 1 */}
            <div className="flex items-start gap-4">
              <div className="w-10 h-10 sm:w-12 sm:h-12 bg-gradient-to-br from-coral to-pink-500 rounded-full flex items-center justify-center flex-shrink-0 shadow-md">
                <span className="text-white text-lg sm:text-xl font-bold">1</span>
              </div>
              <div>
                <h3 className="font-bold text-gray-800 text-lg">Match the Card!</h3>
                <p className="text-gray-600">Look at the card on top. If you have a card with the same number, tap it to play!</p>
              </div>
            </div>

            {/* Rule 2 */}
            <div className="flex items-start gap-4">
              <div className="w-10 h-10 sm:w-12 sm:h-12 bg-gradient-to-br from-amber-400 to-orange-500 rounded-full flex items-center justify-center flex-shrink-0 shadow-md">
                <span className="text-white text-lg sm:text-xl font-bold">2</span>
              </div>
              <div>
                <h3 className="font-bold text-gray-800 text-lg">No Match? Draw!</h3>
                <p className="text-gray-600">Can't match? No worries! Just tap the deck to draw a new card.</p>
              </div>
            </div>

            {/* Rule 3 */}
            <div className="flex items-start gap-4">
              <div className="w-10 h-10 sm:w-12 sm:h-12 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full flex items-center justify-center flex-shrink-0 shadow-md">
                <span className="text-white text-lg sm:text-xl font-bold">3</span>
              </div>
              <div>
                <h3 className="font-bold text-gray-800 text-lg">Empty Hand = You Win! 🏆</h3>
                <p className="text-gray-600">Be the first to play all your cards and you're the winner!</p>
              </div>
            </div>
          </div>

          {/* Pro tip */}
          <div className="mt-6 bg-gradient-to-r from-purple-100 to-indigo-100 rounded-2xl p-4">
            <p className="text-center text-purple-700 font-medium">
              <span className="text-xl">💡</span> <strong>Pro Tip:</strong> Tap a card once to select it, tap again to play!
            </p>
          </div>
        </div>

        {/* Play with Friends Section */}
        <div className="w-full max-w-md bg-gradient-to-r from-indigo-500 to-purple-600 rounded-3xl shadow-xl p-6 sm:p-8 text-white text-center mb-8">
          <div className="text-4xl mb-3">👫👭👬</div>
          <h2 className="text-2xl font-bold mb-2">Play with Friends!</h2>
          <p className="text-white/90 mb-4">
            Pitty Pat is even more fun with friends! Show them how to play and take turns on the same device, or challenge them to beat your high score!
          </p>
          <div className="flex justify-center gap-2 flex-wrap">
            <span className="bg-white/20 px-3 py-1 rounded-full text-sm font-medium">Take Turns</span>
            <span className="bg-white/20 px-3 py-1 rounded-full text-sm font-medium">Beat High Scores</span>
            <span className="bg-white/20 px-3 py-1 rounded-full text-sm font-medium">Teach Friends</span>
          </div>
        </div>

        {/* Fun Facts */}
        <div className="w-full max-w-md grid grid-cols-3 gap-3 mb-8">
          <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-4 text-center shadow-md">
            <div className="text-3xl mb-1">🃏</div>
            <div className="text-2xl font-bold text-gray-800">52</div>
            <div className="text-xs text-gray-500">Cards</div>
          </div>
          <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-4 text-center shadow-md">
            <div className="text-3xl mb-1">✋</div>
            <div className="text-2xl font-bold text-gray-800">5</div>
            <div className="text-xs text-gray-500">Cards Each</div>
          </div>
          <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-4 text-center shadow-md">
            <div className="text-3xl mb-1">🎯</div>
            <div className="text-2xl font-bold text-gray-800">0</div>
            <div className="text-xs text-gray-500">Cards to Win</div>
          </div>
        </div>

        {/* Bottom Play Button */}
        <Link
          href="/play"
          className="px-8 py-4 bg-gradient-to-r from-emerald-500 to-teal-500 text-white text-xl font-bold rounded-2xl shadow-lg hover:shadow-xl transform hover:scale-105 active:scale-95 transition-all duration-200"
        >
          Let's Play! 🚀
        </Link>

        {/* Footer */}
        <p className="mt-8 text-gray-500 text-sm text-center">
          Made with ❤️ for kids who love card games
        </p>
      </div>
    </main>
  );
}
