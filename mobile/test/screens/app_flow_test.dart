import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/audio/sound_effects.dart';
import 'package:pitty_pat/cards/card_face.dart';
import 'package:pitty_pat/game/ai_player.dart';
import 'package:pitty_pat/game/game_controller.dart';
import 'package:pitty_pat/game/models.dart';
import 'package:pitty_pat/game_ui/confetti.dart';
import 'package:pitty_pat/game_ui/flying_card.dart';
import 'package:pitty_pat/game_ui/table_pieces.dart';
import 'package:pitty_pat/main.dart';
import 'package:pitty_pat/screens/game_screen.dart';
import 'package:pitty_pat/profile/profile_store.dart';
import 'package:pitty_pat/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/test_helpers.dart';

final _today = DateTime(2026, 10, 11);
late ProfileStore _profile;

// Fresh settings + profile over the same mocked prefs, with a fixed clock.
Future<SettingsStore> _store([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  _profile = ProfileStore(prefs, now: () => _today);
  return SettingsStore(prefs);
}

// Plain theme: no Google Fonts fetching in tests.
Widget _app(SettingsStore store) =>
    PittyPatApp(store: store, profile: _profile, theme: ThemeData());

class _RecordingSounds implements SoundPlayer {
  final played = <SoundCue>[];

  @override
  void play(SoundCue cue) => played.add(cue);
}

late _RecordingSounds _sounds;

Widget _game(
  SettingsStore store,
  GameController controller, {
  bool reduceMotion = false,
}) => SettingsScope(
  store: store,
  child: ProfileScope(
    store: _profile,
    child: MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: GameScreen(
        difficulty: AIDifficulty.easy,
        matchTarget: controller.state.matchTarget,
        controller: controller,
        sounds: _sounds,
      ),
    ),
  ),
);

GameController _oneCardFromWinning() => GameController(
  random: MaxRandom(),
  initialState: makeState(
    deck: [card(Rank.king, Suit.clubs, faceUp: false)],
    players: [
      Player(
        id: 'player1',
        name: 'Player',
        hand: [card(Rank.five, Suit.spades)],
        isAI: false,
      ),
      Player(
        id: 'ai1',
        name: 'Computer',
        hand: [card(Rank.two, Suit.clubs)],
        isAI: true,
      ),
    ],
  ),
);

Future<void> _playFiveOfSpades(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('5 of spades'));
  await tester.pump();
  await tester.tap(find.bySemanticsLabel('5 of spades'));
  await tester.pump();
}

