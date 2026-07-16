import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../theme/app_state_manager.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showLabel;

  const LanguageSwitcher({super.key, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLocale = AppStateManager.instance.locale.languageCode;

    return GestureDetector(
      onTap: () {
        final newLocale = currentLocale == 'mn' ? 'en' : 'mn';
        AppStateManager.instance.setLocale(Locale(newLocale));
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFlag(currentLocale),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                currentLocale == 'mn' ? 'MN' : 'ENG',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFlag(String locale) {
    if (locale == 'mn') {
      return const CustomSvgIcon(
        'mongolian-flag',
        size: 16,
        preserveColors: true,
      );
    } else {
      return const CustomSvgIcon(
        'english-flag',
        size: 16,
        preserveColors: true,
      );
    }
  }
}
