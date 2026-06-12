import React from 'react';
import { Rank, Suit } from '@/types';

interface CardFaceProps {
  rank: Rank;
  suit: Suit;
  className?: string;
}

const SUIT_GLYPHS: Record<Suit, string> = {
  hearts: '♥',
  diamonds: '♦',
  clubs: '♣',
  spades: '♠',
};

const SUIT_COLORS: Record<Suit, string> = {
  hearts: '#E84855',
  diamonds: '#E84855',
  clubs: '#2D3142',
  spades: '#2D3142',
};

// Pip grid (240x360 viewBox, exact 2:3 card ratio):
// columns x = 66 / 120 / 174, rows y = 72 / 126 / 180 / 234 / 288
// (10 uses half-row centers 99 / 261 to match real playing-card layout).
const L = 66;
const C = 120;
const R = 174;

const PIP_LAYOUTS: Partial<Record<Rank, [number, number][]>> = {
  'A': [[C, 180]],
  '2': [[C, 72], [C, 288]],
  '3': [[C, 72], [C, 180], [C, 288]],
  '4': [[L, 72], [R, 72], [L, 288], [R, 288]],
  '5': [[L, 72], [R, 72], [C, 180], [L, 288], [R, 288]],
  '6': [[L, 72], [R, 72], [L, 180], [R, 180], [L, 288], [R, 288]],
  '7': [[L, 72], [R, 72], [C, 126], [L, 180], [R, 180], [L, 288], [R, 288]],
  '8': [[L, 72], [R, 72], [C, 126], [L, 180], [R, 180], [C, 234], [L, 288], [R, 288]],
  '9': [[L, 72], [R, 72], [L, 126], [R, 126], [C, 180], [L, 234], [R, 234], [L, 288], [R, 288]],
  '10': [[L, 72], [R, 72], [C, 99], [L, 126], [R, 126], [L, 234], [R, 234], [C, 261], [L, 288], [R, 288]],
};

// Simple gold motifs drawn above the face-card display letter.
const FACE_MOTIFS: Record<'J' | 'Q' | 'K', React.ReactNode> = {
  // Feather for the Jack
  J: (
    <g stroke="#F4B942" strokeWidth="6" fill="none" strokeLinecap="round">
      <path d="M90 135 Q120 75 155 100 Q145 140 100 143 Z" fill="#F4B942" stroke="none" />
      <path d="M90 135 Q120 100 150 103" stroke="#FFF8F0" strokeWidth="3" />
      <path d="M90 135 L77 150" />
    </g>
  ),
  // Tiara for the Queen
  Q: (
    <g fill="#F4B942">
      <path d="M70 140 L80 105 L100 127 L120 93 L140 127 L160 105 L170 140 Z" />
      <circle cx="80" cy="101" r="6" />
      <circle cx="120" cy="89" r="6" />
      <circle cx="160" cy="101" r="6" />
    </g>
  ),
  // Crown for the King
  K: (
    <g fill="#F4B942">
      <path d="M67 143 L67 100 L91 120 L120 87 L149 120 L173 100 L173 143 Z" />
      <rect x="67" y="143" width="106" height="10" rx="3" />
    </g>
  ),
};

function CardFace({ rank, suit, className }: CardFaceProps) {
  const color = SUIT_COLORS[suit];
  const glyph = SUIT_GLYPHS[suit];
  const pips = PIP_LAYOUTS[rank];
  const isFaceCard = rank === 'J' || rank === 'Q' || rank === 'K';

  return (
    <svg
      viewBox="0 0 240 360"
      preserveAspectRatio="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      width="100%"
      height="100%"
      role="img"
      aria-label={`${rank} of ${suit}`}
    >
      {/* Card base with subtle edge highlight */}
      <rect x="0" y="0" width="240" height="360" rx="16" fill="#FFFFFF" />
      <rect
        x="1.5"
        y="1.5"
        width="237"
        height="357"
        rx="14.5"
        fill="none"
        stroke="rgba(45,49,66,0.12)"
        strokeWidth="1"
      />
      <rect
        x="3"
        y="3"
        width="234"
        height="354"
        rx="13"
        fill="none"
        stroke="rgba(255,255,255,0.9)"
        strokeWidth="1"
      />

      {/* Corner indices: top-left, and a 180-degree copy at bottom-right */}
      <g fill={color} textAnchor="middle">
        <text x="26" y="44" fontSize="46" fontWeight="700" fontFamily="var(--font-display), 'Inter', sans-serif">
          {rank}
        </text>
        <text x="26" y="78" fontSize="32">{glyph}</text>
      </g>
      <g fill={color} textAnchor="middle" transform="rotate(180 120 180)">
        <text x="26" y="44" fontSize="46" fontWeight="700" fontFamily="var(--font-display), 'Inter', sans-serif">
          {rank}
        </text>
        <text x="26" y="78" fontSize="32">{glyph}</text>
      </g>

      {isFaceCard ? (
        <>
          {FACE_MOTIFS[rank]}
          <text
            x="120"
            y="268"
            textAnchor="middle"
            fontSize="130"
            fontWeight="700"
            fill="#F4B942"
            stroke={color}
            strokeWidth="2"
            fontFamily="var(--font-display), 'Inter', sans-serif"
          >
            {rank}
          </text>
        </>
      ) : (
        <g fill={color} textAnchor="middle">
          {pips?.map(([x, y], i) => (
            <text
              key={i}
              data-pip
              x={x}
              y={y}
              fontSize={rank === 'A' ? 110 : 52}
              // Pips below the card midline render upside-down, like a real deck
              transform={y > 180 ? `rotate(180 ${x} ${y})` : undefined}
              dominantBaseline="central"
            >
              {glyph}
            </text>
          ))}
        </g>
      )}
    </svg>
  );
}

// Pure render component keyed on two strings + className: exact memo win.
export default React.memo(CardFace);
