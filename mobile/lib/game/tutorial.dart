import 'game_engine.dart';
import 'models.dart';

// The first-run tutorial: a rigged 3-card hand against an easy computer.
// Played as intended it runs:
//   1. You play your 7 on the 7 (two-tap).
//   2. Computer has no 7, draws a queen (discarded).
//   3. You have no queen, draw one: it matches and plays itself.
//   4. Computer has no queen, draws a 9 (discarded).
//   5. You play your 9. Computer draws a 3 (discarded).
//   6. You play your last card, a 3, and win.
// Hints are derived from the live state, so they stay right if the player
// goes off script (extra deck cards keep the game going).

PlayingCard _c(Rank r, Suit s, {bool up = false}) => PlayingCard(rank: r, suit: s, faceUp: up);

GameState tutorialGameState({String opponentName = 'Computer'}) => GameState(
      deck: [
        _c(Rank.queen, Suit.diamonds), // computer draws, no match
        _c(Rank.queen, Suit.clubs), // you draw, matches and auto-plays
        _c(Rank.nine, Suit.diamonds), // computer draws, no match
        _c(Rank.three, Suit.spades), // computer draws, no match
        // Spares in case the player draws when they could play
        _c(Rank.eight, Suit.hearts),
        _c(Rank.four, Suit.clubs),
        _c(Rank.jack, Suit.spades),
        _c(Rank.six, Suit.diamonds),
        _c(Rank.ten, Suit.clubs),
        _c(Rank.ace, Suit.diamonds),
      ],
      discardPile: [_c(Rank.seven, Suit.hearts, up: true)],
      players: [
        Player(
          id: 'player1',
          name: 'Player',
          hand: [
            _c(Rank.seven, Suit.spades, up: true),
            _c(Rank.three, Suit.diamonds, up: true),
            _c(Rank.nine, Suit.clubs, up: true),
          ],
          isAI: false,
        ),
        Player(
          id: 'ai1',
          name: opponentName,
          hand: [
            _c(Rank.two, Suit.clubs, up: true),
            _c(Rank.five, Suit.diamonds, up: true),
            _c(Rank.king, Suit.spades, up: true),
          ],
          isAI: true,
        ),
      ],
      currentPlayerIndex: 0,
      phase: GamePhase.playing,
      winner: null,
      turnAction: TurnAction.draw,
      message: "Let's learn Pitty Pat!",
      selectedCardId: null,
      matchTarget: 1,
    );

String _rankName(Rank r) => switch (r) {
      Rank.ace => 'ace',
      Rank.jack => 'jack',
      Rank.queen => 'queen',
      Rank.king => 'king',
      _ => r.label,
    };

/// The coaching line for the current moment of the tutorial.
String tutorialHint(GameState s, {required bool isFirstTurn}) {
  final human = s.players.firstWhere((p) => !p.isAI);
  if (s.phase != GamePhase.playing) {
    return s.winner == human.id
        ? 'Your hand is empty, so you win the round. That\'s Pitty Pat!'
        : "${s.players.firstWhere((p) => p.id == s.winner).name} emptied their hand first. You've got the idea!";
  }
  if (s.currentPlayer.isAI) {
    return "${s.currentPlayer.name}'s turn. They play a match if they have one. If not, they draw.";
  }
  if (s.turnAction == TurnAction.waiting) {
    return 'Nice! Your turn is done.';
  }

  final top = s.topDiscard;
  final rank = _rankName(top.rank);
  if (s.selectedCardId != null) {
    return 'Tap the same card again to play it.';
  }
  if (findPlayableCards(human.hand, top).isNotEmpty) {
    return isFirstTurn
        ? 'Match the rank of the top card. Suits don\'t matter. Tap your $rank to pick it.'
        : 'You have a $rank! Tap it to pick it, then tap again to play.';
  }
  return 'No $rank in your hand. Tap the deck to draw. If the new card matches, it plays itself!';
}
