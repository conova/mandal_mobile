import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/circle_back_button.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/empty_state.dart';

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

  // Track selected indices (includes already-added stocks, pre-checked)
  final Set<int> _selectedIndices = {};

  /// Эхлээд watchlist-д байсан SYMBOL-ууд (save хийхэд дахин нэмэхгүй байхын тулд)
  final Set<String> _originallyAddedSymbols = {};

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

    final stocks = available
        .map((row) => _AvailableStock(
      symbol: row['SYMBOL']?.toString() ?? '',
      name: (row['STOCKNAME'] ?? row['COMPNAME'])?.toString() ?? '',
    ))
        .where((s) => s.symbol.isNotEmpty)
        .toList();

    final originallyAdded = current
        .map((row) => row['SYMBOL']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet();

    setState(() {
      _allStocks = stocks;
      _originallyAddedSymbols
        ..clear()
        ..addAll(originallyAdded);
      // Аль хэдийн нэмэгдсэн хувьцаануудыг selected болгож эхлүүлнэ
      _selectedIndices
        ..clear()
        ..addAll([
          for (int i = 0; i < stocks.length; i++)
            if (originallyAdded.contains(stocks[i].symbol)) i,
        ]);
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

  bool get _hasChanges {
    final selectedSymbols =
    _selectedIndices.map((i) => _allStocks[i].symbol).toSet();
    return !setEquals(selectedSymbols, _originallyAddedSymbols);
  }

  Future<void> _handleSave() async {
    if (_isSaving || !_hasChanges) return;
    setState(() => _isSaving = true);
    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context)!;

    final selectedSymbols =
    _selectedIndices.map((i) => _allStocks[i].symbol).toSet();

    final toAdd = selectedSymbols.difference(_originallyAddedSymbols).toList();
    final toRemove =
    _originallyAddedSymbols.difference(selectedSymbols).toList();

    final errors = <String>[];

    for (final symbol in toAdd) {
      try {
        await auth.addToWatchlist(symbol);
      } catch (e) {
        errors.add('$symbol: ${e.toString().replaceFirst('Exception: ', '')}');
      }
    }
    for (final symbol in toRemove) {
      try {
        await auth.removeFromWatchlist(symbol);
      } catch (e) {
        errors.remove('$symbol: ${e.toString().replaceFirst('Exception: ', '')}');
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    final totalAttempted = toAdd.length + toRemove.length;
    final succeeded = totalAttempted - errors.length;

    if (errors.isEmpty) {
      CustomSnackbar.show(context, message: '${l10n.listUpdated}');
      Navigator.pushReplacementNamed(context, '/watchlist_detail');
    } else if (errors.length == totalAttempted) {
      CustomSnackbar.show(
        context,
        message: '${l10n.error} ${errors.first}',
        type: CustomSnackbarType.error,
      );
    } else {
      CustomSnackbar.show(
        context,
        message: '$succeeded ${l10n.changed}, ${errors.length} ${l10n.hasError}',
        type: CustomSnackbarType.info,
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final filteredIndices = _filteredIndices;
    final hasChanges = _hasChanges;

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
                  CircleBackButton(),
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
                          CustomSvgIcon(
                            'search-icon',
                            color: extendedColors.neutral100,
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
                                hintText: l10n.searchByKeyword,
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
                child: EmptyState(
                  icon: 'star',
                  title: l10n.emptyWatchlist,
                  hint: l10n.emptyWatchlistHint,
                ),
              )
                  : filteredIndices.isEmpty
                  ? Padding(
                padding: EdgeInsets.only(top: 120),
                child: EmptyState(
                  icon: 'search-icon',
                  title: l10n.noResults,
                  hint: l10n.noResultsHint,
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
                  final isSelected =
                  _selectedIndices.contains(stockIndex);

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
                                Flexible(
                                  child: Text(
                                    stock.symbol,
                                    style: theme
                                        .textTheme.bodyLarge
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: extendedColors
                                          .neutral100,
                                    ),
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    stock.name,
                                    style: theme
                                        .textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight:
                                      AppTextStyles.light,
                                      color: extendedColors
                                          .neutral200,
                                    ),
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.check
                                : Icons.add,
                            color: isSelected
                                ? extendedColors.primaryMain
                                : extendedColors.neutral300,
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
                  color: hasChanges
                      ? extendedColors.primaryMain
                      : extendedColors.bgTertiary,
                  borderRadius: BorderRadius.circular(26),
                  child: InkWell(
                    onTap: (hasChanges && !_isSaving) ? _handleSave : null,
                    borderRadius: BorderRadius.circular(26),
                    child: Center(
                      child: Text(
                        _isSaving
                            ? l10n.saving
                            : '${l10n.save} ($_totalSelected)',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: AppTextStyles.regular,
                          color: hasChanges
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