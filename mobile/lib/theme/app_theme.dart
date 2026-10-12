import 'package:flutter/material.dart';

import 'tokens.dart';

// Fredoka for display text and numbers, Inter for body (app/layout.tsx).
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.coral,
      primary: AppColors.coral,
      secondary: AppColors.felt,
      tertiary: AppColors.gold,
      surface: AppColors.cream,
      onSurface: AppColors.ink,
    ),
    scaffoldBackgroundColor: AppColors.cream,
  );

  // Families are declared with every weight in pubspec.yaml, so a fontWeight
  // set later (e.g. w800) picks the matching file instead of faking bold.
  final body = base.textTheme.apply(
    fontFamily: 'Inter',
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );
  TextStyle? display(TextStyle? s) => s?.copyWith(fontFamily: 'Fredoka');

  return base.copyWith(
    textTheme: body.copyWith(
      displayLarge: display(body.displayLarge),
      displayMedium: display(body.displayMedium),
      displaySmall: display(body.displaySmall),
      headlineLarge: display(body.headlineLarge),
      headlineMedium: display(body.headlineMedium),
      headlineSmall: display(body.headlineSmall),
      titleLarge: display(body.titleLarge),
    ),
  );
}

// Card art reads the display family from the theme so it falls back cleanly
// when no app theme is present (tests, previews).
String? displayFontFamily(BuildContext context) =>
    Theme.of(context).textTheme.displayLarge?.fontFamily;
