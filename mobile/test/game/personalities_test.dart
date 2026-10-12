import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/game/game_engine.dart';
import 'package:pitty_pat/game/models.dart';
import 'package:pitty_pat/game/personalities.dart';
import 'package:pitty_pat/game_ui/transitions.dart';

import 'test_helpers.dart';

// nextDouble() always 0 => every chance-based reaction fires; nextInt(n) => 0.
class _Always implements Random {
  @override
  double nextDouble() => 0;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => true;
}

// nextDouble() always just under 1 => chance-based reactions never fire.
class _Never implements Random {
  @override
  double nextDouble() => 0.999;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}

final _rosie = personalityByName('Rosie');
final _dee = personalityByName('Dee');

GameState _table({required List<PlayingCard> ai1, List<PlayingCard> human = const [], int current = 1}) => makeState(
      currentPlayerIndex: current,
      deck: [card(Rank.king, Suit.clubs, faceUp: false), card(Rank.five, Suit.hearts, faceUp: false)],
      players: [
        Player(id: 'player1', name: 'Player', hand: human.isEmpty ? [card(Rank.two, Suit.spades)] : human, isAI: false),
        Player(id: 'ai1', name: 'Rosie', hand: ai1, isAI: true),
      ],
    );

void main() {
  test('the roster has three distinct personalities per difficulty, all with every line', () {
    for (final d in AIDifficulty.values) {
      expect(roster.where((p) => p.difficulty == d), hasLength(3));
    }
    expect(roster.map((p) => p.name).toSet(), hasLength(roster.length));
    for (final p in roster) {
      for (final m in Moment.values) {
        expect(p.lines[m], isNotEmpty, reason: '${p.name} ${m.name}');
      }
    }
  });

  test('pickOpponents prefers the difficulty pool and never repeats', () {
    final sharp = pickOpponents(AIDifficulty.hard, 3, Random(1));
    expect(sharp.map((p) => p.difficulty), everyElement(AIDifficulty.hard));
    expect(sharp.map((p) => p.name).toSet(), hasLength(3));
    final same = pickOpponents(AIDifficulty.hard, 3, Random(1));
    expect(same.map((p) => p.name), sharp.map((p) => p.name)); // seeded = reproducible (daily)
  });

  test('getting down to one card always gets a line', () {
    final prev = _table(ai1: [card(Rank.five, Suit.spades), card(Rank.nine, Suit.clubs)]);
    final r = reactionFor(StateTransition(prev, playCard(prev, '5-spades')), {'ai1': _rosie}, _Never());
    expect(r?.playerId, 'ai1');
    expect(_rosie.lines[Moment.lastCard], contains(r!.line));
  });

  test('ordinary plays and draws are chance-based', () {
    final prev = _table(ai1: [card(Rank.five, Suit.spades), card(Rank.nine, Suit.clubs), card(Rank.two, Suit.clubs)]);
    final play = StateTransition(prev, playCard(prev, '5-spades'));
    expect(reactionFor(play, {'ai1': _rosie}, _Never()), isNull);
    expect(_rosie.lines[Moment.play], contains(reactionFor(play, {'ai1': _rosie}, _Always())!.line));

    final miss = StateTransition(prev, drawCard(prev)); // draws the king onto a 5: miss
    expect(_rosie.lines[Moment.drawMiss], contains(reactionFor(miss, {'ai1': _rosie}, _Always())!.line));
  });

  test('round results always get an important line', () {
    final aiWins = _table(ai1: [card(Rank.five, Suit.spades)]);
    final r = reactionFor(StateTransition(aiWins, playCard(aiWins, '5-spades')), {'ai1': _rosie}, _Never());
    expect(r!.important, isTrue);
    expect(_rosie.lines[Moment.winRound], contains(r.line));

    final humanWins = _table(ai1: [card(Rank.nine, Suit.clubs)], human: [card(Rank.five, Suit.spades)], current: 0);
    final lost = reactionFor(StateTransition(humanWins, playCard(humanWins, '5-spades')), {'ai1': _dee}, _Never());
    expect(_dee.lines[Moment.loseRound], contains(lost!.line));
  });

  test('the human moving, or an unknown opponent, says nothing', () {
    final prev = _table(ai1: [card(Rank.nine, Suit.clubs)], human: [card(Rank.five, Suit.spades), card(Rank.two, Suit.clubs)], current: 0);
    expect(reactionFor(StateTransition(prev, playCard(prev, '5-spades')), {'ai1': _rosie}, _Always()), isNull);
    final aiTurn = _table(ai1: [card(Rank.five, Suit.spades), card(Rank.nine, Suit.clubs)]);
    expect(reactionFor(StateTransition(aiTurn, playCard(aiTurn, '5-spades')), const {}, _Always()), isNull);
  });
}
