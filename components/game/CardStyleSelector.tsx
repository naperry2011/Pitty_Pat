'use client';

import React from 'react';
import { useCardStyle, CardBackStyle } from '@/contexts/CardStyleContext';
import CardBackDesign from './CardBackDesign';
import clsx from 'clsx';

export default function CardStyleSelector() {
  const { cardBackStyle, setCardBackStyle } = useCardStyle();

  const styles: { value: CardBackStyle; name: string }[] = [
    { value: 'classic', name: 'Classic' },
    { value: 'geometric', name: 'Geo' },
    { value: 'gradient', name: 'Wave' },
    { value: 'minimal', name: 'Simple' }
  ];

  return (
    <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-4 shadow-soft">
      <h3 className="text-gray-700 font-bold text-sm mb-3">Card Style</h3>
      <div className="grid grid-cols-4 gap-2">
        {styles.map(({ value, name }) => (
          <button
            key={value}
            onClick={() => setCardBackStyle(value)}
            className={clsx(
              'relative flex flex-col items-center p-2 rounded-xl transition-all tap-scale touch-target',
              cardBackStyle === value
                ? 'bg-gradient-to-br from-sunny/30 to-coral/20 ring-2 ring-sunny shadow-md'
                : 'bg-gray-100/50 active:bg-gray-200/50'
            )}
          >
            <CardBackDesign style={value} size="small" className="mb-1.5" />
            <div className="text-[10px] text-gray-600 font-medium">{name}</div>
            {cardBackStyle === value && (
              <div className="absolute -top-1 -right-1 w-5 h-5 bg-sunny rounded-full flex items-center justify-center shadow-sm">
                <span className="text-gray-800 text-xs">✓</span>
              </div>
            )}
          </button>
        ))}
      </div>
    </div>
  );
}
