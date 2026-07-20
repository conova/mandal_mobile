import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import '../../../theme/app_text_styles.dart';

class OnboardingStep {
  final String title;
  final String description;
  final String image;
  final bool isCompleted;
  final VoidCallback? onTap;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.image,
    this.isCompleted = false,
    this.onTap,
  });
}

class OnboardingStepsSheet extends StatelessWidget {
  final List<OnboardingStep> steps;
  final double progress;
  final VoidCallback onContinue;

  const OnboardingStepsSheet({
    super.key,
    required this.steps,
    required this.progress,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final percent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            decoration: BoxDecoration(
              color: extendedColors.bgBase,
              borderRadius: BorderRadius.zero,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.disabledColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.preparationWork,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.preparationDesc,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral200,
                    fontWeight: AppTextStyles.light,
                  ),
                ),
                const SizedBox(height: 8),
                ...steps.map((step) => _buildStepItem(context, step)),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Shrinks the row to fit its children
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          l10n.registrationProgress(percent.toString()),
                          style: AppTextStyles.body2.copyWith(
                            color: extendedColors.neutral200,
                            fontWeight: AppTextStyles.light,
                          ),
                        ),
                        Text(
                          "$percent%",
                          style: AppTextStyles.body2.copyWith(
                            color: extendedColors.neutral100,
                            fontWeight: AppTextStyles.regular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: extendedColors.neutral500, width: 1.0),
              ),
            ),
            child: CustomButton(
              label: l10n.continueLabel,
              onPressed: onContinue,
              variant: CustomButtonVariant.primary,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, OnboardingStep step) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return InkWell(
      onTap: step.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Image.asset(step.image, height: 48, width: 48,),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppTextStyles.body1.copyWith(
                      color: extendedColors.neutral100,
                      fontWeight: AppTextStyles.light,
                    ),
                  ),
                  Text(
                    (step.isCompleted == true)
                        ? (step.title ==
                                  AppLocalizations.of(
                                    context,
                                  )!.securitiesAgreement
                              ? AppLocalizations.of(context)!.agreed
                              : AppLocalizations.of(context)!.success)
                        : step.description,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: AppTextStyles.light,
                      color: (step.isCompleted == true)
                          ? extendedColors.primaryMain
                          : extendedColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
            if (step.isCompleted == true)
              Stack(
                children: [
                  CustomSvgIcon('check-circle', color: extendedColors.primaryMain),
                  Padding(
                    padding: EdgeInsets.only(left: 7, top: 8, bottom: 8, right: 8),
                    child: CustomSvgIcon('check', color: Colors.white, size: 8,),
                  ),
                ],
              )
            else
              CustomSvgIcon('chevron-right', color: theme.disabledColor),
          ],
        ),
      ),
    );
  }
}
