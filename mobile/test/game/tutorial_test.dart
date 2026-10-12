import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/game/game_controller.dart';
import 'package:pitty_pat/game/models.dart';
import 'package:pitty_pat/game/tutorial.dart';

const _turn = Duration(milliseconds: 600);
const _ai = Duration(milliseconds: 1300);

void main() {
  test('the scripted hand plays out to a human win in 4 human turns', () {
    fakeAsync((async) {
      final c = GameController(difficulty: AIDifficulty.easy, initialState: tutorialGameState());
      String hint() => tutorialHint(c.state, isFirstTurn: false);

      // 1. Play the 7 on the 7
      expect(tutorialHint(c.state, isFirstTurn: true), contains('Tap your 7'));
      c.tapCard('7-spades');
      expect(hint(), contains('again'));
      c.tapCard('7-spades');
      async.elapse(_turn);
      expect(hint(), contains("Computer's turn"));
      async.elapse(_ai + _turn); // computer draws the queen of diamonds

      // 2. No queen: draw, and the drawn queen plays itself
      expect(c.state.topDiscard.id, 'Q-diamonds');
      expect(hint(), contains('No queen'));
      c.drawCard();
      expect(c.state.topDiscard.id, 'Q-clubs');
      async.elapse(_turn + _ai + _turn); // computer draws the 9 of diamonds

      // 3. Play the 9
      expect(c.state.topDiscard.id, '9-diamonds');
      expect(hint(), contains('You have a 9'));
      c.tapCard('9-clubs');
      c.tapCard('9-clubs');
      async.elapse(_turn + _ai + _turn); // computer draws the 3 of spades

      // 4. Play the last card and win
      expect(c.state.topDiscard.id, '3-spades');
      c.tapCard('3-diamonds');
      c.tapCard('3-diamonds');
      expect(c.state.phase, GamePhase.gameEnd);
      expect(c.state.winner, 'player1');
      expect(hint(), contains('you win'));
      c.dispose();
    });
  });

  test('hints stay sensible off script', () {
    final s = tutorialGameState().copyWith(currentPlayerIndex: 1);
    expect(tutorialHint(s, isFirstTurn: false), contains("Computer's turn"));
    final lost = tutorialGameState().copyWith(phase: GamePhase.gameEnd, winner: 'ai1');
    expect(tutorialHint(lost, isFirstTurn: false), contains("You've got the idea"));
  });
}
