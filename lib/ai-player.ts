import { GameState, Card } from '@/types';
import { findPlayableCards, drawCard, playCard, endTurn } from './game-engine';

// AI difficulty levels
export type AIDifficulty = 'easy' | 'medium' | 'hard';

interface AIDecision {
  action: 'play' | 'draw';
  cardId?: string;
}

// Get AI decision based on current game state
export function getAIDecision(state: GameState, difficulty: AIDifficulty = 'easy'): AIDecision {
  const currentPlayer = state.players[state.currentPlayerIndex];

  if (!currentPlayer.isAI) {
    throw new Error('Current player is not an AI');
  }

  const topDiscard = state.discardPile[state.discardPile.length - 1];
  const playableCards = findPlayableCards(currentPlayer.hand, topDiscard);

  if (playableCards.length > 0) {
    // AI has matching cards
    let cardToPlay: Card;

    switch (difficulty) {
      case 'easy':
        // Easy AI: Always plays the first matching card
        cardToPlay = playableCards[0];
        break;

      case 'medium':
        // Medium AI: Randomly chooses from matching cards
        cardToPlay = playableCards[Math.floor(Math.random() * playableCards.length)];
        break;

      case 'hard':
        // Hard AI: Strategic play (save certain cards, play others first)
        // For Pitty Pat, strategy is limited, so we'll play randomly but with slight preference
        // In a more complex version, could track opponent's cards
        cardToPlay = selectStrategicCard(playableCards, currentPlayer.hand);
        break;

      default:
        cardToPlay = playableCards[0];
    }

    return {
      action: 'play',
      cardId: cardToPlay.id
    };
  }

  // No matching cards, must draw
  return {
    action: 'draw'
  };
}

// Strategic card selection for hard AI
function selectStrategicCard(playableCards: Card[], hand: Card[]): Card {
  // Simple strategy: If we have multiple of the same rank, keep one for flexibility
  const rankCounts = new Map<string, number>();

  hand.forEach(card => {
    rankCounts.set(card.rank, (rankCounts.get(card.rank) || 0) + 1);
  });

  // Prefer to play cards we have duplicates of
  for (const card of playableCards) {
    if ((rankCounts.get(card.rank) || 0) > 1) {
      return card;
    }
  }

  // Otherwise, play random
  return playableCards[Math.floor(Math.random() * playableCards.length)];
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