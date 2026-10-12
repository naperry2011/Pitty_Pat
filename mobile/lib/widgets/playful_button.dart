import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

// Port of .btn-playful (primary) and the white secondary button.
class PlayfulButton extends StatefulWidget {
  const PlayfulButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
    this.fontSize = 20,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final double fontSize;

  @override
  State<PlayfulButton> createState() => _PlayfulButtonState();
}

class _PlayfulButtonState extends State<PlayfulButton> {
  bool _pressed = false;

  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final fg = widget.primary ? Colors.white : AppColors.ink;

    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52, minWidth: 160),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: widget.primary
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.coral, Color(0xFFFF8E8E)],
                    )
                  : null,
              color: widget.primary ? null : Colors.white.withValues(alpha: 0.85),
              boxShadow: widget.primary
                  ? const [
                      BoxShadow(
                        color: Color(0x80FF6B6B),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                        spreadRadius: -3,
                      ),
                    ]
                  : AppShadows.card,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: fg, size: widget.fontSize + 2),
                  const SizedBox(width: 8),
                ],
                // Long labels or large system text shrink instead of overflowing.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: displayFontFamily(context),
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
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
