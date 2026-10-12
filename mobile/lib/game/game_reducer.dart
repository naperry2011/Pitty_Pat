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
  const RestartRound();
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
    // A rematch keeps the same table of opponents.
    StartGame(:final matchTarget) => createInitialGameState(
        matchTarget: matchTarget,
        opponentNames: [for (final p in state.players) if (p.isAI) p.name],
        random: random,
      ),
    RestartRound() => _restartRound(state, random),
    DrawCard() => (isPlaying && state.turnAction == TurnAction.draw)
        ? drawCard(state, random).copyWith(selectedCardId: null)
        : state,
    // PlayCard is gated on turnAction (as on the web) so a second play
    // cannot land during the end-of-turn delay.
    PlayCard(:final cardId) => (isPlaying && state.turnAction == TurnAction.draw)
        ? playCard(state, cardId).copyWith(selectedCardId: null)
        : state,
    SelectCard(:final cardId) => isPlaying ? state.copyWith(selectedCardId: cardId) : state,
    EndTurn() => isPlaying ? endTurn(state).copyWith(selectedCardId: null) : state,
  };
}

GameState _restartRound(GameState state, Random? random) {
  final dealt = dealCards(shuffleDeck(createDeck(), random), state.players.length, 5);
  return state.copyWith(
    deck: dealt.remainingDeck,
    discardPile: dealt.discardPile,
    players: [
      for (var i = 0; i < state.players.length; i++)
        state.players[i].copyWith(hand: dealt.playerHands[i]),
    ],
    currentPlayerIndex: 0,
    phase: GamePhase.playing,
    winner: null,
    turnAction: TurnAction.draw,
    message: 'New round! Your turn.',
    selectedCardId: null,
  );
}
