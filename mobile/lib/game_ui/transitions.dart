import '../audio/sound_effects.dart';
import '../game/models.dart';

// How a card reached the top of the discard pile in one state transition.
enum DiscardSource { humanHand, aiHand, deck }

class DiscardArrival {
  const DiscardArrival(this.card, this.source);
  final PlayingCard card;
  final DiscardSource source;
}

// Pure reading of a state transition; drives sound and motion, never game logic.
// Mirrors the transition effects in GameBoard.tsx.
class StateTransition {
  StateTransition(this.prev, this.next);

  final GameState prev;
  final GameState next;

  // New round or rematch: the only ways back into play.
  bool get isNewDeal => next.phase == GamePhase.playing && prev.phase != GamePhase.playing;

  // Every card is unique, so a changed top card means one arrived this transition.
  DiscardArrival? get discardArrival {
    if (isNewDeal || next.discardPile.isEmpty || prev.discardPile.isEmpty) return null;
    final card = next.discardPile.last;
    if (card.id == prev.discardPile.last.id) return null;

    // A card that wasn't in the mover's hand was drawn (including after a reshuffle).
    final fromHand = prev.currentPlayer.hand.any((c) => c.id == card.id);
    if (!fromHand) return DiscardArrival(card, DiscardSource.deck);
    return DiscardArrival(
      card,
      prev.currentPlayer.isAI ? DiscardSource.aiHand : DiscardSource.humanHand,
    );
  }

  bool get humanWon => next.winner != null && next.winner == _humanId(next);

  List<SoundCue> get cues {
    if (isNewDeal) return const [SoundCue.shuffle];
    final out = <SoundCue>[];
    final arrival = discardArrival;
    if (arrival != null) {
      out.add(arrival.source == DiscardSource.deck ? SoundCue.flip : SoundCue.slide);
    }
    if (prev.phase != next.phase) {
      if (next.phase == GamePhase.roundEnd) {
        // Softer cue when the AI takes the round
        out.add(humanWon ? SoundCue.roundWin : SoundCue.match);
      } else if (next.phase == GamePhase.gameEnd) {
        out.add(SoundCue.matchWin);
      }
    }
    return out;
  }

  static String _humanId(GameState s) => s.players.firstWhere((p) => !p.isAI).id;
}
