import type { Metadata } from 'next';
import Link from 'next/link';

export const metadata: Metadata = {
  title: 'How to Play Pitty Pat - Complete Guide & Rules | Learn in 2 Minutes',
  description: 'Learn how to play Pitty Pat card game with our comprehensive guide. Simple rules, strategies, and tips to master this classic matching game. Start playing in minutes!',
  keywords: 'how to play pitty pat, pitty pat rules, pitty pat tutorial, pitty pat strategy, learn pitty pat',
};

export default function HowToPlay() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-green-800 to-green-600 text-white">
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        <Link href="/" className="inline-block mb-4 text-yellow-300 hover:text-yellow-200 transition-colors">
          ← Back to Game
        </Link>

        <h1 className="text-4xl font-bold mb-6">How to Play Pitty Pat</h1>

        <div className="bg-green-700 rounded-lg p-6 mb-6 shadow-xl">
          <h2 className="text-2xl font-semibold mb-4">Quick Overview</h2>
          <p className="text-lg mb-4">
            Pitty Pat is a simple, fast-paced card matching game where players race to be the first to get rid of all their cards.
            It's perfect for all ages and can be learned in just 2 minutes!
          </p>
          <ul className="list-disc list-inside space-y-2">
            <li>Players: 2-4 (currently playing against computer)</li>
            <li>Cards: Standard 52-card deck</li>
            <li>Deal: 5 cards each</li>
            <li>Goal: Be first to play all your cards</li>
          </ul>
        </div>

        <div className="bg-green-700 rounded-lg p-6 mb-6 shadow-xl">
          <h2 className="text-2xl font-semibold mb-4">Setup</h2>
          <ol className="list-decimal list-inside space-y-3">
            <li>Shuffle a standard deck of 52 cards</li>
            <li>Deal 5 cards to each player</li>
            <li>Place remaining cards face down as the draw pile</li>
            <li>Flip the top card of the draw pile to start the discard pile</li>
            <li>The player to the dealer's left goes first</li>
          </ol>
        </div>

        <div className="bg-green-700 rounded-lg p-6 mb-6 shadow-xl">
          <h2 className="text-2xl font-semibold mb-4">How to Play</h2>
          <h3 className="text-xl font-semibold mb-2 text-yellow-300">On Your Turn:</h3>
          <ol className="list-decimal list-inside space-y-3 mb-4">
            <li>
              <strong>Check for a match:</strong> Look at the top card of the discard pile.
              Do you have a card with the same rank (number or face)?
            </li>
            <li>
              <strong>If you have a match:</strong> Play your matching card on top of the discard pile.
              Your turn ends immediately.
            </li>
            <li>
              <strong>If you don't have a match:</strong> Draw one card from the draw pile.
              <ul className="list-disc list-inside ml-6 mt-2">
                <li>If the drawn card matches, play it immediately</li>
                <li>If it doesn't match, it goes on top of the discard pile</li>
              </ul>
            </li>
            <li>
              <strong>End of turn:</strong> Play passes to the next player clockwise
            </li>
          </ol>
        </div>

        <div className="bg-green-700 rounded-lg p-6 mb-6 shadow-xl">
          <h2 className="text-2xl font-semibold mb-4">Winning the Game</h2>
          <p className="mb-4">
            The first player to get rid of all their cards wins the round! It's that simple.
          </p>
          <p className="mb-4">
            You can play multiple rounds and keep score. First to win 5 rounds wins the match.
          </p>
        </div>

        <div className="bg-green-700 rounded-lg p-6 mb-6 shadow-xl">
          <h2 className="text-2xl font-semibold mb-4">Special Rules</h2>
          <ul className="list-disc list-inside space-y-3">
            <li>
              <strong>Matching by rank only:</strong> Suits don't matter. A 7 of hearts matches any other 7.
            </li>
            <li>
              <strong>Automatic play:</strong> If you draw a matching card, you must play it immediately.
            </li>
            <li>
              <strong>Deck runs out:</strong> If the draw pile is empty, shuffle the discard pile (except the top card) to make a new draw pile.
            </li>
          </ul>
        </div>

        <div className="bg-green-700 rounded-lg p-6 mb-6 shadow-xl">
          <h2 className="text-2xl font-semibold mb-4">Strategy Tips</h2>
          <ul className="list-disc list-inside space-y-3">
            <li>
              <strong>Remember what's been played:</strong> Keep track of which ranks have appeared recently.
            </li>
            <li>
              <strong>Watch your opponent:</strong> Notice what they're drawing - it might tell you what they need.
            </li>
            <li>
              <strong>Play duplicates first:</strong> If you have two 5s, play one to keep flexibility.
            </li>
            <li>
              <strong>Speed matters:</strong> In friendly games, quick decisions keep the game exciting!
            </li>
          </ul>
        </div>

        <div className="bg-green-700 rounded-lg p-6 mb-6 shadow-xl">
          <h2 className="text-2xl font-semibold mb-4">Variations</h2>
          <ul className="list-disc list-inside space-y-3">
            <li>
              <strong>Seven-card Pitty Pat:</strong> Deal 7 cards instead of 5 for longer games.
            </li>
            <li>
              <strong>Double deck:</strong> For 5+ players, use two decks shuffled together.
            </li>
            <li>
              <strong>Speed Pitty Pat:</strong> Set a timer for each turn to add pressure!
            </li>
          </ul>
        </div>

        <div className="bg-yellow-600 rounded-lg p-6 mb-6 shadow-xl">
          <h2 className="text-2xl font-semibold mb-4">Ready to Play?</h2>
          <p className="mb-4">
            Now that you know the rules, jump into a game! Our online version handles all the dealing and rules automatically,
            so you can focus on the fun.
          </p>
          <Link href="/" className="inline-block bg-green-700 hover:bg-green-600 px-6 py-3 rounded-lg font-bold transition-colors">
            Play Pitty Pat Now →
          </Link>
        </div>

        <div className="text-center text-sm opacity-75 mt-8">
          <p>© 2025 Pitty Pat Online - The #1 Place to Play Pitty Pat on the Web</p>
        </div>
      </div>
    </div>
  );
}