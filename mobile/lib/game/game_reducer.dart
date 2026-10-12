import 'dart:math';

import 'game_engine.dart';
import 'models.dart';

// Port of gameReducer in hooks/useGameState.ts.

sealed class GameAction {
  const GameAction();
}

class StartGame extends GameAction {
  const StartGame(this.matchTarget);
  final int matchTarget;
}

// Next round with the same players (web: RESTART_GAME).
class RestartRound extends GameAction {
  // Seat index that moves first (pass-and-play rotates it; 1-human games start at 0).
  const RestartRound({this.starter = 0});
  final int starter;
}

class DrawCard extends GameAction {
  const DrawCard();
}

class PlayCard extends GameAction {
  const PlayCard(this.cardId);
  final String cardId;
}

// Two-tap selection; null clears it.
class SelectCard extends GameAction {
  const SelectCard(this.cardId);
  final String? cardId;
}

class EndTurn extends GameAction {
  const EndTurn();
}

GameState gameReducer(GameState state, GameAction action, [Random? random]) {
  final isPlaying = state.phase == GamePhase.playing;

  return switch (action) {
    // A rematch keeps the same table, seat for seat.
    StartGame(:final matchTarget) => createTableState(
        seats: [for (final p in state.players) (name: p.name, isAI: p.isAI)],
        matchTarget: matchTarget,
        random: random,
      ),
    RestartRound(:final starter) => _restartRound(state, starter, random),
    DrawCard() => (isPlaying && state.turnAction == TurnAction.draw)
        ? drawCard(state, random).copyWith(selectedCardId: null)
        : state,
    // PlayCard is gated on turnAction (as on the web) so a second play
    // cannot land during the end-of-turn delay.
    PlayCard(:final cardId) => (isPlaying && state.turnAction == TurnAction.draw)
        ? playCard(state, cardId).copyWith(selectedCardId: null)
        : state,
    SelectCard(:final cardId) => isPlaying ? state.copyWith(selectedCardId: cardId) : state,
    EndTurn() => isPlaying ? _endTurn(state, random) : state,
  };
}

// A dead round is redealt with no score; the player whose turn it now is starts.
GameState _endTurn(GameState state, Random? random) {
  final next = endTurn(state).copyWith(selectedCardId: null);
  if (!isDeadRound(next)) return next;
  return _restartRound(next, next.currentPlayerIndex, random, message: deadRoundMessage);
}

const deadRoundMessage = 'No one can match. Redealing!';

GameState _restartRound(GameState state, int starter, Random? random,
    {String message = 'New round! Your turn.'}) {
  final dealt = dealCards(shuffleDeck(createDeck(), random), state.players.length, 5);
  return state.copyWith(
    deck: dealt.remainingDeck,
    discardPile: dealt.discardPile,
    players: [
      for (var i = 0; i < state.players.length; i++)
        state.players[i].copyWith(hand: dealt.playerHands[i]),
    ],
    currentPlayerIndex: starter.clamp(0, state.players.length - 1),
    phase: GamePhase.playing,
    winner: null,
    turnAction: TurnAction.draw,
    message: message,
    selectedCardId: null,
  );
}
