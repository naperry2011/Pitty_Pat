'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';

export type CardBackStyle = 'classic' | 'geometric' | 'gradient' | 'minimal';

interface CardStyleContextType {
  cardBackStyle: CardBackStyle;
  setCardBackStyle: (style: CardBackStyle) => void;
}

const CardStyleContext = createContext<CardStyleContextType | undefined>(undefined);

export function CardStyleProvider({ children }: { children: React.ReactNode }) {
  const [cardBackStyle, setCardBackStyle] = useState<CardBackStyle>('classic');

  // Load saved preference from localStorage
  useEffect(() => {
    const saved = localStorage.getItem('cardBackStyle');
    if (saved && ['classic', 'geometric', 'gradient', 'minimal'].includes(saved)) {
      setCardBackStyle(saved as CardBackStyle);
    }
  }, []);

  // Save preference to localStorage
  const handleSetCardBackStyle = (style: CardBackStyle) => {
    setCardBackStyle(style);
    localStorage.setItem('cardBackStyle', style);
  };

  return (
    <CardStyleContext.Provider value={{ cardBackStyle, setCardBackStyle: handleSetCardBackStyle }}>
      {children}
    </CardStyleContext.Provider>
  );
}

export function useCardStyle() {
  const context = useContext(CardStyleContext);
  if (!context) {
    throw new Error('useCardStyle must be used within a CardStyleProvider');
  }
  return context;
}