import 'package:flutter/material.dart';
import '../theme/app_state_manager.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool showLabel;
  
  const LanguageSwitcher({
    super.key,
    this.showLabel = true,
  });

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
                currentLocale == 'mn' ? 'MN' : 'EN',
                style: TextStyle(
                  color: colorScheme.onBackground,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFlag(String locale) {
    final flagUrl = locale == 'mn'
        ? 'https://flagcdn.com/w20/mn.png'
        : 'https://flagcdn.com/w20/gb.png';
    
    return Image.network(
      flagUrl,
      width: 20,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.language, size: 16),
    );
  }
}
