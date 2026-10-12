import 'package:flutter/material.dart';

import '../cards/card_back.dart';
import '../cards/playing_card_view.dart';
import '../cosmetics/catalog.dart';
import '../game/models.dart';
import '../game_ui/confetti.dart';
import '../profile/profile_store.dart';
import '../settings/settings_store.dart';
import '../theme/tokens.dart';
import '../widgets/felt_table.dart';
import '../widgets/playful_background.dart';
import '../widgets/screen_header.dart';
import '../widgets/profile_badges.dart';

// Buy cosmetics with coins and equip them.
class LockerScreen extends StatelessWidget {
  const LockerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = ProfileScope.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: PlayfulBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                  child: ScreenHeader(
                    title: 'Locker',
                    trailing: CoinBadge(coins: profile.profile.coins),
                  ),
                ),
                const TabBar(
                  labelColor: AppColors.coralDeep,
                  indicatorColor: AppColors.coral,
                  tabs: [Tab(text: 'Card backs'), Tab(text: 'Felts'), Tab(text: 'Wins')],
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      _Grid(kind: CosmeticKind.cardBack),
                      _Grid(kind: CosmeticKind.felt),
                      _Grid(kind: CosmeticKind.celebration),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.kind});

  final CosmeticKind kind;

  @override
  Widget build(BuildContext context) {
    final items = catalog.where((c) => c.kind == kind).toList();
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _ItemTile(item: items[i]),
    );
  }
}

bool _isEquipped(Cosmetic item, GameSettings s) => switch (item.kind) {
      CosmeticKind.cardBack => cardBackId(s.cardBack) == item.id,
      CosmeticKind.felt => feltId(s.felt) == item.id,
      CosmeticKind.celebration => celebrationId(s.celebration) == item.id,
    };

GameSettings _equip(Cosmetic item, GameSettings s) => switch (item.kind) {
      CosmeticKind.cardBack =>
        s.copyWith(cardBack: CardBackStyle.values.firstWhere((v) => cardBackId(v) == item.id)),
      CosmeticKind.felt => s.copyWith(felt: FeltStyle.values.firstWhere((v) => feltId(v) == item.id)),
      CosmeticKind.celebration =>
        s.copyWith(celebration: CelebrationStyle.values.firstWhere((v) => celebrationId(v) == item.id)),
    };

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final Cosmetic item;

  Future<void> _onTap(BuildContext context) async {
    final profile = ProfileScope.read(context);
    final settings = SettingsScope.of(context);
    if (profile.owns(item.id)) {
      await settings.update(_equip(item, settings.settings));
      return;
    }

    // Replace, don't queue: each tap should explain itself immediately.
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (profile.level < item.minLevel) {
      messenger.showSnackBar(SnackBar(content: Text('Reach level ${item.minLevel} to unlock ${item.name}')));
      return;
    }
    if (profile.profile.coins < item.price) {
      final short = item.price - profile.profile.coins;
      messenger.showSnackBar(SnackBar(content: Text('You need $short more coins. Win matches to earn them!')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unlock ${item.name}?'),
        content: Text('This costs ${item.price} coins.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Unlock')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    if (profile.buy(item) == PurchaseResult.purchased) {
      await settings.update(_equip(item, settings.settings));
      messenger.showSnackBar(SnackBar(content: Text('${item.name} unlocked and equipped!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileScope.of(context);
    final settings = SettingsScope.of(context).settings;
    final owned = profile.owns(item.id);
    final equipped = owned && _isEquipped(item, settings);
    final locked = !owned && profile.level < item.minLevel;

    final status = equipped
        ? 'Equipped'
        : owned
            ? 'Tap to equip'
            : locked
                ? 'Level ${item.minLevel}'
                : '${item.price} coins';

    return Semantics(
      container: true,
      button: true,
      selected: equipped,
      label: '${item.name}, $status',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => _onTap(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: equipped ? AppColors.coral : Colors.transparent, width: 3),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(opacity: locked ? 0.45 : 1, child: _Preview(item: item)),
                    if (locked) const Icon(Icons.lock_rounded, size: 32, color: AppColors.ink),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!owned && !locked) ...[
                    const Icon(Icons.monetization_on_rounded, size: 14, color: AppColors.gold),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: equipped ? AppColors.coralDeep : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.item});

  final Cosmetic item;

  @override
  Widget build(BuildContext context) => switch (item.kind) {
        CosmeticKind.cardBack => PlayingCardView(
            card: const PlayingCard(suit: Suit.spades, rank: Rank.ace),
            backStyle: CardBackStyle.values.firstWhere((v) => cardBackId(v) == item.id),
            width: 70,
          ),
        CosmeticKind.felt => SizedBox(
            width: 120,
            height: 90,
            child: FeltTable(
              felt: FeltStyle.values.firstWhere((v) => feltId(v) == item.id),
              padding: const EdgeInsets.all(12),
              child: const Center(
                child: PlayingCardView(
                  card: PlayingCard(suit: Suit.hearts, rank: Rank.ace, faceUp: true),
                  width: 34,
                ),
              ),
            ),
          ),
        CosmeticKind.celebration => _CelebrationPreview(
            style: CelebrationStyle.values.firstWhere((v) => celebrationId(v) == item.id),
          ),
      };
}

// Loops the celebration so players can see what they're buying.
class _CelebrationPreview extends StatefulWidget {
  const _CelebrationPreview({required this.style});

  final CelebrationStyle style;

  @override
  State<_CelebrationPreview> createState() => _CelebrationPreviewState();
}

class _CelebrationPreviewState extends State<_CelebrationPreview> {
  int _loop = 0;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 120,
          height: 100,
          color: const Color(0xFF1F2937),
          child: MediaQuery.disableAnimationsOf(context)
              ? Icon(Icons.celebration_rounded, color: AppColors.gold.withValues(alpha: 0.9), size: 40)
              : ConfettiBurst(
                  key: ValueKey(_loop),
                  count: 18,
                  style: widget.style,
                  duration: const Duration(milliseconds: 2400),
                  onDone: () {
                    if (mounted) setState(() => _loop++);
                  },
                ),
        ),
      );
}
