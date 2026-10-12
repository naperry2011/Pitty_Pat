import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'ai_player.dart';
import 'game_engine.dart';
import 'game_reducer.dart';
import 'models.dart';
import 'play_style.dart';
import 'timing.dart';

enum _PendingEffect { endTurn, aiMove }

// Port of the useGameState hook. Turn sequencing has a single source:
// DrawCard/PlayCard set turnAction to waiting, and only _scheduleEffects
// dispatches EndTurn. UI handlers never dispatch EndTurn.
class GameController extends ChangeNotifier {
  GameController({
    this.difficulty = AIDifficulty.easy,
    int matchTarget = 5,
    List<String> opponentNames = const ['Computer'],
    // Opponent name -> play style; unlisted AI seats play by [difficulty].
    this.styles = const {},
    // Overrides opponentNames with an explicit table (pass-and-play).
    List<Seat>? seats,
    Random? random,
    // A prepared starting position (the tutorial hand; tests).
    GameState? initialState,
  })  : _random = random,
        _state = initialState ??
            (seats != null
                ? createTableState(seats: seats, matchTarget: matchTarget, random: random)
                : createInitialGameState(matchTarget: matchTarget, opponentNames: opponentNames, random: random)) {
    _scheduleEffects();
  }

  final AIDifficulty difficulty;
  final Map<String, PlayStyle> styles;
  final Random? _random;

  GameState _state;
  GameState get state => _state;

  Timer? _timer;
  _PendingEffect? _pending;
  bool _disposed = false;

  bool get isHumanTurn =>
      _state.phase == GamePhase.playing &&
      _state.turnAction == TurnAction.draw &&
      !_state.currentPlayer.isAI;

  bool isPlayable(PlayingCard card) => isHumanTurn && canPlayCard(card, _state.topDiscard);

  void dispatch(GameAction action) {
    if (_disposed) return;
    final next = gameReducer(_state, action, _random);
    if (identical(next, _state)) return;
    _state = next;
    _scheduleEffects();
    notifyListeners();
  }

  void drawCard() {
    if (isHumanTurn) dispatch(const DrawCard());
  }

  // Two-tap: first tap selects a playable card, second tap on it plays it.
  // Only cards in the hand of the human whose turn it is can be tapped.
  void tapCard(String cardId) {
    final card = _state.currentPlayer.hand.where((c) => c.id == cardId).firstOrNull;
    if (card == null || !isPlayable(card)) return;

    dispatch(_state.selectedCardId == cardId ? PlayCard(cardId) : SelectCard(cardId));
  }

  void clearSelection() {
    if (_state.selectedCardId != null) dispatch(const SelectCard(null));
  }

  void nextRound({int starter = 0}) => dispatch(RestartRound(starter: starter));

  void rematch() => dispatch(StartGame(_state.matchTarget));

  void _scheduleEffects() {
    final s = _state;
    final _PendingEffect? wanted;
    if (s.phase != GamePhase.playing) {
      wanted = null;
    } else if (s.turnAction == TurnAction.waiting) {
      wanted = _PendingEffect.endTurn;
    } else if (s.turnAction == TurnAction.draw && s.currentPlayer.isAI) {
      wanted = _PendingEffect.aiMove;
    } else {
      wanted = null;
    }

    // Like the web effect keyed on [phase, turnAction], an in-flight end-turn
    // timer survives unrelated state changes.
    if (wanted == _PendingEffect.endTurn && _pending == _PendingEffect.endTurn) return;

    _timer?.cancel();
    _timer = null;
    _pending = wanted;

    switch (wanted) {
      case _PendingEffect.endTurn:
        _timer = Timer(GameTiming.endTurnDelay, () {
          _pending = null;
          dispatch(const EndTurn());
        });
      case _PendingEffect.aiMove:
        final style = styles[s.currentPlayer.name];
        _timer = Timer(style?.thinkDelay ?? GameTiming.aiThinkDelay, () {
          _pending = null;
          final decision = getAIDecision(
            _state,
            difficulty,
            _random,
            style?.missChanceFor(_state, _state.currentPlayer),
          );
          dispatch(switch (decision) {
            AIPlay(:final cardId) => PlayCard(cardId),
            AIDraw() => const DrawCard(),
          });
        });
      case null:
        break;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
