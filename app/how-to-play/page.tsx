import type { Metadata } from 'next';
import Link from 'next/link';
import CardFace from '@/components/game/CardFace';

export const metadata: Metadata = {
  title: 'How to Play Pitty Pat - Complete Guide & Rules | Learn in 2 Minutes',
  description: 'Learn how to play Pitty Pat card game with our comprehensive guide. Simple rules, strategies, and tips to master this classic matching game. Start playing in minutes!',
  keywords: 'how to play pitty pat, pitty pat rules, pitty pat tutorial, pitty pat strategy, learn pitty pat',
};

function SectionCard({ children }: { children: React.ReactNode }) {
  return (
    <section className="bg-white rounded-2xl p-6 mb-6 shadow-card">
      {children}
    </section>
  );
}

export default function HowToPlay() {
  return (
    <div className="min-h-screen bg-cream text-ink">
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        <Link href="/" className="inline-block mb-4 text-coral-deep hover:text-coral transition-colors font-medium">
          ← Back to Game
        </Link>

        <h1 className="font-display text-4xl font-bold mb-6">How to Play Pitty Pat</h1>

        <SectionCard>
          <h2 className="font-display text-2xl font-semibold mb-4">Quick Overview</h2>
          <p className="text-lg mb-4 text-ink/80">
            Pitty Pat is a simple, fast-paced card matching game where players race to be the first to get rid of all their cards.
            It&apos;s perfect for all ages and can be learned in just 2 minutes!
          </p>
          <ul className="list-disc list-inside space-y-2 text-ink/80">
            <li>Players: 2-4 (currently playing against computer)</li>
            <li>Cards: Standard 52-card deck</li>
            <li>Deal: 5 cards each</li>
            <li>Goal: Be first to play all your cards</li>
          </ul>
        </SectionCard>

        <SectionCard>
          <h2 className="font-display text-2xl font-semibold mb-4">Setup</h2>
          <ol className="list-decimal list-inside space-y-3 text-ink/80">
            <li>Shuffle a standard deck of 52 cards</li>
            <li>Deal 5 cards to each player</li>
            <li>Place remaining cards face down as the draw pile</li>
            <li>Flip the top card of the draw pile to start the discard pile</li>
            <li>The player to the dealer&apos;s left goes first</li>
          </ol>
        </SectionCard>

        <SectionCard>
          <h2 className="font-display text-2xl font-semibold mb-4">How to Play</h2>

          {/* Matching pair illustration */}
          <figure className="flex flex-col items-center gap-3 bg-cream rounded-2xl p-5 mb-5">
            <div className="flex items-center gap-4" aria-hidden="true">
              <div className="w-20 h-[120px] -rotate-6 shadow-card rounded-lg">
                <CardFace rank="7" suit="hearts" className="rounded-lg" />
              </div>
              <span className="font-display text-2xl font-bold text-coral-deep">=</span>
              <div className="w-20 h-[120px] rotate-6 shadow-card rounded-lg">
                <CardFace rank="7" suit="spades" className="rounded-lg" />
              </div>
            </div>
            <figcaption className="text-sm text-ink/70 text-center">
              <strong className="text-coral-deep">Match!</strong> Only rank matters — the 7 of hearts matches the 7 of spades.
            </figcaption>
          </figure>

          <h3 className="font-display text-xl font-semibold mb-2 text-coral-deep">On Your Turn:</h3>
          <ol className="list-decimal list-inside space-y-3 mb-4 text-ink/80">
            <li>
              <strong className="text-ink">Check for a match:</strong> Look at the top card of the discard pile.
              Do you have a card with the same rank (number or face)?
            </li>
            <li>
              <strong className="text-ink">If you have a match:</strong> Play your matching card on top of the discard pile.
              Your turn ends immediately.
            </li>
            <li>
              <strong className="text-ink">If you don&apos;t have a match:</strong> Draw one card from the draw pile.
              <ul className="list-disc list-inside ml-6 mt-2">
                <li>If the drawn card matches, play it immediately</li>
                <li>If it doesn&apos;t match, it goes on top of the discard pile</li>
              </ul>
            </li>
            <li>
              <strong className="text-ink">End of turn:</strong> Play passes to the next player clockwise
            </li>
          </ol>
        </SectionCard>

        <SectionCard>
          <h2 className="font-display text-2xl font-semibold mb-4">Winning the Game</h2>
          <p className="mb-4 text-ink/80">
            The first player to get rid of all their cards wins the round! It&apos;s that simple.
          </p>
          <p className="mb-4 text-ink/80">
            You can play multiple rounds and keep score. First to win 5 rounds wins the match.
          </p>
        </SectionCard>

        <SectionCard>
          <h2 className="font-display text-2xl font-semibold mb-4">Special Rules</h2>
          <ul className="list-disc list-inside space-y-3 text-ink/80">
            <li>
              <strong className="text-ink">Matching by rank only:</strong> Suits don&apos;t matter. A 7 of hearts matches any other 7.
            </li>
            <li>
              <strong className="text-ink">Automatic play:</strong> If you draw a matching card, you must play it immediately.
            </li>
            <li>
              <strong className="text-ink">Deck runs out:</strong> If the draw pile is empty, shuffle the discard pile (except the top card) to make a new draw pile.
            </li>
          </ul>
        </SectionCard>

        <SectionCard>
          <h2 className="font-display text-2xl font-semibold mb-4">Strategy Tips</h2>
          <ul className="list-disc list-inside space-y-3 text-ink/80">
            <li>
              <strong className="text-ink">Remember what&apos;s been played:</strong> Keep track of which ranks have appeared recently.
            </li>
            <li>
              <strong className="text-ink">Watch your opponent:</strong> Notice what they&apos;re drawing - it might tell you what they need.
            </li>
            <li>
              <strong className="text-ink">Play duplicates first:</strong> If you have two 5s, play one to keep flexibility.
            </li>
            <li>
              <strong className="text-ink">Speed matters:</strong> In friendly games, quick decisions keep the game exciting!
            </li>
          </ul>
        </SectionCard>

        <SectionCard>
          <h2 className="font-display text-2xl font-semibold mb-4">Variations</h2>
          <ul className="list-disc list-inside space-y-3 text-ink/80">
            <li>
              <strong className="text-ink">Seven-card Pitty Pat:</strong> Deal 7 cards instead of 5 for longer games.
            </li>
            <li>
              <strong className="text-ink">Double deck:</strong> For 5+ players, use two decks shuffled together.
            </li>
            <li>
              <strong className="text-ink">Speed Pitty Pat:</strong> Set a timer for each turn to add pressure!
            </li>
          </ul>
        </SectionCard>

        <section className="bg-gradient-to-br from-coral to-coral-deep text-white rounded-2xl p-6 mb-6 shadow-raised">
          <h2 className="font-display text-2xl font-semibold mb-4">Ready to Play?</h2>
          <p className="mb-4 text-white/90">
            Now that you know the rules, jump into a game! Our online version handles all the dealing and rules automatically,
            so you can focus on the fun.
          </p>
          <Link href="/play" className="inline-block bg-white text-coral-deep hover:bg-cream px-6 py-3 rounded-xl font-display font-semibold shadow-card transition-colors">
            Play Pitty Pat Now →
          </Link>
        </section>

        <div className="text-center text-sm text-ink/50 mt-8">
          <p>© 2025 Pitty Pat Online - The #1 Place to Play Pitty Pat on the Web</p>
        </div>
      </div>
    </div>
  );
}
