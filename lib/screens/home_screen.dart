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
import 'components/home/registration_progress_banner.dart';
import 'components/shared/onboarding_steps_sheet.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _registrationProgress = 0.5;
  bool _isDanCompleted = false;
  bool _isAgreementCompleted = false;
  bool _isDocCompleted = false;

  void _showOnboardingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OnboardingStepsSheet(
        progress: _registrationProgress,
        steps: [
          OnboardingStep(
            title: AppLocalizations.of(context)!.danSystem,
            description: AppLocalizations.of(context)!.danSystemDesc,
            icon: Icons.fingerprint_rounded,
            isCompleted: _isDanCompleted,
            onTap: () async {
              if (!_isDanCompleted) {
                final result = await Navigator.pushNamed(
                  context,
                  '/pep_question',
                );
                if (result == true) {
                  setState(() {
                    _isDanCompleted = true;
                    _registrationProgress = 0.6;
                  });
                  Navigator.pop(context); // Close sheet
                  _showOnboardingSheet(); // Re-open with updated state
                }
              }
            },
          ),
          OnboardingStep(
            title: AppLocalizations.of(context)!.securitiesAgreement,
            description: AppLocalizations.of(context)!.securitiesAgreementDesc,
            icon: Icons.assignment_turned_in_rounded,
            isCompleted: _isAgreementCompleted,
            onTap: () async {
              if (!_isAgreementCompleted) {
                final result = await Navigator.pushNamed(
                  context,
                  '/securities_agreement',
                );
                if (result == true) {
                  setState(() {
                    _isAgreementCompleted = true;
                    _registrationProgress = 0.8;
                  });
                  Navigator.pop(context); // Close sheet
                  _showOnboardingSheet(); // Re-open with updated state
                }
              }
            },
          ),
          OnboardingStep(
            title: AppLocalizations.of(context)!.document,
            description: AppLocalizations.of(context)!.documentDesc,
            icon: Icons.contact_page_rounded,
            isCompleted: _isDocCompleted,
            onTap: () async {
              if (!_isDocCompleted) {
                final result = await Navigator.pushNamed(
                  context,
                  '/document_verification',
                );
                if (result == true) {
                  setState(() {
                    _isDocCompleted = true;
                    _registrationProgress = 1.0;
                  });
                  Navigator.pop(context); // Close sheet
                  _showOnboardingSheet(); // Re-open with updated state
                }
              }
            },
          ),
        ],
        onContinue: () {
          Navigator.pop(context);
        },
      ),
    );
  }

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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RegistrationProgressBanner(
                  progress: _registrationProgress,
                  onStartPressed: _showOnboardingSheet,
                ),
                const SizedBox(height: 8),
                const HomeAssetSummary(),
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
