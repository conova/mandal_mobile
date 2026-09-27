import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mandal_capital/screens/components/bond/bond_detail_trading_view.dart';
import 'package:provider/provider.dart';
import '../../common/stock_row_format.dart';
import '../../models/market_instrument.dart';
import '../../services/auth_service.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/custom_svg_icon.dart';
import '../components/bond/bond_action_bottom_bar.dart';
import '../components/bond/bond_detail_closed_view.dart';
import '../components/bond/bond_detail_foreign_view.dart';
import '../components/bond/bond_detail_header.dart';
import '../components/bond/bond_detail_primary_view.dart';
import '../components/bond/bond_detail_secondary_view.dart';
import '../../l10n/app_localizations.dart';

/// Бондын дэлгэрэнгүй — зах зээл/төлвөөс хамаарч вариант бүр тусдаа
/// component (screens/components/bond/):
///   • Анхдагч  → [BondDetailPrimaryView] (дүүргэлт, нэр нь bar дээр)
///   • Хоёрдогч → [BondDetailSecondaryView] (төлбөрийн хуваарь)
///   • Гадаад   → [BondDetailForeignView]
///
/// Захиалгыг дэлгэц дээр биш /bond_buy дээр өгнө.
class BondDetailScreen extends StatefulWidget {
  const BondDetailScreen({super.key});

  @override
  State<BondDetailScreen> createState() => _BondDetailScreenState();
}

class _BondDetailScreenState extends State<BondDetailScreen> {
  MarketInstrument? _bond;
  bool _argsParsed = false;
  
  bool _isLoading = true;
  PortfolioSummary? _portfolioSummary;
  AuthService? _authService;

  double _price = 0.0;
  int _quantity = 0;

  final GlobalKey _tintedHeaderKey = GlobalKey();
  double _headerHeight = 180.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _authService = context.read<AuthService>();
      _authService?.addListener(_onAuthNotify);
      _fetch();
      _measureHeader();
    });
  }

  void _measureHeader() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = _tintedHeaderKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && mounted) {
        final height = renderBox.size.height;
        if (_headerHeight != height) {
          setState(() {
            _headerHeight = height;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _authService?.removeListener(_onAuthNotify);
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
      _price = (_bond!.closePrice ?? _bond!.openPrice ?? 0).toDouble();
    }
  }

  bool get _isForeign => _bond?.isForeign ?? false;

  /// Анхдагч зах зээл → дүүргэлтийн дизайн
  bool get _isPrimary => _bond?.isPrimaryMarket ?? false;

  /// Бүх хоёрдогч бонд (нээлттэй эсэхээс үл хамаарч) → төлбөрийн
  /// хуваарийн дизайн
  bool get _isSecondary => _bond != null && !_isForeign && !_isPrimary;

  bool get _isBondOpen => (_bond?.isOpen ?? false) && !_isPrimary;

  /// Хоёрдогч болон гадаад дизайнд нэрийн блок нь өнгөт дэвсгэр,
  /// цэгэн хээтэй
  bool get _hasTintedHeader => _isSecondary || _isForeign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      appBar: _isBondOpen && !_isPrimary && !_isForeign ? AppBar(
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(width: 40, height: 40, child: CircleBackButton()),
        ),
      ) : null,
      backgroundColor: extendedColors.bgBase,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetch,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Анхдагч дизайнд нэр нь bar дээр, хоёрдогчид дээрх блокт
                      if (!_isPrimary && !_hasTintedHeader) ...[
                        BondDetailHeader(
                          bond: _bond,
                          availableCash: (_portfolioSummary?.cashBalance ?? 0) - (_portfolioSummary?.holdAmount ?? 0),
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (_isPrimary)
                        BondDetailPrimaryView(bond: _bond)
                      else if (_isForeign)
                        BondDetailForeignView(bond: _bond, topPadding: _headerHeight)
                      else if (_isBondOpen && _bond != null)
                        BondDetailTradingView(
                          cash: (_portfolioSummary?.cashBalance ?? 0) - (_portfolioSummary?.holdAmount ?? 0),
                          bond: _bond!,
                          price: _price,
                          quantity: _quantity,
                          onPriceChanged: (val) {
                            setState(() {
                              _price = val;
                            });
                          },
                          onQuantityChanged: (val) {
                            setState(() {
                              _quantity = val;
                            });
                          },
                        )
                      else if (_isSecondary)
                        BondDetailSecondaryView(bond: _bond, topPadding: _headerHeight,)
                      else
                        BondDetailClosedView(bond: _bond),
                      const SizedBox(height: 140), // Bottom bar space
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Хоёрдогч/гадаад дизайн — буцах товч, нэр нэг дэвсгэртэй
          // блокт, баруун дээд буланд цэгэн хээ
          if (_hasTintedHeader && !_isBondOpen || _isForeign)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              key: _tintedHeaderKey,
              child: Container(
                // width: double.infinity, // You can remove this now since right: 0 handles it
                color: extendedColors.bgSecondary,
                child: ClipRect(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.3,
                          child: Image.asset(
                            'assets/images/dots.png',
                            scale: 1,
                            fit: BoxFit.contain,
                            alignment: Alignment.topRight,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: IconButton.styleFrom(
                                    backgroundColor: extendedColors.bgBase,
                                    foregroundColor: extendedColors.neutral100,
                                    padding: const EdgeInsets.all(8),
                                    minimumSize: const Size(40, 40),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: const CircleBorder(),
                                  ),
                                  icon: const CustomSvgIcon(
                                    'close-button',
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: BondDetailHeader(
                                  bond: _bond,
                                  availableCash:
                                  (_portfolioSummary?.cashBalance ?? 0) -
                                      (_portfolioSummary?.holdAmount ?? 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!_hasTintedHeader)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 20,
              left: 20,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: CircleBackButton(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: !_isBondOpen || _isPrimary || _isForeign ?
        BondActionBottomBar(
          label: l10n.availableCash,
          amount: formatStockAmount(
            (_portfolioSummary?.cashBalance ?? 0) -
                (_portfolioSummary?.holdAmount ?? 0),
            isForeign: _isForeign,
          ),
          buttonText: l10n.buyBond,
          onPressed: () =>
            Navigator.pushNamed(context, '/bond_buy', arguments: _bond?.raw),
        )
        : BondDetailTradingBottomBar(
          bond: _bond,
          price: _price,
          quantity: _quantity,
          lockedAmount: _portfolioSummary?.holdAmount,
        ),
    );
  }
}
