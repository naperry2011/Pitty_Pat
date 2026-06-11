'use client';

import React from 'react';
import { motion, useReducedMotion } from 'framer-motion';
import { Card as CardType } from '@/types';
import Card from './Card';
import clsx from 'clsx';

interface DiscardPileProps {
  cards: CardType[];
  className?: string;
}

const cardSpring = { type: 'spring', stiffness: 300, damping: 28 } as const;

// Deterministic per-card rotation for the messy-pile look (render-pure).
function messyRotation(cardId: string): number {
  let hash = 0;
  for (let i = 0; i < cardId.length; i++) {
    hash += cardId.charCodeAt(i);
  }
  return (hash % 13) - 6;
}

export default function DiscardPile({ cards, className = '' }: DiscardPileProps) {
  const reduceMotion = useReducedMotion();
  const topCards = cards.slice(-3); // Show last 3 cards for depth

  return (
    <div className={clsx('relative w-16 h-24 sm:w-20 sm:h-28', className)}>
      {/* Placeholder for empty pile or base reference */}
      {cards.length === 0 ? (
        <div className="w-16 h-24 sm:w-20 sm:h-28 rounded-2xl border-2 border-dashed border-gray-300 opacity-40 flex items-center justify-center bg-white/50">
          <span className="text-gray-400 text-xs">Discard</span>
        </div>
      ) : (
        <>
          {/* Invisible base card to maintain container size */}
          <div className="w-16 h-24 sm:w-20 sm:h-28 opacity-0" />

          {/* Actual cards - messy stack with deterministic rotation */}
          {topCards.map((card, index) => {
            const isTop = index === topCards.length - 1;
            const offset = index * 3;

            return (
              <motion.div
                key={card.id}
                layoutId={card.id}
                // Cards arrive via layout travel from a hand/deck; no fade-in
                initial={false}
                animate={{ rotate: messyRotation(card.id), opacity: isTop ? 1 : 0.6 }}
                transition={reduceMotion ? { duration: 0 } : cardSpring}
                className="absolute"
                style={{
                  top: offset,
                  left: offset,
                  zIndex: index + 1
                }}
              >
                <Card
                  card={{ ...card, faceUp: true }}
                  size="responsive"
                />
              </motion.div>
            );
          })}
        </>
      )}

      {/* Card count badge */}
      {cards.length > 1 && (
        <div className="absolute -bottom-1.5 -right-1.5 bg-sunny text-gray-800 rounded-full w-6 h-6 flex items-center justify-center text-xs font-bold shadow-md z-10">
          {cards.length}
        </div>
      )}
    </div>
  );
}
