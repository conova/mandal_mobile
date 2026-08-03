import 'package:flutter/material.dart';
import '../../models/market_instrument.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/circle_back_button.dart';
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

  MarketInstrument? _bond;
  bool _argsParsed = false;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BondDetailHeader(bond: _bond, showAvailableCash: _isTrading),
            const SizedBox(height: 24),
            if (_isTrading)
              BondDetailTradingView(
                bond: _bond,
                quantity: _quantity,
                onQuantityChanged: (q) => setState(() => _quantity = q),
              )
            else if (_isForeign)
              BondDetailForeignView(bond: _bond)
            else
              BondDetailClosedView(bond: _bond),
            const SizedBox(height: 140), // Bottom bar space
          ],
        ),
      ),
      bottomNavigationBar: _isTrading
          ? BondDetailTradingBottomBar(bond: _bond, quantity: _quantity)
          : BondActionBottomBar(
              label: l10n.availableCash,
              amount: _isForeign ? '3,523.21\$' : '10,000,000₮',
              buttonText: l10n.buyBond,
              onPressed: () =>
                  Navigator.pushNamed(context, '/bond_buy', arguments: _bond?.raw),
            ),
    );
  }
}
