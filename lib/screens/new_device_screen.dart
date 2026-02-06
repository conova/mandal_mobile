import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_button.dart';

class NewDeviceScreen extends StatelessWidget {
  const NewDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dpBgBase : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              // Icon Container
              Container(
                width: 112,
                height: 112,
                margin: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: extendedColors.bgSecondary,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/padlock.png',
                    width: 88,
                    height: 88,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                  l10n.newDeviceTitle,
                  style: AppTextStyles.h2.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: AppTextStyles.semiBold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 24),
              // Description
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                  l10n.newDeviceDescription,
                  style: AppTextStyles.body2.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: AppTextStyles.extraLight,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 64),
              // Buttons
              CustomButton(
                label: l10n.verify,
                onPressed: () {
                  Navigator.pushNamed(context, '/login_verification');
                },
                fullWidth: true,
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: l10n.back,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                variant: CustomButtonVariant.secondary,
                fullWidth: true,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
