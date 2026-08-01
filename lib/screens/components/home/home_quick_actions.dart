import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
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
              icon: const CustomSvgIcon('plus', size: 20,),
              onPressed: () => Navigator.pushNamed(context, '/income_method'),
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
              icon: const CustomSvgIcon('reverse-right', size: 20,),
              onPressed: () => Navigator.pushNamed(context, '/withdraw_method'),
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
              icon: const CustomSvgIcon('clock-fast-forward', size: 20,),
              onPressed: () => Navigator.pushNamed(context, '/transaction_history'),
            ),
          ),
        ),
      ],
    );
  }
}
