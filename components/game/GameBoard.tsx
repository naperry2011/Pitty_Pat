'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useGameState } from '@/hooks/useGameState';
import Hand from './Hand';
import Deck from './Deck';
import DiscardPile from './DiscardPile';
import CardStyleSelector from './CardStyleSelector';
import { findPlayableCards } from '@/lib/game-engine';
import { GameSettings } from '@/lib/settings';
import clsx from 'clsx';

// Confetti component for win celebration
// Piece attributes derive deterministically from the index so render stays pure.
function Confetti() {
  const colors = ['#FF6B6B', '#FFE66D', '#4ECDC4', '#DDA0DD', '#5F7ADB', '#FF9F43'];
  const pieces = Array.from({ length: 50 }, (_, i) => ({
    id: i,
    left: (i * 137) % 100,
    delay: ((i * 31) % 20) / 10,
    color: colors[i % colors.length],
    size: 8 + ((i * 97) % 9)
  }));

  return (
    <div className="confetti-container">
      {pieces.map(piece => (
        <div
          key={piece.id}
          className="confetti-piece"
          style={{
            left: `${piece.left}%`,
            backgroundColor: piece.color,
            width: piece.size,
            height: piece.size,
            animationDelay: `${piece.delay}s`,
            borderRadius: piece.id % 2 === 0 ? '50%' : '2px'
          }}
        />
      ))}
    </div>
  );
}

// Round-win pips: one dot per round needed, filled per wins so far.
function WinPips({ wins, target, filledClass }: { wins: number; target: number; filledClass: string }) {
  return (
    <span className="flex gap-0.5" aria-label={`${wins} of ${target} rounds won`}>
      {Array.from({ length: target }, (_, i) => (
        <span
          key={i}
          className={clsx(
            'inline-block w-2 h-2 rounded-full',
            i < wins ? filledClass : 'bg-gray-300'
          )}
        />
      ))}
    </span>
  );
}

interface GameBoardProps {
  settings: GameSettings;
  onChangeSettings: () => void;
}

