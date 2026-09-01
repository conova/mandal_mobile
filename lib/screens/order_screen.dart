import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../services/auth_service.dart';
import '../widgets/custom_bottom_sheet.dart';
import '../widgets/custom_snackbar.dart';
import 'components/order/order_history_tab.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/order_card.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedFilter;

  bool _isLoading = true;
  bool _isCanceling = false;
  List<Order> _orders = const [];

  AuthService? _authService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _authService = context.read<AuthService>();
      _authService?.addListener(_onAuthNotify);
      _fetch();
    });
  }

  @override
  void dispose() {
    _authService?.removeListener(_onAuthNotify);
    _tabController.dispose();
    super.dispose();
  }

  void _onAuthNotify() {
    if (mounted) {
      _fetch();
    }
  }

  /// Сонгосон chip → API scope. Chip солиход API-г шинээр дуудна.
  String _scopeForFilter(AppLocalizations l10n) {
    if (_selectedFilter == l10n.bond) return 'bond';
    if (_selectedFilter == l10n.stocks) return 'stock';
    return 'all';
  }

  Future<void> _fetch() async {
    // Өмнөх шүүлтийн жагсаалт үлдэж харагдахгүйн тулд цэвэрлэнэ
    setState(() {
      _isLoading = true;
      _orders = const [];
    });
    try {
      final l10n = AppLocalizations.of(context)!;
      final rows = await context
          .read<AuthService>()
          .getActiveOrders(scope: _scopeForFilter(l10n));
      if (!mounted) return;
      setState(() {
        _orders = Order.listFromJson(rows);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, e);
    }
  }

  Future<void> _handleCancelAll() async {
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = Theme.of(context).extension<ExtendedColors>()!;

    final confirm = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => CustomBottomSheet(
          title: l10n.cancelAllOrders,
          description: l10n.cancelAllOrdersDesc,
          confirmText: l10n.remove,
          cancelText: l10n.back,
          onConfirm: () => Navigator.pop(ctx, true),
          onCancel: () => Navigator.pop(ctx, false),
          buttonVariantTop: CustomButtonVariant.primary,
        )
    );

    if (confirm != true) return;

    setState(() => _isCanceling = true);
    try {
      final auth = context.read<AuthService>();
      final cancelList = _orders
          .map((o) => {
                'TXNID': o.txnId,
                'ORDERNO': o.orderNo,
              })
          .toList();

      final msg = await auth.cancelOrders(cancelList);
      if (!mounted) return;
      CustomSnackbar.show(context, message: msg);
      // fetch() will be triggered by refreshActiveOrders() listener if we kept it
      // but here we call it explicitly as well to be safe or because it's local action
      await auth.refreshActiveOrders();
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(context, e);
    } finally {
      if (mounted) setState(() => _isCanceling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final List<String> filters = [l10n.all, l10n.bond, l10n.stocks];
    _selectedFilter ??= l10n.all;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: TabBar(
            controller: _tabController,
            indicatorColor: extendedColors.primaryMain,
            indicatorWeight: 4,
            labelColor: extendedColors.neutral100,
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
            ),
            tabs: [
              Tab(text: l10n.activeOrders),
              Tab(text: l10n.orderHistory),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(context, theme, extendedColors, l10n, filters),
          const OrderHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildOrderList(
    BuildContext context,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
    List<String> filters,
  ) {
    final lang = Localizations.localeOf(context).languageCode;
    final orders = _orders;

    return RefreshIndicator(
      onRefresh: _fetch,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            FilterChipBar(
              filters: filters,
              selectedFilter: _selectedFilter!,
              onFilterSelected: (selected) {
                setState(() => _selectedFilter = selected);
                // Chip солиход харгалзах endpoint-оос дахин татна
                _fetch();
              },
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (orders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/empty_orders.png',
                        height: 160,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: extendedColors.neutral400,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n.noActiveOrders,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: extendedColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          l10n.noActiveOrdersDesc,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w300,
                            color: extendedColors.neutral200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...orders.map(
                (order) => OrderCard(
                  companyName: order.symbol.isNotEmpty &&
                          order.symbol != order.name
                      ? order.symbol
                      : order.nameOf(lang),
                  subtitle: order.nameOf(lang),
                  amount: formatStockAmount(
                    order.totalWithFee,
                    isForeign: order.isForeignCurrency,
                  ),
                  price: formatStockAmount(
                    order.price,
                    isForeign: order.isForeignCurrency,
                  ),
                  execution: order.executionLabel,
                  date: order.orderDateLabel,
                  type: order.isBuy ? OrderType.buy : OrderType.sell,
                  status: order.isOpen ? OrderStatus.open : OrderStatus.closed,
                  market: order.isForeign
                      ? MarketType.foreign
                      : (order.isBond ? MarketType.bond : MarketType.stock),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/order_detail',
                    arguments: {'order': order},
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (!_isLoading && orders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomButton(
                  label: '${l10n.cancelAllOrders} (${orders.length})',
                  isLoading: _isCanceling,
                  onPressed: _isCanceling ? null : _handleCancelAll,
                  variant: CustomButtonVariant.red,
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 8),
              //   child: Center(
              //     child: GestureDetector(
              //       onTap: () {
              //         //
              //       },
              //       child: Text(
              //         '${l10n.cancelAllOrders} (${orders.length})',
              //         style: theme.textTheme.bodyLarge?.copyWith(
              //           color: extendedColors.red,
              //           decoration: TextDecoration.underline,
              //           decorationColor: extendedColors.red,
              //           decorationThickness: 2,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
