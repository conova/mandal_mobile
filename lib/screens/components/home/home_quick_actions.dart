import 'package:flutter/material.dart';
import '../../../widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CustomButton(
              label: l10n.income,
              variant: CustomButtonVariant.primary,
              size: CustomButtonSize.small,
              icon: Icons.add,
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CustomButton(
              label: l10n.expense,
              variant: CustomButtonVariant.tertiary,
              size: CustomButtonSize.small,
              icon: Icons.north_east,
              onPressed: () {},
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CustomButton(
              label: l10n.history,
              variant: CustomButtonVariant.tertiary,
              size: CustomButtonSize.small,
              icon: Icons.history,
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
