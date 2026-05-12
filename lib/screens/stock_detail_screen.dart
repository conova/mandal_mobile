import 'package:flutter/material.dart';
import 'components/stock_detail/stock_detail_header.dart';
import 'components/stock_detail/stock_detail_chart.dart';
import 'components/stock_detail/stock_detail_general_info.dart';
import 'components/stock_detail/stock_detail_dividend_history.dart';
import 'components/stock_detail/stock_detail_bottom_bar.dart';

class StockDetailScreen extends StatelessWidget {
  const StockDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StockDetailHeader(),
            SizedBox(height: 32),
            StockDetailChart(),
            SizedBox(height: 32),
            StockDetailGeneralInfo(),
            SizedBox(height: 48),
            StockDetailDividendHistory(),
            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: StockDetailBottomBar(
        onTrade: () => Navigator.pushNamed(context, '/stock_trading'),
      ),
    );
  }
}
