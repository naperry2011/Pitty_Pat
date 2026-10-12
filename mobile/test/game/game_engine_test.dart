import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/game/game_engine.dart';
import 'package:pitty_pat/game/models.dart';

import 'test_helpers.dart';

void main() {
  group('createDeck', () {
    test('creates 52 unique cards, 13 per suit', () {
      final deck = createDeck();
      expect(deck, hasLength(52));
      expect(deck.map((c) => c.id).toSet(), hasLength(52));
      for (final suit in Suit.values) {
        expect(deck.where((c) => c.suit == suit), hasLength(13));
      }
    });

    test('ids match the web format', () {
      final ids = createDeck().map((c) => c.id);
      expect(ids, containsAll(['A-hearts', '10-spades', 'K-clubs']));
    });
  });

  group('shuffleDeck', () {
    test('preserves the card set and does not mutate the input', () {
      final deck = createDeck();
      final before = deck.map((c) => c.id).toList();
      final shuffled = shuffleDeck(deck);
      expect(deck.map((c) => c.id).toList(), before);
      expect(shuffled.map((c) => c.id).toList()..sort(), [...before]..sort());
    });

    test('same seed gives the same order', () {
      final a = shuffleDeck(createDeck(), Random(42)).map((c) => c.id).toList();
      final b = shuffleDeck(createDeck(), Random(42)).map((c) => c.id).toList();
      expect(a, b);
    });
  });

  group('dealCards', () {
    test('deals the requested hands, one discard, and the remainder', () {
      final dealt = dealCards(createDeck(), 2, 5);
      expect(dealt.playerHands, hasLength(2));
      expect(dealt.playerHands[0], hasLength(5));
      expect(dealt.playerHands[1], hasLength(5));
      expect(dealt.discardPile, hasLength(1));
      expect(dealt.discardPile[0].faceUp, isTrue);
      expect(dealt.remainingDeck, hasLength(52 - 10 - 1));
    });
  });

  group('canPlayCard / findPlayableCards', () {
    test('matches on rank only', () {
      expect(canPlayCard(card(Rank.five, Suit.spades), card(Rank.five, Suit.hearts)), isTrue);
      expect(canPlayCard(card(Rank.six, Suit.hearts), card(Rank.five, Suit.hearts)), isFalse);
    });

    test('findPlayableCards returns all rank matches', () {
      final hand = [
        card(Rank.five, Suit.spades),
        card(Rank.six, Suit.clubs),
        card(Rank.five, Suit.diamonds),
      ];
      final playable = findPlayableCards(hand, card(Rank.five, Suit.hearts));
      expect(playable.map((c) => c.id), ['5-spades', '5-diamonds']);
    });
  });

  group('playCard', () {
    test('moves a matching card from hand to discard and waits', () {
      final state = makeState(players: [
        Player(
            id: 'player1',
            name: 'Player',
            hand: [card(Rank.five, Suit.spades), card(Rank.nine, Suit.clubs)],
            isAI: false),
        Player(id: 'ai1', name: 'Computer', hand: [card(Rank.two, Suit.clubs)], isAI: true),
      ]);
      final next = playCard(state, '5-spades');
      expect(next.players[0].hand.map((c) => c.id), ['9-clubs']);
      expect(next.discardPile.last.id, '5-spades');
      expect(next.turnAction, TurnAction.waiting);
      expect(next.phase, GamePhase.playing);
    });

    test('rejects a non-matching card without changing hands', () {
      final state = makeState(players: [
        Player(id: 'player1', name: 'Player', hand: [card(Rank.nine, Suit.clubs)], isAI: false),
        const Player(id: 'ai1', name: 'Computer', hand: [], isAI: true),
      ]);
      final next = playCard(state, '9-clubs');
      expect(next.players[0].hand, hasLength(1));
      expect(next.discardPile, hasLength(1));
    });

    test('emptying the hand wins the round and increments wins', () {
      final state = makeState(players: [
        Player(
            id: 'player1',
            name: 'Player',
            hand: [card(Rank.five, Suit.spades)],
            isAI: false,
            wins: 2),
        Player(id: 'ai1', name: 'Computer', hand: [card(Rank.two, Suit.clubs)], isAI: true),
      ]);
      final next = playCard(state, '5-spades');
      expect(next.phase, GamePhase.roundEnd);
      expect(next.winner, 'player1');
      expect(next.players[0].wins, 3);
    });
  });

  group('drawCard', () {
    test('auto-plays a drawn card that matches the discard', () {
      final state = makeState(deck: [card(Rank.five, Suit.clubs, faceUp: false)]);
      final next = drawCard(state);
      expect(next.deck, isEmpty);
      expect(next.discardPile.last.id, '5-clubs');
      expect(next.turnAction, TurnAction.waiting);
    });

    test('discards a drawn card that does not match', () {
      final state = makeState(deck: [card(Rank.king, Suit.clubs, faceUp: false)]);
      final next = drawCard(state);
      expect(next.discardPile.last.id, 'K-clubs');
      expect(next.turnAction, TurnAction.waiting);
    });

    test('reshuffles an empty deck and still draws a card for the player', () {
      // BUG-004: the reshuffle path must not consume the turn without a draw.
      final state = makeState(discardPile: [
        card(Rank.nine, Suit.clubs),
        card(Rank.king, Suit.diamonds),
        card(Rank.three, Suit.spades), // top card stays
      ]);
      final next = drawCard(state);
      expect(next.deck, hasLength(1));
      expect(next.discardPile, hasLength(2));
      expect(next.discardPile[0].id, '3-spades');
      expect(next.turnAction, TurnAction.waiting);
    });
  });

  group('endTurn', () {
    test('advances to the next player', () {
      final next = endTurn(makeState(turnAction: TurnAction.waiting));
      expect(next.currentPlayerIndex, 1);
    });

    test('gives every next player a draw action, including the AI', () {
      final toAI = endTurn(makeState(currentPlayerIndex: 0, turnAction: TurnAction.waiting));
      expect(toAI.turnAction, TurnAction.draw);
      final toHuman = endTurn(makeState(currentPlayerIndex: 1, turnAction: TurnAction.waiting));
      expect(toHuman.turnAction, TurnAction.draw);
    });
  });

  group('match structure', () {
    test('round win below the match target ends the round only', () {
      final state = makeState(matchTarget: 3, players: [
        Player(
            id: 'player1',
            name: 'Player',
            hand: [card(Rank.five, Suit.spades)],
            isAI: false,
            wins: 1),
        Player(id: 'ai1', name: 'Computer', hand: [card(Rank.two, Suit.clubs)], isAI: true),
      ]);
      final next = playCard(state, '5-spades');
      expect(next.phase, GamePhase.roundEnd);
      expect(next.players[0].wins, 2);
    });

    test('reaching the match target ends the match with gameEnd', () {
      final state = makeState(matchTarget: 3, players: [
        Player(
            id: 'player1',
            name: 'Player',
            hand: [card(Rank.five, Suit.spades)],
            isAI: false,
            wins: 2),
        Player(id: 'ai1', name: 'Computer', hand: [card(Rank.two, Suit.clubs)], isAI: true),
      ]);
      final next = playCard(state, '5-spades');
      expect(next.phase, GamePhase.gameEnd);
      expect(next.players[0].wins, 3);
      expect(next.winner, 'player1');
    });

    test('createInitialGameState stores the match target', () {
      expect(createInitialGameState(playerName: 'P', matchTarget: 10).matchTarget, 10);
    });
  });

  group('createInitialGameState', () {
    test('deals 5 cards each, one discard, human starts with a draw action', () {
      final state = createInitialGameState(playerName: 'Tester');
      expect(state.players[0].hand, hasLength(5));
      expect(state.players[1].hand, hasLength(5));
      expect(state.discardPile, hasLength(1));
      expect(state.deck, hasLength(41));
      expect(state.currentPlayerIndex, 0);
      expect(state.turnAction, TurnAction.draw);
      expect(state.phase, GamePhase.playing);
    });

    test('a seeded random produces a reproducible deal', () {
      final a = createInitialGameState(random: Random(7));
      final b = createInitialGameState(random: Random(7));
      expect(a.players[0].hand, b.players[0].hand);
      expect(a.discardPile, b.discardPile);
    });
  });

  group('isDeadRound', () {
    GameState kingsInHands({List<PlayingCard>? deck, List<PlayingCard>? discard}) => makeState(
          deck: deck ?? [card(Rank.queen, Suit.clubs, faceUp: false)],
          discardPile: discard ?? [card(Rank.five, Suit.hearts)],
          players: [
            Player(id: 'player1', name: 'Player', hand: [card(Rank.king, Suit.spades)], isAI: false),
            Player(id: 'ai1', name: 'Computer', hand: [card(Rank.king, Suit.hearts)], isAI: true),
          ],
        );

    test('is dead when no copy of a held rank is left outside the hands', () {
      expect(isDeadRound(kingsInHands()), isTrue);
    });

    test('is live while a held rank is still in the deck', () {
      expect(isDeadRound(kingsInHands(deck: [card(Rank.king, Suit.clubs, faceUp: false)])), isFalse);
    });

    test('a copy buried in the discard pile still counts (it can be reshuffled)', () {
      expect(
        isDeadRound(kingsInHands(discard: [card(Rank.king, Suit.clubs), card(Rank.five, Suit.hearts)])),
        isFalse,
      );
    });
  });
}
