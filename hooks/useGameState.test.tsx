import { describe, test, expect, beforeEach, afterEach, vi } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useGameState } from './useGameState';
import * as aiPlayer from '@/lib/ai-player';

vi.mock('@/lib/ai-player', async (importOriginal) => {
  const mod = await importOriginal<typeof import('@/lib/ai-player')>();
  return { ...mod, getAIDecision: vi.fn(mod.getAIDecision) };
});

// Math.random() === 0.99 makes the Fisher-Yates shuffle an identity permutation,
// so the deal is deterministic: player gets A-5 of hearts, AI gets 6-10 of hearts,
// the first discard is J of hearts, and the stock starts Q-hearts, K-hearts, A-diamonds...
beforeEach(() => {
  vi.useFakeTimers();
  vi.spyOn(Math, 'random').mockReturnValue(0.99);
});

afterEach(() => {
  vi.runOnlyPendingTimers();
  vi.useRealTimers();
  vi.restoreAllMocks();
});

describe('useGameState', () => {
  test('initializes the game after mount', () => {
    const { result } = renderHook(() => useGameState('easy'));
    expect(result.current.gameState.phase).toBe('playing');
    expect(result.current.gameState.players[0].hand).toHaveLength(5);
    expect(result.current.gameState.players[1].hand).toHaveLength(5);
    expect(result.current.gameState.turnAction).toBe('draw');
  });

  test('passes the match target into the initial game state', () => {
    const { result } = renderHook(() => useGameState('easy', 3));
    expect(result.current.gameState.matchTarget).toBe(3);
  });

  test('handleNewGame resets wins for a rematch', () => {
    const { result } = renderHook(() => useGameState('easy', 3));
    act(() => { result.current.handleNewGame(); });
    expect(result.current.gameState.players[0].wins).toBe(0);
  });

  test('AI turns are decided by getAIDecision with the configured difficulty', () => {
    const { result } = renderHook(() => useGameState('hard'));

    // Human draws (Q-hearts, no match with J-hearts, discarded), then the turn
    // passes to the AI and the AI takes its move.
    act(() => {
      result.current.handleDrawCard();
    });
    act(() => {
      vi.advanceTimersByTime(600); // end of human turn
    });
    expect(result.current.gameState.currentPlayerIndex).toBe(1);
    act(() => {
      vi.advanceTimersByTime(1300); // AI thinking delay
    });

    expect(aiPlayer.getAIDecision).toHaveBeenCalled();
    expect(vi.mocked(aiPlayer.getAIDecision).mock.calls[0][1]).toBe('hard');
  });

  test('a full draw cycle passes the turn to the AI exactly once and back', () => {
    const { result } = renderHook(() => useGameState('easy'));

    // Human draws Q-hearts (no match against J-hearts): hand unchanged, card discarded.
    act(() => {
      result.current.handleDrawCard();
    });
    expect(result.current.gameState.players[0].hand).toHaveLength(5);
    expect(result.current.gameState.discardPile).toHaveLength(2);
    expect(result.current.gameState.turnAction).toBe('waiting');

    // Turn passes to the AI.
    act(() => {
      vi.advanceTimersByTime(600);
    });
    expect(result.current.gameState.currentPlayerIndex).toBe(1);

    // AI draws K-hearts (no match against Q-hearts) and the turn comes back.
    act(() => {
      vi.advanceTimersByTime(1300);
    });
    expect(result.current.gameState.discardPile).toHaveLength(3);
    expect(result.current.gameState.players[1].hand).toHaveLength(5);
    act(() => {
      vi.advanceTimersByTime(600);
    });
    expect(result.current.gameState.currentPlayerIndex).toBe(0);
    expect(result.current.gameState.turnAction).toBe('draw');

    // Exactly one draw each: 41 - 2 = 39 cards left in the stock.
    expect(result.current.gameState.deck).toHaveLength(39);
  });
});
