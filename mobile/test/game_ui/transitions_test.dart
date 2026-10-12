import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/audio/sound_effects.dart';
import 'package:pitty_pat/game/game_engine.dart';
import 'package:pitty_pat/game/game_reducer.dart';
import 'package:pitty_pat/game/models.dart';
import 'package:pitty_pat/game_ui/transitions.dart';

import '../game/test_helpers.dart';

GameState _withHands(List<PlayingCard> human, List<PlayingCard> ai,
        {int current = 0, List<PlayingCard> deck = const [], List<PlayingCard>? discard, int wins = 0}) =>
    makeState(
      deck: deck,
      discardPile: discard,
      currentPlayerIndex: current,
      matchTarget: 3,
      players: [
        Player(id: 'player1', name: 'Player', hand: human, isAI: false, wins: wins),
        Player(id: 'ai1', name: 'Computer', hand: ai, isAI: true),
      ],
    );

void main() {
  test('human play slides from the human hand', () {
    final prev = _withHands([card(Rank.five, Suit.spades), card(Rank.two, Suit.clubs)], [card(Rank.nine, Suit.clubs)]);
    final t = StateTransition(prev, playCard(prev, '5-spades'));
    expect(t.discardArrival?.source, DiscardSource.humanHand);
    expect(t.discardArrival?.card.id, '5-spades');
    expect(t.cues, [SoundCue.slide]);
  });

  test('AI play slides from the AI hand', () {
    final prev = _withHands([card(Rank.two, Suit.clubs)], [card(Rank.five, Suit.spades), card(Rank.nine, Suit.clubs)], current: 1);
    final t = StateTransition(prev, playCard(prev, '5-spades'));
    expect(t.discardArrival?.source, DiscardSource.aiHand);
    expect(t.cues, [SoundCue.slide]);
  });

  test('a draw flips in from the deck', () {
    final prev = _withHands([card(Rank.two, Suit.clubs)], [card(Rank.nine, Suit.clubs)],
        deck: [card(Rank.king, Suit.hearts, faceUp: false)]);
    final t = StateTransition(prev, drawCard(prev));
    expect(t.discardArrival?.source, DiscardSource.deck);
    expect(t.cues, [SoundCue.flip]);
  });

  test('a reshuffle-then-draw still counts as a draw, not a new deal', () {
    final prev = _withHands([card(Rank.two, Suit.clubs)], [card(Rank.nine, Suit.clubs)], discard: [
      card(Rank.nine, Suit.hearts),
      card(Rank.king, Suit.diamonds),
      card(Rank.three, Suit.spades),
    ]);
    final t = StateTransition(prev, drawCard(prev));
    expect(t.isNewDeal, isFalse);
    expect(t.discardArrival?.source, DiscardSource.deck);
    expect(t.cues, [SoundCue.flip]);
  });

  test('selection and end-turn changes produce no cues', () {
    final prev = _withHands([card(Rank.five, Suit.spades)], [card(Rank.nine, Suit.clubs)]);
    expect(StateTransition(prev, gameReducer(prev, const SelectCard('5-spades'))).cues, isEmpty);
    final waiting = prev.copyWith(turnAction: TurnAction.waiting);
    expect(StateTransition(waiting, endTurn(waiting)).cues, isEmpty);
  });

  test('human round win plays slide then the round-win flourish', () {
    final prev = _withHands([card(Rank.five, Suit.spades)], [card(Rank.nine, Suit.clubs)]);
    final t = StateTransition(prev, playCard(prev, '5-spades'));
    expect(t.humanWon, isTrue);
    expect(t.cues, [SoundCue.slide, SoundCue.roundWin]);
  });

  test('AI round win plays the softer match cue', () {
    final prev = _withHands([card(Rank.two, Suit.clubs)], [card(Rank.five, Suit.spades)], current: 1);
    expect(StateTransition(prev, playCard(prev, '5-spades')).cues, [SoundCue.slide, SoundCue.match]);
  });

  test('match win plays the fanfare', () {
    final prev = _withHands([card(Rank.five, Suit.spades)], [card(Rank.nine, Suit.clubs)], wins: 2);
    expect(StateTransition(prev, playCard(prev, '5-spades')).cues, [SoundCue.slide, SoundCue.matchWin]);
  });

  group('displayMessage speaks to the player as "you"', () {
    final base = _withHands([card(Rank.five, Suit.spades)], [card(Rank.nine, Suit.clubs)]);
    String shown(String m) => displayMessage(base.copyWith(message: m));

    test('human messages', () {
      expect(shown("Player's turn"), 'Your turn');
      expect(shown('Player played a 9'), 'You played a 9');
      expect(shown('Player drew and played a Q!'), 'You drew and played a Q!');
      expect(shown('Player wins the match!'), 'You win the match!');
      expect(shown('Player wins the round!'), 'You win the round!');
    });

    test('pass-and-play names everyone, including the opening greeting', () {
      final pp = base.copyWith(message: 'Game started! Your turn.');
      expect(displayMessage(pp, secondPerson: false), "Player's turn");
      expect(displayMessage(base.copyWith(message: 'Player played a 9'), secondPerson: false), 'Player played a 9');
    });

    test('everything else passes through', () {
      expect(shown("Computer's turn"), "Computer's turn");
      expect(shown('Computer played a 9'), 'Computer played a 9');
      expect(shown("That card doesn't match the rank!"), "That card doesn't match the rank!");
      expect(shown('Game started! Your turn.'), 'Game started! Your turn.');
    });
  });

  test('next round and rematch are new deals with a shuffle', () {
    final ended = _withHands(const [], [card(Rank.nine, Suit.clubs)]).copyWith(phase: GamePhase.roundEnd);
    final t = StateTransition(ended, gameReducer(ended, const RestartRound()));
    expect(t.isNewDeal, isTrue);
    expect(t.discardArrival, isNull);
    expect(t.cues, [SoundCue.shuffle]);
  });

  test('a dead-round redeal counts as a new deal', () {
    final prev = _withHands([card(Rank.king, Suit.spades)], [card(Rank.king, Suit.hearts)],
        current: 1, deck: [card(Rank.queen, Suit.clubs, faceUp: false)]);
    final next = gameReducer(prev.copyWith(turnAction: TurnAction.waiting), const EndTurn());
    expect(next.message, deadRoundMessage);
    final t = StateTransition(prev, next);
    expect(t.isNewDeal, isTrue);
    expect(t.discardArrival, isNull);
    expect(t.cues, [SoundCue.shuffle]);
  });
}
