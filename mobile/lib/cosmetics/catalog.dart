import 'package:flutter/painting.dart';

import '../cards/card_back.dart';
import '../theme/tokens.dart';

enum FeltStyle {
  teal('Classic Teal', AppColors.felt, AppColors.feltDeep),
  royal('Royal Blue', Color(0xFF3B5BDB), Color(0xFF243B9C)),
  burgundy('Burgundy', Color(0xFFA3324B), Color(0xFF6E1F33)),
  midnight('Midnight', Color(0xFF2D3A5C), Color(0xFF161D33)),
  sunset('Sunset', Color(0xFFFF8A65), Color(0xFFD9534F));

  const FeltStyle(this.label, this.light, this.deep);
  final String label;
  final Color light;
  final Color deep;
}

enum CelebrationStyle {
  confetti('Confetti'),
  goldRush('Gold Rush'),
  suitShower('Suit Shower');

  const CelebrationStyle(this.label);
  final String label;
}

enum CosmeticKind { cardBack, felt, celebration }

class Cosmetic {
  const Cosmetic({
    required this.id,
    required this.kind,
    required this.name,
    this.price = 0,
    this.minLevel = 1,
  });

  final String id;
  final CosmeticKind kind;
  final String name;
  final int price; // 0 = owned from the start
  final int minLevel;

  bool get isFree => price == 0 && minLevel <= 1;
}

String cardBackId(CardBackStyle s) => 'back.${s.name}';
String feltId(FeltStyle s) => 'felt.${s.name}';
String celebrationId(CelebrationStyle s) => 'celebration.${s.name}';

const _backPrices = {
  CardBackStyle.classic: (0, 1),
  CardBackStyle.minimal: (0, 1),
  CardBackStyle.geometric: (150, 1),
  CardBackStyle.gradient: (150, 2),
  CardBackStyle.midnight: (300, 3),
  CardBackStyle.royal: (400, 5),
};

const _feltPrices = {
  FeltStyle.teal: (0, 1),
  FeltStyle.royal: (200, 2),
  FeltStyle.burgundy: (200, 2),
  FeltStyle.midnight: (350, 4),
  FeltStyle.sunset: (350, 4),
};

const _celebrationPrices = {
  CelebrationStyle.confetti: (0, 1),
  CelebrationStyle.goldRush: (250, 3),
  CelebrationStyle.suitShower: (400, 5),
};

const _backNames = {
  CardBackStyle.classic: 'Classic',
  CardBackStyle.minimal: 'Minimal',
  CardBackStyle.geometric: 'Geometric',
  CardBackStyle.gradient: 'Dreamy',
  CardBackStyle.midnight: 'Midnight',
  CardBackStyle.royal: 'Royal',
};

final List<Cosmetic> catalog = [
  for (final s in CardBackStyle.values)
    Cosmetic(
      id: cardBackId(s),
      kind: CosmeticKind.cardBack,
      name: _backNames[s]!,
      price: _backPrices[s]!.$1,
      minLevel: _backPrices[s]!.$2,
    ),
  for (final s in FeltStyle.values)
    Cosmetic(
      id: feltId(s),
      kind: CosmeticKind.felt,
      name: s.label,
      price: _feltPrices[s]!.$1,
      minLevel: _feltPrices[s]!.$2,
    ),
  for (final s in CelebrationStyle.values)
    Cosmetic(
      id: celebrationId(s),
      kind: CosmeticKind.celebration,
      name: s.label,
      price: _celebrationPrices[s]!.$1,
      minLevel: _celebrationPrices[s]!.$2,
    ),
];

Cosmetic cosmeticById(String id) => catalog.firstWhere((c) => c.id == id);

Set<String> get starterCosmetics => {for (final c in catalog) if (c.isFree) c.id};
