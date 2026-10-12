import 'package:flutter/material.dart';

// Mirrors tailwind.config.ts and app/globals.css.
abstract final class AppColors {
  static const coral = Color(0xFFFF6B6B);
  static const coralDeep = Color(0xFFE84855);
  static const cream = Color(0xFFFFF8F0);
  static const felt = Color(0xFF2E9E8F);
  static const feltDeep = Color(0xFF1F7A6D);
  static const gold = Color(0xFFF4B942);
  static const ink = Color(0xFF2D3142);
  static const sunny = Color(0xFFFFE66D);
  static const mint = Color(0xFF4ECDC4);
  static const softPurple = Color(0xFFDDA0DD);

  // Card-face suit colors (CardFace.tsx)
  static const suitRed = coralDeep;
  static const suitBlack = ink;

  // Playable / selected highlights (Card.tsx yellow-300 / yellow-400)
  static const playable = Color(0xFFFDE047);
  static const selected = Color(0xFFFACC15);
}

abstract final class AppShadows {
  static const card = [
    BoxShadow(color: Color(0x1F2D3142), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const raised = [
    BoxShadow(color: Color(0x292D3142), blurRadius: 20, offset: Offset(0, 6)),
  ];
  static const floating = [
    BoxShadow(color: Color(0x382D3142), blurRadius: 32, offset: Offset(0, 12)),
  ];
  static const selected = [
    BoxShadow(color: AppColors.sunny, spreadRadius: 3),
    BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 8), spreadRadius: -4),
  ];
}

abstract final class AppRadii {
  static const card = 12.0;
  static const panel = 24.0;
}
