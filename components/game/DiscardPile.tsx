'use client';

import React from 'react';
import { Card as CardType } from '@/types';
import Card from './Card';
import clsx from 'clsx';

interface DiscardPileProps {
  cards: CardType[];
  className?: string;
}

export default function DiscardPile({ cards, className = '' }: DiscardPileProps) {
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

          {/* Actual cards - slightly fanned */}
          {topCards.map((card, index) => {
            const isTop = index === topCards.length - 1;
            const offset = index * 3;
            const rotation = (index - 1) * 3;

            return (
              <div
                key={card.id}
                className={clsx(
                  'absolute top-0 left-0 transition-all duration-300',
                  !isTop && 'opacity-60'
                )}
                style={{
                  transform: `translate(${offset}px, ${offset}px) rotate(${rotation}deg)`,
                  zIndex: index + 1
                }}
              >
                <Card
                  card={{ ...card, faceUp: true }}
                  size="responsive"
                />
              </div>
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
