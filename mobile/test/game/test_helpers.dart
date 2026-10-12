import 'dart:math';

import 'package:pitty_pat/game/models.dart';

PlayingCard card(Rank rank, Suit suit, {bool faceUp = true}) =>
    PlayingCard(rank: rank, suit: suit, faceUp: faceUp);

GameState makeState({
  List<PlayingCard> deck = const [],
  List<PlayingCard>? discardPile,
  List<Player>? players,
  int currentPlayerIndex = 0,
  TurnAction turnAction = TurnAction.draw,
  int matchTarget = 5,
}) =>
    GameState(
      deck: deck,
      discardPile: discardPile ?? [card(Rank.five, Suit.hearts)],
      players: players ??
          const [
            Player(id: 'player1', name: 'Player', hand: [], isAI: false),
            Player(id: 'ai1', name: 'Computer', hand: [], isAI: true),
          ],
      currentPlayerIndex: currentPlayerIndex,
      phase: GamePhase.playing,
      winner: null,
      turnAction: turnAction,
      message: '',
      selectedCardId: null,
      matchTarget: matchTarget,
    );

// Stands in for Math.random mocks in the web tests: nextInt always returns the max value.
class MaxRandom implements Random {
  @override
  int nextInt(int max) => max - 1;

  @override
  double nextDouble() => 0.99;

  @override
  bool nextBool() => true;
}
