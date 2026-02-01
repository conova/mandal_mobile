import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'components/home/home_header.dart';
import 'components/home/home_asset_summary.dart';
import 'components/home/home_equity_chart.dart';
import 'components/home/home_quick_actions.dart';
import 'components/home/home_asset_breakdown.dart';
import 'components/home/home_promotion_banner.dart';
import 'components/home/home_watchlist_section.dart';
import 'components/home/home_recommendation_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: const HomeHeader(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 120),
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
                SizedBox(height: 24),
                HomePromotionBanner(),
                SizedBox(height: 32),
                HomeWatchlistSection(),
                SizedBox(height: 32),
                HomeRecommendationSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
