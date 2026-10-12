import 'package:flutter/material.dart';

import '../cosmetics/catalog.dart';
import '../theme/tokens.dart';

// Port of the .game-table felt in app/globals.css; colors come from the equipped felt.
class FeltTable extends StatelessWidget {
  const FeltTable({
    super.key,
    required this.child,
    this.felt = FeltStyle.teal,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final FeltStyle felt;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.panel),
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.1,
            colors: [felt.light, felt.deep],
          ),
          border: Border.all(color: AppColors.cream.withValues(alpha: 0.35), width: 3),
          boxShadow: const [
            BoxShadow(color: Color(0x4D2D3142), blurRadius: 40, offset: Offset(0, 10), spreadRadius: -10),
          ],
        ),
        child: child,
      );
}
