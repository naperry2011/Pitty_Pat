import type { Metadata } from 'next';
import Link from 'next/link';

export const metadata: Metadata = {
  title: 'Pitty Pat Rules - Quick Reference Guide | Official Card Game Rules',
  description: 'Official Pitty Pat card game rules. Quick reference for setup, gameplay, and winning conditions. Perfect for beginners and experienced players.',
  keywords: 'pitty pat rules, pitty pat card game rules, pitty pat instructions, official pitty pat rules',
};

export default function Rules() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-green-800 to-green-600 text-white">
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        <Link href="/" className="inline-block mb-4 text-yellow-300 hover:text-yellow-200 transition-colors">
          ← Back to Game
        </Link>

        <h1 className="text-4xl font-bold mb-6">Pitty Pat Rules - Quick Reference</h1>

        <div className="grid md:grid-cols-2 gap-6">
          <div className="bg-green-700 rounded-lg p-6 shadow-xl">
            <h2 className="text-2xl font-semibold mb-4 text-yellow-300">Game Setup</h2>
            <table className="w-full">
              <tbody>
                <tr className="border-b border-green-600">
                  <td className="py-2 font-semibold">Players:</td>
                  <td className="py-2">2-4</td>
                </tr>
                <tr className="border-b border-green-600">
                  <td className="py-2 font-semibold">Deck:</td>
                  <td className="py-2">Standard 52 cards</td>
                </tr>
                <tr className="border-b border-green-600">
                  <td className="py-2 font-semibold">Deal:</td>
                  <td className="py-2">5 cards each</td>
                </tr>
                <tr className="border-b border-green-600">
                  <td className="py-2 font-semibold">Objective:</td>
                  <td className="py-2">First to empty hand</td>
                </tr>
                <tr>
                  <td className="py-2 font-semibold">Start:</td>
                  <td className="py-2">Flip one card to discard</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div className="bg-green-700 rounded-lg p-6 shadow-xl">
            <h2 className="text-2xl font-semibold mb-4 text-yellow-300">Turn Sequence</h2>
            <ol className="list-decimal list-inside space-y-2">
              <li>Look at top discard card</li>
              <li>Check hand for matching rank</li>
              <li className="ml-4">
                <strong>If match:</strong> Play it
              </li>
              <li className="ml-4">
                <strong>If no match:</strong> Draw card
              </li>
              <li>If drawn card matches, play it</li>
              <li>Otherwise, discard drawn card</li>
              <li>Next player's turn</li>
            </ol>
          </div>
        </div>

        <div className="bg-green-700 rounded-lg p-6 shadow-xl mt-6">
          <h2 className="text-2xl font-semibold mb-4 text-yellow-300">Key Rules</h2>
          <div className="grid md:grid-cols-2 gap-4">
            <div className="flex items-start">
              <span className="text-2xl mr-3">♠️</span>
              <div>
                <h3 className="font-semibold">Matching</h3>
                <p className="text-sm">Only rank matters (7♥ matches 7♠)</p>
              </div>
            </div>
            <div className="flex items-start">
              <span className="text-2xl mr-3">♥️</span>
              <div>
                <h3 className="font-semibold">Drawing</h3>
                <p className="text-sm">Draw only if you can't match</p>
              </div>
            </div>
            <div className="flex items-start">
              <span className="text-2xl mr-3">♣️</span>
              <div>
                <h3 className="font-semibold">Auto-play</h3>
                <p className="text-sm">Must play if drawn card matches</p>
              </div>
            </div>
            <div className="flex items-start">
              <span className="text-2xl mr-3">♦️</span>
              <div>
                <h3 className="font-semibold">Winning</h3>
                <p className="text-sm">First to play all cards wins</p>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-green-700 rounded-lg p-6 shadow-xl mt-6">
          <h2 className="text-2xl font-semibold mb-4 text-yellow-300">Example Turn</h2>
          <div className="bg-green-800 rounded p-4 font-mono text-sm">
            <p className="mb-2">Discard pile shows: 7♥</p>
            <p className="mb-2">Your hand: [3♠] [7♣] [K♦] [A♥] [9♠]</p>
            <p className="mb-2 text-yellow-300">→ You have 7♣ which matches!</p>
            <p className="mb-2">Action: Play 7♣ on discard pile</p>
            <p>Result: Hand now has 4 cards, turn ends</p>
          </div>
        </div>

        <div className="bg-green-700 rounded-lg p-6 shadow-xl mt-6">
          <h2 className="text-2xl font-semibold mb-4 text-yellow-300">Special Situations</h2>
          <dl className="space-y-3">
            <div>
              <dt className="font-semibold">Draw pile empty?</dt>
              <dd className="ml-4 text-sm">Shuffle discard pile (except top card) to make new draw pile</dd>
            </div>
            <div>
              <dt className="font-semibold">Multiple matches in hand?</dt>
              <dd className="ml-4 text-sm">Can only play one card per turn</dd>
            </div>
            <div>
              <dt className="font-semibold">Forgot to play a match?</dt>
              <dd className="ml-4 text-sm">Too bad! Must wait for next turn</dd>
            </div>
          </dl>
        </div>

        <div className="bg-yellow-600 rounded-lg p-6 shadow-xl mt-6">
          <h2 className="text-2xl font-semibold mb-4">Quick Tips</h2>
          <ul className="list-disc list-inside space-y-2">
            <li>Always check for matches before drawing</li>
            <li>Remember what ranks have been played</li>
            <li>Play duplicates to keep flexibility</li>
            <li>Watch what opponents are drawing</li>
          </ul>
        </div>

        <div className="flex gap-4 mt-8">
          <Link href="/" className="flex-1 bg-green-700 hover:bg-green-600 px-6 py-3 rounded-lg font-bold text-center transition-colors">
            Play Now →
          </Link>
          <Link href="/how-to-play" className="flex-1 bg-blue-700 hover:bg-blue-600 px-6 py-3 rounded-lg font-bold text-center transition-colors">
            Full Guide →
          </Link>
        </div>

        <div className="text-center text-sm opacity-75 mt-8">
          <p>© 2025 Pitty Pat Online - Play Free Card Games Online</p>
        </div>
      </div>
    </div>
  );
}