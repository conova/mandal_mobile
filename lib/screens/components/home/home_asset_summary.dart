import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/extended_colors.dart';

class HomeAssetSummary extends StatefulWidget {
  const HomeAssetSummary({super.key});

  @override
  State<HomeAssetSummary> createState() => _HomeAssetSummaryState();
}

class _HomeAssetSummaryState extends State<HomeAssetSummary> {
  PortfolioSummary _summary = PortfolioSummary.empty;

  @override
  void initState() {
    super.initState();
    // Background fetch — UI блоклохгүй. PortfolioSummary.empty (0₮) утгаараа
    // шууд рендерлэгдэх ба API ирэхэд аяндаа шинэчилнэ.
    Future.microtask(_fetch);
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    try {
      final auth = context.read<AuthService>();
      final summary = await auth.getPortfolioSummary();
      if (!mounted) return;
      setState(() => _summary = summary);
    } catch (e) {
      // Silent fail — UI default утгаараа үлдэнэ
      debugPrint('[HomeAssetSummary] алдаа: $e');
    }
  }

  /// 50,628,000.21 → ('50,628,000', '.21')
  (String, String) _splitAmount(double value) {
    final str = value.toStringAsFixed(2);
    final dotIdx = str.indexOf('.');
    final wholePart = str.substring(0, dotIdx);
    final decPart = str.substring(dotIdx); // includes '.'
    final wholeWithCommas = wholePart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return (wholeWithCommas, '$decPart₮');
  }

  /// 210351.52 → '+210,351.52₮' / '-210,351.52₮'
  String _formatChange(double value) {
    final sign = value >= 0 ? '+' : '-';
    final absStr = value.abs().toStringAsFixed(2);
    final dotIdx = absStr.indexOf('.');
    final whole = absStr
        .substring(0, dotIdx)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$sign$whole${absStr.substring(dotIdx)}₮';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    // Хүүхдийн данс идэвхтэй бол түүний нийт дүнг (өөрчлөлт 0) харуулна
    final activeChild = context.watch<AuthService>().activeSubAccount;
    final totalAssets = activeChild?.amount ?? _summary.totalAssets;
    final totalChange = activeChild == null ? _summary.totalChange : 0.0;
    final changePercent = activeChild == null ? _summary.changePercent : 0.0;

    final (whole, decimal) = _splitAmount(totalAssets);
    final changeStr = _formatChange(totalChange);
    final percentStr = '${changePercent.abs().toStringAsFixed(2)}%';
    final isUp = totalChange >= 0;
    final changeColor =
        isUp ? extendedColors.primaryMain : extendedColors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.totalAssets,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: AppTextStyles.light,
            color: extendedColors.neutral100,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                whole,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: AppTextStyles.semiBold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              decimal,
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: AppTextStyles.semiBold,
                color: extendedColors.neutral300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              changeStr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: changeColor,
                fontWeight: AppTextStyles.light,
              ),
            ),
            const SizedBox(width: 4),
            CustomSvgIcon('divider-icon', size: 15, color: extendedColors.primaryMain,),
            const SizedBox(width: 4),
            if (isUp)
              const CustomSvgIcon(
                'button-up',
                size: 6,
                color: AppColors.primaryMain,
              )
            else
              const CustomSvgIcon(
                'button-down',
                size: 6,
                color: AppColors.redMain,
              ),
            const SizedBox(width: 4),
            Text(
              '$percentStr ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: changeColor,
                fontWeight: AppTextStyles.light,
              ),
            ),
            Text(
              '(${l10n.last1Month})',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: AppTextStyles.light,
                color: extendedColors.neutral100,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
