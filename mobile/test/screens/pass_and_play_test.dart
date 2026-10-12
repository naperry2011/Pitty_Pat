import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/audio/sound_effects.dart';
import 'package:pitty_pat/game/game_controller.dart';
import 'package:pitty_pat/game/game_engine.dart';
import 'package:pitty_pat/game/game_reducer.dart';
import 'package:pitty_pat/game/models.dart';
import 'package:pitty_pat/main.dart';
import 'package:pitty_pat/profile/profile_store.dart';
import 'package:pitty_pat/screens/game_screen.dart';
import 'package:pitty_pat/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/test_helpers.dart';

late SettingsStore _settings;
late ProfileStore _profile;

Future<void> _stores([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues({'tutorialDone': true, ...prefs});
  final p = await SharedPreferences.getInstance();
  _settings = SettingsStore(p);
  _profile = ProfileStore(p, now: () => DateTime(2026, 10, 11));
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

Widget _host(Widget home) => SettingsScope(
      store: _settings,
      child: ProfileScope(store: _profile, child: MaterialApp(home: home)),
    );

const _humans = [(name: 'Mia', isAI: false), (name: 'Jay', isAI: false), (name: 'Sam', isAI: false)];

void main() {
  setUp(() => defaultSoundPlayer = const MutedSoundPlayer());

  group('game logic', () {
    test('a table of humans gets player ids in seat order', () {
      final s = createTableState(seats: _humans);
      expect(s.players.map((p) => p.id), ['player1', 'player2', 'player3']);
      expect(s.players.map((p) => p.name), ['Mia', 'Jay', 'Sam']);
      expect(s.players.every((p) => !p.isAI), isTrue);
    });

    test('a rematch keeps every seat, humans included', () {
      final s = createTableState(seats: _humans);
      final next = gameReducer(s, const StartGame(5));
      expect(next.players.map((p) => (p.name, p.isAI)), [('Mia', false), ('Jay', false), ('Sam', false)]);
    });

    test('the next round can start with any seat', () {
      final ended = createTableState(seats: _humans).copyWith(phase: GamePhase.roundEnd);
      expect(gameReducer(ended, const RestartRound(starter: 2)).currentPlayerIndex, 2);
    });

    test('only the current player can tap their cards', () {
      fakeAsync((async) {
        final c = GameController(
          initialState: makeState(
            currentPlayerIndex: 1,
            players: [
              Player(id: 'player1', name: 'Mia', hand: [card(Rank.five, Suit.spades)], isAI: false),
              Player(id: 'player2', name: 'Jay', hand: [card(Rank.five, Suit.clubs), card(Rank.two, Suit.clubs)], isAI: false),
            ],
          ),
        );
        c.tapCard('5-spades'); // Mia's card on Jay's turn
        expect(c.state.selectedCardId, isNull);
        c.tapCard('5-clubs');
        c.tapCard('5-clubs');
        expect(c.state.players[1].hand.map((x) => x.id), ['2-clubs']);
        c.dispose();
      });
    });
  });

  group('names', () {
    test('blank names fall back, long ones are capped, repeats get numbered', () {
      expect(resolvePassNames(['  Mia ', '', 'Mia', 'Bartholomew the Great'], 4), [
        'Mia',
        'Player 2',
        'Mia 2',
        'Bartholomew',
      ]);
    });
  });

  group('flow', () {
    testWidgets('setup -> pass screen -> reveal -> play -> pass to the next player', (tester) async {
      _phone(tester);
      await _stores();
      await tester.pumpWidget(PittyPatApp(store: _settings, profile: _profile, theme: ThemeData()));

      await tester.tap(find.text('Pass & Play'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.enterText(find.widgetWithText(TextField, 'Player 1'), 'Mia');
      await tester.enterText(find.widgetWithText(TextField, 'Player 2'), 'Jay');
      await tester.ensureVisible(find.text('Deal!'));
      await tester.tap(find.text('Deal!'));
      await tester.pumpAndSettle();

      // Mia goes first, behind the pass screen.
      expect(find.text('Pass the phone to'), findsOneWidget);
      expect(find.text("I'm Mia, show my cards"), findsOneWidget);
      expect(_settings.settings.passNames.take(3), ['Mia', 'Jay', 'Player 3']);

      await tester.tap(find.text("I'm Mia, show my cards"));
      await tester.pumpAndSettle();
      expect(find.text("Mia's hand"), findsOneWidget);
      expect(find.text('Pass the phone to'), findsNothing);
      // Everyone else sits in the seat row.
      expect(find.bySemanticsLabel(RegExp(r'^Jay, 5 cards')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'^Player 3, 5 cards')), findsOneWidget);

      // Mia draws; when her turn ends the phone goes to Jay.
      await tester.tap(find.bySemanticsLabel(RegExp('Draw pile')));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text("I'm Jay, show my cards"), findsOneWidget);

      await tester.tap(find.text("I'm Jay, show my cards"));
      await tester.pumpAndSettle();
      expect(find.text("Jay's hand"), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'^Mia, 5 cards')), findsOneWidget);

      // Shared-phone games never touch the profile.
      expect(_profile.profile.coins, 0);
    });

    testWidgets('a round win names the winner and the next round starts with the player after them',
        (tester) async {
      _phone(tester);
      await _stores();
      final controller = GameController(
        random: MaxRandom(),
        initialState: makeState(
          deck: [card(Rank.king, Suit.clubs, faceUp: false)],
          players: [
            Player(id: 'player1', name: 'Mia', hand: [card(Rank.five, Suit.spades)], isAI: false),
            Player(id: 'player2', name: 'Jay', hand: [card(Rank.two, Suit.clubs)], isAI: false),
            Player(id: 'player3', name: 'Sam', hand: [card(Rank.nine, Suit.clubs)], isAI: false),
          ],
        ),
      );
      await tester.pumpWidget(_host(GameScreen.passAndPlay(
        playerNames: const ['Mia', 'Jay', 'Sam'],
        matchTarget: 5,
        controller: controller,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text("I'm Mia, show my cards"));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('5 of spades'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('5 of spades'));
      await tester.pumpAndSettle();
      expect(find.text('Mia wins the round!'), findsOneWidget);

      await tester.tap(find.text('Next round'));
      await tester.pumpAndSettle();
      expect(controller.state.currentPlayer.name, 'Jay');
      expect(find.text("I'm Jay, show my cards"), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
