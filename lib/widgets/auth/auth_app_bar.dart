import 'package:flutter/material.dart';
import '../language_switcher.dart';
import '../logo.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showLogo;
  final VoidCallback? onClose;

  const AuthAppBar({super.key, this.showLogo = true, this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leadingWidth: 70,
      leading: showLogo
          ? Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 12),
              child: Center(
                child: AppLogo(
                  width: 40,
                  height: 40,
                  color: colorScheme.primary,
                ),
              ),
            )
          : null,
      actions: [
        const LanguageSwitcher(),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          child: InkWell(
            onTap: onClose ?? () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(16), // Half of 32 for a circle
            child: SizedBox(
              width: 32,
              height: 32,
              child: Icon(
                Icons.close,
                color: colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
