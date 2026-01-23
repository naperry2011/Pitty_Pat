'use client';

import React from 'react';
import { Card as CardType } from '@/types';
import Card from './Card';
import clsx from 'clsx';

interface HandProps {
  cards: CardType[];
  onCardTap?: (cardId: string, isPlayable: boolean) => void;
  isPlayerHand?: boolean;
  disabled?: boolean;
  className?: string;
  playableCardIds?: string[];
  selectedCardId?: string | null;
}

export default function Hand({
  cards,
  onCardTap,
  isPlayerHand = true,
  disabled = false,
  className = '',
  playableCardIds = [],
  selectedCardId = null
}: HandProps) {
  return (
    <div className={clsx(
      'flex justify-center items-center flex-wrap',
      // Gap between cards - bigger gap for player hand, smaller for AI
      isPlayerHand ? 'gap-2 sm:gap-3' : 'gap-1 sm:gap-2',
      className
    )}>
      {cards.map((card) => {
        const isPlayable = playableCardIds?.includes(card.id);
        const isSelected = selectedCardId === card.id;

        return (
          <div
            key={card.id}
            className={clsx(
              'transition-all duration-300',
              isSelected && '-translate-y-2'
            )}
            style={{
              zIndex: isSelected ? 50 : 1
            }}
          >
            <Card
              card={isPlayerHand ? card : { ...card, faceUp: false }}
              onClick={onCardTap && isPlayerHand ? () => onCardTap(card.id, isPlayable) : undefined}
              disabled={disabled}
              size="responsive"
              isSelected={isSelected}
              isPlayable={isPlayable}
              className={clsx(
                isPlayerHand && 'touch-target'
              )}
            />
          </div>
        );
      })}
    </div>
  );
}
