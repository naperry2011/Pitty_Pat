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

void main() {
  group('getAIDecision', () {
    test('draws when no card matches', () {
      final state = aiTurnState(
        [card(Rank.two, Suit.clubs), card(Rank.nine, Suit.hearts)],
        card(Rank.five, Suit.spades),
      );
      expect(getAIDecision(state, AIDifficulty.easy), const AIDraw());
    });

    test('easy difficulty plays the first matching card', () {
      final state = aiTurnState(
        [card(Rank.five, Suit.clubs), card(Rank.five, Suit.diamonds), card(Rank.nine, Suit.hearts)],
        card(Rank.five, Suit.spades),
      );
      expect(getAIDecision(state, AIDifficulty.easy, MaxRandom()), const AIPlay('5-clubs'));
    });

    test('medium difficulty plays a random matching card', () {
      final state = aiTurnState(
        [card(Rank.five, Suit.clubs), card(Rank.five, Suit.diamonds), card(Rank.nine, Suit.hearts)],
        card(Rank.five, Suit.spades),
      );
      expect(getAIDecision(state, AIDifficulty.medium, MaxRandom()), const AIPlay('5-diamonds'));
    });

    test('hard difficulty prefers playing from a duplicated rank', () {
      final state = aiTurnState(
        [card(Rank.five, Suit.clubs), card(Rank.nine, Suit.diamonds), card(Rank.nine, Suit.hearts)],
        card(Rank.nine, Suit.spades),
      );
      final decision = getAIDecision(state, AIDifficulty.hard);
      expect(decision, isA<AIPlay>());
      expect(['9-diamonds', '9-hearts'], contains((decision as AIPlay).cardId));
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
