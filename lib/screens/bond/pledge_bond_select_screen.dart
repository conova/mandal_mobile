import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/stock_row_format.dart';
import '../../models/market_instrument.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/custom_snackbar.dart';

/// Барьцаалах бонд сонгох — миний бондуудын (/stocks/mybonds) жагсаалтаас
/// сонгож барьцаалах захиалгын дэлгэц рүү шилжинэ.
class PledgeBondSelectScreen extends StatefulWidget {
  const PledgeBondSelectScreen({super.key});

  @override
  State<PledgeBondSelectScreen> createState() => _PledgeBondSelectScreenState();
}

class _PledgeBondSelectScreenState extends State<PledgeBondSelectScreen> {
  bool _isLoading = true;
  List<MarketInstrument> _myBonds = const [];

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
        _myBonds = MarketInstrument.listFromJson(rows);
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

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  l10n.selectPledgeBond,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.pledgeBondSelectDesc,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral300,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _myBonds.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noData,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: extendedColors.neutral300,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _myBonds.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          thickness: 1,
                          color: extendedColors.neutral500,
                        ),
                        itemBuilder: (context, index) =>
                            _buildBondRow(_myBonds[index], theme,
                                extendedColors, l10n),
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
    final name = bond.name;
    final subtitle = bond.subtitle;

    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        '/pledge_bond_order',
        arguments: bond.raw,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: extendedColors.neutral100,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: extendedColors.neutral300,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${l10n.availableAmountLabel}: ',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: AppTextStyles.light,
                          color: extendedColors.neutral300,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          formatStockAmount(
                            bond.amt,
                            isForeign: bond.isForeign,
                            decimals: 0,
                          ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: extendedColors.primaryMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: extendedColors.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}
