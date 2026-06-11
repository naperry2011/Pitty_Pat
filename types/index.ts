// Card-related types
export type Suit = 'hearts' | 'diamonds' | 'clubs' | 'spades';
export type Rank = 'A' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' | '10' | 'J' | 'Q' | 'K';

export interface Card {
  id: string;
  suit: Suit;
  rank: Rank;
  faceUp: boolean;
}

// Player types
export interface Player {
  id: string;
  name: string;
  hand: Card[];
  isAI: boolean;
  wins: number;
}

// Game state types
export type GamePhase = 'waiting' | 'playing' | 'roundEnd' | 'gameEnd';
export type TurnAction = 'draw' | 'play' | 'waiting';

export interface GameState {
  deck: Card[];
  discardPile: Card[];
  players: Player[];
  currentPlayerIndex: number;
  phase: GamePhase;
  winner: string | null;
  turnAction: TurnAction;
  message: string;
  selectedCardId: string | null;  // For two-tap mobile interaction
  matchTarget: number;  // Round wins needed to win the match
}

// Game action types for reducer
export type GameAction =
  | { type: 'START_GAME' }
  | { type: 'RESTART_GAME' }
  | { type: 'DRAW_CARD' }
  | { type: 'PLAY_CARD'; cardId: string }
  | { type: 'SELECT_CARD'; cardId: string | null }  // For two-tap selection
  | { type: 'END_TURN' }
  | { type: 'UPDATE_MESSAGE'; message: string };
