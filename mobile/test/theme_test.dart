import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pitty_pat/theme/app_theme.dart';

void main() {
  // Bold text only renders bold on a device when the theme names a family
  // that pubspec.yaml declares with every weight. Per-weight family names
  // (e.g. google_fonts' "Fredoka_regular") hold a single file, so w700/w800
  // fell back to a faked or regular weight.
  test('theme uses the weighted Fredoka and Inter families', () {
    final t = buildAppTheme().textTheme;
    for (final s in [t.displayLarge, t.headlineSmall, t.titleLarge]) {
      expect(s?.fontFamily, 'Fredoka');
    }
    for (final s in [t.bodyMedium, t.bodyLarge, t.labelLarge]) {
      expect(s?.fontFamily, 'Inter');
    }
  });

  test('pubspec declares the bold files for both families', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final file in [
      'Fredoka-Bold.ttf',
      'Fredoka-SemiBold.ttf',
      'Inter-Bold.ttf',
      'Inter-ExtraBold.ttf',
    ]) {
      expect(pubspec, contains('asset: assets/google_fonts/$file'));
    }
  });
}
