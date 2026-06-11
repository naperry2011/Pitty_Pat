import { describe, test, expect } from 'vitest';
import {
  createDeck,
  shuffleDeck,
  dealCards,
  canPlayCard,
  findPlayableCards,
  drawCard,
  playCard,
  endTurn,
  createInitialGameState,
} from './game-engine';
import { Card, GameState, Rank, Suit } from '@/types';

function card(rank: Rank, suit: Suit, faceUp = true): Card {
  return { id: `${rank}-${suit}`, rank, suit, faceUp };
}

function makeState(overrides: Partial<GameState> = {}): GameState {
  return {
    deck: [],
    discardPile: [card('5', 'hearts')],
    players: [
      { id: 'player1', name: 'Player', hand: [], isAI: false, wins: 0 },
      { id: 'ai1', name: 'Computer', hand: [], isAI: true, wins: 0 },
    ],
    currentPlayerIndex: 0,
    phase: 'playing',
    winner: null,
    turnAction: 'draw',
    message: '',
    selectedCardId: null,
    ...overrides,
  };
}

describe('createDeck', () => {
  test('creates 52 unique cards, 13 per suit', () => {
    const deck = createDeck();
    expect(deck).toHaveLength(52);
    expect(new Set(deck.map(c => c.id)).size).toBe(52);
    for (const suit of ['hearts', 'diamonds', 'clubs', 'spades']) {
      expect(deck.filter(c => c.suit === suit)).toHaveLength(13);
    }
  });
});

describe('shuffleDeck', () => {
  test('preserves the card set and does not mutate the input', () => {
    const deck = createDeck();
    const before = deck.map(c => c.id);
    const shuffled = shuffleDeck(deck);
    expect(deck.map(c => c.id)).toEqual(before);
    expect(shuffled.map(c => c.id).sort()).toEqual([...before].sort());
  });
});

describe('dealCards', () => {
  test('deals the requested hands, one discard, and the remainder', () => {
    const { playerHands, remainingDeck, discardPile } = dealCards(createDeck(), 2, 5);
    expect(playerHands).toHaveLength(2);
    expect(playerHands[0]).toHaveLength(5);
    expect(playerHands[1]).toHaveLength(5);
    expect(discardPile).toHaveLength(1);
    expect(discardPile[0].faceUp).toBe(true);
    expect(remainingDeck).toHaveLength(52 - 10 - 1);
  });
});

describe('canPlayCard / findPlayableCards', () => {
  test('matches on rank only', () => {
    expect(canPlayCard(card('5', 'spades'), card('5', 'hearts'))).toBe(true);
    expect(canPlayCard(card('6', 'hearts'), card('5', 'hearts'))).toBe(false);
  });

  test('findPlayableCards returns all rank matches', () => {
    const hand = [card('5', 'spades'), card('6', 'clubs'), card('5', 'diamonds')];
    const playable = findPlayableCards(hand, card('5', 'hearts'));
    expect(playable.map(c => c.id)).toEqual(['5-spades', '5-diamonds']);
  });
});

describe('playCard', () => {
  test('moves a matching card from hand to discard and waits', () => {
    const state = makeState({
      players: [
        { id: 'player1', name: 'Player', hand: [card('5', 'spades'), card('9', 'clubs')], isAI: false, wins: 0 },
        { id: 'ai1', name: 'Computer', hand: [card('2', 'clubs')], isAI: true, wins: 0 },
      ],
    });
    const next = playCard(state, '5-spades');
    expect(next.players[0].hand.map(c => c.id)).toEqual(['9-clubs']);
    expect(next.discardPile[next.discardPile.length - 1].id).toBe('5-spades');
    expect(next.turnAction).toBe('waiting');
    expect(next.phase).toBe('playing');
  });

  test('rejects a non-matching card without changing hands', () => {
    const state = makeState({
      players: [
        { id: 'player1', name: 'Player', hand: [card('9', 'clubs')], isAI: false, wins: 0 },
        { id: 'ai1', name: 'Computer', hand: [], isAI: true, wins: 0 },
      ],
    });
    const next = playCard(state, '9-clubs');
    expect(next.players[0].hand).toHaveLength(1);
    expect(next.discardPile).toHaveLength(1);
  });

  test('emptying the hand wins the round and increments wins', () => {
    const state = makeState({
      players: [
        { id: 'player1', name: 'Player', hand: [card('5', 'spades')], isAI: false, wins: 2 },
        { id: 'ai1', name: 'Computer', hand: [card('2', 'clubs')], isAI: true, wins: 0 },
      ],
    });
    const next = playCard(state, '5-spades');
    expect(next.phase).toBe('roundEnd');
    expect(next.winner).toBe('player1');
    expect(next.players[0].wins).toBe(3);
  });
});

describe('drawCard', () => {
  test('auto-plays a drawn card that matches the discard', () => {
    const state = makeState({ deck: [card('5', 'clubs', false)] });
    const next = drawCard(state);
    expect(next.deck).toHaveLength(0);
    expect(next.discardPile[next.discardPile.length - 1].id).toBe('5-clubs');
    expect(next.turnAction).toBe('waiting');
  });

  test('discards a drawn card that does not match', () => {
    const state = makeState({ deck: [card('K', 'clubs', false)] });
    const next = drawCard(state);
    expect(next.discardPile[next.discardPile.length - 1].id).toBe('K-clubs');
    expect(next.turnAction).toBe('waiting');
  });

  test('reshuffles an empty deck and still draws a card for the player', () => {
    // BUG-004: the reshuffle path must not consume the turn without a draw.
    const state = makeState({
      deck: [],
      discardPile: [
        card('9', 'clubs'),
        card('K', 'diamonds'),
        card('3', 'spades'), // top card stays
      ],
    });
    const next = drawCard(state);
    // Top discard before the draw was 3-spades; the two below it become the new stock.
    // One card must have been drawn: stock shrinks to 1 and the discard grows.
    expect(next.deck).toHaveLength(1);
    expect(next.discardPile.length).toBe(2);
    expect(next.discardPile[0].id).toBe('3-spades');
    expect(next.turnAction).toBe('waiting');
  });
});

describe('endTurn', () => {
  test('advances to the next player', () => {
    const state = makeState({ turnAction: 'waiting' });
    const next = endTurn(state);
    expect(next.currentPlayerIndex).toBe(1);
  });

  test('gives every next player a draw action, including the AI', () => {
    // New sequencing contract: the AI turn is gated on turnAction === 'draw',
    // so endTurn must hand the AI a real action instead of 'waiting'.
    const toAI = endTurn(makeState({ currentPlayerIndex: 0, turnAction: 'waiting' }));
    expect(toAI.turnAction).toBe('draw');
    const toHuman = endTurn(makeState({ currentPlayerIndex: 1, turnAction: 'waiting' }));
    expect(toHuman.turnAction).toBe('draw');
  });
});

describe('createInitialGameState', () => {
  test('deals 5 cards each, one discard, human starts with a draw action', () => {
    const state = createInitialGameState('Tester');
    expect(state.players[0].hand).toHaveLength(5);
    expect(state.players[1].hand).toHaveLength(5);
    expect(state.discardPile).toHaveLength(1);
    expect(state.deck).toHaveLength(41);
    expect(state.currentPlayerIndex).toBe(0);
    expect(state.turnAction).toBe('draw');
    expect(state.phase).toBe('playing');
  });
});
