import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../theme/app_text_styles.dart';

class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/key.png',
                          width: 90,
                          height: 90,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.youAreBlocked,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: extendedColors.neutral100,
                        fontWeight: AppTextStyles.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.blockedReason,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ]
                ),
              ),
              const SizedBox(height: 40,),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: l10n.releaseBlock,
                  onPressed: () => Navigator.of(context).pop(),
                  variant: CustomButtonVariant.primary,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: l10n.returnToLogin,
                  onPressed: () => Navigator.of(context).pop(),
                  variant: CustomButtonVariant.secondary,
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
