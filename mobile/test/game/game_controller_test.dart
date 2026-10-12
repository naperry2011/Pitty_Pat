import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/game/game_controller.dart';
import 'package:pitty_pat/game/game_engine.dart';
import 'package:pitty_pat/game/game_reducer.dart';
import 'package:pitty_pat/game/models.dart';

import 'test_helpers.dart';

// MaxRandom makes the Fisher-Yates shuffle an identity permutation, so the deal is
// deterministic: player gets A-5 of hearts, AI gets 6-10 of hearts, the first
// discard is J of hearts, and the stock starts Q-hearts, K-hearts, A-diamonds...
// (Same fixture as hooks/useGameState.test.tsx.)

const _endTurn = Duration(milliseconds: 600);
const _aiThink = Duration(milliseconds: 1300);

GameState _aiTurnWith(List<PlayingCard> aiHand, PlayingCard top) => makeState(
      deck: [card(Rank.king, Suit.clubs, faceUp: false)],
      discardPile: [top],
      currentPlayerIndex: 1,
      players: [
        Player(id: 'player1', name: 'Player', hand: [card(Rank.two, Suit.spades)], isAI: false),
        Player(id: 'ai1', name: 'Computer', hand: aiHand, isAI: true),
      ],
    );

void main() {
  group('gameReducer', () {
    test('StartGame resets wins for a rematch', () {
      final initial = createInitialGameState(matchTarget: 5);
      final withWins = initial.copyWith(
        players: [for (final p in initial.players) p.copyWith(wins: 4)],
      );
      final next = gameReducer(withWins, const StartGame(3));
      expect(next.players.map((p) => p.wins), [0, 0]);
      expect(next.matchTarget, 3);
    });

    test('RestartRound deals a fresh round and keeps wins', () {
      final ended = makeState(players: const [
        Player(id: 'player1', name: 'Player', hand: [], isAI: false, wins: 2),
        Player(id: 'ai1', name: 'Computer', hand: [], isAI: true, wins: 1),
      ]).copyWith(phase: GamePhase.roundEnd, winner: 'player1', currentPlayerIndex: 1);
      final next = gameReducer(ended, const RestartRound());
      expect(next.phase, GamePhase.playing);
      expect(next.winner, isNull);
      expect(next.currentPlayerIndex, 0);
      expect(next.players.map((p) => p.hand.length), [5, 5]);
      expect(next.players.map((p) => p.wins), [2, 1]);
      expect(next.deck, hasLength(41));
    });

    test('PlayCard is ignored while the turn is waiting to end', () {
      final state = makeState(
        turnAction: TurnAction.waiting,
        players: [
          Player(id: 'player1', name: 'Player', hand: [card(Rank.five, Suit.spades)], isAI: false),
          const Player(id: 'ai1', name: 'Computer', hand: [], isAI: true),
        ],
      );
      expect(gameReducer(state, const PlayCard('5-spades')), same(state));
    });

    test('actions other than StartGame/RestartRound are ignored outside play', () {
      final ended = makeState().copyWith(phase: GamePhase.roundEnd);
      expect(gameReducer(ended, const DrawCard()), same(ended));
      expect(gameReducer(ended, const EndTurn()), same(ended));
      expect(gameReducer(ended, const SelectCard('x')), same(ended));
    });
  });

  group('GameController', () {
    test('starts a playable game with the configured match target', () {
      final c = GameController(matchTarget: 3, random: MaxRandom());
      expect(c.state.phase, GamePhase.playing);
      expect(c.state.players.map((p) => p.hand.length), [5, 5]);
      expect(c.state.turnAction, TurnAction.draw);
      expect(c.state.matchTarget, 3);
      expect(c.state.topDiscard.id, 'J-hearts');
      c.dispose();
    });

    test('a full draw cycle passes the turn to the AI exactly once and back', () {
      fakeAsync((async) {
        final c = GameController(random: MaxRandom());

        // Human draws Q-hearts (no match against J-hearts): discarded.
        c.drawCard();
        expect(c.state.players[0].hand, hasLength(5));
        expect(c.state.discardPile, hasLength(2));
        expect(c.state.turnAction, TurnAction.waiting);

        async.elapse(_endTurn);
        expect(c.state.currentPlayerIndex, 1);

        // AI draws K-hearts (no match against Q-hearts) and the turn comes back.
        async.elapse(_aiThink);
        expect(c.state.discardPile, hasLength(3));
        expect(c.state.players[1].hand, hasLength(5));

        async.elapse(_endTurn);
        expect(c.state.currentPlayerIndex, 0);
        expect(c.state.turnAction, TurnAction.draw);
        expect(c.state.deck, hasLength(39));
        c.dispose();
      });
    });

    test('AI moves use the configured difficulty', () {
      fakeAsync((async) {
        final hand = [
          card(Rank.five, Suit.clubs),
          card(Rank.five, Suit.diamonds),
          card(Rank.nine, Suit.hearts),
        ];
        final easy = GameController(
          difficulty: AIDifficulty.easy,
          random: MaxRandom(),
          initialState: _aiTurnWith(hand, card(Rank.five, Suit.spades)),
        );
        final medium = GameController(
          difficulty: AIDifficulty.medium,
          random: MaxRandom(),
          initialState: _aiTurnWith(hand, card(Rank.five, Suit.spades)),
        );

        async.elapse(_aiThink);
        expect(easy.state.topDiscard.id, '5-clubs');
        expect(medium.state.topDiscard.id, '5-diamonds');
        easy.dispose();
        medium.dispose();
      });
    });

    test('AI does not act before its thinking delay', () {
      fakeAsync((async) {
        final c = GameController(
          initialState: _aiTurnWith([card(Rank.five, Suit.clubs)], card(Rank.five, Suit.spades)),
        );
        async.elapse(const Duration(milliseconds: 1100));
        expect(c.state.players[1].hand, hasLength(1));
        async.elapse(const Duration(milliseconds: 200));
        expect(c.state.players[1].hand, isEmpty);
        c.dispose();
      });
    });

    test('two-tap: first tap selects, second tap plays', () {
      fakeAsync((async) {
        final c = GameController(
          initialState: makeState(
            deck: [card(Rank.king, Suit.clubs, faceUp: false)],
            players: [
              Player(
                id: 'player1',
                name: 'Player',
                hand: [card(Rank.five, Suit.spades), card(Rank.nine, Suit.clubs)],
                isAI: false,
              ),
              Player(id: 'ai1', name: 'Computer', hand: [card(Rank.two, Suit.clubs)], isAI: true),
            ],
          ),
        );

        c.tapCard('9-clubs'); // not playable
        expect(c.state.selectedCardId, isNull);

        c.tapCard('5-spades');
        expect(c.state.selectedCardId, '5-spades');
        expect(c.state.players[0].hand, hasLength(2));

        c.tapCard('5-spades');
        expect(c.state.players[0].hand.map((x) => x.id), ['9-clubs']);
        expect(c.state.selectedCardId, isNull);
        expect(c.state.turnAction, TurnAction.waiting);
        c.dispose();
      });
    });

    test('a second play cannot land during the end-turn delay', () {
      fakeAsync((async) {
        final c = GameController(
          initialState: makeState(
            deck: [card(Rank.king, Suit.clubs, faceUp: false)],
            players: [
              Player(
                id: 'player1',
                name: 'Player',
                hand: [
                  card(Rank.five, Suit.spades),
                  card(Rank.five, Suit.clubs),
                  card(Rank.nine, Suit.clubs),
                ],
                isAI: false,
              ),
              Player(id: 'ai1', name: 'Computer', hand: [card(Rank.two, Suit.clubs)], isAI: true),
            ],
          ),
        );

        c.tapCard('5-spades');
        c.tapCard('5-spades');
        c.tapCard('5-clubs');
        c.tapCard('5-clubs');
        expect(c.state.players[0].hand, hasLength(2));

        async.elapse(_endTurn);
        expect(c.state.currentPlayerIndex, 1);
        c.dispose();
      });
    });

    test('winning a round stops turn timers until the next round', () {
      fakeAsync((async) {
        final c = GameController(
          initialState: makeState(
            deck: [card(Rank.king, Suit.clubs, faceUp: false)],
            players: [
              Player(id: 'player1', name: 'Player', hand: [card(Rank.five, Suit.spades)], isAI: false),
              Player(id: 'ai1', name: 'Computer', hand: [card(Rank.two, Suit.clubs)], isAI: true),
            ],
          ),
          random: MaxRandom(),
        );

        c.tapCard('5-spades');
        c.tapCard('5-spades');
        expect(c.state.phase, GamePhase.roundEnd);

        async.elapse(const Duration(seconds: 5));
        expect(c.state.phase, GamePhase.roundEnd);
        expect(c.state.currentPlayerIndex, 0);

        c.nextRound();
        expect(c.state.phase, GamePhase.playing);
        expect(c.state.players[0].wins, 1);
        expect(c.isHumanTurn, isTrue);
        c.dispose();
      });
    });

    test('dispose cancels a pending AI move', () {
      fakeAsync((async) {
        final c = GameController(
          initialState: _aiTurnWith([card(Rank.five, Suit.clubs)], card(Rank.five, Suit.spades)),
        );
        c.dispose();
        async.elapse(_aiThink);
        expect(async.pendingTimers, isEmpty);
      });
    });

    test('notifies listeners on each state change', () {
      fakeAsync((async) {
        final c = GameController(random: MaxRandom());
        var notified = 0;
        c.addListener(() => notified++);
        c.drawCard();
        async.elapse(_endTurn);
        expect(notified, 2);
        c.dispose();
      });
    });
  });
}
