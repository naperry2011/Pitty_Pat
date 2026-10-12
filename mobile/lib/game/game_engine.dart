import 'dart:math';

import 'models.dart';

// Port of lib/game-engine.ts. Keep rules in sync with the web version.

List<PlayingCard> createDeck() => [
      for (final suit in Suit.values)
        for (final rank in Rank.values) PlayingCard(suit: suit, rank: rank),
    ];

// Fisher-Yates shuffle
List<PlayingCard> shuffleDeck(List<PlayingCard> deck, [Random? random]) {
  final rng = random ?? Random();
  final shuffled = [...deck];
  for (var i = shuffled.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = tmp;
  }
  return shuffled;
}

typedef DealResult = ({
  List<List<PlayingCard>> playerHands,
  List<PlayingCard> remainingDeck,
  List<PlayingCard> discardPile,
});

DealResult dealCards(List<PlayingCard> deck, int numPlayers, int cardsPerPlayer) {
  final currentDeck = [...deck];
  final playerHands = <List<PlayingCard>>[];

  for (var i = 0; i < numPlayers; i++) {
    final hand = currentDeck.take(cardsPerPlayer).map((c) => c.copyWith(faceUp: true)).toList();
    currentDeck.removeRange(0, cardsPerPlayer);
    playerHands.add(hand);
  }

  final discardPile = [currentDeck.removeAt(0).copyWith(faceUp: true)];

  return (playerHands: playerHands, remainingDeck: currentDeck, discardPile: discardPile);
}

bool canPlayCard(PlayingCard card, PlayingCard topDiscard) => card.rank == topDiscard.rank;

List<PlayingCard> findPlayableCards(List<PlayingCard> hand, PlayingCard topDiscard) =>
    hand.where((card) => canPlayCard(card, topDiscard)).toList();

// True when no one can ever play again: every rank still held has no copy left
// in the deck or discard pile, so it can never reach the top (e.g. four players
// each holding one King).
bool isDeadRound(GameState state) {
  final heldRanks = {for (final p in state.players) for (final c in p.hand) c.rank};
  if (heldRanks.isEmpty) return false;
  return ![...state.deck, ...state.discardPile].any((c) => heldRanks.contains(c.rank));
}

GameState drawCard(GameState state, [Random? random]) {
  var deck = state.deck;
  var discardPile = state.discardPile;

  if (deck.isEmpty) {
    // Reshuffle discard pile into a new deck (keep top card), then draw from it
    if (discardPile.length <= 1) return state;

    final topCard = discardPile.last;
    final cardsToShuffle = discardPile
        .sublist(0, discardPile.length - 1)
        .map((c) => c.copyWith(faceUp: false))
        .toList();
    deck = shuffleDeck(cardsToShuffle, random);
    discardPile = [topCard];
  }

  final drawnCard = deck.first.copyWith(faceUp: true);
  final newDeck = deck.sublist(1);
  final currentPlayer = state.currentPlayer;
  final matched = canPlayCard(drawnCard, discardPile.last);

  // A matching draw auto-plays; a non-matching draw goes straight to the discard (classic rule).
  return state.copyWith(
    deck: newDeck,
    discardPile: [...discardPile, drawnCard],
    turnAction: TurnAction.waiting,
    message: matched
        ? '${currentPlayer.name} drew and played a ${drawnCard.rank.label}!'
        : '${currentPlayer.name} drew and discarded a ${drawnCard.rank.label}',
  );
}

GameState playCard(GameState state, String cardId) {
  final currentPlayer = state.currentPlayer;
  final cardIndex = currentPlayer.hand.indexWhere((c) => c.id == cardId);

  if (cardIndex == -1) return state;

  final card = currentPlayer.hand[cardIndex];

  if (!canPlayCard(card, state.topDiscard)) {
    return state.copyWith(message: "That card doesn't match the rank!");
  }

  final newHand = [...currentPlayer.hand]..removeAt(cardIndex);
  final discardPile = [...state.discardPile, card];

  if (newHand.isEmpty) {
    final winner = currentPlayer.copyWith(hand: newHand, wins: currentPlayer.wins + 1);
    final wonMatch = winner.wins >= state.matchTarget;
    return state.copyWith(
      players: [
        for (final p in state.players) p.id == winner.id ? winner : p,
      ],
      discardPile: discardPile,
      phase: wonMatch ? GamePhase.gameEnd : GamePhase.roundEnd,
      winner: winner.id,
      message: wonMatch ? '${winner.name} wins the match!' : '${winner.name} wins the round!',
    );
  }

  return state.copyWith(
    players: [
      for (var i = 0; i < state.players.length; i++)
        i == state.currentPlayerIndex ? currentPlayer.copyWith(hand: newHand) : state.players[i],
    ],
    discardPile: discardPile,
    turnAction: TurnAction.waiting,
    message: '${currentPlayer.name} played a ${card.rank.label}',
  );
}

GameState endTurn(GameState state) {
  final nextPlayerIndex = (state.currentPlayerIndex + 1) % state.players.length;
  return state.copyWith(
    currentPlayerIndex: nextPlayerIndex,
    turnAction: TurnAction.draw,
    message: "${state.players[nextPlayerIndex].name}'s turn",
  );
}

// App extension over the web engine: 1-3 computer opponents (2-4 players, as in
// the real game). The web version is always one opponent named "Computer".
const maxOpponents = 3;

GameState createInitialGameState({
  String playerName = 'Player',
  int matchTarget = 5,
  List<String> opponentNames = const ['Computer'],
  Random? random,
}) {
  assert(opponentNames.isNotEmpty && opponentNames.length <= maxOpponents);
  return createTableState(
    seats: [
      (name: playerName, isAI: false),
      for (final name in opponentNames) (name: name, isAI: true),
    ],
    matchTarget: matchTarget,
    random: random,
  );
}

// Who sits at the table, in turn order. Pass-and-play seats 2-4 humans.
typedef Seat = ({String name, bool isAI});

// Ids stay stable for the 1-human case: the human is player1, computers ai1..aiN.
GameState createTableState({
  required List<Seat> seats,
  int matchTarget = 5,
  Random? random,
}) {
  assert(seats.length >= 2 && seats.length <= maxOpponents + 1);
  final dealt = dealCards(shuffleDeck(createDeck(), random), seats.length, 5);
  var humans = 0;
  var computers = 0;

  return GameState(
    deck: dealt.remainingDeck,
    discardPile: dealt.discardPile,
    players: [
      for (var i = 0; i < seats.length; i++)
        Player(
          id: seats[i].isAI ? 'ai${++computers}' : 'player${++humans}',
          name: seats[i].name,
          hand: dealt.playerHands[i],
          isAI: seats[i].isAI,
        ),
    ],
    currentPlayerIndex: 0,
    phase: GamePhase.playing,
    winner: null,
    turnAction: TurnAction.draw,
    message: 'Game started! Your turn.',
    selectedCardId: null,
    matchTarget: matchTarget,
  );
}
