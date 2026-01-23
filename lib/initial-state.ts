import { GameState } from '@/types';

// Create a stable initial state for SSR/hydration
// The actual game will be initialized on the client after mount
export function createPlaceholderGameState(): GameState {
  return {
    deck: [],
    discardPile: [],
    players: [
      {
        id: 'player1',
        name: 'Player',
        hand: [],
        isAI: false,
        wins: 0
      },
      {
        id: 'ai1',
        name: 'Computer',
        hand: [],
        isAI: true,
        wins: 0
      }
    ],
    currentPlayerIndex: 0,
    phase: 'waiting',
    winner: null,
    turnAction: 'waiting',
    message: 'Loading game...',
    selectedCardId: null
  };
}