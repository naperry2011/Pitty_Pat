import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/game/game_controller.dart';
import 'package:pitty_pat/game/game_engine.dart';
import 'package:pitty_pat/game/game_reducer.dart';
import 'package:pitty_pat/game/models.dart';

int _cardsInPlay(GameState s) =>
    s.deck.length + s.discardPile.length + s.players.fold(0, (a, p) => a + p.hand.length);

void main() {
  test('deals 5 cards to each of 4 players', () {
    final s = createInitialGameState(opponentNames: ['A', 'B', 'C']);
    expect(s.players.map((p) => p.hand.length), [5, 5, 5, 5]);
    expect(s.players.map((p) => p.id), ['player1', 'ai1', 'ai2', 'ai3']);
    expect(s.players.skip(1).map((p) => p.name), ['A', 'B', 'C']);
    expect(s.deck, hasLength(52 - 20 - 1));
  });

  test('turns go around the whole table and back to the human', () {
    var s = createInitialGameState(opponentNames: ['A', 'B']);
    final order = <int>[];
    for (var i = 0; i < 4; i++) {
      s = endTurn(s);
      order.add(s.currentPlayerIndex);
    }
    expect(order, [1, 2, 0, 1]);
  });

  test('a rematch keeps the same opponents and resets wins', () {
    final s = createInitialGameState(opponentNames: ['A', 'B', 'C']);
    final scored = s.copyWith(players: [for (final p in s.players) p.copyWith(wins: 2)]);
    final next = gameReducer(scored, const StartGame(5));
    expect(next.players.skip(1).map((p) => p.name), ['A', 'B', 'C']);
    expect(next.players.map((p) => p.wins), [0, 0, 0, 0]);
  });

  test('a full 4-player match plays to completion and never loses a card', () {
    fakeAsync((async) {
      final c = GameController(
        difficulty: AIDifficulty.medium,
        matchTarget: 3,
        opponentNames: ['A', 'B', 'C'],
        random: Random(12),
      );
      var turns = 0;
      while (c.state.phase != GamePhase.gameEnd && turns < 5000) {
        final s = c.state;
        expect(_cardsInPlay(s), 52);
        if (s.phase == GamePhase.roundEnd) {
          c.nextRound();
        } else if (c.isHumanTurn) {
          // The human plays like the easy AI: first match, otherwise draw.
          final playable = findPlayableCards(s.players[0].hand, s.topDiscard);
          if (playable.isEmpty) {
            c.drawCard();
          } else {
            c.tapCard(playable.first.id);
            c.tapCard(playable.first.id);
          }
        }
        async.elapse(const Duration(milliseconds: 1300));
        turns++;
      }
      expect(c.state.phase, GamePhase.gameEnd);
      expect(c.state.players.map((p) => p.wins).reduce(max), 3);
      c.dispose();
    });
  });
}
