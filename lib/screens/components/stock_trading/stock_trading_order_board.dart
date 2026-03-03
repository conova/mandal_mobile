import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';

class StockTradingOrderBoard extends StatelessWidget {
  const StockTradingOrderBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTableHeader(l10n.buyTab, true, theme, extendedColors),
            _buildTableHeader(l10n.sellTab, false, theme, extendedColors),
          ],
        ),
        const SizedBox(height: 16),
        _buildOrderDepthRow(
          '861',
          '63.50₮',
          '66.10₮',
          '492',
          0.8,
          0.4,
          extendedColors,
          theme,
        ),
        _buildOrderDepthRow(
          '1476',
          '65.55₮',
          '68.00₮',
          '1107',
          0.2,
          0.6,
          extendedColors,
          theme,
        ),
        _buildOrderDepthRow(
          '984',
          '64.25₮',
          '67.80₮',
          '615',
          0.5,
          0.3,
          extendedColors,
          theme,
        ),
        _buildOrderDepthRow(
          '1599',
          '64.90₮',
          '66.75₮',
          '1230',
          0.1,
          0.7,
          extendedColors,
          theme,
        ),
        _buildOrderDepthRow(
          '1107',
          '65.90₮',
          '64.60₮',
          '738',
          0.3,
          0.4,
          extendedColors,
          theme,
        ),
        _buildOrderDepthRow(
          '1722',
          '66.40₮',
          '65.70₮',
          '1353',
          0.6,
          0.2,
          extendedColors,
          theme,
        ),
        _buildOrderDepthRow(
          '1230',
          '65.10₮',
          '67.45₮',
          '861',
          0.4,
          0.5,
          extendedColors,
          theme,
        ),
        _buildOrderDepthRow(
          '1845',
          '64.75₮',
          '66.30₮',
          '1476',
          0.7,
          0.8,
          extendedColors,
          theme,
        ),
        _buildOrderDepthRow(
          '1353',
          '63.95₮',
          '72.50₮',
          '984',
          0.4,
          0.1,
          extendedColors,
          theme,
        ),
        _buildOrderDepthRow(
          '1968',
          '63.85₮',
          '71.20₮',
          '1599',
          0.2,
          0.3,
          extendedColors,
          theme,
        ),
      ],
    );
  }

  Widget _buildTableHeader(
    String label,
    bool isBuy,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: isBuy
            ? const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              )
            : const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
      ),
      child: Center(
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDepthRow(
    String bQty,
    String bPrice,
    String sPrice,
    String sQty,
    double bFill,
    double sFill,
    ExtendedColors extendedColors,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(bQty, style: theme.textTheme.bodySmall),
                const SizedBox(width: 8),
                Container(
                  width: 100,
                  height: 32,
                  decoration: BoxDecoration(
                    color: extendedColors.primaryMain.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 100 * bFill,
                        child: Container(
                          decoration: BoxDecoration(
                            color: extendedColors.primaryMain.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          bPrice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 32,
                  decoration: BoxDecoration(
                    color: extendedColors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 100 * sFill,
                        child: Container(
                          decoration: BoxDecoration(
                            color: extendedColors.red.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          sPrice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: extendedColors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(sQty, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
