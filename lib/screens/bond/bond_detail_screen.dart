import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../../common/stock_row_format.dart';
import '../components/bond/bond_progress.dart';
import '../components/bond/bond_order_board.dart';
import '../components/bond/bond_quantity_selector.dart';
import '../components/bond/bond_payment_details.dart';
import '../components/bond/bond_action_bottom_bar.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extended_colors.dart';

/// Бондын дэлгэрэнгүй — бондын төлвөөс хамаарч 3 дизайнтай:
///   • Хоёрдогч + хаалттай → мэдээллийн дэлгэц (өгөөж, огноонууд)
///   • Хоёрдогч + нээлттэй → арилжааны дэлгэц (ханш, ширхэг, захиалгын самбар)
///   • Гадаад + хоёрдогч  → цуглуулах дүнгийн явцтай мэдээллийн дэлгэц
class BondDetailScreen extends StatefulWidget {
  const BondDetailScreen({super.key});

  @override
  State<BondDetailScreen> createState() => _BondDetailScreenState();
}

class _BondDetailScreenState extends State<BondDetailScreen> {
  int _quantity = 0;

  Map<String, dynamic>? _bond;
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
    if (args is Map) {
      if (args['bond'] is Map) {
        _bond = Map<String, dynamic>.from(args['bond'] as Map);
      } else if (!args.containsKey('bond')) {
        _bond = Map<String, dynamic>.from(args);
      }
    }
  }

  // ── Туслах уншигчид ──────────────────────────────────────────────────

  String _field(String key) => _bond?[key]?.toString() ?? '';

  bool get _isForeign => _field('ISFOREIGN') == '1';
  bool get _isOpen => _field('ISOPEN') == '1';

  /// "2026/07/18" → DateTime (парс болохгүй бол null)
  DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    final parts = raw.split(RegExp(r'[/.\-]'));
    if (parts.length < 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  /// Огноог "2026.2.10 (122 хоног)" хэлбэрээр — үлдсэн хоногтой нь
  String _dateWithDays(String raw, AppLocalizations l10n) {
    final date = _parseDate(raw);
    if (date == null) return raw.isEmpty ? '-' : raw;
    final formatted = '${date.year}.${date.month}.${date.day}';
    final days = date.difference(DateTime.now()).inDays;
    if (days <= 0) return formatted;
    return '$formatted (${l10n.daysCount(days.toString())})';
  }

  double? _num(String key) =>
      double.tryParse(_field(key).replaceAll(',', ''));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final bond = _bond;
    final title = bond == null
        ? 'Net Capital'
        : (bond['STOCKNAME'] ?? bond['COMPNAME'] ?? bond['SYMBOL'])
                ?.toString() ??
            '';
    final subtitle = bond == null
        ? 'Нэт Капитал'
        : (bond['COMPNAME2'] ?? bond['TYPENAME'])?.toString() ?? '';

    // Гадаад → progress дизайн; нээлттэй → арилжааны дизайн;
    // бусад (хаалттай) → мэдээллийн дизайн
    final isTrading = bond != null && !_isForeign && _isOpen;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isTrading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Icon(
                  Icons.plagiarism_outlined,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {},
              ),
            ),
        ],
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, extendedColors, l10n, title, subtitle,
                isTrading: isTrading),
            const SizedBox(height: 24),
            if (isTrading)
              ..._buildTradingBody(theme, extendedColors, l10n)
            else
              ..._buildInfoBody(theme, extendedColors, l10n),
            const SizedBox(height: 140), // Bottom bar space
          ],
        ),
      ),
      bottomNavigationBar: isTrading
          ? _buildTradingBottomBar(theme, extendedColors, l10n)
          : BondActionBottomBar(
              label: l10n.availableCash,
              amount: _isForeign ? '3,523.21\$' : '10,000,000₮',
              buttonText: l10n.buyBond,
              onPressed: () =>
                  Navigator.pushNamed(context, '/bond_buy', arguments: bond),
            ),
    );
  }

  // ── Нийтлэг header: нэр + badge-ууд ──────────────────────────────────

  Widget _buildHeader(
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
    String title,
    String subtitle, {
    required bool isTrading,
  }) {
    final statusLabel = _bond == null
        ? l10n.closed
        : (_isForeign ? l10n.foreign : (_isOpen ? l10n.open : l10n.closed));
    final marketLabel = _bond == null
        ? l10n.primaryMarket
        : (_field('MARKET').toLowerCase() == 'primary'
            ? l10n.primaryMarket
            : l10n.secondaryMarket);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Урт нэрсийг таслахгүй — багтахгүй бол дараагийн мөрөнд бүтнээр
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100,
              ),
            ),
            if (subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral200,
                  ),
                ),
              ),
          ],
        ),
        // Арилжааны дизайнд бэлэн мөнгө нэрийн доор гарна
        if (isTrading) ...[
          const SizedBox(height: 8),
          Text(
            '${l10n.availableCash}: 10,000,000₮',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.primaryMain,
              fontWeight: AppTextStyles.bold,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildBadge(
              statusLabel.toUpperCase(),
              extendedColors.primary100,
              extendedColors.primaryMain,
            ),
            _buildBadge(
              marketLabel.toUpperCase(),
              extendedColors.bgSecondary,
              Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ],
    );
  }

  // ── Дизайн 1/3: мэдээллийн дэлгэц (хаалттай / гадаад) ─────────────────

  List<Widget> _buildInfoBody(
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    final progress = _bond == null
        ? null
        : orderProgress(_bond!['ORDEREDAMT'], _bond!['AMT']);
    final payday = _field('PAYDAY');

    return [
      // Гадаад бонд: цуглуулах дүнгийн явц + арилжаа биелэх огноо
      if (_isForeign) ...[
        if (progress != null) ...[
          BondProgress(
            current: formatStockAmount(
              _bond?['ORDEREDAMT'],
              isForeign: true,
              decimals: 0,
            ),
            total: formatStockAmount(
              _bond?['AMT'],
              isForeign: true,
              decimals: 0,
            ),
            percentage: progress,
          ),
          const SizedBox(height: 24),
        ],
        if (payday.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: extendedColors.primary100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: extendedColors.primaryMain,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tradePlannedDate,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.neutral100,
                          fontWeight: AppTextStyles.extraLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dateWithDays(payday, l10n).split(' (').first,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: extendedColors.neutral100,
                          fontWeight: AppTextStyles.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
      _buildInfoListCard(theme, extendedColors, l10n),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: CustomButton(
          onPressed: () {},
          label: l10n.viewBondPresentation,
          variant: CustomButtonVariant.tertiary,
        ),
      ),
    ];
  }

  /// Өгөөж + огноонуудын мэдээллийн карт
  Widget _buildInfoListCard(
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    final intRate = _field('INTRATE');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            theme,
            extendedColors,
            Icons.percent,
            l10n.annualYield,
            _bond == null ? '12.5%' : (intRate.isEmpty ? '-' : '$intRate%'),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            theme,
            extendedColors,
            Icons.event_available_outlined,
            l10n.nextInterestPayDate,
            _bond == null
                ? '2026.2.10 (${l10n.daysCount('122')})'
                : _dateWithDays(_field('PAYDAY'), l10n),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            theme,
            extendedColors,
            Icons.event_note_outlined,
            l10n.bondMaturityDate,
            _bond == null
                ? '2026.8.10 (${l10n.daysCount('280')})'
                : _dateWithDays(_field('TERM'), l10n),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            theme,
            extendedColors,
            Icons.autorenew,
            l10n.paymentFrequency,
            _bond == null ? 'Хагас жил' : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    ExtendedColors extendedColors,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 26, color: extendedColors.neutral100),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral300,
                  fontWeight: AppTextStyles.extraLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.neutral100,
                  fontWeight: AppTextStyles.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Дизайн 2: арилжааны дэлгэц (хоёрдогч + нээлттэй) ─────────────────

  List<Widget> _buildTradingBody(
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    final price = _num('CLOSEPRICE') ?? _num('OPENPRICE') ?? 0;
    final total = price * _quantity;
    final rate = _num('INTRATE') ?? 0;
    final expectedReturn = total * rate / 100;

    return [
      // Авах ханш + ширхэг
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: extendedColors.bgBase,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: extendedColors.neutral500),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.buyRate,
              style: theme.textTheme.labelMedium?.copyWith(
                color: extendedColors.neutral300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatStockAmount(price, decimals: 0),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      BondQuantitySelector(
        maxQuantity: 8000,
        onChanged: (quantity) {
          setState(() => _quantity = quantity);
        },
      ),
      const SizedBox(height: 24),
      BondPaymentDetails(
        totalPayment: formatStockAmount(total, decimals: 0),
        totalReturn: formatStockAmount(expectedReturn, decimals: 0),
        onDetailsPressed: () {},
      ),
      const SizedBox(height: 32),
      Divider(height: 1, color: extendedColors.neutral500),
      const SizedBox(height: 24),
      // Захиалгын самбар — API байхгүй тул түр демо утгууд
      BondOrderBoard(
        orders: [
          BondOrderEntry(price: 989000, quantity: 21),
          BondOrderEntry(price: 990000, quantity: 12),
          BondOrderEntry(price: 1001000, quantity: 5),
          BondOrderEntry(price: 1002000, quantity: 32),
          BondOrderEntry(price: 1002500, quantity: 52),
        ],
      ),
    ];
  }

  Widget _buildTradingBottomBar(
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        boxShadow: [
          BoxShadow(
            color: extendedColors.neutral500,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/release_locked'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: extendedColors.primary100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: extendedColors.neutral100, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${l10n.lockedAmountLabel}: 500,000₮',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: AppTextStyles.bold,
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ),
                  Text(
                    l10n.release,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: extendedColors.neutral100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.expand_less, color: extendedColors.neutral100),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: l10n.placeOrder,
              onPressed: _quantity > 0
                  ? () => Navigator.pushNamed(
                        context,
                        '/bond_confirmation',
                        arguments: _bond,
                      )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.paragraph1.copyWith(
          color: textColor,
          fontWeight: AppTextStyles.regular,
        ),
      ),
    );
  }
}
