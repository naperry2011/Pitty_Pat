import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cosmetics/catalog.dart';
import 'profile/profile_store.dart';
import 'screens/home_screen.dart';
import 'settings/settings_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts are bundled (pubspec.yaml `fonts:`); release builds have no INTERNET permission.
  LicenseRegistry.addLicense(() async* {
    for (final family in ['Fredoka', 'Inter']) {
      yield LicenseEntryWithLineBreaks(
        [family],
        await rootBundle.loadString('assets/google_fonts/OFL-$family.txt'),
      );
    }
  });
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsStore(prefs);
  final profile = ProfileStore(prefs);
  await unequipUnowned(settings, profile);
  runApp(PittyPatApp(store: settings, profile: profile, theme: buildAppTheme()));
}

/// Anything equipped but not owned (e.g. a back that became an unlockable)
/// falls back to the free default.
Future<void> unequipUnowned(SettingsStore settings, ProfileStore profile) async {
  const d = GameSettings();
  final s = settings.settings;
  final fixed = s.copyWith(
    cardBack: profile.owns(cardBackId(s.cardBack)) ? null : d.cardBack,
    felt: profile.owns(feltId(s.felt)) ? null : d.felt,
    celebration: profile.owns(celebrationId(s.celebration)) ? null : d.celebration,
  );
  if (fixed.cardBack != s.cardBack || fixed.felt != s.felt || fixed.celebration != s.celebration) {
    await settings.update(fixed);
  }
}

class PittyPatApp extends StatelessWidget {
  const PittyPatApp({super.key, required this.store, required this.profile, required this.theme});

  final SettingsStore store;
  final ProfileStore profile;
  // Injected so tests can run without the Google Fonts theme.
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Above MaterialApp so modal sheets (separate routes) can read them.
    return SettingsScope(
      store: store,
      child: ProfileScope(
        store: profile,
        child: MaterialApp(
          title: 'Pitty Pat',
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
