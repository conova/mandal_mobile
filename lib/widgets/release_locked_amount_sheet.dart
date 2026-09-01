import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../screens/components/release_locked_amount/release_locked_amount_header.dart';
import '../screens/components/release_locked_amount/release_locked_amount_list.dart';
import '../screens/components/release_locked_amount/release_locked_amount_bottom_bar.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import 'custom_snackbar.dart';
import '../l10n/app_localizations.dart';
import 'custom_svg_icon.dart';

/// Түгжигдсэн дүн суллах — bottom sheet хувилбар (тусдаа дэлгэц рүү
/// шилжихгүй, арилжааны дэлгэцийн дээр нээгдэнэ).
class ReleaseLockedAmountSheet extends StatefulWidget {
  const ReleaseLockedAmountSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReleaseLockedAmountSheet(),
    );
  }

  @override
  State<ReleaseLockedAmountSheet> createState() =>
      _ReleaseLockedAmountSheetState();
}

class _ReleaseLockedAmountSheetState extends State<ReleaseLockedAmountSheet> {
  final Set<int> _selectedIndices = {};
  bool _isLoading = true;
  bool _isCancelling = false;
  double _availableCash = 0;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      final lang = Localizations.localeOf(context).languageCode;
      final l10n = AppLocalizations.of(context)!;

      // 1. Get Available Cash
      final summary = await authService.getPortfolioSummary();
      
      // 2. Get Active Orders
      final rows = await authService.getActiveOrders(scope: 'all');
      final orders = Order.listFromJson(rows);

      // 3. Transform orders into items
      final List<Map<String, dynamic>> newItems = [];
      
      // Түгжигдсэн дүн = биелээгүй тоо × үнэ + шимтгэл (lockedAmount)
      final stocks = orders.where((o) => !o.isBond).toList();
      final bonds = orders.where((o) => o.isBond).toList();

      if (stocks.isNotEmpty) {
        final stockTotal = stocks.fold<double>(0, (sum, o) => sum + o.lockedAmount);
        newItems.add({
          'title': l10n.stocks,
          'amount': stockTotal,
          'isSection': true,
        });
        for (var order in stocks) {
          newItems.add({
            'title': order.symbol.isNotEmpty ? order.symbol : order.nameOf(lang),
            'subtitle': order.nameOf(lang),
            'date': order.orderDateLabel,
            'amount': order.lockedAmount,
            'isSection': false,
            'order': order,
          });
        }
      }

      if (bonds.isNotEmpty) {
        final bondTotal = bonds.fold<double>(0, (sum, o) => sum + o.lockedAmount);
        newItems.add({
          'title': l10n.bond,
          'amount': bondTotal,
          'isSection': true,
        });
        for (var order in bonds) {
          newItems.add({
            'title': order.symbol.isNotEmpty ? order.symbol : order.nameOf(lang),
            'subtitle': order.nameOf(lang),
            'date': order.orderDateLabel,
            'amount': order.lockedAmount,
            'isSection': false,
            'order': order,
          });
        }
      }

      if (mounted) {
        setState(() {
          _availableCash = summary.cashBalance;
          _items = newItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomSnackbar.showError(context, e);
      }
    }
  }

  /// Сонгосон захиалгуудыг цуцална (/order/cancel) — амжилттай болмогц
  /// жагсаалт, бэлэн мөнгөө дахин татна
  Future<void> _cancelSelected() async {
    if (_isCancelling) return;
    final orders = _selectedIndices
        .where((i) =>
            i < _items.length && (_items[i]['isSection'] ?? false) == false)
        .map((i) => _items[i]['order'])
        .whereType<Order>()
        .map((o) => <String, dynamic>{
              'TXNID': o.txnId,
              'ORDERNO': o.orderNo,
            })
        .toList();
    if (orders.isEmpty) return;

    setState(() => _isCancelling = true);
    try {
      final message =
          await context.read<AuthService>().cancelOrders(orders);
      if (!mounted) return;
      CustomSnackbar.show(context, message: message);
      // Түгжээ суларсан тул жагсаалт, үлдэгдлээ шинэчилнэ
      _selectedIndices.clear();
      await _fetchData();
      context.read<AuthService>().refreshActiveOrders();
      //if (mounted) context.read<AuthService>().refreshActiveOrders();
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e);
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  double get _totalSelectedAmount {
    double total = 0;
    for (int index in _selectedIndices) {
      if (index < _items.length && !(_items[index]['isSection'] ?? false)) {
        total += (_items[index]['amount'] as num).toDouble();
      }
    }
    return total;
  }

  double get _projectedCash => _availableCash + _totalSelectedAmount;

  void _handleToggle(int index) {
    setState(() {
      final item = _items[index];
      if (item['isSection'] == true) {
        // Find all child items of this section
        final List<int> children = [];
        for (int i = index + 1; i < _items.length; i++) {
          if (_items[i]['isSection'] == true) break;
          children.add(i);
        }

        // If all children are already selected, deselect all.
        // Otherwise, select all.
        final bool allSelected = children.every((i) => _selectedIndices.contains(i));
        if (allSelected) {
          for (final i in children) {
            _selectedIndices.remove(i);
          }
        } else {
          for (final i in children) {
            _selectedIndices.add(i);
          }
        }
      } else {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
        } else {
          _selectedIndices.add(index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final extendedColors = Theme.of(context).extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final projectedCashText =
        '${_projectedCash.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}₮';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Чирэх бариул
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 16),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: extendedColors.neutral400,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const ReleaseLockedAmountHeader(),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isNotEmpty
                    ? ReleaseLockedAmountList(
                      items: _items,
                      selectedIndices: _selectedIndices,
                      onToggle: _handleToggle,
                    )
                    : Container(
                        padding: EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: extendedColors.primary100,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: CustomSvgIcon(
                                'file-cross',
                                color: extendedColors.primaryMain,
                                size: 24,
                              ),
                            ),
                            Text(
                              l10n.noActiveOrders,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: extendedColors.neutral100,
                              ),
                            )
                          ],
                        ),
                    )
            ),
            ReleaseLockedAmountBottomBar(
              projectedCashText: projectedCashText,
              onBack: () => Navigator.pop(context),
              isCancelEnabled: _selectedIndices.isNotEmpty && !_isCancelling,
              onCancel: _cancelSelected,
            ),
          ],
        ),
      ),
    );
  }
}
