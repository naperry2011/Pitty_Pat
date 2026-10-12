import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/game/game_controller.dart';
import 'package:pitty_pat/game/models.dart';
import 'package:pitty_pat/game/personalities.dart';
import 'package:pitty_pat/game/play_style.dart';

import 'test_helpers.dart';

class _Roll implements Random {
  _Roll(this.value);
  final double value;

  @override
  double nextDouble() => value;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => true;
}

// The AI (seat 1) holds [aiCards] cards and has [aiWins]; the human holds
// [humanCards] cards and has [humanWins].
GameState _table({int aiCards = 4, int humanCards = 4, int aiWins = 0, int humanWins = 0}) {
  List<PlayingCard> hand(int n, Suit s) => [for (var i = 0; i < n; i++) card(Rank.values[i + 1], s)];
  return makeState(
    currentPlayerIndex: 1,
    players: [
      Player(id: 'player1', name: 'Player', hand: hand(humanCards, Suit.spades), isAI: false, wins: humanWins),
      Player(id: 'ai1', name: 'Bot', hand: hand(aiCards, Suit.hearts), isAI: true, wins: aiWins),
    ],
  );
}

double _miss(Trait trait, GameState s) => PlayStyle(miss: 0.3, trait: trait).missChanceFor(s, s.players[1]);

void main() {
  group('traits', () {
    test('none keeps the base rate', () {
      expect(_miss(Trait.none, _table()), 0.3);
    });

    test('closer never misses with two or fewer cards', () {
      expect(_miss(Trait.closer, _table(aiCards: 3)), 0.3);
      expect(_miss(Trait.closer, _table(aiCards: 2)), 0);
    });

    test('coasts gets careless only while leading', () {
      expect(_miss(Trait.coasts, _table(aiWins: 2, humanWins: 1)), closeTo(0.5, 1e-9));
      expect(_miss(Trait.coasts, _table(aiWins: 1, humanWins: 1)), 0.3);
    });

    test('focused never misses while someone is on their last card', () {
      expect(_miss(Trait.focused, _table(humanCards: 1)), 0);
      expect(_miss(Trait.focused, _table(humanCards: 2)), 0.3);
    });

    test('steadies never misses while trailing', () {
      expect(_miss(Trait.steadies, _table(humanWins: 1)), 0);
      expect(_miss(Trait.steadies, _table(aiWins: 1, humanWins: 1)), 0.3);
    });

    test('tilts gets careless while trailing', () {
      expect(_miss(Trait.tilts, _table(humanWins: 1)), closeTo(0.5, 1e-9));
      expect(_miss(Trait.tilts, _table()), 0.3);
    });
  });

  group('roster', () {
    test('Sharp opponents never miss in any situation', () {
      final states = [
        _table(),
        _table(aiWins: 3),
        _table(humanWins: 3),
        _table(aiCards: 1, humanCards: 1),
      ];
      for (final p in roster.where((p) => p.difficulty == AIDifficulty.hard)) {
        for (final s in states) {
          expect(p.style.missChanceFor(s, s.players[1]), 0, reason: p.name);
        }
      }
    });

    test('each tier averages near its difficulty rate', () {
      for (final d in AIDifficulty.values) {
        final tier = roster.where((p) => p.difficulty == d).map((p) => p.style.miss).toList();
        final avg = tier.reduce((a, b) => a + b) / tier.length;
        expect(avg, closeTo(missChanceByDifficulty[d]!, 0.03), reason: d.name);
      }
    });

    // 15 characters is what fits under the name at a 4-player table on a small phone.
    test('taglines are short enough for the narrowest seat', () {
      for (final p in roster) {
        expect(p.tagline.length, lessThanOrEqualTo(15), reason: p.name);
      }
    });

    test('opponents in a tier differ in pace or trait', () {
      for (final d in AIDifficulty.values) {
        final tier = roster.where((p) => p.difficulty == d).map((p) => (p.style.thinkDelay, p.style.trait));
        expect(tier.toSet(), hasLength(3), reason: d.name);
      }
    });
  });

  group('GameController with styles', () {
    GameState aiToPlay() => makeState(
          currentPlayerIndex: 1,
          deck: [card(Rank.king, Suit.clubs, faceUp: false), card(Rank.nine, Suit.hearts, faceUp: false)],
          players: [
            Player(id: 'player1', name: 'Player', hand: [card(Rank.two, Suit.spades)], isAI: false),
            Player(
              id: 'ai1',
              name: 'Bot',
              hand: [card(Rank.five, Suit.clubs), card(Rank.nine, Suit.clubs), card(Rank.three, Suit.clubs)],
              isAI: true,
            ),
          ],
        );

    test('an opponent moves on its own think delay', () {
      fakeAsync((async) {
        final c = GameController(
          difficulty: AIDifficulty.hard,
          styles: const {'Bot': PlayStyle(miss: 0, thinkDelay: Duration(milliseconds: 1900))},
          initialState: aiToPlay(),
        );
        async.elapse(const Duration(milliseconds: 1800));
        expect(c.state.players[1].hand, hasLength(3));
        async.elapse(const Duration(milliseconds: 200));
        expect(c.state.players[1].hand, hasLength(2));
        c.dispose();
      });
    });

    test("an opponent's style replaces the table difficulty", () {
      fakeAsync((async) {
        // Sharp table, but this opponent misses on a roll of 0.5.
        final c = GameController(
          difficulty: AIDifficulty.hard,
          random: _Roll(0.5),
          styles: const {'Bot': PlayStyle(miss: 0.6)},
          initialState: aiToPlay(),
        );
        async.elapse(const Duration(milliseconds: 1300));
        expect(c.state.players[1].hand, hasLength(3));
        expect(c.state.topDiscard.id, 'K-clubs');
        c.dispose();
      });
    });
  });
}
