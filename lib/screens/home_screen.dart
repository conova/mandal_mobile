import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../services/auth_service.dart';
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
  final ScrollController _scrollController = ScrollController();
  double _scrollOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final newOpacity = (offset / 100).clamp(0.0, 1.0);
    if (newOpacity != _scrollOpacity) {
      setState(() {
        _scrollOpacity = newOpacity;
      });
    }
  }

  /// KYC алхам гүйцэтгэсний дараа дуудна: server-аас info шинэчилж sheet-ийг
  /// дахин нээнэ (Provider notifyListeners-аар home_screen автомат rebuild).
  Future<void> _onStepFinished() async {
    Navigator.pop(context); // Close current sheet
    await context.read<AuthService>().refreshUserInfo();
    if (!mounted) return;
    _showOnboardingSheet(); // Шинэ state-тэй дахин нээ
  }

  void _showOnboardingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        // Sheet нь Provider-аас бодит цаг хугацааны state-ийг авна
        final auth = ctx.watch<AuthService>();
        return OnboardingStepsSheet(
          progress: auth.kycProgress,
          steps: [
            OnboardingStep(
              title: AppLocalizations.of(ctx)!.danSystem,
              description: AppLocalizations.of(ctx)!.danSystemDesc,
              icon: Icons.fingerprint_rounded,
              isCompleted: auth.isDanVerified,
              onTap: () async {
                if (auth.isDanVerified) return;
                final result = await Navigator.pushNamed(ctx, '/pep_question');
                if (result == true) await _onStepFinished();
              },
            ),
            OnboardingStep(
              title: AppLocalizations.of(ctx)!.securitiesAgreement,
              description: AppLocalizations.of(ctx)!.securitiesAgreementDesc,
              icon: Icons.assignment_turned_in_rounded,
              isCompleted: auth.hasAgreement,
              onTap: () async {
                if (auth.hasAgreement) return;
                final result = await Navigator.pushNamed(
                  ctx,
                  '/securities_agreement',
                );
                if (result == true) await _onStepFinished();
              },
            ),
            OnboardingStep(
              title: AppLocalizations.of(ctx)!.document,
              description: AppLocalizations.of(ctx)!.documentDesc,
              icon: Icons.contact_page_rounded,
              isCompleted: auth.isPepDeclared,
              onTap: () async {
                if (auth.isPepDeclared) return;
                final result = await Navigator.pushNamed(
                  ctx,
                  '/document_verification',
                );
                if (result == true) await _onStepFinished();
              },
            ),
          ],
          onContinue: () => Navigator.pop(ctx),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final auth = context.watch<AuthService>();
    // KYC бүрэн дууссан үед registration banner-ыг харуулахгүй
    final showRegistrationBanner = !auth.isKycComplete && auth.userInfo != null;
    final progress = auth.kycProgress;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: HomeHeader(showSummaryOpacity: _scrollOpacity),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AuthService>().refreshUserInfo();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showRegistrationBanner)
                  RegistrationProgressBanner(
                    progress: progress,
                    onStartPressed: _showOnboardingSheet,
                  ),
                const SizedBox(height: 8),
                const HomeAssetSummary(),
                SizedBox(height: 20),
                HomeEquityChart(),
                SizedBox(height: 16),
                HomeQuickActions(),
                SizedBox(height: 40),
                HomeAssetBreakdown(),
                SizedBox(height: 32),
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
