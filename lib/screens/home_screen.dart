import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'components/home/home_stock_recommendation_section.dart';
import 'components/home/registration_progress_banner.dart';
import 'components/shared/onboarding_steps_sheet.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_snackbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOpacity = 0.0;
  bool _checkedDanReturn = false;

  /// Pull-to-refresh тоолуур — нэмэгдэх бүрд бүх хэсгийн Key өөрчлөгдөж
  /// компонентууд дахин үүсэн initState-ийн API-гаа шинээр дуудна
  int _refreshTick = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // // Бондын жагсаалтыг татаж "Primary" бонд байгаа эсэхийг шалгах (баннер харуулах)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     context.read<AuthService>().getBondList().catchError((_) => <Map<String, dynamic>>[]);
    //   }
    // });
  }

  /// DAN баталгаажуулалтаас буцаж ирсэн эсэхийг шалгаад onboarding sheet
  /// нээнэ. Хоёр зам бий:
  ///   • App — webview `/main` руу `showOnboarding: true` argument-тэй буудаг
  ///   • Browser — DAN tab `/main?success` эсвэл `/main?fail` хаягаар
  ///     аппыг reload хийдэг (web/index.html-ийн message listener)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedDanReturn) return;
    _checkedDanReturn = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    final fromDanApp = args is Map && args['showOnboarding'] == true;
    final qp = Uri.base.queryParameters;
    final fromDanWeb =
        kIsWeb && (qp.containsKey('success') || qp.containsKey('fail'));

    if (fromDanApp || fromDanWeb) {
      // Browser зам: алдааны message-ийг URL-аас уншиж toast-оор харуулна
      // (app/webview зам дээр webview_screen өөрөө snackbar гаргадаг)
      final failed = fromDanWeb && qp.containsKey('fail');
      final message = qp['message'];

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        // Алдаатай үед зөвхөн toast — onboarding sheet нээхгүй
        if (failed) {
          CustomSnackbar.show(
            context,
            message: (message != null && message.isNotEmpty)
                ? message
                : 'Баталгаажуулалтын явцад алдаа гарлаа',
            type: CustomSnackbarType.error,
          );
          return;
        }

        // DAN-ий үр дүнгээр kyc төлөв өөрчлөгдсөн тул эхлээд шинэчилнэ
        try {
          await context.read<AuthService>().refreshUserInfo();
        } catch (_) {
          // Шинэчлэлт амжилтгүй ч sheet-ээ кэшэлсэн төлвөөр нээнэ
        }
        if (mounted) _showOnboardingSheet();
      });
    }
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
              image: 'assets/images/finger_print.png',
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
              image: 'assets/images/stamp.png',
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
              image: 'assets/images/document.png',
              // 3 зураг (id_front, id_back, selfie) бүгд true бол дууссан
              isCompleted: auth.areAllDocumentsUploaded,
              onTap: () async {
                if (auth.areAllDocumentsUploaded) return;
                final result = await Navigator.pushNamed(
                  ctx,
                  '/document_verification',
                );
                if (result == true) await _onStepFinished();
              },
            ),
          ],
          // Үргэлжлүүлэх — гүйцээгээгүй эхний алхам руу шилжинэ,
          // бүгд дууссан бол success дэлгэц рүү орно
          onContinue: () async {
            final navigator = Navigator.of(context);
            if (auth.isKycComplete) {
              Navigator.pop(ctx);
              navigator.pushNamed('/onboarding_success');
              return;
            }
            final route = !auth.isDanVerified
                ? '/pep_question'
                : !auth.hasAgreement
                ? '/securities_agreement'
                : '/document_verification';
            final result = await Navigator.pushNamed(ctx, route);
            if (result == true) await _onStepFinished();
          },
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
    // Гүйцээгээгүй эхний алхам: 1 — ХУР, 2 — гэрээ, 3 — бичиг баримт
    final currentStep = !auth.isDanVerified
        ? 1
        : !auth.hasAgreement
        ? 2
        : 3;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      // Key — refresh бүрд header дахин үүсэж нийт хөрөнгө, badge-ээ татна
      appBar: HomeHeader(
        key: ValueKey('home_header_$_refreshTick'),
        showSummaryOpacity: _scrollOpacity,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // userInfo (KYC banner) + бүх хэсгийн API-г шинээр дуудна
          try {
            await context.read<AuthService>().refreshUserInfo();
          } catch (_) {
            // userInfo амжилтгүй ч бусад хэсгүүдээ шинэчилнэ
          }
          // try {
          //   await Future.wait([
          //     context.read<AuthService>().refreshUserInfo(),
          //     context.read<AuthService>().getBondList(),
          //   ]);
          // } catch (_) {
          //   // userInfo амжилтгүй ч бусад хэсгүүдээ шинэчилнэ
          // }
          if (mounted) setState(() => _refreshTick++);
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            child: Column(
              key: ValueKey('home_body_$_refreshTick'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showRegistrationBanner)
                  RegistrationProgressBanner(
                    progress: progress,
                    currentStep: currentStep,
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
                if (auth.hasPrimaryBond) ...[
                  HomePromotionBanner(),
                  SizedBox(height: 32),
                ],
                HomeWatchlistSection(),
                SizedBox(height: 32),
                HomeRecommendationSection(),
                SizedBox(height: 32),
                HomeStockRecommendationSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
