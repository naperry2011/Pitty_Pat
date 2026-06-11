import { describe, test, expect, afterEach, vi } from 'vitest';
import { getAIDecision } from './ai-player';
import { Card, GameState, Rank, Suit } from '@/types';

function card(rank: Rank, suit: Suit): Card {
  return { id: `${rank}-${suit}`, rank, suit, faceUp: true };
}

function aiTurnState(aiHand: Card[], topDiscard: Card): GameState {
  return {
    deck: [],
    discardPile: [topDiscard],
    players: [
      { id: 'player1', name: 'Player', hand: [], isAI: false, wins: 0 },
      { id: 'ai1', name: 'Computer', hand: aiHand, isAI: true, wins: 0 },
    ],
    currentPlayerIndex: 1,
    phase: 'playing',
    winner: null,
    turnAction: 'draw',
    message: '',
    selectedCardId: null,
  };
}

afterEach(() => {
  vi.restoreAllMocks();
});

describe('getAIDecision', () => {
  test('draws when no card matches', () => {
    const state = aiTurnState([card('2', 'clubs'), card('9', 'hearts')], card('5', 'spades'));
    expect(getAIDecision(state, 'easy')).toEqual({ action: 'draw' });
  });

  test('easy difficulty plays the first matching card', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0.99);
    const state = aiTurnState(
      [card('5', 'clubs'), card('5', 'diamonds'), card('9', 'hearts')],
      card('5', 'spades')
    );
    const decision = getAIDecision(state, 'easy');
    expect(decision).toEqual({ action: 'play', cardId: '5-clubs' });
  });

  test('medium difficulty plays a random matching card', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0.99);
    const state = aiTurnState(
      [card('5', 'clubs'), card('5', 'diamonds'), card('9', 'hearts')],
      card('5', 'spades')
    );
    const decision = getAIDecision(state, 'medium');
    expect(decision).toEqual({ action: 'play', cardId: '5-diamonds' });
  });

  test('hard difficulty prefers playing from a duplicated rank', () => {
    const state = aiTurnState(
      [card('5', 'clubs'), card('9', 'diamonds'), card('9', 'hearts')],
      card('9', 'spades')
    );
    const decision = getAIDecision(state, 'hard');
    expect(decision.action).toBe('play');
    expect(['9-diamonds', '9-hearts']).toContain(decision.cardId);
  });

  test('throws if the current player is not an AI', () => {
    const state = aiTurnState([card('5', 'clubs')], card('5', 'spades'));
    expect(() => getAIDecision({ ...state, currentPlayerIndex: 0 }, 'easy')).toThrow();
  });
});
