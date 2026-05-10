import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../theme/extended_colors.dart';

class WatchlistStock {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool? isPositive;

  const WatchlistStock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    this.isPositive,
  });
}

class WatchlistDetailScreen extends StatefulWidget {
  const WatchlistDetailScreen({super.key});

  @override
  State<WatchlistDetailScreen> createState() => _WatchlistDetailScreenState();
}

class _WatchlistDetailScreenState extends State<WatchlistDetailScreen> {
  List<WatchlistStock> _watchlistItems = [
    const WatchlistStock(
      symbol: 'AARD',
      name: 'Ард капитал',
      price: '3,299.02₮',
      change: '9.72%',
      isPositive: true,
    ),
    const WatchlistStock(
      symbol: 'APU',
      name: 'АПУ ХХК',
      price: '957.01₮',
      change: '0.24%',
      isPositive: false,
    ),
    const WatchlistStock(
      symbol: 'GLMT',
      name: 'Голомт банк',
      price: '1,124.00₮',
      change: '0.00%',
      isPositive: null,
    ),
    const WatchlistStock(
      symbol: 'KHAN',
      name: 'Хаан банк',
      price: '1,348.24₮',
      change: '4.02%',
      isPositive: false,
    ),
    const WatchlistStock(
      symbol: 'LEND',
      name: 'Lend.mn',
      price: '170.00₮',
      change: '3.43%',
      isPositive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: extendedColors.neutral100,
                      size: 24,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/add_watchlist',
                      );
                      if (result != null && result is List<WatchlistStock>) {
                        setState(() {
                          _watchlistItems = result;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: extendedColors.primaryMain,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // App icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: extendedColors.neutral100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.add,
                        color: extendedColors.primaryMain,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'Хадгалсан',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      '${_watchlistItems.length} ширхэг хувьцаа',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral300,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Divider(
                      color: extendedColors.neutral500,
                      height: 1,
                    ),
                    const SizedBox(height: 16),

                    // Column headers
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Text(
                              'Хувьцаа',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: extendedColors.neutral200,
                              ),
                            ),
                          ),
                          Text(
                            'Сүүлийн ханш (24 цаг)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: extendedColors.neutral200,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Reorderable list
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            final elevation = Tween<double>(
                              begin: 0,
                              end: 4,
                            ).animate(animation).value;
                            return Material(
                              elevation: elevation,
                              color: extendedColors.bgBase,
                              borderRadius: BorderRadius.circular(8),
                              child: child,
                            );
                          },
                          child: child,
                        );
                      },
                      itemCount: _watchlistItems.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _watchlistItems.removeAt(oldIndex);
                          _watchlistItems.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = _watchlistItems[index];
                        return _buildWatchlistItem(
                          key: ValueKey(item.symbol + index.toString()),
                          item: item,
                          extendedColors: extendedColors,
                          theme: theme,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistItem({
    required Key key,
    required WatchlistStock item,
    required ExtendedColors extendedColors,
    required ThemeData theme,
  }) {
    final changePrefix = item.isPositive == null
        ? ''
        : (item.isPositive! ? '\u25B2 ' : '\u25BC ');
    final changeColor = item.isPositive == null
        ? extendedColors.neutral200
        : (item.isPositive! ? extendedColors.primaryMain : extendedColors.red);

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: extendedColors.bgBase,
      child: Row(
        children: [
          // Drag handle
          Icon(
            Icons.drag_handle,
            color: extendedColors.neutral300,
            size: 24,
          ),
          const SizedBox(width: 12),

          // Stock info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.symbol,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral200,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Price & change
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.price,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$changePrefix${item.change}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w500,
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
}
