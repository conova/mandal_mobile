import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../models/market_instrument.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_snackbar.dart';

class BondPortfolioScreen extends StatefulWidget {
  const BondPortfolioScreen({super.key});

  @override
  State<BondPortfolioScreen> createState() => _BondPortfolioScreenState();
}

class _BondPortfolioScreenState extends State<BondPortfolioScreen> {
  int _selectedFilter = 0;

  bool _isLoading = true;
  List<MarketInstrument> _holdings = const [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchMyBonds);
  }

  Future<void> _fetchMyBonds() async {
    try {
      final auth = context.read<AuthService>();
      final rows = await auth.getMyBonds();
      if (!mounted) return;
      setState(() {
        _holdings = MarketInstrument.listFromJson(rows);
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

    final filterLabels = [
      l10n.ownedAmountLabel,
      l10n.totalReturnReceived,
      l10n.futureReturn,
    ];

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, theme, extendedColors, l10n),
            const SizedBox(height: 24),
            // My Bond section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.myBond,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: filterLabels.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? extendedColors.neutral100
                            : extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        filterLabels[index],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? extendedColors.bgBase
                              : extendedColors.neutral200,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Table header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.bondName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: extendedColors.neutral300,
                    ),
                  ),
                  Text(
                    l10n.amountPieces,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: extendedColors.neutral300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bond rows
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_holdings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.noData,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral300,
                    ),
                  ),
                ),
              )
            else
              ..._holdings.map(
                (bond) => _buildBondRow(bond, theme, extendedColors, l10n),
              ),
            const SizedBox(height: 8),
            Divider(height: 1, color: extendedColors.neutral500),
            const SizedBox(height: 24),
            // Statistics section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.statistics,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              theme: theme,
              extendedColors: extendedColors,
              icon: Icons.receipt_long_outlined,
              label: l10n.totalReturnReceived,
              amount: '8,250,000.00₮',
              buttonLabel: l10n.view,
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              theme: theme,
              extendedColors: extendedColors,
              icon: Icons.calendar_today_outlined,
              label: l10n.futureReturn,
              amount: '17,650,400.00₮',
              buttonLabel: l10n.view,
            ),
            const SizedBox(height: 24),
            // Time filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildTimeFilter(theme, extendedColors),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [extendedColors.purple200, extendedColors.purple100],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: extendedColors.bgBase.withValues(alpha: 0.5),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: extendedColors.neutral100,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: extendedColors.neutral100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.account_balance_outlined,
                color: extendedColors.bgBase,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.bonds,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral300,
              ),
            ),
            const SizedBox(height: 8),
            _buildAmountText('50,000,000.00₮', theme, extendedColors),
            const SizedBox(height: 4),
            Text(
              l10n.approxUsd('14,084.50'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.purple500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountText(String amount, ThemeData theme, ExtendedColors extendedColors) {
    final dotIndex = amount.indexOf('.');
    if (dotIndex == -1) {
      return Text(
        amount,
        style: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: extendedColors.neutral100,
        ),
      );
    }

    final integerPart = amount.substring(0, dotIndex);
    final decimalPart = amount.substring(dotIndex);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: integerPart,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          TextSpan(
            text: decimalPart,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBondRow(
    MarketInstrument bond,
    ThemeData theme,
    ExtendedColors extendedColors,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        bond.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: extendedColors.neutral100,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        bond.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: extendedColors.neutral300,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    bond.isForeign
                        ? l10n.foreign
                        : (bond.isOpen ? l10n.open : l10n.closed),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                  ),
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
                  formatStockAmount(bond.amt, isForeign: bond.isForeign),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.interestRateShort} - ${formatIntRate(bond.intRate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: extendedColors.neutral300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required ThemeData theme,
    required ExtendedColors extendedColors,
    required IconData icon,
    required String label,
    required String amount,
    required String buttonLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: extendedColors.bgSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: extendedColors.neutral200, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral300,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.info_outline, size: 16, color: extendedColors.neutral400),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: extendedColors.neutral400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              buttonLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: extendedColors.neutral100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilter(ThemeData theme, ExtendedColors extendedColors) {
    final filters = ['7Х', '1С', '3С', '1Ж', 'Бүгд'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: filters.map((label) {
        final isLast = label == 'Бүгд';
        return Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
            color: isLast ? extendedColors.neutral100 : extendedColors.neutral300,
          ),
        );
      }).toList(),
    );
  }
}
