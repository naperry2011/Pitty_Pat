import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/audio/sound_effects.dart';
import 'package:pitty_pat/profile/player_profile.dart';
import 'package:pitty_pat/profile/profile_store.dart';
import 'package:pitty_pat/screens/ladder_screen.dart';
import 'package:pitty_pat/settings/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _host({int cleared = 0}) async {
  SharedPreferences.setMockInitialValues({
    'tutorialDone': true,
    'profile.v1': jsonEncode(PlayerProfile(ladderCleared: cleared).toJson()),
  });
  final prefs = await SharedPreferences.getInstance();
  final profile = ProfileStore(prefs, now: () => DateTime(2026, 10, 11));
  return SettingsScope(
    store: SettingsStore(prefs),
    child: ProfileScope(store: profile, child: const MaterialApp(home: LadderScreen())),
  );
}

void main() {
  setUp(() => defaultSoundPlayer = const MutedSoundPlayer());

  testWidgets('shows cleared, next and locked rungs', (tester) async {
    tester.view.physicalSize = const Size(411, 914) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(await _host(cleared: 2));

    expect(find.textContaining('2 of 9 cleared'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Rung 1, Rosie.*cleared')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Rung 3, Lulu.*next up, \+55 coins')), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Vince'), 200);
    expect(find.bySemanticsLabel(RegExp(r'^Rung 9, Vince.*locked')), findsOneWidget);
  });

  testWidgets('the next rung opens a 1v1 first-to-3 match against that opponent', (tester) async {
    tester.view.physicalSize = const Size(411, 914) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(await _host(cleared: 2));

    await tester.ensureVisible(find.text('Lulu'));
    await tester.tap(find.text('Lulu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.bySemanticsLabel(RegExp(r'^Lulu, 5 cards')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('locked rungs do nothing', (tester) async {
    tester.view.physicalSize = const Size(411, 914) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(await _host());

    await tester.ensureVisible(find.text('Pops'));
    await tester.tap(find.text('Pops'));
    await tester.pumpAndSettle();
    expect(find.byType(LadderScreen), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Pops, 5 cards')), findsNothing);
  });
}
