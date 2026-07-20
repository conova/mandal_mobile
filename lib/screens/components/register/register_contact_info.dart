import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_state_manager.dart';
import '../../../theme/extended_colors.dart';

class RegisterContactInfo extends StatelessWidget {
  const RegisterContactInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final appState = AppStateManager.instance;

    if (appState.locale.languageCode == 'mn') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.registerContactPrefix,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral200,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: Text(
                  'info@mandal.capital',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.registerContactPostfix,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral200,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.registerContactPrefix,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral200,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.registerContactPostfix,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral200,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'info@mandal.capital',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral200,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      );
    }
  }
}
