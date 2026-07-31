import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_button.dart';

/// Гүйлгээний эцсийн үр дүн.
///
/// Args: { status: PaymentStatus }
class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final status = args['status'] as PaymentStatus;

    final (icon, color, title, subtitle) = _resolve(
      status,
      extendedColors,
      colorScheme,
    );

    return PopScope(
      // Гүйлгээ дууссан — system back-аар төлбөрийн өмнөх дэлгэц рүү
      // буцахын оронд "Дуусгах"-тай ижил үндсэн дэлгэц рүү гарна
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _finish(context);
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 56),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral500,
                  ),
                ),
                const SizedBox(height: 32),
                _buildDetails(status, theme, extendedColors),
                const Spacer(flex: 3),
                CustomButton(
                  label: 'Дуусгах',
                  onPressed: () => _finish(context),
                  variant: CustomButtonVariant.primary,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Үндсэн дэлгэц рүү буцна. Stack-д /main байгаа бол түүн хүртэл pop
  /// хийж төлөвийг нь хадгална, байхгүй бол шинээр нээнэ (popUntil
  /// хоосон stack дээр гацахаас сэргийлнэ).
  void _finish(BuildContext context) {
    var mainFound = false;
    Navigator.popUntil(context, (route) {
      if (route.settings.name == '/main') {
        mainFound = true;
        return true;
      }
      return route.isFirst;
    });
    if (!mainFound) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    }
  }

  /// PDF section 10 + банкны нэр-ийн категори
  (IconData icon, Color color, String title, String subtitle) _resolve(
    PaymentStatus status,
    ExtendedColors c,
    ColorScheme cs,
  ) {
    switch (status.category) {
      case PaymentStatusCategory.success:
        return (
          Icons.check_circle_outline,
          c.primaryMain,
          'Төлбөр амжилттай',
          status.detail ?? 'Гүйлгээ амжилттай биелэгдлээ.',
        );
      case PaymentStatusCategory.warning:
        return (
          Icons.warning_amber_outlined,
          c.yellow,
          _warningTitle(status.status),
          status.detail ?? 'Гүйлгээ дуусаагүй байна.',
        );
      case PaymentStatusCategory.error:
        return (
          Icons.cancel_outlined,
          cs.error,
          'Гүйлгээ амжилтгүй',
          status.detail ?? 'Гүйлгээ татгалзагдсан. Дахин оролдоно уу.',
        );
      case PaymentStatusCategory.pending:
        return (
          Icons.hourglass_empty,
          c.primaryMain,
          'Боловсруулж байна',
          'Гүйлгээ бүртгэгдлээ. Удалгүй шинэчлэгдэнэ.',
        );
    }
  }

  String _warningTitle(String status) {
    switch (status) {
      case 'Expired':
        return 'Хугацаа дууссан';
      case 'Cancelled':
        return 'Цуцлагдсан';
      case 'Reversed':
        return 'Буцаагдсан';
      case 'Rejected':
      case 'Refused':
        return 'Татгалзсан';
      case 'Closed':
        return 'Хаагдсан';
      default:
        return status;
    }
  }

  Widget _buildDetails(
    PaymentStatus status,
    ThemeData theme,
    ExtendedColors c,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(theme, c, 'Гүйлгээний дугаар', status.tranid.toString()),
          _row(theme, c, 'Дүн', _formatAmount(status.amount)),
          if (status.approvalCode != null)
            _row(theme, c, 'Approval code', status.approvalCode!),
          if (status.paymentMethod != null)
            _row(theme, c, 'Төлбөрийн арга', status.paymentMethod!),
          if (status.brand != null && status.maskedPan != null)
            _row(theme, c, status.brand!, status.maskedPan!),
          if (status.bankname != null) _row(theme, c, 'Банк', status.bankname!),
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, ExtendedColors c, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: c.neutral500),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '₮ $formatted';
  }
}
