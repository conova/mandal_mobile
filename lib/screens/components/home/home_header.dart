import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_api_service.dart';
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

  /// FCM ажиллаагүй орчинд (NotificationService provider байхгүй)
  /// unread_count-ыг локалд хадгална
  int _localUnread = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchTotal);
    Future.microtask(_fetchUnreadCount);
  }

  /// Нүүр нээгдэхэд notification list-ийг эхний байдлаар (limit 1) дуудаж
  /// unread_count-ыг хонхны badge-д тавина
  Future<void> _fetchUnreadCount() async {
    try {
      final feed =
          await context.read<NotificationApiService>().list(limit: 1);
      if (!mounted) return;
      try {
        // NotificationService-д тавьснаар FCM push ирэхэд +1 нэмэгдэж,
        // мэдэгдлийн дэлгэц дээр уншихад буурна
        context.read<NotificationService>().setUnreadCount(feed.unreadCount);
      } on ProviderNotFoundException {
        setState(() => _localUnread = feed.unreadCount);
      }
    } catch (_) {
      // Badge-гүй үлдээнэ — дараагийн нээлтэд дахин татна
    }
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

    // Уншаагүй мэдэгдлийн тоо — хонхон дээр badge-ээр гарна.
    // Firebase init амжилтгүй үед provider бүртгэгдээгүй байж болно.
    int unreadBadge = _localUnread;
    try {
      unreadBadge = context.watch<NotificationService>().unreadCount;
    } on ProviderNotFoundException {
      // FCM ажиллаагүй орчин — API-с татсан локал тоог харуулна
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
      leadingWidth: 0,
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
      titleSpacing: 0,
      title: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 16,
            child: ProfileSwitcher(),
          ),
          Center(
            child: Opacity(
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
          ),
          Positioned(
            right: 8,
            child: Opacity(
              opacity: 1.0 - widget.showSummaryOpacity,
              child: IgnorePointer(
                ignoring: widget.showSummaryOpacity > 0.5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/education'),
                      icon: const CustomSvgIcon('book-open-01', size: 24),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/notifications'),
                          icon: const CustomSvgIcon('bell-02', size: 24),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 10),
                        ),
                        if (unreadBadge > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                constraints: const BoxConstraints(minWidth: 22),
                                decoration: BoxDecoration(
                                    color: colorScheme.error,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: extendedColors.bgBase, width: 2)),
                                child: Text(
                                  unreadBadge > 99 ? '99+' : unreadBadge.toString(),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/profile'),
                      icon: const CustomSvgIcon('user-03', size: 24),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      actions: [

      ],
    );
  }
}
