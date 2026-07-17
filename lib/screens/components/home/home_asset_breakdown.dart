import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/asset_card.dart';
import '../../../widgets/custom_snackbar.dart';

class HomeAssetBreakdown extends StatefulWidget {
  const HomeAssetBreakdown({super.key});

  @override
  State<HomeAssetBreakdown> createState() => _HomeAssetBreakdownState();
}

class _HomeAssetBreakdownState extends State<HomeAssetBreakdown> {
  /// API хариу хүртэлх default — UI шууд харагдахын тулд хоосон тулсан
  /// asset-уудыг нүдэнд харагдуулна (₮ + $ + бонд + хувьцаа).
  static const List<Map<String, dynamic>> _placeholderItems = [
    {'type': 'mnt', 'amount': 0, 'count': 0},
    {'type': 'usd', 'amount': 0, 'count': 0},
    {'type': 'bond', 'amount': 0, 'count': 0},
    {'type': 'stock', 'amount': 0, 'count': 0},
  ];

  /// Дата ирсэн эсэх — true бол `_items`-ийг харуулна, false бол placeholder.
  bool _loaded = false;
  List<Map<String, dynamic>> _items = const [];

  /// Эзэмшдэг бонд/хувьцааны тойм — mybonds/mystocks API-аас (null бол
  /// хараахан ирээгүй; breakdown-ийн count-ийг ашиглана)
  int? _myBondCount;
  int? _myStockCount;

  @override
  void initState() {
    super.initState();
    // Background fetch — UI блоклохгүй.
    Future.microtask(_fetch);
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    try {
      final auth = context.read<AuthService>();
      // 3 API-г зэрэг дуудна: breakdown + миний бонд/хувьцааны тойм
      final results = await Future.wait([
        auth.getAssetBreakdown(),
        auth.getMyBonds().catchError((_) => <Map<String, dynamic>>[]),
        auth.getMyStocks().catchError((_) => <Map<String, dynamic>>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _items = results[0];
        _myBondCount = results[1].length;
        _myStockCount = results[2].length;
        _loaded = true;
      });
    } catch (e) {
      // Placeholder харагдсаар үлдэх ч алдааг мэдэгдэнэ
      if (!mounted) return;
      CustomSnackbar.showError(context, e);
    }
  }

  /// type/symbol → (icon, fallback route, fallback iconColor)
  ({Widget icon, String route, Color? color}) _meta(
    String? type,
    ExtendedColors extendedColors,
  ) {
    final t = (type ?? '').toLowerCase();
    switch (t) {
      case 'mnt':
      case 'cash':
      case 'tugrik':
        return (
          icon: CustomSvgIcon('tugrug-01', size: 24, color: extendedColors.bgBase,),
          route: '/currency_detail',
          color: null,
        );
      case 'usd':
      case 'dollar':
        return (icon: CustomSvgIcon('currency-dollar', size: 24, color: extendedColors.bgBase,), route: '/currency_detail', color: null);
      case 'bond':
      case 'bonds':
        return (
          icon: const CustomSvgIcon('bank-note-01', size: 24, color: AppColors.bgBase,),
          route: '/bond_portfolio',
          color: extendedColors.purple,
        );
      case 'stock':
      case 'stocks':
      case 'equity':
        return (
          icon: const CustomSvgIcon('coins-swap-02', size: 24, color: AppColors.bgBase,),
          route: '/stock_portfolio',
          color: extendedColors.orange,
        );
      default:
        return (
          icon: const CustomSvgIcon('wallet-01', size: 24, color: AppColors.bgBase,),
          route: '/stock_portfolio',
          color: extendedColors.neutral300,
        );
    }
  }

  String _formatAmount(num n, String currency) {
    final str = n.toStringAsFixed(2);
    final dotIdx = str.indexOf('.');
    final whole = str
        .substring(0, dotIdx)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$whole${str.substring(dotIdx)}$currency';
  }

  /// API хариугаас хамаарч дэлгэцэн дээр render хийх жагсаалт буцаана:
  ///   • Хариу ирээгүй / ирсэн ч хоосон → placeholder (4 нэр төрөл)
  ///   • Хариу ирсэн, дата бий → жинхэнэ дата
  List<Map<String, dynamic>> _renderItems() {
    if (_loaded && _items.isNotEmpty) return _items;
    return _placeholderItems;
  }

  /// type → орчуулагдсан default нэр
  String _defaultName(String? type, AppLocalizations l10n) {
    switch ((type ?? '').toLowerCase()) {
      case 'usd':
      case 'dollar':
        return l10n.dollar;
      case 'bond':
      case 'bonds':
        return l10n.bonds;
      case 'stock':
      case 'stocks':
      case 'equity':
        return l10n.stocks;
      case 'mnt':
      case 'cash':
      case 'tugrik':
      default:
        return l10n.tugrik;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.assetBreakdown,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: AppTextStyles.semiBold,
          ),
        ),
        const SizedBox(height: 16),
        // 1) API хариу ирээгүй → placeholder asset-уудыг шууд харуулна
        // 2) API хариу ирсэн, гэхдээ хоосон → "бүртгэлгүй" мессеж
        // 3) API хариу ирсэн, дата бий → жинхэнэ item-уудыг харуулна
        ..._renderItems().map((item) {
            final type = item['type']?.toString();
            final name = item['name']?.toString() ?? _defaultName(type, l10n);
            final amount = (item['amount'] as num?) ?? 0;
            // Бонд/хувьцааны тоог mybonds/mystocks-ийн бодит тоймоор
            // солино (ирээгүй бол breakdown-ийн count хэвээр)
            final typeLower = type?.toLowerCase();
            final overrideCount = typeLower == 'bond' || typeLower == 'bonds'
                ? _myBondCount
                : (typeLower == 'stock' ||
                        typeLower == 'stocks' ||
                        typeLower == 'equity'
                    ? _myStockCount
                    : null);
            final count =
                overrideCount ?? (item['count'] as num?)?.toInt() ?? 0;
            final currency = item['currency']?.toString() ??
                (type?.toLowerCase() == 'usd' ? '\$' : '₮');
            final meta = _meta(type, extendedColors);
            final subtitle = type?.toLowerCase() == 'mnt' ||
                    type?.toLowerCase() == 'usd' ||
                    type?.toLowerCase() == 'cash' ||
                    type?.toLowerCase() == 'tugrik' ||
                    type?.toLowerCase() == 'dollar'
                ? l10n.orderCount(count.toString())
                : '$count ${l10n.type}';

            return AssetCard(
              icon: meta.icon,
              title: name,
              subtitle: subtitle,
              amount: _formatAmount(amount, currency),
              iconColor: meta.color,
              isDark: type?.toLowerCase() == 'usd',
              onTap: () => Navigator.pushNamed(
                context,
                meta.route,
                arguments: type?.toLowerCase(),
              ),
            );
          }),
      ],
    );
  }
}
