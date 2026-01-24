import 'package:flutter/material.dart';
import 'components/home/home_header.dart';
import 'components/home/home_asset_summary.dart';
import 'components/home/home_equity_chart.dart';
import 'components/home/home_quick_actions.dart';
import 'components/home/home_asset_breakdown.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: const HomeHeader(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Individual components handle their own data, 
          // but we could trigger a global refresh via Provider if needed.
          await Future.delayed(const Duration(seconds: 1));
        },
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeAssetSummary(),
                SizedBox(height: 20),
                HomeEquityChart(),
                SizedBox(height: 24),
                HomeQuickActions(),
                SizedBox(height: 32),
                HomeAssetBreakdown(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

