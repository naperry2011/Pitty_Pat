'use client';

import Link from 'next/link';
import { motion, useReducedMotion } from 'framer-motion';
import CardFace from '@/components/game/CardFace';
import Icon, { IconName } from '@/components/ui/Icon';
import { Rank, Suit } from '@/types';

// Hero fan: five cards arced like a held hand. z stacks the center card on top.
const HERO_CARDS: { rank: Rank; suit: Suit; rotate: number; x: number; y: number; z: number }[] = [
  { rank: 'A', suit: 'hearts', rotate: -24, x: -84, y: 26, z: 1 },
  { rank: 'K', suit: 'spades', rotate: -12, x: -42, y: 8, z: 2 },
  { rank: 'Q', suit: 'diamonds', rotate: 0, x: 0, y: 0, z: 3 },
  { rank: 'J', suit: 'clubs', rotate: 12, x: 42, y: 8, z: 2 },
  { rank: '10', suit: 'hearts', rotate: 24, x: 84, y: 26, z: 1 },
];

const STEPS: { icon: IconName; title: string; body: string }[] = [
  {
    icon: 'cards',
    title: 'Match the Card!',
    body: 'Look at the card on top. If you have a card with the same number, tap it to play!',
  },
  {
    icon: 'arrow-down',
    title: 'No Match? Draw!',
    body: "Can't match? No worries! Just tap the deck to draw a new card.",
  },
  {
    icon: 'trophy',
    title: 'Empty Hand = You Win!',
    body: "Be the first to play all your cards and you're the winner!",
  },
];

const FUN_FACTS = [
  { value: '52', label: 'Cards' },
  { value: '5', label: 'Cards Each' },
  { value: '0', label: 'Cards to Win' },
];

export default function Home() {
  const reduceMotion = useReducedMotion();

  return (
    <main className="min-h-screen bg-cream">
      <div className="min-h-screen flex flex-col items-center justify-center px-4 py-10 safe-area-top safe-area-bottom">
        {/* Hero */}
        <div className="text-center mb-10">
          {/* Fanned card arc */}
          <div className="relative h-40 sm:h-48 w-72 sm:w-80 mx-auto mb-6" aria-hidden="true">
            {HERO_CARDS.map((card, i) => (
              <motion.div
                key={`${card.rank}-${card.suit}`}
                className="absolute left-1/2 bottom-0 -ml-10 sm:-ml-12 w-20 h-[120px] sm:w-24 sm:h-36 drop-shadow-lg"
                style={{ originY: 1, zIndex: card.z }}
                initial={
                  reduceMotion
                    ? false
                    : { opacity: 0, y: 40, rotate: 0, x: 0 }
                }
                animate={{
                  opacity: 1,
                  x: card.x,
                  y: card.y,
                  rotate: card.rotate,
                }}
                transition={
                  reduceMotion
                    ? { duration: 0 }
                    : {
                        type: 'spring',
                        stiffness: 260,
                        damping: 20,
                        delay: 0.15 + i * 0.08,
                      }
                }
              >
                <CardFace rank={card.rank} suit={card.suit} className="rounded-lg" />
              </motion.div>
            ))}
          </div>

          <h1 className="font-display text-5xl sm:text-7xl font-bold text-ink mb-3">
            Pitty&nbsp;Pat!
          </h1>
          <p className="text-xl sm:text-2xl text-ink/70 font-medium">
            The Super Fun Card Game!
          </p>
        </div>

        {/* Play Button */}
        <Link
          href="/play"
          className="mb-12 px-12 py-5 bg-gradient-to-br from-coral to-coral-deep text-white font-display text-2xl sm:text-3xl font-semibold rounded-3xl shadow-raised hover:shadow-floating hover:-translate-y-0.5 active:scale-95 transition-all duration-200"
        >
          Play Now!
        </Link>

        {/* How to Play */}
        <section className="w-full max-w-md mb-8">
          <h2 className="font-display text-2xl sm:text-3xl font-semibold text-ink text-center mb-5">
            How to Play
          </h2>

          <div className="space-y-3">
            {STEPS.map(step => (
              <div
                key={step.title}
                className="flex items-start gap-4 bg-white rounded-2xl p-4 sm:p-5 shadow-card"
              >
                <div className="w-11 h-11 sm:w-12 sm:h-12 rounded-full bg-coral/10 text-coral-deep flex items-center justify-center flex-shrink-0">
                  <Icon name={step.icon} size={24} />
                </div>
                <div>
                  <h3 className="font-display font-semibold text-ink text-lg">{step.title}</h3>
                  <p className="text-ink/70 text-sm sm:text-base">{step.body}</p>
                </div>
              </div>
            ))}
          </div>

          {/* Pro tip */}
          <div className="mt-4 bg-gold/15 border border-gold/40 rounded-2xl p-4">
            <p className="text-center text-ink/80 text-sm sm:text-base">
              <strong className="text-ink">Pro Tip:</strong> Tap a card once to select it, tap
              again to play!
            </p>
          </div>
        </section>

        {/* Play with Friends */}
        <section className="w-full max-w-md bg-gradient-to-br from-felt to-felt-deep rounded-3xl shadow-raised p-6 sm:p-8 text-cream text-center mb-8">
          <h2 className="font-display text-2xl font-semibold mb-2">Play with Friends!</h2>
          <p className="text-cream/90 mb-4">
            Pitty Pat is even more fun with friends! Show them how to play and take turns on the
            same device, or challenge them to beat your high score!
          </p>
          <div className="flex justify-center gap-2 flex-wrap">
            <span className="bg-cream/15 px-3 py-1 rounded-full text-sm font-medium">
              Take Turns
            </span>
            <span className="bg-cream/15 px-3 py-1 rounded-full text-sm font-medium">
              Beat High Scores
            </span>
            <span className="bg-cream/15 px-3 py-1 rounded-full text-sm font-medium">
              Teach Friends
            </span>
          </div>
        </section>

        {/* Fun Facts */}
        <div className="w-full max-w-md grid grid-cols-3 gap-3 mb-10">
          {FUN_FACTS.map(fact => (
            <div key={fact.label} className="bg-white rounded-2xl p-4 text-center shadow-card">
              <div className="font-display text-3xl font-bold text-coral-deep">{fact.value}</div>
              <div className="text-xs text-ink/60 mt-1">{fact.label}</div>
            </div>
          ))}
        </div>

        {/* Bottom Play Button */}
        <Link
          href="/play"
          className="px-9 py-4 bg-gradient-to-br from-coral to-coral-deep text-white font-display text-xl font-semibold rounded-2xl shadow-raised hover:shadow-floating hover:-translate-y-0.5 active:scale-95 transition-all duration-200"
        >
          Let&apos;s Play!
        </Link>

        {/* Footer */}
        <footer className="mt-10 text-ink/50 text-sm text-center space-x-4">
          <span>Made with care for kids who love card games</span>
          <Link href="/how-to-play" className="underline hover:text-ink/70">
            How to Play
          </Link>
          <Link href="/rules" className="underline hover:text-ink/70">
            Rules
          </Link>
        </footer>
      </div>
    </main>
  );
}
