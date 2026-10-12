import { describe, test, expect, afterEach, vi } from 'vitest';
import { getAIDecision, MISS_CHANCE } from './ai-player';
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
    matchTarget: 5,
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

  const matchState = () =>
    aiTurnState(
      [card('5', 'clubs'), card('5', 'diamonds'), card('9', 'hearts')],
      card('5', 'spades')
    );

  test('plays a matching card when the miss roll fails', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0.99);
    for (const d of ['easy', 'medium', 'hard'] as const) {
      expect(getAIDecision(matchState(), d)).toEqual({ action: 'play', cardId: '5-clubs' });
    }
  });

  test('easy and medium sometimes overlook a match and draw', () => {
    const random = vi.spyOn(Math, 'random');
    random.mockReturnValue(0.3);
    expect(getAIDecision(matchState(), 'easy')).toEqual({ action: 'draw' });
    random.mockReturnValue(0.1);
    expect(getAIDecision(matchState(), 'medium')).toEqual({ action: 'draw' });
    random.mockReturnValue(0.2);
    expect(getAIDecision(matchState(), 'medium')).toEqual({ action: 'play', cardId: '5-clubs' });
  });

  test('hard never misses a match', () => {
    vi.spyOn(Math, 'random').mockReturnValue(0);
    expect(getAIDecision(matchState(), 'hard')).toEqual({ action: 'play', cardId: '5-clubs' });
  });

  test('miss rates rank the difficulties', () => {
    expect(MISS_CHANCE.easy).toBeGreaterThan(MISS_CHANCE.medium);
    expect(MISS_CHANCE.medium).toBeGreaterThan(MISS_CHANCE.hard);
  });

  test('throws if the current player is not an AI', () => {
    const state = aiTurnState([card('5', 'clubs')], card('5', 'spades'));
    expect(() => getAIDecision({ ...state, currentPlayerIndex: 0 }, 'easy')).toThrow();
  });
});
