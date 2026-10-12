import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/game/models.dart';

import 'test_helpers.dart';

GameState aiTurnState(List<PlayingCard> aiHand, PlayingCard topDiscard) => makeState(
      discardPile: [topDiscard],
      currentPlayerIndex: 1,
      players: [
        const Player(id: 'player1', name: 'Player', hand: [], isAI: false),
        Player(id: 'ai1', name: 'Computer', hand: aiHand, isAI: true),
      ],
    );

class _FixedDouble implements Random {
  _FixedDouble(this.value);
  final double value;

  @override
  double nextDouble() => value;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => true;
}

void main() {
  group('getAIDecision', () {
    test('draws when no card matches', () {
      final state = aiTurnState(
        [card(Rank.two, Suit.clubs), card(Rank.nine, Suit.hearts)],
        card(Rank.five, Suit.spades),
      );
      expect(getAIDecision(state, AIDifficulty.easy), const AIDraw());
    });

    final matchState = aiTurnState(
      [card(Rank.five, Suit.clubs), card(Rank.five, Suit.diamonds), card(Rank.nine, Suit.hearts)],
      card(Rank.five, Suit.spades),
    );

    test('plays a matching card when the miss roll fails', () {
      for (final d in AIDifficulty.values) {
        expect(getAIDecision(matchState, d, MaxRandom()), const AIPlay('5-clubs'));
      }
    });

    test('easy and medium sometimes overlook a match and draw', () {
      expect(getAIDecision(matchState, AIDifficulty.easy, _FixedDouble(0.3)), const AIDraw());
      expect(getAIDecision(matchState, AIDifficulty.medium, _FixedDouble(0.1)), const AIDraw());
      expect(getAIDecision(matchState, AIDifficulty.medium, _FixedDouble(0.2)), const AIPlay('5-clubs'));
    });

    test('hard never misses a match', () {
      expect(getAIDecision(matchState, AIDifficulty.hard, _FixedDouble(0)), const AIPlay('5-clubs'));
    });

    test('miss rates rank the difficulties', () {
      expect(missChanceByDifficulty[AIDifficulty.easy]!, greaterThan(missChanceByDifficulty[AIDifficulty.medium]!));
      expect(missChanceByDifficulty[AIDifficulty.medium]!, greaterThan(missChanceByDifficulty[AIDifficulty.hard]!));
    });

    test('throws if the current player is not an AI', () {
      final state = aiTurnState([card(Rank.five, Suit.clubs)], card(Rank.five, Suit.spades));
      expect(
        () => getAIDecision(state.copyWith(currentPlayerIndex: 0), AIDifficulty.easy),
        throwsStateError,
      );
    });
  });
}
