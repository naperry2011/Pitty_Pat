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

AIDecision getAIDecision(GameState state, AIDifficulty difficulty, [Random? random]) {
  final currentPlayer = state.currentPlayer;

  if (!currentPlayer.isAI) {
    throw StateError('Current player is not an AI');
  }

  final rng = random ?? Random();
  final playableCards = findPlayableCards(currentPlayer.hand, state.topDiscard);

  if (playableCards.isEmpty) return const AIDraw();

  final cardToPlay = switch (difficulty) {
    AIDifficulty.easy => playableCards.first,
    AIDifficulty.medium => playableCards[rng.nextInt(playableCards.length)],
    AIDifficulty.hard => _selectStrategicCard(playableCards, currentPlayer.hand, rng),
  };

  return AIPlay(cardToPlay.id);
}

// Prefer playing from a duplicated rank so a single copy stays for flexibility.
PlayingCard _selectStrategicCard(List<PlayingCard> playable, List<PlayingCard> hand, Random rng) {
  final rankCounts = <Rank, int>{};
  for (final card in hand) {
    rankCounts[card.rank] = (rankCounts[card.rank] ?? 0) + 1;
  }

  for (final card in playable) {
    if ((rankCounts[card.rank] ?? 0) > 1) return card;
  }

  return playable[rng.nextInt(playable.length)];
}
