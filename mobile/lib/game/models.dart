enum Suit { hearts, diamonds, clubs, spades }

enum Rank {
  ace('A'),
  two('2'),
  three('3'),
  four('4'),
  five('5'),
  six('6'),
  seven('7'),
  eight('8'),
  nine('9'),
  ten('10'),
  jack('J'),
  queen('Q'),
  king('K');

  const Rank(this.label);
  final String label;
}

class PlayingCard {
  const PlayingCard({required this.suit, required this.rank, this.faceUp = false});

  final Suit suit;
  final Rank rank;
  final bool faceUp;

  // Matches the web format: `${rank}-${suit}`, e.g. "A-hearts", "10-spades".
  String get id => '${rank.label}-${suit.name}';

  PlayingCard copyWith({bool? faceUp}) =>
      PlayingCard(suit: suit, rank: rank, faceUp: faceUp ?? this.faceUp);

  @override
  bool operator ==(Object other) =>
      other is PlayingCard && other.suit == suit && other.rank == rank && other.faceUp == faceUp;

  @override
  int get hashCode => Object.hash(suit, rank, faceUp);

  @override
  String toString() => id;
}

class Player {
  const Player({
    required this.id,
    required this.name,
    required this.hand,
    required this.isAI,
    this.wins = 0,
  });

  final String id;
  final String name;
  final List<PlayingCard> hand;
  final bool isAI;
  final int wins;

  Player copyWith({List<PlayingCard>? hand, int? wins}) => Player(
        id: id,
        name: name,
        hand: hand ?? this.hand,
        isAI: isAI,
        wins: wins ?? this.wins,
      );
}

enum GamePhase { waiting, playing, roundEnd, gameEnd }

enum TurnAction { draw, play, waiting }

const Object _unset = Object();

class GameState {
  const GameState({
    required this.deck,
    required this.discardPile,
    required this.players,
    required this.currentPlayerIndex,
    required this.phase,
    required this.winner,
    required this.turnAction,
    required this.message,
    required this.selectedCardId,
    required this.matchTarget,
  });

  final List<PlayingCard> deck;
  final List<PlayingCard> discardPile;
  final List<Player> players;
  final int currentPlayerIndex;
  final GamePhase phase;
  final String? winner;
  final TurnAction turnAction;
  final String message;
  final String? selectedCardId; // For two-tap mobile interaction
  final int matchTarget; // Round wins needed to win the match

  Player get currentPlayer => players[currentPlayerIndex];
  PlayingCard get topDiscard => discardPile.last;

  GameState copyWith({
    List<PlayingCard>? deck,
    List<PlayingCard>? discardPile,
    List<Player>? players,
    int? currentPlayerIndex,
    GamePhase? phase,
    Object? winner = _unset,
    TurnAction? turnAction,
    String? message,
    Object? selectedCardId = _unset,
    int? matchTarget,
  }) =>
      GameState(
        deck: deck ?? this.deck,
        discardPile: discardPile ?? this.discardPile,
        players: players ?? this.players,
        currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
        phase: phase ?? this.phase,
        winner: identical(winner, _unset) ? this.winner : winner as String?,
        turnAction: turnAction ?? this.turnAction,
        message: message ?? this.message,
        selectedCardId:
            identical(selectedCardId, _unset) ? this.selectedCardId : selectedCardId as String?,
        matchTarget: matchTarget ?? this.matchTarget,
      );
}
