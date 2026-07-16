import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../../../l10n/app_localizations.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final double showSummaryOpacity;
  const HomeHeader({super.key, this.showSummaryOpacity = 0.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: extendedColors.bgBase,
      elevation: 0,
      centerTitle: true,
      // Зүүн талын leading icon байхгүй — `Icons.book` placeholder
      // нь өмнө empty onPressed-тэй сууж байсныг устгав.
      automaticallyImplyLeading: false,
      title: Opacity(
        opacity: showSummaryOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.totalAssets,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.disabledColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '50,628,000',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '.53₮',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.disabledColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: const CustomSvgIcon('bell-02', size: 24,),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          icon: const CustomSvgIcon('user-03', size: 24,),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
