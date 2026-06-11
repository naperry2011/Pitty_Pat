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

const ClassicBack = React.memo(function ClassicBack() {
  // useId gives each instance unique def ids so duplicate backs on one page
  // never reference another instance's (potentially hidden) defs.
  const uid = React.useId();
  const baseId = `pp-classic-base-${uid}`;
  const latticeId = `pp-classic-lattice-${uid}`;
  return (
    <svg viewBox="0 0 240 360" preserveAspectRatio="none" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <defs>
        <linearGradient id={baseId} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor={CORAL} />
          <stop offset="100%" stopColor={CORAL_DEEP} />
        </linearGradient>
        <pattern id={latticeId} width="28" height="28" patternUnits="userSpaceOnUse">
          <path d="M0 14 L14 0 L28 14 L14 28 Z" fill="none" stroke={CREAM} strokeOpacity="0.35" strokeWidth="2" />
        </pattern>
      </defs>
      <rect width="240" height="360" rx="16" fill={`url(#${baseId})`} />
      <rect x="14" y="14" width="212" height="332" rx="10" fill={`url(#${latticeId})`} />
      <rect x="14" y="14" width="212" height="332" rx="10" fill="none" stroke={GOLD} strokeWidth="3" />
      <rect x="6" y="6" width="228" height="348" rx="13" fill="none" stroke={CREAM} strokeOpacity="0.7" strokeWidth="2" />
      {/* Gold center crest */}
      <circle cx="120" cy="180" r="42" fill={GOLD} stroke={CREAM} strokeWidth="3" />
      <circle cx="120" cy="180" r="33" fill="none" stroke={CORAL_DEEP} strokeWidth="2" />
      <text x="120" y="195" textAnchor="middle" fontSize="38" fontWeight="700" fill={CORAL_DEEP} fontFamily="var(--font-display), 'Inter', sans-serif">
        PP
      </text>
    </svg>
  );
});

const GeometricBack = React.memo(function GeometricBack() {
  const uid = React.useId();
  const trisId = `pp-geo-tris-${uid}`;
  return (
    <svg viewBox="0 0 240 360" preserveAspectRatio="none" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <defs>
        <pattern id={trisId} width="50" height="44" patternUnits="userSpaceOnUse">
          <rect width="50" height="44" fill={FELT} />
          <path d="M0 44 L25 0 L50 44 Z" fill={FELT_DEEP} />
          <path d="M25 44 L37.5 22 L50 44 Z" fill={CREAM} fillOpacity="0.85" />
          <path d="M0 44 L12.5 22 L25 44 Z" fill={CREAM} fillOpacity="0.25" />
        </pattern>
      </defs>
      <rect width="240" height="360" rx="16" fill={FELT_DEEP} />
      <rect x="12" y="12" width="216" height="336" rx="10" fill={`url(#${trisId})`} />
      <rect x="12" y="12" width="216" height="336" rx="10" fill="none" stroke={CREAM} strokeWidth="3" />
      <rect x="5" y="5" width="230" height="350" rx="13" fill="none" stroke={CREAM} strokeOpacity="0.4" strokeWidth="2" />
      {/* Center diamond emblem */}
      <rect x="94" y="154" width="52" height="52" rx="6" transform="rotate(45 120 180)" fill={CREAM} />
      <text x="120" y="191" textAnchor="middle" fontSize="30" fontWeight="700" fill={FELT_DEEP} fontFamily="var(--font-display), 'Inter', sans-serif">
        PP
      </text>
    </svg>
  );
});

// Deterministic star positions for the gradient back
const STARS: [number, number, number][] = [
  [38, 52, 3], [115, 36, 2], [192, 62, 3.5], [67, 113, 2], [173, 134, 2.5],
  [34, 195, 2.5], [206, 206, 2], [86, 247, 3], [154, 278, 2], [53, 309, 2],
  [192, 319, 3],
];

const GradientBack = React.memo(function GradientBack() {
  const uid = React.useId();
  const baseId = `pp-grad-base-${uid}`;
  return (
    <svg viewBox="0 0 240 360" preserveAspectRatio="none" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <defs>
        <linearGradient id={baseId} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor={CORAL} />
          <stop offset="100%" stopColor={PURPLE} />
        </linearGradient>
      </defs>
      <rect width="240" height="360" rx="16" fill={`url(#${baseId})`} />
      <rect x="10" y="10" width="220" height="340" rx="11" fill="none" stroke={CREAM} strokeOpacity="0.6" strokeWidth="2" />
      {/* Subtle star field */}
      {STARS.map(([x, y, r], i) => (
        <g key={i} fill={CREAM} opacity={0.65}>
          <path d={`M${x} ${y - r * 2} Q${x + r * 0.5} ${y - r * 0.5} ${x + r * 2} ${y} Q${x + r * 0.5} ${y + r * 0.5} ${x} ${y + r * 2} Q${x - r * 0.5} ${y + r * 0.5} ${x - r * 2} ${y} Q${x - r * 0.5} ${y - r * 0.5} ${x} ${y - r * 2} Z`} />
        </g>
      ))}
      {/* Crescent moon center */}
      <circle cx="120" cy="180" r="26" fill={CREAM} fillOpacity="0.9" />
      <circle cx="129" cy="173" r="22" fill={CORAL} fillOpacity="0.55" />
      <circle cx="129" cy="173" r="22" fill={PURPLE} fillOpacity="0.5" />
    </svg>
  );
});

const MinimalBack = React.memo(function MinimalBack() {
  return (
    <svg viewBox="0 0 240 360" preserveAspectRatio="none" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
      <rect width="240" height="360" rx="16" fill={CREAM} />
      <rect x="14" y="14" width="212" height="332" rx="10" fill="none" stroke={CORAL} strokeWidth="3" />
      {/* Single coral heart pip */}
      <path
        d="M120 201 C98 183 91 169 91 157 C91 144 101 136 111 136 C116 136 120 139 120 143 C120 139 124 136 129 136 C139 136 149 144 149 157 C149 169 142 183 120 201 Z"
        fill={CORAL}
      />
      <circle cx="120" cy="225" r="3" fill={CORAL_DEEP} />
    </svg>
  );
});

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
        'relative rounded-xl overflow-hidden shadow-card',
        sizeClasses[size],
        className
      )}
    >
      {designs[style]}
    </div>
  );
}
