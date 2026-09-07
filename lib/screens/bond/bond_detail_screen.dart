import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/stock_row_format.dart';
import '../../models/market_instrument.dart';
import '../../models/order_book_entry.dart';
import '../../services/auth_service.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/custom_snackbar.dart';
import '../components/bond/bond_action_bottom_bar.dart';
import '../components/bond/bond_detail_closed_view.dart';
import '../components/bond/bond_detail_foreign_view.dart';
import '../components/bond/bond_detail_header.dart';
import '../components/bond/bond_detail_trading_view.dart';
import '../../l10n/app_localizations.dart';

/// Бондын дэлгэрэнгүй — бондын төлвөөс хамаарч 3 дизайнтай, вариант бүр
/// тусдаа component (screens/components/bond/):
///   • Хоёрдогч + хаалттай → [BondDetailClosedView]
///   • Хоёрдогч + нээлттэй → [BondDetailTradingView] (арилжаа)
///   • Гадаад + хоёрдогч  → [BondDetailForeignView]
class BondDetailScreen extends StatefulWidget {
  const BondDetailScreen({super.key});

  @override
  State<BondDetailScreen> createState() => _BondDetailScreenState();
}

class _BondDetailScreenState extends State<BondDetailScreen> {
  int _quantity = 0;
  double _price = 0;

  MarketInstrument? _bond;
  bool _argsParsed = false;
  
  bool _isLoading = true;
  PortfolioSummary? _portfolioSummary;
  AuthService? _authService;

  /// /stocks/order_book — авах/зарах талууд
  List<OrderBookEntry> _buyOrders = const [];
  List<OrderBookEntry> _sellOrders = const [];
  bool _orderBookLoading = true;

  /// Дэлгэц идэвхтэй байх үед самбарыг 5 секунд тутам шинэчилнэ
  Timer? _orderBookTimer;
  bool _orderBookFetching = false;

  @override
  void initState() {
    super.initState();
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
    _orderBookTimer?.cancel();
    super.dispose();
  }

  void _onAuthNotify() {
    if (mounted) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    try {
      final summary = await context.read<AuthService>().getPortfolioSummary();
      if (!mounted) return;
      setState(() {
        _portfolioSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsParsed) return;
    _argsParsed = true;
    // /stocks/* мөр arguments-аар ирнэ (bondlist, nbo, mybonds).
    // Хоёр бүтцийг дэмжинэ:
    //   • {'bond': {...}, 'languageCode': 'mn'} — BondMarketCard
    //   • {...} шууд түүхий мөр — home recommendation carousel
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is MarketInstrument) {
      _bond = args;
    } else if (args is Map) {
      if (args['bond'] is Map) {
        _bond = MarketInstrument.fromJson(
          Map<String, dynamic>.from(args['bond'] as Map),
        );
      } else if (!args.containsKey('bond')) {
        _bond = MarketInstrument.fromJson(Map<String, dynamic>.from(args));
      }
    }

    if (_bond != null) {
      _fetchOrderBook();

      // 5 секунд тутамд чимээгүй шинэчилнэ (dispose дээр зогсоно)
      if ((_bond?.stockcode ?? '').isNotEmpty) {
        _orderBookTimer?.cancel();
        _orderBookTimer = Timer.periodic(
          const Duration(seconds: 5),
          (_) => _fetchOrderBook(),
        );
      }
    }
  }


  Future<void> _fetchOrderBook() async {
    final stockcode = _bond?.stockcode ?? '';
    if (stockcode.isEmpty) {
      setState(() => _orderBookLoading = false);
      return;
    }
    if (_orderBookFetching) return;
    _orderBookFetching = true;
    try {
      final rows = await context.read<AuthService>().getOrderBook(stockcode);
      if (!mounted) return;
      setState(() {
        _buyOrders = OrderBookEntry.sideFromJson(rows, 'BUY');
        _sellOrders = OrderBookEntry.sideFromJson(rows, 'SELL');
        _orderBookLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final wasInitialLoad = _orderBookLoading;
      setState(() => _orderBookLoading = false);
      if (wasInitialLoad) CustomSnackbar.showError(context, e);
    } finally {
      _orderBookFetching = false;
    }
  }

  bool get _isForeign => _bond?.isForeign ?? false;
  bool get _isOpen => _bond?.isOpen ?? false;

  /// Гадаад → progress дизайн; нээлттэй → арилжааны дизайн;
  /// бусад (хаалттай / демо) → мэдээллийн дизайн
  bool get _isTrading => _bond != null && !_isForeign && _isOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircleBackButton(),
          ),
        ),
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BondDetailHeader(
                bond: _bond,
                showAvailableCash: _isTrading,
                availableCash: (_portfolioSummary?.cashBalance ?? 0) - (_portfolioSummary?.holdAmount ?? 0),
              ),
              const SizedBox(height: 24),
              if (_isTrading)
                BondDetailTradingView(
                  bond: _bond,
                  price: _price,
                  quantity: _quantity,
                  onQuantityChanged: (q) => setState(() => _quantity = q),
                  onPriceChanged: (p) => setState(() => _price = p),
                  buyOrders: _buyOrders,
                  sellOrders: _sellOrders,
                )
              else if (_isForeign)
                BondDetailForeignView(bond: _bond)
              else
                BondDetailClosedView(bond: _bond),
              const SizedBox(height: 140), // Bottom bar space
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isTrading
          ? BondDetailTradingBottomBar(
              bond: _bond,
              price: _price,
              quantity: _quantity,
              lockedAmount: _portfolioSummary?.holdAmount,
            )
          : BondActionBottomBar(
              label: l10n.availableCash,
              amount: formatStockAmount(
                (_portfolioSummary?.cashBalance ?? 0) - (_portfolioSummary?.holdAmount ?? 0),
                isForeign: _isForeign,
              ),
              buttonText: l10n.buyBond,
              onPressed: () =>
                  Navigator.pushNamed(context, '/bond_buy', arguments: _bond?.raw),
            ),
    );
  }
}
