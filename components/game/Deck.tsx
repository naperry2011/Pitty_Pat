'use client';

import React from 'react';
import Card from './Card';
import clsx from 'clsx';

interface DeckProps {
  cardCount: number;
  onClick?: () => void;
  disabled?: boolean;
  className?: string;
}

export default function Deck({
  cardCount,
  onClick,
  disabled = false,
  className = ''
}: DeckProps) {
  const isClickable = onClick && !disabled && cardCount > 0;

  return (
    <div className={clsx(
      'relative w-16 h-24 sm:w-20 sm:h-28',
      className
    )}>
      {/* Stack effect - show multiple cards */}
      {cardCount > 2 && (
        <div className="absolute top-0 left-0 opacity-40" style={{ transform: 'translate(-2px, -2px)' }}>
          <Card
            card={{ id: 'deck-3', suit: 'spades', rank: 'A', faceUp: false }}
            size="responsive"
            disabled
          />
        </div>
      )}
      {cardCount > 1 && (
        <div className="absolute top-0 left-0 opacity-70" style={{ transform: 'translate(-1px, -1px)' }}>
          <Card
            card={{ id: 'deck-2', suit: 'spades', rank: 'A', faceUp: false }}
            size="responsive"
            disabled
          />
        </div>
      )}

      {/* Top card of deck */}
      <div className="absolute top-0 left-0">
        {cardCount > 0 ? (
          <Card
            card={{ id: 'deck-1', suit: 'spades', rank: 'A', faceUp: false }}
            onClick={isClickable ? onClick : undefined}
            disabled={disabled}
            size="responsive"
            className={clsx(
              isClickable && 'tap-scale',
              isClickable && 'ring-2 ring-mint/50 ring-offset-2'
            )}
          />
        ) : (
          <div className="w-16 h-24 sm:w-20 sm:h-28 rounded-2xl border-2 border-dashed border-gray-300 opacity-40 flex items-center justify-center bg-white/50">
            <span className="text-gray-400 text-xs">Empty</span>
          </div>
        )}
      </div>

      {/* Card count badge */}
      {cardCount > 0 && (
        <div className="absolute -bottom-1.5 -right-1.5 bg-mint text-white rounded-full w-6 h-6 flex items-center justify-center text-xs font-bold shadow-md z-10">
          {cardCount}
        </div>
      )}
    </div>
  );
}
