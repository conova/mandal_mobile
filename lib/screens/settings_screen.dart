import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.uiComponentsShowcase),
            subtitle: Text(l10n.uiComponentsSubtitle),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/components');
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: Text(l10n.theme),
            subtitle: Text(l10n.themeColorsSubtitle),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/theme_colors');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: Text(Localizations.localeOf(context).languageCode.toUpperCase()),
          ),
          // Add more settings items here
        ],
      ),
    );
  }
}
