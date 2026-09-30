import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/payment_webview.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/custom_svg_icon.dart';

/// Бүртгэлийн хураамж (kyc.payment_status: false) төлөгдөөгүй үед
/// нийт хөрөнгийн дээр харагдах анхааруулга + идэвхжүүлэх товч
class RegistrationFeeBanner extends StatefulWidget {
  const RegistrationFeeBanner({super.key});

  @override
  State<RegistrationFeeBanner> createState() => _RegistrationFeeBannerState();
}

class _RegistrationFeeBannerState extends State<RegistrationFeeBanner> {
  bool _isLoading = false;

  Future<void> _activate() async {
    final l10n = AppLocalizations.of(context)!;
    // Webview-ээс home/register_success руу шилжвэл энэ widget устах тул
    // AuthService-ийг урьдчилж авна
    final auth = context.read<AuthService>();
    setState(() => _isLoading = true);
    try {
      final result = await openPaymentWebview(
        context,
        amount: 5000,
        homeRoute: '/register_success',
      );
      // Үр дүнгээс үл хамааран info-г шинэчилнэ — payment_status true болсон
      // бол banner нуугдаж, товчнууд идэвхжинэ
      await auth.refreshUserInfo();
      if (!mounted) return;
      if (result != null && result != 'success') {
        CustomSnackbar.show(
          context,
          message: l10n.paymentFailed,
          type: CustomSnackbarType.error,
        );
      }
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: extendedColors.yellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: extendedColors.yellow.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CustomSvgIcon(
            'warning-sign',
            size: 20,
            color: extendedColors.yellow,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.registrationFeeUnpaidTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTextStyles.semiBold,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.registrationFeeUnpaidDesc,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral200,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isLoading ? null : _activate,
            style: ElevatedButton.styleFrom(
              backgroundColor: extendedColors.yellow,
              foregroundColor: extendedColors.bgBase,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: extendedColors.bgBase,
                    ),
                  )
                : Text(
                    l10n.activate,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: AppTextStyles.bold,
                      color: extendedColors.bgBase,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
