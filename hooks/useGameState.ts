'use client';

import { useReducer, useCallback, useEffect, useRef } from 'react';
import { GameState, GameAction } from '@/types';
import {
  createInitialGameState,
  drawCard,
  playCard,
  endTurn,
  shuffleDeck,
  createDeck,
  dealCards
} from '@/lib/game-engine';
import { getAIDecision, AIDifficulty } from '@/lib/ai-player';
import { createPlaceholderGameState } from '@/lib/initial-state';
import { TIMING } from '@/lib/timing';
import { logGameState } from '@/lib/debug-helper';

// Game reducer to handle state transitions
export function gameReducer(state: GameState, action: GameAction): GameState {
  const newState: GameState = (() => {
    switch (action.type) {
      case 'START_GAME':
        return createInitialGameState('Player', action.matchTarget);

    case 'RESTART_GAME': {
      // Start a new round with same players
      const deck = shuffleDeck(createDeck());
      const { playerHands, remainingDeck, discardPile } = dealCards(deck, state.players.length, 5);

      return {
        ...state,
        deck: remainingDeck,
        discardPile,
        players: state.players.map((player, index) => ({
          ...player,
          hand: playerHands[index]
        })),
        currentPlayerIndex: 0,
        phase: 'playing',
        winner: null,
        turnAction: 'draw',
        message: "New round! Your turn.",
        selectedCardId: null
      };
    }

    case 'DRAW_CARD':
      if (state.turnAction !== 'draw' || state.phase !== 'playing') return state;
      return {
        ...drawCard(state),
        selectedCardId: null  // Clear selection on draw
      };

    case 'PLAY_CARD':
      if (state.phase !== 'playing') return state;
      return {
        ...playCard(state, action.cardId),
        selectedCardId: null  // Clear selection after play
      };

    case 'SELECT_CARD':
      // Toggle card selection for two-tap interaction
      if (state.phase !== 'playing') return state;
      return {
        ...state,
        selectedCardId: action.cardId
      };

    case 'END_TURN':
      if (state.phase !== 'playing') return state;
      return {
        ...endTurn(state),
        selectedCardId: null  // Clear selection on turn end
      };

    case 'UPDATE_MESSAGE':
      return {
        ...state,
        message: action.message
      };

      default:
        return state;
    }
  })();

  // Log state changes for debugging
  logGameState(action.type, newState);
  return newState;
}

export function useGameState(aiDifficulty: AIDifficulty = 'easy', matchTarget = 5) {
  const isInitialized = useRef(false);
  const [gameState, dispatch] = useReducer(gameReducer, createPlaceholderGameState());

  // Initialize game after mount to avoid hydration issues
  useEffect(() => {
    if (!isInitialized.current) {
      isInitialized.current = true;
      dispatch({ type: 'START_GAME', matchTarget });
    }
    // matchTarget changes after init are intentionally ignored (isInitialized ref guards re-init).
  }, [matchTarget]);

  // Handle drawing a card
  const handleDrawCard = useCallback(() => {
    if (gameState.turnAction === 'draw' && gameState.phase === 'playing') {
      dispatch({ type: 'DRAW_CARD' });
    }
  }, [gameState.turnAction, gameState.phase]);

  // Handle card selection (for two-tap mobile interaction)
  const handleSelectCard = useCallback((cardId: string | null) => {
    dispatch({ type: 'SELECT_CARD', cardId });
  }, []);

  // Handle playing a card (called on second tap of selected card)
  const handlePlayCard = useCallback((cardId: string) => {
    const currentPlayer = gameState.players[gameState.currentPlayerIndex];

    if (!currentPlayer.isAI && gameState.phase === 'playing') {
      // Check if card can be played first
      const card = currentPlayer.hand.find(c => c.id === cardId);
      const topDiscard = gameState.discardPile[gameState.discardPile.length - 1];

      if (card && topDiscard && card.rank === topDiscard.rank) {
        dispatch({ type: 'PLAY_CARD', cardId });
      }
    }
  }, [gameState]);

  // Handle card tap with two-tap logic
  const handleCardTap = useCallback((cardId: string, isPlayable: boolean) => {
    if (!isPlayable) return;

    // If this card is already selected, play it
    if (gameState.selectedCardId === cardId) {
      handlePlayCard(cardId);
    } else {
      // Otherwise, select this card
      handleSelectCard(cardId);
    }
  }, [gameState.selectedCardId, handlePlayCard, handleSelectCard]);

  // Clear selection when tapping elsewhere
  const handleClearSelection = useCallback(() => {
    if (gameState.selectedCardId) {
      handleSelectCard(null);
    }
  }, [gameState.selectedCardId, handleSelectCard]);

  // Handle starting a new game
  const handleNewGame = useCallback(() => {
    dispatch({ type: 'START_GAME', matchTarget });
  }, [matchTarget]);

  // Handle restarting after a round
  const handleRestartRound = useCallback(() => {
    dispatch({ type: 'RESTART_GAME' });
  }, []);

  // End the turn once the current player's action resolves.
  // Turn advancement has a single source: PLAY_CARD/DRAW_CARD set turnAction
  // to 'waiting', and only this effect dispatches END_TURN.
  useEffect(() => {
    if (gameState.phase !== 'playing' || gameState.turnAction !== 'waiting') return;

    const timer = setTimeout(() => {
      dispatch({ type: 'END_TURN' });
    }, TIMING.endTurnDelay);

    return () => clearTimeout(timer);
  }, [gameState.phase, gameState.turnAction]);

  // Handle AI turns: act only while the AI actually holds a 'draw' action
  useEffect(() => {
    if (gameState.phase !== 'playing' || gameState.turnAction !== 'draw') return;

    const currentPlayer = gameState.players[gameState.currentPlayerIndex];
    if (!currentPlayer || !currentPlayer.isAI) return;

    // Thinking delay for realism
    const timer = setTimeout(() => {
      const decision = getAIDecision(gameState, aiDifficulty);

      if (decision.action === 'play' && decision.cardId) {
        dispatch({ type: 'PLAY_CARD', cardId: decision.cardId });
      } else {
        dispatch({ type: 'DRAW_CARD' });
      }
    }, TIMING.aiThinkDelay);

    // Cleanup timeout on unmount or when dependencies change
    return () => clearTimeout(timer);
  }, [gameState, aiDifficulty]);

  return {
    gameState,
    handleDrawCard,
    handlePlayCard,
    handleCardTap,
    handleSelectCard,
    handleClearSelection,
    handleNewGame,
    handleRestartRound,
    dispatch
  };
}
