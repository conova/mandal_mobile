import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.book, color: colorScheme.onSurface),
        onPressed: () {},
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: Icon(Icons.notifications_outlined, color: colorScheme.onSurface),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: colorScheme.error, shape: BoxShape.circle),
              ),
            )
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          icon: Icon(Icons.person_outline, color: colorScheme.onSurface),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