export default function GameBoard({ settings, onChangeSettings }: GameBoardProps) {
  const {
    gameState,
    handleDrawCard,
    handleCardTap,
    handleClearSelection,
    handleNewGame,
    handleRestartRound
  } = useGameState(settings.difficulty, settings.matchTarget);
  const [showInstructions, setShowInstructions] = useState(false);
  const [showConfetti, setShowConfetti] = useState(false);

  const currentPlayer = gameState.players[gameState.currentPlayerIndex];
  const humanPlayer = gameState.players.find(p => !p.isAI);
  const aiPlayer = gameState.players.find(p => p.isAI);
  const topDiscard = gameState.discardPile[gameState.discardPile.length - 1];

  const playableCards = humanPlayer && topDiscard
    ? findPlayableCards(humanPlayer.hand, topDiscard)
    : [];

  const isPlayerTurn = currentPlayer && !currentPlayer.isAI;
  const canDraw = isPlayerTurn && gameState.turnAction === 'draw';
  const canPlay = isPlayerTurn && playableCards.length > 0;

  // Show confetti on win
  useEffect(() => {
    if (gameState.phase === 'roundEnd' && gameState.winner === humanPlayer?.id) {
      // Reacting to a game-state transition; the timeout below clears it again.
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setShowConfetti(true);
      const timer = setTimeout(() => setShowConfetti(false), 3000);
      return () => clearTimeout(timer);
    }
  }, [gameState.phase, gameState.winner, humanPlayer?.id]);

  // Show loading state while game initializes
  if (gameState.phase === 'waiting' && gameState.deck.length === 0) {
    return (
      <div className="min-h-screen flex items-center justify-center playful-bg">
        <div className="text-gray-600 text-2xl animate-pulse flex items-center gap-3">
          <span className="text-4xl">🎴</span>
          <span>Starting game...</span>
        </div>
      </div>
    );
  }

  return (
    <div
      className="min-h-screen playful-bg relative overflow-hidden no-select"
      onClick={handleClearSelection}
    >
      {/* Confetti celebration */}
      {showConfetti && <Confetti />}

      {/* Match over overlay */}
      {gameState.phase === 'gameEnd' && (
        <div
          className="fixed inset-0 z-50 bg-black/60 flex items-center justify-center px-4"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="bg-white rounded-3xl shadow-playful p-6 sm:p-8 max-w-sm w-full flex flex-col items-center gap-5 animate-pop">
            <h2 className="text-2xl sm:text-3xl font-black text-center text-gray-800">
              {gameState.winner === humanPlayer?.id
                ? 'You win the match! 🏆'
                : 'Computer wins the match! 🤖'}
            </h2>

            {/* Final pip score */}
            <div className="flex gap-4">
              <div className="flex flex-col items-center gap-1.5">
                <span className="text-coral font-bold text-sm">You</span>
                <WinPips wins={humanPlayer?.wins || 0} target={gameState.matchTarget} filledClass="bg-coral" />
              </div>
              <div className="flex flex-col items-center gap-1.5">
                <span className="text-suit-spades font-bold text-sm">CPU</span>
                <WinPips wins={aiPlayer?.wins || 0} target={gameState.matchTarget} filledClass="bg-slate-600" />
              </div>
            </div>

            <div className="flex flex-col gap-3 w-full items-center">
              <button
                onClick={handleNewGame}
                className="btn-playful text-lg touch-target"
              >
                Rematch 🔄
              </button>
              <button
                onClick={onChangeSettings}
                className="bg-white/80 text-gray-700 font-bold px-6 py-2.5 rounded-2xl shadow-soft active:scale-95 transition-transform touch-target"
              >
                Change settings
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Main Content - Mobile-first stacked layout */}
      <div className="max-w-lg mx-auto flex flex-col min-h-screen px-3 py-4 safe-area-top safe-area-bottom">

        {/* Header: Home + Title + Score */}
        <div className="flex items-center justify-between mb-4">
          {/* Home Button */}
          <Link
            href="/"
            className="w-10 h-10 bg-white/80 backdrop-blur-sm rounded-xl shadow-soft flex items-center justify-center text-xl active:scale-95 transition-transform"
            onClick={(e) => e.stopPropagation()}
          >
            🏠
          </Link>

          {/* Title */}
          <h1 className="text-2xl sm:text-3xl font-black text-transparent bg-clip-text bg-gradient-to-r from-coral to-soft-purple">
            Pitty Pat
          </h1>

          {/* Compact Score with round-win pips */}
          <div className="flex gap-2">
            <div className="bg-white/80 backdrop-blur-sm px-3 py-1.5 rounded-xl shadow-soft flex flex-col items-center gap-1">
              <span className="text-coral font-bold text-xs leading-none">You</span>
              <WinPips wins={humanPlayer?.wins || 0} target={gameState.matchTarget} filledClass="bg-coral" />
            </div>
            <div className="bg-white/80 backdrop-blur-sm px-3 py-1.5 rounded-xl shadow-soft flex flex-col items-center gap-1">
              <span className="text-suit-spades font-bold text-xs leading-none">CPU</span>
              <WinPips wins={aiPlayer?.wins || 0} target={gameState.matchTarget} filledClass="bg-slate-600" />
            </div>
          </div>
        </div>

        {/* Game Status Message */}
        <div className="mb-3 min-h-[44px] flex items-center justify-center">
          {gameState.phase === 'roundEnd' && gameState.winner ? (
            <div className={clsx(
              "px-6 py-2.5 rounded-2xl shadow-lg win-bounce",
              gameState.winner === humanPlayer?.id
                ? "bg-gradient-to-r from-mint to-suit-clubs text-white"
                : "bg-gradient-to-r from-soft-purple to-suit-spades text-white"
            )}>
              <div className="text-xl sm:text-2xl font-bold flex items-center gap-2">
                {gameState.winner === humanPlayer?.id
                  ? <>Great job! You win! 🎉</>
                  : <>Computer wins! 🤖</>
                }
              </div>
            </div>
          ) : (
            <div className="bg-white/70 backdrop-blur-sm px-4 py-2 rounded-full shadow-soft">
              <div className="text-gray-700 text-base font-medium">
                {gameState.message}
              </div>
            </div>
          )}
        </div>

        {/* AI Hand (top) */}
        <div className="mb-3">
          <div className={clsx(
            "text-center mb-2 font-bold text-sm transition-all duration-300",
            currentPlayer?.isAI ? "text-suit-spades scale-105" : "text-gray-500"
          )}>
            Computer {currentPlayer?.isAI && <span className="animate-pulse">🤔</span>}
          </div>
          <div className="flex justify-center">
            {aiPlayer && (
              <Hand
                cards={aiPlayer.hand}
                isPlayerHand={false}
                disabled
              />
            )}
          </div>
        </div>

        {/* Game Table - Deck & Discard */}
        <div
          className="flex-1 game-table rounded-3xl p-4 sm:p-6 mb-3 flex flex-col items-center justify-center"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Deck and Discard */}
          <div className="flex justify-center items-start gap-8 sm:gap-12 mb-4">
            <div className="flex flex-col items-center">
              <div className="text-gray-500 text-xs font-semibold uppercase tracking-wider mb-2">
                Draw
              </div>
              <Deck
                cardCount={gameState.deck.length}
                onClick={canDraw ? handleDrawCard : undefined}
                disabled={!canDraw}
              />
            </div>

            <div className="flex flex-col items-center">
              <div className="text-gray-500 text-xs font-semibold uppercase tracking-wider mb-2">
                Discard
              </div>
              <DiscardPile cards={gameState.discardPile} />
            </div>
          </div>

          {/* Action Hint */}
          {isPlayerTurn && gameState.phase === 'playing' && (
            <div className="mt-2">
              <div className={clsx(
                "px-4 py-2 rounded-full text-white text-sm font-bold shadow-playful",
                canPlay ? "bg-gradient-to-r from-coral to-suit-hearts" : "bg-gradient-to-r from-mint to-suit-clubs"
              )}>
                {canPlay ? (
                  <span className="flex items-center gap-2">
                    <span>Tap a matching card!</span>
                    <span className="animate-bounce">👇</span>
                  </span>
                ) : canDraw ? (
                  <span className="flex items-center gap-2">
                    <span>Tap deck to draw</span>
                    <span className="animate-pulse">👆</span>
                  </span>
                ) : null}
              </div>
            </div>
          )}
        </div>

        {/* Player Hand (bottom) */}
        <div className="mb-3">
          <div className={clsx(
            "text-center mb-2 font-bold text-sm transition-all duration-300",
            isPlayerTurn ? "text-coral scale-105" : "text-gray-500"
          )}>
            Your Hand {isPlayerTurn && <span>✨</span>}
          </div>
          <div className="flex justify-center" onClick={(e) => e.stopPropagation()}>
            {humanPlayer && (
              <Hand
                cards={humanPlayer.hand}
                onCardTap={isPlayerTurn ? handleCardTap : undefined}
                isPlayerHand
                playableCardIds={playableCards.map(c => c.id)}
                selectedCardId={gameState.selectedCardId}
              />
            )}
          </div>
        </div>

        {/* Restart Button */}
        {gameState.phase === 'roundEnd' && (
          <div className="flex justify-center mb-4">
            <button
              onClick={handleRestartRound}
              className="btn-playful text-lg touch-target"
            >
              Play Again! 🎮
            </button>
          </div>
        )}

        {/* Collapsible Footer: Instructions + Card Style */}
        <div className="mt-auto">
          <button
            onClick={() => setShowInstructions(!showInstructions)}
            className="w-full bg-white/50 backdrop-blur-sm rounded-xl px-4 py-2.5 flex items-center justify-between touch-target"
          >
            <span className="text-gray-600 font-medium text-sm">
              {showInstructions ? 'Hide' : 'Show'} Help & Settings
            </span>
            <span className={clsx(
              "text-gray-400 transition-transform duration-200",
              showInstructions && "rotate-180"
            )}>
              ▼
            </span>
          </button>

          {showInstructions && (
            <div className="mt-3 space-y-3 animate-pop">
              {/* How to Play */}
              <div className="bg-white/80 backdrop-blur-sm rounded-2xl p-4 shadow-soft">
                <h3 className="text-gray-700 font-bold text-sm mb-2">How to Play</h3>
                <div className="text-gray-600 text-xs space-y-1.5">
                  <div className="flex items-start gap-2">
                    <span className="text-coral">●</span>
                    <span>Match the rank of the top discard card</span>
                  </div>
                  <div className="flex items-start gap-2">
                    <span className="text-sunny">●</span>
                    <span>No match? Draw from the deck</span>
                  </div>
                  <div className="flex items-start gap-2">
                    <span className="text-mint">●</span>
                    <span>First to empty your hand wins!</span>
                  </div>
                </div>
              </div>

              {/* Card Style Selector */}
              <CardStyleSelector />
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
