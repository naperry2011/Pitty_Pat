'use client';

import React from 'react';
import { Card as CardType } from '@/types';
import clsx from 'clsx';
import { useCardStyle } from '@/contexts/CardStyleContext';
import CardBackDesign from './CardBackDesign';

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

  const suitSymbols = {
    hearts: '♥',
    diamonds: '♦',
    clubs: '♣',
    spades: '♠'
  };

  // Rich, vibrant suit colors
  const suitColorClasses = {
    hearts: 'text-red-500',
    diamonds: 'text-orange-500',
    clubs: 'text-emerald-600',
    spades: 'text-indigo-600'
  };

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

  // Card front - premium solid design
  return (
    <div
      className={clsx(
        'rounded-xl relative no-select overflow-hidden',
        sizeClasses[size],
        isClickable && 'cursor-pointer card-interactive',
        isSelected && 'selected-glow -translate-y-3 z-20',
        className
      )}
      onClick={isClickable ? onClick : undefined}
      style={{
        boxShadow: isSelected
          ? '0 0 0 3px #FFE66D, 0 8px 24px -4px rgba(0,0,0,0.25)'
          : '0 4px 12px -2px rgba(0,0,0,0.15), 0 2px 4px -2px rgba(0,0,0,0.1)',
        ...style
      }}
    >
      {/* Card base - solid white with subtle gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-white via-white to-gray-50 rounded-xl" />

      {/* Card border */}
      <div
        className={clsx(
          "absolute inset-0 rounded-xl border-2",
          isSelected ? "border-yellow-400" : isPlayable ? "border-yellow-300" : "border-gray-200"
        )}
      />

      {/* Subtle card texture pattern */}
      <div className="absolute inset-0 opacity-[0.03] rounded-xl"
        style={{
          backgroundImage: `repeating-linear-gradient(
            45deg,
            transparent,
            transparent 2px,
            #000 2px,
            #000 4px
          )`
        }}
      />

      {/* Inner decorative border for premium look */}
      <div className="absolute inset-[3px] rounded-lg border border-gray-100" />

      {/* Playable indicator glow */}
      {isPlayable && !isSelected && (
        <div className="absolute inset-0 rounded-xl bg-yellow-400/10 animate-pulse" />
      )}

      {/* Not playable overlay - subtle gray instead of opacity */}
      {!isPlayable && isClickable && (
        <div className="absolute inset-0 rounded-xl bg-gray-400/20" />
      )}

      {/* Card content */}
      <div className={clsx('relative h-full flex flex-col items-center justify-center', suitColorClasses[card.suit])}>
        {/* Top left corner */}
        <div className="absolute top-1 left-1.5 flex flex-col items-center leading-none">
          <span className="font-black text-[0.75em] drop-shadow-sm">{card.rank}</span>
          <span className="text-[0.6em]">{suitSymbols[card.suit]}</span>
        </div>

        {/* Center suit symbol - larger and bolder */}
        <div className="text-[2em] drop-shadow-sm">{suitSymbols[card.suit]}</div>

        {/* Bottom right corner */}
        <div className="absolute bottom-1 right-1.5 flex flex-col items-center leading-none rotate-180">
          <span className="font-black text-[0.75em] drop-shadow-sm">{card.rank}</span>
          <span className="text-[0.6em]">{suitSymbols[card.suit]}</span>
        </div>
      </div>

      {/* Selected indicator */}
      {isSelected && (
        <div className="absolute -top-2 left-1/2 -translate-x-1/2 bg-yellow-400 text-gray-800 text-[0.45em] font-bold px-2 py-0.5 rounded-full shadow-lg border border-yellow-500">
          TAP TO PLAY
        </div>
      )}
    </div>
  );
}
