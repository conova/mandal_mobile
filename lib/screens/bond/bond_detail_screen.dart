import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/stock_row_format.dart';
import '../../models/market_instrument.dart';
import '../../services/auth_service.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/circle_back_button.dart';
import '../components/bond/bond_action_bottom_bar.dart';
import '../components/bond/bond_detail_closed_view.dart';
import '../components/bond/bond_detail_foreign_view.dart';
import '../components/bond/bond_detail_header.dart';
import '../components/bond/bond_detail_primary_view.dart';
import '../components/bond/bond_detail_secondary_view.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_text_styles.dart';

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

  }


  bool get _isForeign => _bond?.isForeign ?? false;

  /// Анхдагч зах зээл → дүүргэлтийн дизайн
  bool get _isPrimary => _bond?.isPrimaryMarket ?? false;

  /// Бүх хоёрдогч бонд (нээлттэй эсэхээс үл хамаарч) → төлбөрийн
  /// хуваарийн дизайн
  bool get _isSecondary => _bond != null && !_isForeign && !_isPrimary;

  /// Хоёрдогч болон гадаад дизайнд нэрийн блок нь өнгөт дэвсгэр,
  /// цэгэн хээтэй
  bool get _hasTintedHeader => _isSecondary || _isForeign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      // Хоёрдогч дизайнд буцах товч, нэр нь нэг дэвсгэртэй блок дотор
      // байрлах тул AppBar ашиглахгүй
      appBar: _hasTintedHeader
          ? null
          : AppBar(
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
        // Анхдагч зах зээлд нэр, дэд нэр нь bar дээр голлож харагдана
        centerTitle: true,
        title: !_isPrimary
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _bond?.name ?? '',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                  ),
                  if ((_bond?.subtitle ?? '').isNotEmpty)
                    Text(
                      _bond!.subtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: AppTextStyles.light,
                        color: extendedColors.neutral200,
                      ),
                    ),
                ],
              ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Хоёрдогч/гадаад дизайн — буцах товч, нэр нэг дэвсгэртэй
              // блокт, баруун дээд буланд цэгэн хээ
              if (_hasTintedHeader)
                Container(
                  width: double.infinity,
                  color: extendedColors.bgSecondary,
                  child: ClipRect(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/dots.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.topRight,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                        SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircleBackButton(),
                                ),
                                const SizedBox(height: 28),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: BondDetailHeader(
                                    bond: _bond,
                                    availableCash:
                                        (_portfolioSummary?.cashBalance ?? 0) -
                                            (_portfolioSummary?.holdAmount ??
                                                0),
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
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Анхдагч дизайнд нэр нь bar дээр, хоёрдогчид дээрх блокт
              if (!_isPrimary && !_hasTintedHeader) ...[
                BondDetailHeader(
                  bond: _bond,
                  availableCash: (_portfolioSummary?.cashBalance ?? 0) - (_portfolioSummary?.holdAmount ?? 0),
                ),
                const SizedBox(height: 24),
              ],
              if (_isPrimary)
                BondDetailPrimaryView(bond: _bond)
              else if (_isForeign)
                BondDetailForeignView(bond: _bond)
              else if (_isSecondary)
                BondDetailSecondaryView(bond: _bond)
              else
                BondDetailClosedView(bond: _bond),
                    const SizedBox(height: 140), // Bottom bar space
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BondActionBottomBar(
        label: l10n.availableCash,
        amount: formatStockAmount(
          (_portfolioSummary?.cashBalance ?? 0) -
              (_portfolioSummary?.holdAmount ?? 0),
          isForeign: _isForeign,
        ),
        buttonText: l10n.buyBond,
        onPressed: () =>
            Navigator.pushNamed(context, '/bond_buy', arguments: _bond?.raw),
      ),
    );
  }
}
