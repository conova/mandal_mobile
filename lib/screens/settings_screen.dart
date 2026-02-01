import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'components/settings/settings_list_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SettingsListItem(
            icon: Icons.palette,
            title: l10n.uiComponentsShowcase,
            subtitle: l10n.uiComponentsSubtitle,
            onTap: () {
              Navigator.pushNamed(context, '/components');
            },
          ),
          SettingsListItem(
            icon: Icons.color_lens_outlined,
            title: l10n.theme,
            subtitle: l10n.themeColorsSubtitle,
            onTap: () {
              Navigator.pushNamed(context, '/theme_colors');
            },
          ),
          const Divider(),
          SettingsListItem(
            icon: Icons.language,
            title: l10n.language,
            trailing: Text(
              Localizations.localeOf(context).languageCode.toUpperCase(),
            ),
            showArrow: false,
          ),
          // Add more settings items here
        ],
      ),
    );
  }
}
