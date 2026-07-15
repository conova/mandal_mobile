import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../theme/app_text_styles.dart';

class OnboardingSuccessScreen extends StatefulWidget {
  const OnboardingSuccessScreen({super.key});

  @override
  State<OnboardingSuccessScreen> createState() =>
      _OnboardingSuccessScreenState();
}

class _OnboardingSuccessScreenState extends State<OnboardingSuccessScreen> {
  bool _isChecking = false;

  /// /user/info-г шинэчилж KYC-ийн явцыг шалгана:
  ///   • 100% бол — home руу шууд гарна
  ///   • дутуу бол — home руу буцаад onboarding sheet-ийг дахин нээлгэнэ
  ///     (үлдсэн алхмаа үргэлжлүүлэх боломж олгоно)
  Future<void> _handleStart() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    final auth = context.read<AuthService>();
    try {
      await auth.refreshUserInfo();
    } catch (_) {
      // info татагдаагүй ч кэшэлсэн төлвөөрөө шийднэ
    }
    if (!mounted) return;
    setState(() => _isChecking = false);

    final isComplete = auth.kycProgress >= 1.0;
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/main',
      (route) => false,
      arguments: {'showOnboarding': !isComplete},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return PopScope(
      // Баталгаажуулалт дууссан — system back-аар дууссан KYC урсгал руу
      // буцахын оронд Start товчтой ижил шалгалтаар үндсэн дэлгэц рүү гарна
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleStart();
      },
      child: Scaffold(
        backgroundColor: extendedColors.bgBase,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Spacer(),
                const Align(
                  alignment: Alignment.center,
                  child: _SuccessHeaderIcon(),
                ),
                const SizedBox(height: 32),
                _SuccessContent(
                  l10n: l10n,
                  theme: theme,
                  extendedColors: extendedColors,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: l10n.start,
                    isLoading: _isChecking,
                    onPressed: _isChecking ? null : _handleStart,
                    variant: CustomButtonVariant.primary,
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessHeaderIcon extends StatelessWidget {
  const _SuccessHeaderIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 215,
      height: 212,
      child: Image.asset('assets/images/ready_trade.png', fit: BoxFit.contain),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final ExtendedColors extendedColors;

  const _SuccessContent({
    required this.l10n,
    required this.theme,
    required this.extendedColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            l10n.readyToTrade,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onBackground,
              fontWeight: AppTextStyles.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.readyToTradeDesc,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: extendedColors.neutral200,
              fontWeight: AppTextStyles.extraLight,
            ),
          ),
        ],
      ),
    );
  }
}