Future<void> _setPhoneSize(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() {
    _sounds = _RecordingSounds();
    defaultSoundPlayer = _sounds;
  });

  testWidgets('game cues: shuffle on the deal, flip on a draw', (tester) async {
    await _setPhoneSize(tester);
    final controller = GameController(random: MaxRandom());
    await tester.pumpWidget(_game(await _store(), controller));
    await tester.pumpAndSettle();
    expect(_sounds.played, [SoundCue.shuffle]);

    controller.drawCard();
    await tester.pump();
    expect(_sounds.played, [SoundCue.shuffle, SoundCue.flip]);
    await tester.pumpAndSettle();
  });

  testWidgets('muted settings play no sounds', (tester) async {
    await _setPhoneSize(tester);
    final controller = GameController(random: MaxRandom());
    await tester.pumpWidget(
      _game(await _store({'soundMuted': true}), controller),
    );
    await tester.pumpAndSettle();
    controller.drawCard();
    await tester.pumpAndSettle();
    expect(_sounds.played, isEmpty);
  });

  testWidgets('a played card flies to the discard pile, then lands', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    await tester.pumpWidget(_game(await _store(), _oneCardFromWinning()));
    await tester.pumpAndSettle();

    final onPile = find.descendant(
      of: find.byType(DiscardPileView),
      matching: find.byWidgetPredicate(
        (w) => w is CardFace && w.rank == Rank.five && w.suit == Suit.spades,
      ),
    );

    await _playFiveOfSpades(tester);
    expect(find.byType(FlyingCard), findsOneWidget);
    // The pile draws the card only once it lands (its label already announces it)
    expect(onPile, findsNothing);
    expect(
      find.bySemanticsLabel(RegExp('top card 5 of spades')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(FlyingCard), findsNothing);
    expect(onPile, findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('a human round win throws confetti and plays the win cue', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    await tester.pumpWidget(_game(await _store(), _oneCardFromWinning()));
    await tester.pumpAndSettle();

    await _playFiveOfSpades(tester);
    expect(find.byType(ConfettiBurst), findsOneWidget);
    expect(
      _sounds.played,
      containsAllInOrder([SoundCue.slide, SoundCue.roundWin]),
    );

    await tester.pump(const Duration(seconds: 4));
    expect(find.byType(ConfettiBurst), findsNothing);
  });

  testWidgets('reduced motion skips flights and confetti but keeps sound', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    await tester.pumpWidget(
      _game(await _store(), _oneCardFromWinning(), reduceMotion: true),
    );
    await tester.pumpAndSettle();

    await _playFiveOfSpades(tester);
    expect(find.byType(FlyingCard), findsNothing);
    expect(find.byType(ConfettiBurst), findsNothing);
    expect(_sounds.played, contains(SoundCue.roundWin));
  });

  testWidgets('home -> setup -> game saves the chosen settings', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    final store = await _store({'tutorialDone': true});
    await tester.pumpWidget(_app(store));

    expect(find.text('Pitty Pat'), findsOneWidget);
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    expect(find.text('Game Setup'), findsOneWidget);
    await tester.tap(find.text('Sharp'));
    await tester.tap(find.text('First to 3'));
    await tester.pump();
    await tester.tap(find.text('Play!'));
    await tester.pumpAndSettle();

    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('Your hand'), findsOneWidget);
    expect(store.settings.difficulty, AIDifficulty.hard);
    expect(store.settings.matchTarget, 3);

    // Leave the game so its controller and timers are disposed.
    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Pitty Pat'), findsOneWidget);
  });

  testWidgets('setup preselects the saved settings', (tester) async {
    await _setPhoneSize(tester);
    final store = await _store({'difficulty': 'medium', 'matchTarget': 10, 'tutorialDone': true});
    await tester.pumpWidget(_app(store));
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play!'));
    await tester.pumpAndSettle();

    final screen = tester.widget<GameScreen>(find.byType(GameScreen));
    expect(screen.difficulty, AIDifficulty.medium);
    expect(screen.matchTarget, 10);
    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();
  });

  testWidgets('settings sheet changes the card back', (tester) async {
    await _setPhoneSize(tester);
    final store = await _store();
    await tester.pumpWidget(_app(store));
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('minimal card back'));
    await tester.pump();
    expect(store.settings.cardBack.name, 'minimal');
  });

  testWidgets(
    'tapping the deck draws, and the turn plays out to the AI and back',
    (tester) async {
      await _setPhoneSize(tester);
      final store = await _store();
      final controller = GameController(random: MaxRandom());
      await tester.pumpWidget(_game(store, controller));

      expect(find.text('Tap the deck to draw'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(RegExp('Draw pile')));
      await tester.pump();
      expect(controller.state.discardPile, hasLength(2));

      await tester.pump(const Duration(milliseconds: 600));
      expect(find.bySemanticsLabel(RegExp(r'^Computer, \d+ cards, thinking')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump(const Duration(milliseconds: 600));
      expect(controller.isHumanTurn, isTrue);
    },
  );

  testWidgets('winning the last card shows the round banner and Next round', (
    tester,
  ) async {
    await _setPhoneSize(tester);
    final store = await _store();
    final controller = GameController(
      random: MaxRandom(),
      initialState: makeState(
        deck: [card(Rank.king, Suit.clubs, faceUp: false)],
        players: [
          Player(
            id: 'player1',
            name: 'Player',
            hand: [card(Rank.five, Suit.spades)],
            isAI: false,
          ),
          Player(
            id: 'ai1',
            name: 'Computer',
            hand: [card(Rank.two, Suit.clubs)],
            isAI: true,
          ),
        ],
      ),
    );
    await tester.pumpWidget(_game(store, controller));
    await tester.pumpAndSettle(); // let the deal-in finish

    await tester.tap(find.bySemanticsLabel('5 of spades'));
    await tester.pump();
    expect(find.text('TAP TO PLAY'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('5 of spades'));
    await tester.pumpAndSettle();

    expect(find.text('Great job! You win the round!'), findsOneWidget);
    await tester.tap(find.text('Next round'));
    await tester.pumpAndSettle();
    expect(controller.state.phase, GamePhase.playing);
    expect(controller.state.players[0].hand, hasLength(5));
  });

  testWidgets(
    'winning the match shows the dialog, and Rematch resets the score',
    (tester) async {
      await _setPhoneSize(tester);
      final store = await _store();
      final controller = GameController(
        random: MaxRandom(),
        initialState: makeState(
          matchTarget: 3,
          deck: [card(Rank.king, Suit.clubs, faceUp: false)],
          players: [
            Player(
              id: 'player1',
              name: 'Player',
              hand: [card(Rank.five, Suit.spades)],
              isAI: false,
              wins: 2,
            ),
            Player(
              id: 'ai1',
              name: 'Computer',
              hand: [card(Rank.two, Suit.clubs)],
              isAI: true,
            ),
          ],
        ),
      );
      await tester.pumpWidget(_game(store, controller));
      await tester.pumpAndSettle(); // let the deal-in finish

      await tester.tap(find.bySemanticsLabel('5 of spades'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('5 of spades'));
      await tester.pumpAndSettle();

      expect(find.text('You win the match!'), findsOneWidget);
      await tester.tap(find.text('Rematch'));
      await tester.pumpAndSettle();
      expect(find.text('You win the match!'), findsNothing);
      expect(controller.state.players.map((p) => p.wins), [0, 0]);
      expect(controller.state.matchTarget, 3);
    },
  );
}
