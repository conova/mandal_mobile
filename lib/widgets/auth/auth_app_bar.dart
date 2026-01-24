import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../language_switcher.dart';
import '../logo.dart';

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showLogo;
  final VoidCallback? onClose;

  const AuthAppBar({
    super.key,
    this.showLogo = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.background,
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
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.close, color: colorScheme.onBackground, size: 20),
            onPressed: onClose ?? () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
