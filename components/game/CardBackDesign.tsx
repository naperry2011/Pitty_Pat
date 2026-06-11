'use client';

import React from 'react';
import { CardBackStyle } from '@/contexts/CardStyleContext';
import clsx from 'clsx';

interface CardBackDesignProps {
  style: CardBackStyle;
  size: 'small' | 'medium' | 'large' | 'responsive';
  className?: string;
}

// Premium palette
const CORAL = '#FF6B6B';
const CORAL_DEEP = '#E84855';
const CREAM = '#FFF8F0';
const FELT = '#2E9E8F';
const FELT_DEEP = '#1F7A6D';
const GOLD = '#F4B942';
const PURPLE = '#DDA0DD';

function ClassicBack() {
  return (
    <svg viewBox="0 0 250 350" preserveAspectRatio="none" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <defs>
        <linearGradient id="pp-classic-base" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor={CORAL} />
          <stop offset="100%" stopColor={CORAL_DEEP} />
        </linearGradient>
        <pattern id="pp-classic-lattice" width="28" height="28" patternUnits="userSpaceOnUse">
          <path d="M0 14 L14 0 L28 14 L14 28 Z" fill="none" stroke={CREAM} strokeOpacity="0.35" strokeWidth="2" />
        </pattern>
      </defs>
      <rect width="250" height="350" rx="16" fill="url(#pp-classic-base)" />
      <rect x="14" y="14" width="222" height="322" rx="10" fill="url(#pp-classic-lattice)" />
      <rect x="14" y="14" width="222" height="322" rx="10" fill="none" stroke={GOLD} strokeWidth="3" />
      <rect x="6" y="6" width="238" height="338" rx="13" fill="none" stroke={CREAM} strokeOpacity="0.7" strokeWidth="2" />
      {/* Gold center crest */}
      <circle cx="125" cy="175" r="42" fill={GOLD} stroke={CREAM} strokeWidth="3" />
      <circle cx="125" cy="175" r="33" fill="none" stroke={CORAL_DEEP} strokeWidth="2" />
      <text x="125" y="190" textAnchor="middle" fontSize="38" fontWeight="700" fill={CORAL_DEEP} fontFamily="var(--font-display), 'Inter', sans-serif">
        PP
      </text>
    </svg>
  );
}

function GeometricBack() {
  return (
    <svg viewBox="0 0 250 350" preserveAspectRatio="none" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <defs>
        <pattern id="pp-geo-tris" width="50" height="44" patternUnits="userSpaceOnUse">
          <rect width="50" height="44" fill={FELT} />
          <path d="M0 44 L25 0 L50 44 Z" fill={FELT_DEEP} />
          <path d="M25 44 L37.5 22 L50 44 Z" fill={CREAM} fillOpacity="0.85" />
          <path d="M0 44 L12.5 22 L25 44 Z" fill={CREAM} fillOpacity="0.25" />
        </pattern>
      </defs>
      <rect width="250" height="350" rx="16" fill={FELT_DEEP} />
      <rect x="12" y="12" width="226" height="326" rx="10" fill="url(#pp-geo-tris)" />
      <rect x="12" y="12" width="226" height="326" rx="10" fill="none" stroke={CREAM} strokeWidth="3" />
      <rect x="5" y="5" width="240" height="340" rx="13" fill="none" stroke={CREAM} strokeOpacity="0.4" strokeWidth="2" />
      {/* Center diamond emblem */}
      <rect x="99" y="149" width="52" height="52" rx="6" transform="rotate(45 125 175)" fill={CREAM} />
      <text x="125" y="186" textAnchor="middle" fontSize="30" fontWeight="700" fill={FELT_DEEP} fontFamily="var(--font-display), 'Inter', sans-serif">
        PP
      </text>
    </svg>
  );
}

// Deterministic star positions for the gradient back
const STARS: [number, number, number][] = [
  [40, 50, 3], [120, 35, 2], [200, 60, 3.5], [70, 110, 2], [180, 130, 2.5],
  [35, 190, 2.5], [215, 200, 2], [90, 240, 3], [160, 270, 2], [55, 300, 2],
  [200, 310, 3], [130, 175, 0],
];

function GradientBack() {
  return (
    <svg viewBox="0 0 250 350" preserveAspectRatio="none" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <defs>
        <linearGradient id="pp-grad-base" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor={CORAL} />
          <stop offset="100%" stopColor={PURPLE} />
        </linearGradient>
      </defs>
      <rect width="250" height="350" rx="16" fill="url(#pp-grad-base)" />
      <rect x="10" y="10" width="230" height="330" rx="11" fill="none" stroke={CREAM} strokeOpacity="0.6" strokeWidth="2" />
      {/* Subtle star field */}
      {STARS.filter(([, , r]) => r > 0).map(([x, y, r], i) => (
        <g key={i} fill={CREAM} opacity={0.65}>
          <path d={`M${x} ${y - r * 2} Q${x + r * 0.5} ${y - r * 0.5} ${x + r * 2} ${y} Q${x + r * 0.5} ${y + r * 0.5} ${x} ${y + r * 2} Q${x - r * 0.5} ${y + r * 0.5} ${x - r * 2} ${y} Q${x - r * 0.5} ${y - r * 0.5} ${x} ${y - r * 2} Z`} />
        </g>
      ))}
      {/* Crescent moon center */}
      <circle cx="125" cy="175" r="26" fill={CREAM} fillOpacity="0.9" />
      <circle cx="134" cy="168" r="22" fill={CORAL} fillOpacity="0.55" />
      <circle cx="134" cy="168" r="22" fill={PURPLE} fillOpacity="0.5" />
    </svg>
  );
}

function MinimalBack() {
  return (
    <svg viewBox="0 0 250 350" preserveAspectRatio="none" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <rect width="250" height="350" rx="16" fill={CREAM} />
      <rect x="14" y="14" width="222" height="322" rx="10" fill="none" stroke={CORAL} strokeWidth="3" />
      {/* Single coral heart pip */}
      <path
        d="M125 196 C103 178 96 164 96 152 C96 139 106 131 116 131 C121 131 125 134 125 138 C125 134 129 131 134 131 C144 131 154 139 154 152 C154 164 147 178 125 196 Z"
        fill={CORAL}
      />
      <circle cx="125" cy="220" r="3" fill={CORAL_DEEP} />
    </svg>
  );
}

export default function CardBackDesign({ style, size, className = '' }: CardBackDesignProps) {
  const sizeClasses = {
    small: 'w-12 h-[4.5rem] sm:w-14 sm:h-20',
    medium: 'w-16 h-24 sm:w-20 sm:h-28',
    large: 'w-20 h-28 sm:w-24 sm:h-36',
    responsive: 'w-[16vw] h-[24vw] sm:w-[12vw] sm:h-[18vw] md:w-20 md:h-28'
  };

  const designs: Record<CardBackStyle, React.ReactNode> = {
    classic: <ClassicBack />,
    geometric: <GeometricBack />,
    gradient: <GradientBack />,
    minimal: <MinimalBack />,
  };

  return (
    <div
      className={clsx(
        'relative rounded-xl overflow-hidden',
        sizeClasses[size],
        className
      )}
      style={{
        boxShadow: '0 4px 12px -2px rgba(45,49,66,0.2), 0 2px 4px -2px rgba(45,49,66,0.1)'
      }}
    >
      {designs[style]}
    </div>
  );
}
