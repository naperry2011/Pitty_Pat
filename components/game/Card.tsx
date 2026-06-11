'use client';

import React from 'react';
import { Card as CardType } from '@/types';
import clsx from 'clsx';
import { useCardStyle } from '@/contexts/CardStyleContext';
import CardBackDesign from './CardBackDesign';
import CardFace from './CardFace';

interface CardProps {
  card: CardType;
  onClick?: () => void;
  disabled?: boolean;
  size?: 'small' | 'medium' | 'large' | 'responsive';
  className?: string;
  style?: React.CSSProperties;
  isSelected?: boolean;
  isPlayable?: boolean;
}

export default function Card({
  card,
  onClick,
  disabled = false,
  size = 'medium',
  className = '',
  style,
  isSelected = false,
  isPlayable = false
}: CardProps) {
  const { cardBackStyle } = useCardStyle();

  // Size classes - responsive uses viewport-based sizing
  const sizeClasses = {
    small: 'w-12 h-[4.5rem] text-base sm:w-14 sm:h-20 sm:text-lg',
    medium: 'w-16 h-24 text-xl sm:w-20 sm:h-28 sm:text-2xl',
    large: 'w-20 h-28 text-2xl sm:w-24 sm:h-36 sm:text-3xl',
    responsive: 'w-[16vw] h-[24vw] text-[3.5vw] sm:w-[12vw] sm:h-[18vw] sm:text-[2.5vw] md:w-20 md:h-28 md:text-xl'
  };

  const isClickable = onClick && !disabled;

  if (!card.faceUp) {
    // Card back - use the selected style
    return (
      <div
        className={clsx(
          'no-select',
          isClickable && 'cursor-pointer card-interactive tap-scale',
          className
        )}
        onClick={isClickable ? onClick : undefined}
        style={style}
      >
        <CardBackDesign style={cardBackStyle} size={size} />
      </div>
    );
  }

  // Card front - SVG playing card face
  return (
    <div
      className={clsx(
        'rounded-xl relative no-select overflow-hidden',
        sizeClasses[size],
        isClickable && 'cursor-pointer card-interactive',
        // Resting cards use the shadow-card elevation token; selected keeps its ring
        isSelected ? 'selected-glow -translate-y-3 z-20' : 'shadow-card',
        className
      )}
      onClick={isClickable ? onClick : undefined}
      style={{
        ...(isSelected && {
          boxShadow: '0 0 0 3px #FFE66D, 0 8px 24px -4px rgba(0,0,0,0.25)'
        }),
        ...style
      }}
    >
      <CardFace rank={card.rank} suit={card.suit} />

      {/* Card border */}
      <div
        className={clsx(
          "absolute inset-0 rounded-xl border-2",
          isSelected ? "border-yellow-400" : isPlayable ? "border-yellow-300" : "border-transparent"
        )}
      />

      {/* Playable indicator glow */}
      {isPlayable && !isSelected && (
        <div className="absolute inset-0 rounded-xl bg-yellow-400/10 animate-pulse" />
      )}

      {/* Not playable overlay - subtle gray instead of opacity */}
      {!isPlayable && isClickable && (
        <div className="absolute inset-0 rounded-xl bg-gray-400/20" />
      )}

      {/* Selected indicator */}
      {isSelected && (
        <div className="absolute -top-2 left-1/2 -translate-x-1/2 bg-yellow-400 text-gray-800 text-[0.45em] font-bold px-2 py-0.5 rounded-full shadow-lg border border-yellow-500">
          TAP TO PLAY
        </div>
      )}
    </div>
  );
}
