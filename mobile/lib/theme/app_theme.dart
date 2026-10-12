import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final body = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );
  final display = GoogleFonts.fredokaTextTheme(body);

  return base.copyWith(
    textTheme: body.copyWith(
      displayLarge: display.displayLarge,
      displayMedium: display.displayMedium,
      displaySmall: display.displaySmall,
      headlineLarge: display.headlineLarge,
      headlineMedium: display.headlineMedium,
      headlineSmall: display.headlineSmall,
      titleLarge: display.titleLarge,
    ),
  );
}

// Card art reads the display family from the theme so it falls back cleanly
// when no app theme is present (tests, previews).
String? displayFontFamily(BuildContext context) =>
    Theme.of(context).textTheme.displayLarge?.fontFamily;
