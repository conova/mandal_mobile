import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'stock_trading_swipe_action.dart';

class StockTradingConfirmationOverlay extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const StockTradingConfirmationOverlay({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<StockTradingConfirmationOverlay> createState() =>
      _StockTradingConfirmationOverlayState();
}

class _StockTradingConfirmationOverlayState
    extends State<StockTradingConfirmationOverlay> {
  double _dragProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: widget.onCancel,
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _dragProgress -= details.primaryDelta! / size.height;
                    _dragProgress = _dragProgress.clamp(0.0, 1.0);
                  });
                },
                onVerticalDragEnd: (details) {
                  if (_dragProgress > 0.5 || details.primaryVelocity! < -500) {
                    widget.onConfirm();
                  } else {
                    setState(() {
                      _dragProgress = 0.0;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: size.height * (0.6 + _dragProgress * 0.4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32 * (1 - _dragProgress)),
                      topRight: Radius.circular(32 * (1 - _dragProgress)),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'MNDL',
                                      style: theme.textTheme.headlineLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                    Text(
                                      'Мандал даатгал ХК',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.5),
                                          ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.star_border),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 48),
                            _buildConfirmRow(
                              l10n.orderTypeLabel,
                              l10n.limitPrice,
                              theme,
                            ),
                            const SizedBox(height: 24),
                            _buildConfirmRow(
                              l10n.quantityLabel,
                              '1,000',
                              theme,
                            ),
                            const SizedBox(height: 24),
                            _buildConfirmRow(l10n.unitPrice, '62.00₮', theme),
                            const SizedBox(height: 24),
                            _buildConfirmRow(
                              l10n.commissionLabel,
                              '12,132₮',
                              theme,
                            ),
                            const SizedBox(height: 24),
                            const Divider(height: 1, thickness: 1),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.totalPaymentLabel,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                                Text(
                                  '65,520.23₮',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const StockTradingSwipeAction(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
