import { Card, Suit, Rank, GameState, Player } from '@/types';

const SUITS: Suit[] = ['hearts', 'diamonds', 'clubs', 'spades'];
const RANKS: Rank[] = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];

// Create a standard 52-card deck
export function createDeck(): Card[] {
  const deck: Card[] = [];
  for (const suit of SUITS) {
    for (const rank of RANKS) {
      deck.push({
        id: `${rank}-${suit}`,
        suit,
        rank,
        faceUp: false
      });
    }
  }
  return deck;
}

// Fisher-Yates shuffle algorithm
export function shuffleDeck(deck: Card[]): Card[] {
  const shuffled = [...deck];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }
  return shuffled;
}

// Deal cards to players
export function dealCards(deck: Card[], numPlayers: number, cardsPerPlayer: number): {
  playerHands: Card[][];
  remainingDeck: Card[];
  discardPile: Card[];
} {
  const playerHands: Card[][] = [];
  let currentDeck = [...deck];

  // Deal cards to each player
  for (let i = 0; i < numPlayers; i++) {
    const hand = currentDeck.splice(0, cardsPerPlayer).map(card => ({
      ...card,
      faceUp: true // Cards in hand are face up for the owner
    }));
    playerHands.push(hand);
  }

  // Start discard pile with one card face up
  const discardPile = [{ ...currentDeck.shift()!, faceUp: true }];

  return {
    playerHands,
    remainingDeck: currentDeck,
    discardPile
  };
}

// Check if a card can be played (matches rank of top discard)
export function canPlayCard(card: Card, topDiscard: Card): boolean {
  return card.rank === topDiscard.rank;
}

// Find all playable cards in a hand
export function findPlayableCards(hand: Card[], topDiscard: Card): Card[] {
  return hand.filter(card => canPlayCard(card, topDiscard));
}

// Draw a card from the deck
export function drawCard(state: GameState): GameState {
  if (state.deck.length === 0) {
    // Reshuffle discard pile if deck is empty (keep top card)
    if (state.discardPile.length <= 1) {
      // No cards to reshuffle
      return state;
    }

    const topCard = state.discardPile[state.discardPile.length - 1];
    const cardsToShuffle = state.discardPile.slice(0, -1).map(card => ({
      ...card,
      faceUp: false
    }));
    const reshuffled = shuffleDeck(cardsToShuffle);

    return {
      ...state,
      deck: reshuffled,
      discardPile: [topCard]
    };
  }

  const drawnCard = { ...state.deck[0], faceUp: true };
  const newDeck = state.deck.slice(1);
  const currentPlayer = state.players[state.currentPlayerIndex];

  // Check if drawn card matches top discard
  const topDiscard = state.discardPile[state.discardPile.length - 1];

  if (canPlayCard(drawnCard, topDiscard)) {
    // Auto-play the matching card
    return {
      ...state,
      deck: newDeck,
      discardPile: [...state.discardPile, drawnCard],
      turnAction: 'waiting',
      message: `${currentPlayer.name} drew and played a ${drawnCard.rank}!`
    };
  } else {
    // Discard the drawn card immediately (classic Pitty Pat rule)
    // The drawn card doesn't match, so it goes straight to the discard pile
    return {
      ...state,
      deck: newDeck,
      discardPile: [...state.discardPile, drawnCard],
      turnAction: 'waiting',
      message: `${currentPlayer.name} drew and discarded a ${drawnCard.rank}`
    };
  }
}

// Play a card from hand
export function playCard(state: GameState, cardId: string): GameState {
  const currentPlayer = state.players[state.currentPlayerIndex];
  const cardIndex = currentPlayer.hand.findIndex(c => c.id === cardId);

  if (cardIndex === -1) {
    return state; // Card not found
  }

  const card = currentPlayer.hand[cardIndex];
  const topDiscard = state.discardPile[state.discardPile.length - 1];

  if (!canPlayCard(card, topDiscard)) {
    return {
      ...state,
      message: "That card doesn't match the rank!"
    };
  }

  // Remove card from hand
  const newHand = [...currentPlayer.hand];
  newHand.splice(cardIndex, 1);

  // Update player's hand
  const updatedPlayers = state.players.map((player, index) =>
    index === state.currentPlayerIndex
      ? { ...player, hand: newHand }
      : player
  );

  // Check for win
  if (newHand.length === 0) {
    const winner = {
      ...currentPlayer,
      hand: newHand,
      wins: currentPlayer.wins + 1
    };
    return {
      ...state,
      players: updatedPlayers.map(p => p.id === winner.id ? winner : p),
      discardPile: [...state.discardPile, card],
      phase: 'roundEnd',
      winner: winner.id,
      message: `${winner.name} wins the round!`
    };
  }

  // Continue game
  return {
    ...state,
    players: updatedPlayers,
    discardPile: [...state.discardPile, card],
    turnAction: 'waiting',
    message: `${currentPlayer.name} played a ${card.rank}`
  };
}

// End current turn and move to next player
export function endTurn(state: GameState): GameState {
  const nextPlayerIndex = (state.currentPlayerIndex + 1) % state.players.length;
  const nextPlayer = state.players[nextPlayerIndex];

  return {
    ...state,
    currentPlayerIndex: nextPlayerIndex,
    turnAction: nextPlayer.isAI ? 'waiting' : 'draw',
    message: `${nextPlayer.name}'s turn`
  };
}

// Get card display string (for debugging/logs)
export function getCardDisplay(card: Card): string {
  const suitSymbols = {
    hearts: '♥️',
    diamonds: '♦️',
    clubs: '♣️',
    spades: '♠️'
  };
  return `${card.rank}${suitSymbols[card.suit]}`;
}

// Create initial game state
export function createInitialGameState(playerName: string = 'Player'): GameState {
  const deck = shuffleDeck(createDeck());
  const { playerHands, remainingDeck, discardPile } = dealCards(deck, 2, 5);

  const players: Player[] = [
    {
      id: 'player1',
      name: playerName,
      hand: playerHands[0],
      isAI: false,
      wins: 0
    },
    {
      id: 'ai1',
      name: 'Computer',
      hand: playerHands[1],
      isAI: true,
      wins: 0
    }
  ];

  return {
    deck: remainingDeck,
    discardPile,
    players,
    currentPlayerIndex: 0,
    phase: 'playing',
    winner: null,
    turnAction: 'draw',
    message: "Game started! Your turn.",
    selectedCardId: null
  };
}