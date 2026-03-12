import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../theme/extended_colors.dart';

class _AvailableStock {
  final String symbol;
  final String name;

  const _AvailableStock({required this.symbol, required this.name});
}

class AddWatchlistScreen extends StatefulWidget {
  const AddWatchlistScreen({super.key});

  @override
  State<AddWatchlistScreen> createState() => _AddWatchlistScreenState();
}

class _AddWatchlistScreenState extends State<AddWatchlistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // All available stocks
  final List<_AvailableStock> _allStocks = const [
    _AvailableStock(symbol: 'NVDA', name: 'NVIDIA'),
    _AvailableStock(symbol: 'AAPL', name: 'Apple Inc'),
    _AvailableStock(symbol: 'AMZN', name: 'Amazon.com'),
    _AvailableStock(symbol: 'TSLA', name: 'Tesla'),
    _AvailableStock(symbol: 'MSFT', name: 'Microsoft Inc'),
    _AvailableStock(symbol: 'META', name: 'Facebook'),
    _AvailableStock(symbol: 'NVDA', name: 'NVIDIA'),
    _AvailableStock(symbol: 'AAPL', name: 'Apple Inc'),
    _AvailableStock(symbol: 'MSFT', name: 'Microsoft Inc'),
    _AvailableStock(symbol: 'META', name: 'Facebook'),
    _AvailableStock(symbol: 'NVDA', name: 'NVIDIA'),
  ];

  // Track selected indices
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<int> get _filteredIndices {
    if (_searchQuery.isEmpty) {
      return List.generate(_allStocks.length, (i) => i);
    }
    return List.generate(_allStocks.length, (i) => i).where((i) {
      final stock = _allStocks[i];
      return stock.symbol.toLowerCase().contains(_searchQuery) ||
          stock.name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  int get _totalSelected => _selectedIndices.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final filteredIndices = _filteredIndices;
    final hasSelections = _totalSelected > 0;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: extendedColors.bgTertiary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: extendedColors.neutral100,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: extendedColors.bgSecondary,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(
                            Icons.search,
                            color: extendedColors.neutral300,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: AppTextStyles.light,
                                color: extendedColors.neutral100,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Хайх',
                                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: AppTextStyles.light,
                                  color: extendedColors.neutral300,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stock list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: filteredIndices.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: extendedColors.neutral500,
                  indent: 20,
                  endIndent: 20,
                ),
                itemBuilder: (context, index) {
                  final stockIndex = filteredIndices[index];
                  final stock = _allStocks[stockIndex];
                  final isSelected = _selectedIndices.contains(stockIndex);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIndices.remove(stockIndex);
                        } else {
                          _selectedIndices.add(stockIndex);
                        }
                      });
                    },
                    child: Container(
                      color: isSelected
                          ? extendedColors.primary100
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  stock.symbol,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: extendedColors.neutral100,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  stock.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: AppTextStyles.light,
                                    color: extendedColors.neutral200,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              color: extendedColors.primaryMain,
                              size: 24,
                            )
                          else
                            Icon(
                              Icons.add,
                              color: extendedColors.neutral300,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom save button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Material(
                  color: hasSelections
                      ? extendedColors.primaryMain
                      : extendedColors.bgTertiary,
                  borderRadius: BorderRadius.circular(26),
                  child: InkWell(
                    onTap: hasSelections ? () => Navigator.pop(context) : null,
                    borderRadius: BorderRadius.circular(26),
                    child: Center(
                      child: Text(
                        'Хадгалах ($_totalSelected)',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: AppTextStyles.regular,
                          color: hasSelections
                              ? Colors.white
                              : extendedColors.neutral200,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
