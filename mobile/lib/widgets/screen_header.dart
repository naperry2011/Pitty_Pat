import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

// Back button + display title used by the secondary screens. The title scales
// down rather than overflowing on narrow phones or large system text.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const BackButton(),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: displayFontFamily(context),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.coralDeep,
                  ),
                ),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      );
}
