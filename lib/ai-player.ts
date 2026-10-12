import { GameState } from '@/types';
import { findPlayableCards, drawCard, playCard, endTurn } from './game-engine';

// AI difficulty levels
export type AIDifficulty = 'easy' | 'medium' | 'hard';

interface AIDecision {
  action: 'play' | 'draw';
  cardId?: string;
}

// Playing a match is always the best move: it sheds a card, while drawing never
// does. Every playable card shares the top discard's rank, so which one is played
// doesn't matter either. Difficulty is therefore how often the AI overlooks a
// match it holds (it draws instead).
export const MISS_CHANCE: Record<AIDifficulty, number> = {
  easy: 0.35,
  medium: 0.12,
  hard: 0,
};

// Get AI decision based on current game state
export function getAIDecision(state: GameState, difficulty: AIDifficulty = 'easy'): AIDecision {
  const currentPlayer = state.players[state.currentPlayerIndex];

  if (!currentPlayer.isAI) {
    throw new Error('Current player is not an AI');
  }

  const topDiscard = state.discardPile[state.discardPile.length - 1];
  const playableCards = findPlayableCards(currentPlayer.hand, topDiscard);

  if (playableCards.length === 0) {
    return { action: 'draw' };
  }

  const missChance = MISS_CHANCE[difficulty];
  if (missChance > 0 && Math.random() < missChance) {
    return { action: 'draw' };
  }

  return { action: 'play', cardId: playableCards[0].id };
}

// Execute AI turn with delay for realism
export async function executeAITurn(
  state: GameState,
  difficulty: AIDifficulty = 'easy',
  delayMs: number = 1000
): Promise<GameState> {
  // Add thinking delay for realism
  await new Promise(resolve => setTimeout(resolve, delayMs));

  const decision = getAIDecision(state, difficulty);
  let newState: GameState;

  if (decision.action === 'play' && decision.cardId) {
    newState = playCard(state, decision.cardId);
  } else {
    newState = drawCard(state);
  }

  // End the AI's turn if the round hasn't ended
  if (newState.phase === 'playing') {
    newState = endTurn(newState);
  }

  return newState;
}

// Get AI personality message (for fun flavor text)
export function getAIPersonalityMessage(difficulty: AIDifficulty, situation: 'win' | 'lose' | 'play' | 'draw'): string {
  const messages = {
    easy: {
      win: "Lucky me! 🎉",
      lose: "Good game!",
      play: "I'll play this one!",
      draw: "Let me draw a card..."
    },
    medium: {
      win: "Great match!",
      lose: "Well played!",
      play: "Here's my move.",
      draw: "Drawing..."
    },
    hard: {
      win: "Calculated victory.",
      lose: "You played well.",
      play: "Strategic play.",
      draw: "Interesting..."
    }
  };

  return messages[difficulty][situation];
}