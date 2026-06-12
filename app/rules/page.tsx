import type { Metadata } from 'next';
import Link from 'next/link';
import CardFace from '@/components/game/CardFace';

export const metadata: Metadata = {
  title: 'Pitty Pat Rules - Quick Reference Guide | Official Card Game Rules',
  description: 'Official Pitty Pat card game rules. Quick reference for setup, gameplay, and winning conditions. Perfect for beginners and experienced players.',
  keywords: 'pitty pat rules, pitty pat card game rules, pitty pat instructions, official pitty pat rules',
};

export default function Rules() {
  return (
    <div className="min-h-screen bg-cream text-ink">
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        <Link href="/" className="inline-block mb-4 text-coral-deep hover:text-coral transition-colors font-medium">
          ← Back to Game
        </Link>

        <h1 className="font-display text-4xl font-bold mb-6">Pitty Pat Rules - Quick Reference</h1>

        <div className="grid md:grid-cols-2 gap-6">
          <section className="bg-white rounded-2xl p-6 shadow-card">
            <h2 className="font-display text-2xl font-semibold mb-4 text-coral-deep">Game Setup</h2>
            <table className="w-full">
              <tbody>
                <tr className="border-b border-ink/10">
                  <td className="py-2 font-semibold">Players:</td>
                  <td className="py-2 text-ink/80">2-4</td>
                </tr>
                <tr className="border-b border-ink/10">
                  <td className="py-2 font-semibold">Deck:</td>
                  <td className="py-2 text-ink/80">Standard 52 cards</td>
                </tr>
                <tr className="border-b border-ink/10">
                  <td className="py-2 font-semibold">Deal:</td>
                  <td className="py-2 text-ink/80">5 cards each</td>
                </tr>
                <tr className="border-b border-ink/10">
                  <td className="py-2 font-semibold">Objective:</td>
                  <td className="py-2 text-ink/80">First to empty hand</td>
                </tr>
                <tr>
                  <td className="py-2 font-semibold">Start:</td>
                  <td className="py-2 text-ink/80">Flip one card to discard</td>
                </tr>
              </tbody>
            </table>
          </section>

          <section className="bg-white rounded-2xl p-6 shadow-card">
            <h2 className="font-display text-2xl font-semibold mb-4 text-coral-deep">Turn Sequence</h2>
            <ol className="list-decimal list-inside space-y-2 text-ink/80">
              <li>Look at top discard card</li>
              <li>Check hand for matching rank</li>
              <li className="ml-4">
                <strong className="text-ink">If match:</strong> Play it
              </li>
              <li className="ml-4">
                <strong className="text-ink">If no match:</strong> Draw card
              </li>
              <li>If drawn card matches, play it</li>
              <li>Otherwise, discard drawn card</li>
              <li>Next player&apos;s turn</li>
            </ol>
          </section>
        </div>

        <section className="bg-white rounded-2xl p-6 shadow-card mt-6">
          <h2 className="font-display text-2xl font-semibold mb-4 text-coral-deep">Key Rules</h2>
          <div className="grid md:grid-cols-2 gap-4">
            <div className="flex items-start">
              <span className="text-2xl mr-3 text-ink" aria-hidden="true">♠</span>
              <div>
                <h3 className="font-semibold">Matching</h3>
                <p className="text-sm text-ink/70">Only rank matters (7♥ matches 7♠)</p>
              </div>
            </div>
            <div className="flex items-start">
              <span className="text-2xl mr-3 text-coral-deep" aria-hidden="true">♥</span>
              <div>
                <h3 className="font-semibold">Drawing</h3>
                <p className="text-sm text-ink/70">Draw only if you can&apos;t match</p>
              </div>
            </div>
            <div className="flex items-start">
              <span className="text-2xl mr-3 text-ink" aria-hidden="true">♣</span>
              <div>
                <h3 className="font-semibold">Auto-play</h3>
                <p className="text-sm text-ink/70">Must play if drawn card matches</p>
              </div>
            </div>
            <div className="flex items-start">
              <span className="text-2xl mr-3 text-coral-deep" aria-hidden="true">♦</span>
              <div>
                <h3 className="font-semibold">Winning</h3>
                <p className="text-sm text-ink/70">First to play all cards wins</p>
              </div>
            </div>
          </div>
        </section>

        <section className="bg-white rounded-2xl p-6 shadow-card mt-6">
          <h2 className="font-display text-2xl font-semibold mb-4 text-coral-deep">Example Turn</h2>

          {/* Hand illustration: the discard shows 7 of hearts, your hand holds the 7 of clubs */}
          <figure className="bg-cream rounded-2xl p-5 mb-4">
            <div className="flex items-end justify-center gap-6 flex-wrap" aria-hidden="true">
              <div className="flex flex-col items-center gap-2">
                <span className="text-xs font-semibold text-ink/60 uppercase tracking-wide">Discard pile</span>
                <div className="w-16 h-24 shadow-card rounded-md">
                  <CardFace rank="7" suit="hearts" className="rounded-md" />
                </div>
              </div>
              <div className="flex flex-col items-center gap-2">
                <span className="text-xs font-semibold text-ink/60 uppercase tracking-wide">Your hand</span>
                <div className="flex">
                  <div className="w-16 h-24 shadow-card rounded-md -rotate-3"><CardFace rank="3" suit="spades" className="rounded-md" /></div>
                  <div className="w-16 h-24 shadow-raised rounded-md -ml-6 -translate-y-2 ring-2 ring-gold"><CardFace rank="7" suit="clubs" className="rounded-md" /></div>
                  <div className="w-16 h-24 shadow-card rounded-md -ml-6"><CardFace rank="K" suit="diamonds" className="rounded-md" /></div>
                  <div className="w-16 h-24 shadow-card rounded-md -ml-6 rotate-2"><CardFace rank="A" suit="hearts" className="rounded-md" /></div>
                  <div className="w-16 h-24 shadow-card rounded-md -ml-6 rotate-3"><CardFace rank="9" suit="spades" className="rounded-md" /></div>
                </div>
              </div>
            </div>
            <figcaption className="text-sm text-ink/70 text-center mt-3">
              The 7♣ in your hand matches the 7♥ on the discard pile — play it!
            </figcaption>
          </figure>

          <div className="bg-ink text-cream rounded-xl p-4 font-mono text-sm">
            <p className="mb-2">Discard pile shows: 7♥</p>
            <p className="mb-2">Your hand: [3♠] [7♣] [K♦] [A♥] [9♠]</p>
            <p className="mb-2 text-gold">→ You have 7♣ which matches!</p>
            <p className="mb-2">Action: Play 7♣ on discard pile</p>
            <p>Result: Hand now has 4 cards, turn ends</p>
          </div>
        </section>

        <section className="bg-white rounded-2xl p-6 shadow-card mt-6">
          <h2 className="font-display text-2xl font-semibold mb-4 text-coral-deep">Special Situations</h2>
          <dl className="space-y-3">
            <div>
              <dt className="font-semibold">Draw pile empty?</dt>
              <dd className="ml-4 text-sm text-ink/70">Shuffle discard pile (except top card) to make new draw pile</dd>
            </div>
            <div>
              <dt className="font-semibold">Multiple matches in hand?</dt>
              <dd className="ml-4 text-sm text-ink/70">Can only play one card per turn</dd>
            </div>
            <div>
              <dt className="font-semibold">Forgot to play a match?</dt>
              <dd className="ml-4 text-sm text-ink/70">Too bad! Must wait for next turn</dd>
            </div>
          </dl>
        </section>

        <section className="bg-gold/15 border border-gold/40 rounded-2xl p-6 mt-6">
          <h2 className="font-display text-2xl font-semibold mb-4">Quick Tips</h2>
          <ul className="list-disc list-inside space-y-2 text-ink/80">
            <li>Always check for matches before drawing</li>
            <li>Remember what ranks have been played</li>
            <li>Play duplicates to keep flexibility</li>
            <li>Watch what opponents are drawing</li>
          </ul>
        </section>

        <div className="flex gap-4 mt-8">
          <Link href="/play" className="flex-1 bg-gradient-to-br from-coral to-coral-deep hover:shadow-floating text-white px-6 py-3 rounded-xl font-display font-semibold text-center shadow-raised transition-all">
            Play Now →
          </Link>
          <Link href="/how-to-play" className="flex-1 bg-white hover:bg-cream text-ink px-6 py-3 rounded-xl font-display font-semibold text-center shadow-card transition-colors">
            Full Guide →
          </Link>
        </div>

        <div className="text-center text-sm text-ink/50 mt-8">
          <p>© 2025 Pitty Pat Online - Play Free Card Games Online</p>
        </div>
      </div>
    </div>
  );
}
