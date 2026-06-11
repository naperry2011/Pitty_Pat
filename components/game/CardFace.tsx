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

// Pip grid: columns x = 70 / 125 / 180, rows y = 70 / 125 / 175 / 225 / 280
// (10 uses half-row centers 97.5 / 252.5 to match real playing-card layout).
const L = 70;
const C = 125;
const R = 180;

const PIP_LAYOUTS: Partial<Record<Rank, [number, number][]>> = {
  'A': [[C, 175]],
  '2': [[C, 70], [C, 280]],
  '3': [[C, 70], [C, 175], [C, 280]],
  '4': [[L, 70], [R, 70], [L, 280], [R, 280]],
  '5': [[L, 70], [R, 70], [C, 175], [L, 280], [R, 280]],
  '6': [[L, 70], [R, 70], [L, 175], [R, 175], [L, 280], [R, 280]],
  '7': [[L, 70], [R, 70], [C, 125], [L, 175], [R, 175], [L, 280], [R, 280]],
  '8': [[L, 70], [R, 70], [C, 125], [L, 175], [R, 175], [C, 225], [L, 280], [R, 280]],
  '9': [[L, 70], [R, 70], [L, 125], [R, 125], [C, 175], [L, 225], [R, 225], [L, 280], [R, 280]],
  '10': [[L, 70], [R, 70], [C, 97.5], [L, 125], [R, 125], [L, 225], [R, 225], [C, 252.5], [L, 280], [R, 280]],
};

// Simple gold motifs drawn above the face-card display letter.
const FACE_MOTIFS: Record<'J' | 'Q' | 'K', React.ReactNode> = {
  // Feather for the Jack
  J: (
    <g stroke="#F4B942" strokeWidth="6" fill="none" strokeLinecap="round">
      <path d="M95 130 Q125 70 160 95 Q150 135 105 138 Z" fill="#F4B942" stroke="none" />
      <path d="M95 130 Q125 95 155 98" stroke="#FFF8F0" strokeWidth="3" />
      <path d="M95 130 L82 145" />
    </g>
  ),
  // Tiara for the Queen
  Q: (
    <g fill="#F4B942">
      <path d="M75 135 L85 100 L105 122 L125 88 L145 122 L165 100 L175 135 Z" />
      <circle cx="85" cy="96" r="6" />
      <circle cx="125" cy="84" r="6" />
      <circle cx="165" cy="96" r="6" />
    </g>
  ),
  // Crown for the King
  K: (
    <g fill="#F4B942">
      <path d="M72 138 L72 95 L96 115 L125 82 L154 115 L178 95 L178 138 Z" />
      <rect x="72" y="138" width="106" height="10" rx="3" />
    </g>
  ),
};

export default function CardFace({ rank, suit, className }: CardFaceProps) {
  const color = SUIT_COLORS[suit];
  const glyph = SUIT_GLYPHS[suit];
  const pips = PIP_LAYOUTS[rank];
  const isFaceCard = rank === 'J' || rank === 'Q' || rank === 'K';

  return (
    <svg
      viewBox="0 0 250 350"
      preserveAspectRatio="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      width="100%"
      height="100%"
      role="img"
      aria-label={`${rank} of ${suit}`}
    >
      {/* Card base with subtle edge highlight */}
      <rect x="0" y="0" width="250" height="350" rx="16" fill="#FFFFFF" />
      <rect
        x="1.5"
        y="1.5"
        width="247"
        height="347"
        rx="14.5"
        fill="none"
        stroke="rgba(45,49,66,0.12)"
        strokeWidth="1"
      />
      <rect
        x="3"
        y="3"
        width="244"
        height="344"
        rx="13"
        fill="none"
        stroke="rgba(255,255,255,0.9)"
        strokeWidth="1"
      />

      {/* Corner indices: top-left, and a 180-degree copy at bottom-right */}
      <g fill={color} textAnchor="middle">
        <text x="27" y="42" fontSize="38" fontWeight="700" fontFamily="var(--font-display), 'Inter', sans-serif">
          {rank}
        </text>
        <text x="27" y="74" fontSize="28">{glyph}</text>
      </g>
      <g fill={color} textAnchor="middle" transform="rotate(180 125 175)">
        <text x="27" y="42" fontSize="38" fontWeight="700" fontFamily="var(--font-display), 'Inter', sans-serif">
          {rank}
        </text>
        <text x="27" y="74" fontSize="28">{glyph}</text>
      </g>

      {isFaceCard ? (
        <>
          {FACE_MOTIFS[rank]}
          <text
            x="125"
            y="262"
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
              transform={y > 175 ? `rotate(180 ${x} ${y})` : undefined}
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
