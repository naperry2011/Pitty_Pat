import 'dart:math';

import 'game_engine.dart';
import 'models.dart';

// Port of lib/ai-player.ts. UI labels: easy = Chill, medium = Clever, hard = Sharp.
enum AIDifficulty { easy, medium, hard }

sealed class AIDecision {
  const AIDecision();
}

class AIPlay extends AIDecision {
  const AIPlay(this.cardId);
  final String cardId;

  @override
  bool operator ==(Object other) => other is AIPlay && other.cardId == cardId;

  @override
  int get hashCode => cardId.hashCode;
}

class AIDraw extends AIDecision {
  const AIDraw();

  @override
  bool operator ==(Object other) => other is AIDraw;

  @override
  int get hashCode => 0;
}

// Playing a match is always the best move: it sheds a card, while drawing never
// does. Every playable card shares the top discard's rank, so which one is played
// doesn't matter either. Difficulty is therefore how often the AI overlooks a
// match it holds (it draws instead).
const missChanceByDifficulty = {
  AIDifficulty.easy: 0.35,
  AIDifficulty.medium: 0.12,
  AIDifficulty.hard: 0.0,
};

// [missChance] overrides the difficulty's rate (app-only opponent play styles).
AIDecision getAIDecision(GameState state, AIDifficulty difficulty, [Random? random, double? missChance]) {
  final currentPlayer = state.currentPlayer;

  if (!currentPlayer.isAI) {
    throw StateError('Current player is not an AI');
  }

  final playableCards = findPlayableCards(currentPlayer.hand, state.topDiscard);

  if (playableCards.isEmpty) return const AIDraw();

  final chance = missChance ?? missChanceByDifficulty[difficulty]!;
  if (chance > 0 && (random ?? Random()).nextDouble() < chance) return const AIDraw();

  return AIPlay(playableCards.first.id);
}
