'use client';

import React from 'react';
import { CardBackStyle } from '@/contexts/CardStyleContext';
import clsx from 'clsx';

interface CardBackDesignProps {
  style: CardBackStyle;
  size: 'small' | 'medium' | 'large' | 'responsive';
  className?: string;
}

export default function CardBackDesign({ style, size, className = '' }: CardBackDesignProps) {
  const sizeClasses = {
    small: 'w-12 h-[4.5rem] sm:w-14 sm:h-20',
    medium: 'w-16 h-24 sm:w-20 sm:h-28',
    large: 'w-20 h-28 sm:w-24 sm:h-36',
    responsive: 'w-[16vw] h-[24vw] sm:w-[12vw] sm:h-[18vw] md:w-20 md:h-28'
  };

  const renderDesign = () => {
    switch (style) {
      case 'classic':
        // Rich red classic playing card back
        return (
          <>
            {/* Base gradient */}
            <div className="absolute inset-0 bg-gradient-to-br from-red-600 via-red-700 to-red-800 rounded-xl" />

            {/* Outer gold border */}
            <div className="absolute inset-0 rounded-xl border-2 border-yellow-500/80" />

            {/* Inner decorative frame */}
            <div className="absolute inset-1.5 rounded-lg border border-yellow-400/60" />
            <div className="absolute inset-2.5 rounded-md border border-yellow-400/40" />

            {/* Diamond pattern background */}
            <div className="absolute inset-3 overflow-hidden rounded">
              <div className="absolute inset-0" style={{
                backgroundImage: `
                  linear-gradient(45deg, rgba(255,215,0,0.15) 25%, transparent 25%),
                  linear-gradient(-45deg, rgba(255,215,0,0.15) 25%, transparent 25%),
                  linear-gradient(45deg, transparent 75%, rgba(255,215,0,0.15) 75%),
                  linear-gradient(-45deg, transparent 75%, rgba(255,215,0,0.15) 75%)
                `,
                backgroundSize: '8px 8px',
                backgroundPosition: '0 0, 0 4px, 4px -4px, -4px 0px'
              }} />
            </div>

            {/* Center medallion */}
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="w-6 h-6 sm:w-8 sm:h-8 rounded-full bg-gradient-to-br from-yellow-400 to-yellow-600 border-2 border-yellow-300 shadow-lg flex items-center justify-center">
                <span className="text-red-800 font-black text-[0.5em] sm:text-xs">PP</span>
              </div>
            </div>

            {/* Corner suits */}
            <div className="absolute top-2 left-2 text-yellow-400 text-[0.5em] font-bold">♠</div>
            <div className="absolute top-2 right-2 text-yellow-400 text-[0.5em] font-bold">♥</div>
            <div className="absolute bottom-2 left-2 text-yellow-400 text-[0.5em] font-bold">♦</div>
            <div className="absolute bottom-2 right-2 text-yellow-400 text-[0.5em] font-bold">♣</div>
          </>
        );

      case 'geometric':
        // Royal purple with geometric pattern
        return (
          <>
            {/* Base gradient */}
            <div className="absolute inset-0 bg-gradient-to-br from-purple-600 via-purple-700 to-indigo-800 rounded-xl" />

            {/* Border */}
            <div className="absolute inset-0 rounded-xl border-2 border-purple-400/70" />

            {/* Inner frame */}
            <div className="absolute inset-1.5 rounded-lg border border-purple-300/50" />

            {/* Geometric pattern */}
            <div className="absolute inset-2.5 overflow-hidden rounded">
              {/* Diagonal lines */}
              <div className="absolute inset-0" style={{
                backgroundImage: `repeating-linear-gradient(
                  45deg,
                  transparent,
                  transparent 4px,
                  rgba(255,255,255,0.1) 4px,
                  rgba(255,255,255,0.1) 5px
                )`
              }} />
              <div className="absolute inset-0" style={{
                backgroundImage: `repeating-linear-gradient(
                  -45deg,
                  transparent,
                  transparent 4px,
                  rgba(255,255,255,0.1) 4px,
                  rgba(255,255,255,0.1) 5px
                )`
              }} />
            </div>

            {/* Center diamond */}
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="w-7 h-7 sm:w-9 sm:h-9 rotate-45 bg-gradient-to-br from-purple-400 to-purple-600 border-2 border-purple-300 shadow-lg" />
              <div className="absolute w-4 h-4 sm:w-5 sm:h-5 rotate-45 bg-gradient-to-br from-white to-purple-100 border border-purple-300" />
            </div>

            {/* PP text */}
            <div className="absolute bottom-2 right-2 text-purple-200 text-[0.4em] font-bold">PP</div>
          </>
        );

      case 'gradient':
        // Ocean wave gradient
        return (
          <>
            {/* Base gradient */}
            <div className="absolute inset-0 bg-gradient-to-br from-teal-500 via-cyan-600 to-blue-700 rounded-xl" />

            {/* Border */}
            <div className="absolute inset-0 rounded-xl border-2 border-cyan-300/70" />

            {/* Inner frame */}
            <div className="absolute inset-1.5 rounded-lg border border-cyan-200/50" />

            {/* Wave pattern */}
            <div className="absolute inset-2 overflow-hidden rounded">
              <svg viewBox="0 0 100 140" className="w-full h-full" preserveAspectRatio="none">
                <defs>
                  <linearGradient id="waveGrad" x1="0%" y1="0%" x2="0%" y2="100%">
                    <stop offset="0%" stopColor="rgba(255,255,255,0.3)" />
                    <stop offset="100%" stopColor="rgba(255,255,255,0.1)" />
                  </linearGradient>
                </defs>
                <path d="M0,30 Q25,15 50,30 T100,30 L100,50 Q75,35 50,50 T0,50 Z" fill="url(#waveGrad)" />
                <path d="M0,60 Q25,45 50,60 T100,60 L100,80 Q75,65 50,80 T0,80 Z" fill="url(#waveGrad)" />
                <path d="M0,90 Q25,75 50,90 T100,90 L100,110 Q75,95 50,110 T0,110 Z" fill="url(#waveGrad)" />
              </svg>
            </div>

            {/* Center circle */}
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="w-7 h-7 sm:w-9 sm:h-9 rounded-full bg-gradient-to-br from-white to-cyan-100 border-2 border-cyan-200 shadow-lg flex items-center justify-center">
                <span className="text-cyan-700 font-black text-[0.5em] sm:text-xs">PP</span>
              </div>
            </div>
          </>
        );

      case 'minimal':
        // Sunny golden minimal design
        return (
          <>
            {/* Base gradient */}
            <div className="absolute inset-0 bg-gradient-to-br from-amber-400 via-orange-500 to-amber-600 rounded-xl" />

            {/* Border */}
            <div className="absolute inset-0 rounded-xl border-2 border-yellow-300/80" />

            {/* Inner frame */}
            <div className="absolute inset-2 rounded-lg border border-white/40" />

            {/* Simple cross pattern */}
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="w-full h-0.5 bg-white/30 absolute" />
              <div className="h-full w-0.5 bg-white/30 absolute" />
            </div>

            {/* Center emblem */}
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="w-8 h-8 sm:w-10 sm:h-10 rounded-full bg-gradient-to-br from-white to-amber-100 border-2 border-white shadow-lg flex items-center justify-center">
                <div className="w-5 h-5 sm:w-6 sm:h-6 rounded-full bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center">
                  <span className="text-white font-black text-[0.4em] sm:text-[0.5em]">PP</span>
                </div>
              </div>
            </div>

            {/* Corner dots */}
            <div className="absolute top-2 left-2 w-1.5 h-1.5 rounded-full bg-white/60" />
            <div className="absolute top-2 right-2 w-1.5 h-1.5 rounded-full bg-white/60" />
            <div className="absolute bottom-2 left-2 w-1.5 h-1.5 rounded-full bg-white/60" />
            <div className="absolute bottom-2 right-2 w-1.5 h-1.5 rounded-full bg-white/60" />
          </>
        );
    }
  };

  return (
    <div
      className={clsx(
        'relative rounded-xl overflow-hidden',
        sizeClasses[size],
        className
      )}
      style={{
        boxShadow: '0 4px 12px -2px rgba(0,0,0,0.2), 0 2px 4px -2px rgba(0,0,0,0.1)'
      }}
    >
      {renderDesign()}
    </div>
  );
}
