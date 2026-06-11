'use client';

import React from 'react';
import { motion, useReducedMotion } from 'framer-motion';
import { Card as CardType } from '@/types';
import Card from './Card';
import { TIMING } from '@/lib/timing';
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

const cardSpring = { type: 'spring', stiffness: 300, damping: 28 } as const;

export default function Hand({
  cards,
  onCardTap,
  isPlayerHand = true,
  disabled = false,
  className = '',
  playableCardIds = [],
  selectedCardId = null
}: HandProps) {
  const reduceMotion = useReducedMotion();

  return (
    <div className={clsx(
      'flex justify-center items-center flex-wrap',
      // Gap between cards - bigger gap for player hand, smaller for AI
      isPlayerHand ? 'gap-2 sm:gap-3' : 'gap-1 sm:gap-2',
      className
    )}>
      {cards.map((card, index) => {
        const isPlayable = playableCardIds?.includes(card.id);
        const isSelected = selectedCardId === card.id;

        return (
          <motion.div
            key={card.id}
            layoutId={card.id}
            // Deal-in: cards fly from the table center toward their hand
            initial={{ opacity: 0, y: isPlayerHand ? -120 : 120, scale: 0.6 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            transition={
              reduceMotion
                ? { duration: 0 }
                : {
                    ...cardSpring,
                    delay: (index * TIMING.dealStagger) / 1000,
                    // Reflow/travel of already-dealt cards should not inherit the deal delay
                    layout: cardSpring
                  }
            }
            style={{ zIndex: isSelected ? 50 : 1 }}
          >
            <div className={clsx(
              'transition-all duration-300',
              isSelected && '-translate-y-2'
            )}>
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
          </motion.div>
        );
      })}
    </div>
  );
}
