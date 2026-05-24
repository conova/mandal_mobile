import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_snackbar.dart';

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

  // API-аас татна (initState-д). Анхны state хоосон.
  List<_AvailableStock> _allStocks = const [];
  bool _isLoadingStocks = true;

  // Track selected indices
  final Set<int> _selectedIndices = {};

  /// Аль хэдийн watchlist-д нэмэгдсэн хувьцааны SYMBOL-ууд
  final Set<String> _alreadyAddedSymbols = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadAll();
  }

  Future<void> _loadAll() async {
    // Available stocks + одоогийн watchlist parallel татах
    final auth = context.read<AuthService>();
    final results = await Future.wait([
      auth.getAvailableStocks().catchError((_) => <Map<String, dynamic>>[]),
      auth.getWatchlist().catchError((_) => <Map<String, dynamic>>[]),
    ]);
    if (!mounted) return;
    final available = results[0];
    final current = results[1];
    setState(() {
      _allStocks = available
          .map((row) => _AvailableStock(
                symbol: row['SYMBOL']?.toString() ?? '',
                name: (row['STOCKNAME'] ?? row['COMPNAME'])?.toString() ?? '',
              ))
          .where((s) => s.symbol.isNotEmpty)
          .toList();
      _alreadyAddedSymbols
        ..clear()
        ..addAll(current
            .map((row) => row['SYMBOL']?.toString() ?? '')
            .where((s) => s.isNotEmpty));
      _isLoadingStocks = false;
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

  bool _isSaving = false;

  Future<void> _handleSave() async {
    if (_isSaving || _selectedIndices.isEmpty) return;
    setState(() => _isSaving = true);
    final auth = context.read<AuthService>();
    final selectedSymbols =
        _selectedIndices.map((i) => _allStocks[i].symbol).toList();

    final errors = <String>[];
    for (final symbol in selectedSymbols) {
      try {
        await auth.addToWatchlist(symbol);
      } catch (e) {
        errors.add(
          '$symbol: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (errors.isEmpty) {
      CustomSnackbar.show(
        context,
        message: '${selectedSymbols.length} хувьцаа нэмэгдлээ',
      );
      Navigator.pop(context, true);
    } else if (errors.length == selectedSymbols.length) {
      CustomSnackbar.show(
        context,
        message: 'Алдаа: ${errors.first}',
        type: CustomSnackbarType.error,
      );
    } else {
      CustomSnackbar.show(
        context,
        message:
            '${selectedSymbols.length - errors.length} нэмэгдлээ, ${errors.length} алдаатай',
        type: CustomSnackbarType.info,
      );
      Navigator.pop(context, true);
    }
  }

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
              child: _isLoadingStocks
                  ? const Center(child: CircularProgressIndicator())
                  : _allStocks.isEmpty
                      ? Center(
                          child: Text(
                            'Жагсаалт хоосон байна',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: extendedColors.neutral300,
                            ),
                          ),
                        )
                      : ListView.separated(
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
                  final isAlreadyAdded =
                      _alreadyAddedSymbols.contains(stock.symbol);

                  return GestureDetector(
                    onTap: isAlreadyAdded
                        ? null
                        : () {
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
                                Flexible(
                                  child: Text(
                                    stock.symbol,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isAlreadyAdded
                                          ? extendedColors.neutral300
                                          : extendedColors.neutral100,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    stock.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: AppTextStyles.light,
                                      color: isAlreadyAdded
                                          ? extendedColors.neutral300
                                          : extendedColors.neutral200,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isAlreadyAdded)
                            // Аль хэдийн нэмэгдсэн → "Нэмэгдсэн" пилл
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: extendedColors.bgSecondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_rounded,
                                    color: extendedColors.primaryMain,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Нэмэгдсэн',
                                    style:
                                        theme.textTheme.labelSmall?.copyWith(
                                      color: extendedColors.neutral200,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (isSelected)
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
                    onTap: (hasSelections && !_isSaving) ? _handleSave : null,
                    borderRadius: BorderRadius.circular(26),
                    child: Center(
                      child: Text(
                        _isSaving
                            ? 'Хадгалж байна...'
                            : 'Хадгалах ($_totalSelected)',
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
