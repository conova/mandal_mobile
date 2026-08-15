import 'package:flutter/material.dart';
import '../screens/components/release_locked_amount/release_locked_amount_header.dart';
import '../screens/components/release_locked_amount/release_locked_amount_list.dart';
import '../screens/components/release_locked_amount/release_locked_amount_bottom_bar.dart';
import '../theme/extended_colors.dart';

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

  // TODO: идэвхтэй захиалгуудын түгжигдсэн дүнгийн API холбогдмогц
  // энэ жагсаалтыг серверээс авна
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
    final extendedColors = Theme.of(context).extension<ExtendedColors>()!;

    final projectedCashText =
        '${_projectedCash.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}₮';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                // TODO: захиалга цуцлах API холбогдмогц энд дуудна
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
