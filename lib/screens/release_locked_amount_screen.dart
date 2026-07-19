import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/circle_back_button.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';

import 'components/release_locked_amount/release_locked_amount_header.dart';
import 'components/release_locked_amount/release_locked_amount_list.dart';
import 'components/release_locked_amount/release_locked_amount_bottom_bar.dart';

class ReleaseLockedAmountScreen extends StatefulWidget {
  const ReleaseLockedAmountScreen({super.key});

  @override
  State<ReleaseLockedAmountScreen> createState() =>
      _ReleaseLockedAmountScreenState();
}

class _ReleaseLockedAmountScreenState extends State<ReleaseLockedAmountScreen> {
  final Set<int> _selectedIndices = {};

  final List<Map<String, dynamic>> _items = [
    {'title': 'Хувьцаа', 'subtitle': '', 'amount': 29341.30, 'isSection': true},
    {
      'title': 'APU',
      'subtitle': 'АПУ ХХК',
      'amount': 29341.30,
      'isSection': false,
    },
    {'title': 'Бонд', 'subtitle': '', 'amount': 100000.00, 'isSection': true},
    {
      'title': 'Simple',
      'subtitle': 'Симпл',
      'amount': 100000.00,
      'isSection': false,
    },
  ];

  double get _totalSelectedAmount {
    double total = 0;
    for (int index in _selectedIndices) {
      if (!_items[index]['isSection']) {
        total += _items[index]['amount'];
      }
    }
    return total;
  }

  double get _currentCash => 142000.53;
  double get _projectedCash => _currentCash + _totalSelectedAmount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    final projectedCashText =
        '${_projectedCash.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}₮';

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        leadingWidth: 60,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20, top: 20),
            child: CircleBackButton(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: extendedColors.bgSecondary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: extendedColors.neutral100,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.limitPrice,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: AppTextStyles.bold,
                      color: extendedColors.neutral100,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ReleaseLockedAmountHeader(),
          Expanded(
            child: ReleaseLockedAmountList(
              items: _items,
              selectedIndices: _selectedIndices,
              onToggle: (index) {
                setState(() {
                  if (_selectedIndices.contains(index)) {
                    _selectedIndices.remove(index);
                  } else {
                    _selectedIndices.add(index);
                  }
                });
              },
            ),
          ),
          ReleaseLockedAmountBottomBar(
            projectedCashText: projectedCashText,
            onBack: () => Navigator.pop(context),
            isCancelEnabled: _selectedIndices.isNotEmpty,
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
