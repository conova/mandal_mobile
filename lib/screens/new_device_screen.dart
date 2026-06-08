import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';

/// "Шинэ төхөөрөмж" introductory screen — login deviceId бүртгэлгүй үед
/// харагдана. Хэрэглэгч баталгаажуулах товчийг дарвал
/// [/login_verification] руу шилжинэ, sessionId-г дамжуулна.
///
/// Route args (`Map<String, dynamic>`):
///   - sessionId: String? — login API-аас ирсэн OTP session
class NewDeviceScreen extends StatelessWidget {
  const NewDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final sessionId = args?['sessionId'] as String?;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Align(
                alignment: Alignment.centerLeft,
                child: _NewDeviceHeaderIcon(extendedColors: extendedColors),
              ),
              const SizedBox(height: 32),
              _NewDeviceContent(
                l10n: l10n,
                theme: theme,
                extendedColors: extendedColors,
              ),
              const SizedBox(height: 48),
              _NewDeviceActionButtons(
                l10n: l10n,
                extendedColors: extendedColors,
                onVerify: () => Navigator.pushNamed(
                  context,
                  '/login_verification',
                  arguments: {'sessionId': sessionId},
                ),
                onBack: () => Navigator.pop(context),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewDeviceHeaderIcon extends StatelessWidget {
  final ExtendedColors extendedColors;

  const _NewDeviceHeaderIcon({required this.extendedColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Image.asset('assets/images/lock.png', fit: BoxFit.contain),
    );
  }
}

class _NewDeviceContent extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;
  final ExtendedColors extendedColors;

  const _NewDeviceContent({
    required this.l10n,
    required this.theme,
    required this.extendedColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.newDeviceTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: extendedColors.neutral100,
              fontWeight: AppTextStyles.semiBold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.newDeviceDesc,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: extendedColors.neutral100,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewDeviceActionButtons extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onVerify;
  final VoidCallback onBack;
  final ExtendedColors extendedColors;

  const _NewDeviceActionButtons({
    required this.l10n,
    required this.onVerify,
    required this.onBack,
    required this.extendedColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: l10n.verify,
            onPressed: onVerify,
            variant: CustomButtonVariant.primary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: l10n.back,
            onPressed: onBack,
            variant: CustomButtonVariant.secondary,
          ),
        ),
      ],
    );
  }
}
