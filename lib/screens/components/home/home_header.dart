import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';

class HomeHeader extends StatefulWidget implements PreferredSizeWidget {
  final double showSummaryOpacity;
  const HomeHeader({super.key, this.showSummaryOpacity = 0.0});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeHeaderState extends State<HomeHeader> {
  /// Нийт хөрөнгө — /portfolio/summary-аас (null бол хараахан ирээгүй)
  double? _totalAssets;

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchTotal);
  }

  Future<void> _fetchTotal() async {
    try {
      final summary = await context.read<AuthService>().getPortfolioSummary();
      if (!mounted) return;
      setState(() => _totalAssets = summary.totalAssets);
    } catch (_) {
      // Татагдаагүй бол дүнгүй (хоосон) үлдээнэ
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    // "50,628,000.53₮" → бүхэл ба бутархай хэсгийг тусад нь загварчилна
    final formatted = _totalAssets == null
        ? ''
        : formatStockAmount(_totalAssets, decimals: 2);
    final dotIdx = formatted.indexOf('.');
    final whole = dotIdx == -1 ? formatted : formatted.substring(0, dotIdx);
    final fraction = dotIdx == -1 ? '' : formatted.substring(dotIdx);

    return AppBar(
      backgroundColor: extendedColors.bgBase,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Opacity(
        opacity: widget.showSummaryOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.totalAssets,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.disabledColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (_totalAssets != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    whole,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (fraction.isNotEmpty)
                    Text(
                      fraction,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.disabledColor,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: const CustomSvgIcon('bell-02', size: 24),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          icon: const CustomSvgIcon('user-03', size: 24),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
