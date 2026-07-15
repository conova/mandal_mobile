import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_button.dart';

/// "Бонд барьцаалах" banner — гэгээн ногоон gradient дэвсгэр, баруун дээд
/// буланд pig.png, гарчгийн доор teal зураас, голд нь 2 үзүүлэлт,
/// доор нь бүтэн өргөнтэй товч.
class PledgeBondBanner extends StatelessWidget {
  /// "Бонд барьцаалах" товч — заагаагүй бол шууд сонгох дэлгэц рүү шилжинэ.
  /// Барьцаалах бонд байхгүй үед sheet харуулах г.м. шийдвэрийг эцэг
  /// дэлгэц эндээс өгнө.
  final VoidCallback? onPledgePressed;

  const PledgeBondBanner({super.key, this.onPledgePressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [extendedColors.primary100, extendedColors.bgBase],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Гахайн зураг — баруун дээд булан
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/images/pig.png',
              width: 128,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Гарчиг — зурагтай мөргөлдөхгүйн тулд баруун талд зай үлдээнэ
                Padding(
                  padding: const EdgeInsets.only(right: 128),
                  child: Text(
                    l10n.pledgeBond,
                    style: AppTextStyles.title1Condensed.copyWith(
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Teal доогуур зураас
                Container(
                  width: 32,
                  height: 5,
                  decoration: BoxDecoration(color: extendedColors.primaryMain),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(right: 100),
                  child: Text(
                    l10n.pledgeBondDesc,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: AppTextStyles.light,
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Үзүүлэлтүүд — голдоо босоо зураасаар тусгаарлагдсан
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildBannerMetric(
                          theme,
                          l10n.availableAmountLabel,
                          '23,000,000₮',
                          extendedColors,
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: extendedColors.neutral400,
                      ),
                      Expanded(
                        child: _buildBannerMetric(
                          theme,
                          l10n.costLabel,
                          'Бондын хүү +6%',
                          extendedColors,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: l10n.pledgeBond,
                    onPressed: onPledgePressed ??
                        () => Navigator.pushNamed(
                              context,
                              '/pledge_bond_select',
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerMetric(
    ThemeData theme,
    String label,
    String value,
    ExtendedColors extendedColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: AppTextStyles.extraLight,
            color: extendedColors.neutral300,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: extendedColors.neutral100,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
