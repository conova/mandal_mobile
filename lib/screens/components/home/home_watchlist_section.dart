import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../watchlist_detail_screen.dart' show WatchlistStock;

/// Home-ийн доорх watchlist хэсэг — API-аас бодит datasource татна.
/// Минут тутамд автомат refresh хийнэ.
class HomeWatchlistSection extends StatefulWidget {
  const HomeWatchlistSection({super.key});

  @override
  State<HomeWatchlistSection> createState() => _HomeWatchlistSectionState();
}

class _HomeWatchlistSectionState extends State<HomeWatchlistSection> {
  static const int _previewCount = 5; // home дээр харагдах дээд тоо
  static const Duration _refreshInterval = Duration(minutes: 1);

  List<WatchlistStock> _items = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetch();
    // _refreshTimer = Timer.periodic(_refreshInterval, (_) => _fetch());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final auth = context.read<AuthService>();
      final raw = await auth.getWatchlist();
      if (!mounted) return;
      setState(() {
        _items = raw.map(WatchlistStock.fromApi).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final preview = _items.take(_previewCount).toList();
    final total = _items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.watchlist,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_items.isNotEmpty)
              GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(context, '/add_watchlist');
                  _fetch(); // буцаж ирэхэд шинэчлэх
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: extendedColors.primaryMain,
                    shape: BoxShape.circle,
                  ),
                  child: const CustomSvgIcon(
                    'plus',
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 25),
        if (_isLoading && _items.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_items.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: extendedColors.primaryMain.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: CustomSvgIcon(
                    'star',
                    size: 32,
                    color: extendedColors.primaryMain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.askingWatchlist,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    l10n.watchlistDescription,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral100,
                      fontWeight: AppTextStyles.extraLight,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 130,
                  child: CustomButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/add_watchlist');
                      _fetch();
                    },
                    label: l10n.add,
                    icon: const CustomSvgIcon('plus', size: 18),
                    size: CustomButtonSize.small,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.stocks,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral200,
                ),
              ),
              Text(
                l10n.lastPrice24h,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral200,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...preview.map((s) => _buildItem(s, extendedColors, context)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/watchlist_detail');
                _fetch(); // буцаж ирэхэд шинэчлэх
              },
              label: '${l10n.viewAll} ($total)',
              variant: CustomButtonVariant.tertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItem(
    WatchlistStock s,
    ExtendedColors extendedColors,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        '/stock_detail',
        arguments: {
          'symbol': s.symbol,
          'name': s.name,
          'price': s.price,
          'change': s.change,
          'isGrowing': s.isPositive,
          'stockcode': s.stockcode,
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.symbol,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    s.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: AppTextStyles.light,
                      color: extendedColors.neutral200,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    s.price,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (s.isPositive != null) ...[
                        CustomSvgIcon(
                          s.isPositive! ? 'button-up' : 'button-down',
                          size: 6,
                          color: s.isPositive!
                              ? extendedColors.primaryMain
                              : extendedColors.red,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        s.change,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: s.isPositive == null
                              ? extendedColors.neutral200
                              : (s.isPositive!
                                  ? extendedColors.primaryMain
                                  : extendedColors.red),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
