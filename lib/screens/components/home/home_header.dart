import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';
import '../../../widgets/custom_snackbar.dart';
import 'profile_switcher.dart';

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
    } catch (e) {
      // Дүнгүй үлдээгээд алдааг мэдэгдэнэ
      if (!mounted) return;
      CustomSnackbar.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    // Шинэ (хараагүй) push notification байвал хонхон дээр улаан цэг гарна.
    // Firebase init амжилтгүй үед provider бүртгэгдээгүй байж болно.
    bool hasUnseenNotification = false;
    try {
      hasUnseenNotification = context.watch<NotificationService>().hasUnseen;
    } on ProviderNotFoundException {
      // FCM ажиллаагүй орчин — цэг харуулахгүй
    }

    // Хүүхдийн данс идэвхтэй бол түүний дүнг харуулна
    final activeChild = context.watch<AuthService>().activeSubAccount;
    final displayTotal = activeChild?.amount ?? _totalAssets;

    // "50,628,000.53₮" → бүхэл ба бутархай хэсгийг тусад нь загварчилна
    final formatted = displayTotal == null
        ? ''
        : formatStockAmount(displayTotal, decimals: 2);
    final dotIdx = formatted.indexOf('.');
    final whole = dotIdx == -1 ? formatted : formatted.substring(0, dotIdx);
    final fraction = dotIdx == -1 ? '' : formatted.substring(dotIdx);

    return AppBar(
      backgroundColor: extendedColors.bgBase,
      elevation: 0,
      // Зүүн талд профайл солигч (өөрийн/хүүхдийн данс)
      leadingWidth: 84,
      leading: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: ProfileSwitcher(),
        ),
      ),
      // Scroll хийхэд өнгө өөрчлөгдөхөөс сэргийлнэ (M3 surface tint)
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      // Доод border — scroll хийхэд (summary харагдахтай зэрэг) илэрнэ
      shape: Border(
        bottom: BorderSide(
          color: extendedColors.neutral500.withValues(
            alpha: extendedColors.neutral500.a * widget.showSummaryOpacity,
          ),
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Opacity(
        opacity: widget.showSummaryOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.totalAssets,
              style: theme.textTheme.labelMedium?.copyWith(
                color: extendedColors.neutral200,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (displayTotal != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    whole,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                  ),
                  if (fraction.isNotEmpty)
                    Text(
                      fraction,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: extendedColors.neutral200,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/education'),
          icon: const CustomSvgIcon('book-open-01', size: 24),
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: const CustomSvgIcon('bell-02', size: 24),
            ),
            if (hasUnseenNotification)
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
