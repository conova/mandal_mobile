import 'package:flutter/material.dart';
import 'components/stock_detail/stock_detail_header.dart';
import 'components/stock_detail/stock_detail_chart.dart';
import 'components/stock_detail/stock_detail_general_info.dart';
import 'components/stock_detail/stock_detail_dividend_history.dart';
import 'components/stock_detail/stock_detail_bottom_bar.dart';

/// Route args:
///   { symbol: String, name: String, price: String, change: String,
///     isGrowing: bool? }
class StockDetailScreen extends StatelessWidget {
  const StockDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    final symbol = (args['symbol'] as String?) ?? '';
    final name = (args['name'] as String?) ?? '';
    final price = (args['price'] as String?) ?? '-';
    final change = (args['change'] as String?) ?? '-';
    final isGrowing = args['isGrowing'] as bool?;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.star_border, color: theme.colorScheme.onSurface),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StockDetailHeader(
              symbol: symbol,
              name: name,
              price: price,
              change: change,
              isGrowing: isGrowing,
            ),
            const SizedBox(height: 32),
            StockDetailChart(symbol: symbol),
            const SizedBox(height: 32),
            const StockDetailGeneralInfo(),
            const SizedBox(height: 48),
            const StockDetailDividendHistory(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: StockDetailBottomBar(
        onTrade: () => Navigator.pushNamed(
          context,
          '/stock_trading',
          arguments: args,
        ),
      ),
    );
  }
}
