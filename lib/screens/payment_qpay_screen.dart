import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/payment_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';

/// QPAY гүйлгээний дэлгэц.
///
/// Args (route arguments):
///   { amount: double, description?: String, ordernum?: String }
///
/// Flow:
///   1. App нээгдэхэд `initQpay()`-г дуудна
///   2. Хариунаас `redirect_url`-г QR болгож харуулна
///   3. 3 секунд тутамд status шалгах polling эхэлнэ
///   4. Status terminal болсон үед /payment_result-руу шилжинэ
///   5. 10 минут timeout
class PaymentQpayScreen extends StatefulWidget {
  const PaymentQpayScreen({super.key});

  @override
  State<PaymentQpayScreen> createState() => _PaymentQpayScreenState();
}

class _PaymentQpayScreenState extends State<PaymentQpayScreen> {
  static const _pollingInterval = Duration(seconds: 3);
  static const _timeout = Duration(minutes: 10);

  bool _isInitializing = true;
  bool _isCancelling = false;
  String? _error;
  InitPaymentResult? _payment;
  Timer? _pollingTimer;
  DateTime? _expiresAt;

  late double _amount;
  String? _description;
  String? _ordernum;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_payment == null && _isInitializing && _error == null) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _amount = (args['amount'] as num).toDouble();
      _description = args['description'] as String?;
      _ordernum = args['ordernum'] as String?;
      _initPayment();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initPayment() async {
    try {
      final service = context.read<PaymentService>();
      final result = await service.initQpay(
        amount: _amount,
        description: _description,
        ordernum: _ordernum,
      );
      if (!mounted) return;
      setState(() {
        _payment = result;
        _isInitializing = false;
        _expiresAt = DateTime.now().add(_timeout);
      });
      _startPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _pollStatus());
  }

  Future<void> _pollStatus() async {
    final payment = _payment;
    if (payment == null) return;
    if (_expiresAt != null && DateTime.now().isAfter(_expiresAt!)) {
      _pollingTimer?.cancel();
      _navigateToResult(
        PaymentStatus(
          tranid: payment.tranid,
          checkid: payment.checkid,
          status: 'Expired',
          amount: _amount,
          detail: 'Хүлээх хугацаа дууссан',
        ),
      );
      return;
    }

    try {
      final service = context.read<PaymentService>();
      final status = await service.inquiry(
        tranid: payment.tranid,
        checkid: payment.checkid,
      );
      if (!mounted) return;
      if (status.isTerminal) {
        _pollingTimer?.cancel();
        _navigateToResult(status);
      }
    } catch (_) {
      // Сүлжээний түр алдааг үл тоомсорлоно; дараагийн poll-д дахин оролдоно
    }
  }

  void _navigateToResult(PaymentStatus status) {
    Navigator.pushReplacementNamed(
      context,
      '/payment_result',
      arguments: {'status': status},
    );
  }

  Future<void> _handleCancel() async {
    final payment = _payment;
    if (_isCancelling) return;
    // Гүйлгээ үүсээгүй (init алдаа г.м.) — цуцлах юмгүй тул шууд буцна
    if (payment == null) {
      _pollingTimer?.cancel();
      Navigator.pop(context);
      return;
    }
    setState(() => _isCancelling = true);
    try {
      final service = context.read<PaymentService>();
      await service.cancel(tranid: payment.tranid, amount: _amount);
      _pollingTimer?.cancel();
      if (!mounted) return;
      _navigateToResult(
        PaymentStatus(
          tranid: payment.tranid,
          checkid: payment.checkid,
          status: 'Cancelled',
          amount: _amount,
          detail: 'Хэрэглэгч цуцалсан',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      CustomSnackbar.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: CustomSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;

    return PopScope(
      // System back нь X товчтой ижил ажиллах ёстой — шууд pop хийвэл
      // QPay гүйлгээ сервер талд цуцлагдалгүй үлдэнэ
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isInitializing) return;
        _handleCancel();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('QPAY төлбөр'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isInitializing ? null : _handleCancel,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildBody(theme, extendedColors),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ExtendedColors extendedColors) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildError(theme);
    }
    return _buildQr(theme, extendedColors);
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'QPAY үүсгэхэд алдаа гарлаа',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          CustomButton(
            label: 'Дахин оролдох',
            onPressed: () {
              setState(() {
                _isInitializing = true;
                _error = null;
              });
              _initPayment();
            },
            variant: CustomButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildQr(ThemeData theme, ExtendedColors extendedColors) {
    final qrData = _payment?.redirectUrl ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'Төлөх дүн',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatAmount(_amount),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: qrData.isEmpty
                ? const SizedBox(
                    width: 240,
                    height: 240,
                    child: Center(child: Text('QR data олдсонгүй')),
                  )
                : QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 32),
        _buildInstruction(theme, extendedColors),
        const Spacer(),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Төлбөрийг хүлээж байна...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          label: _isCancelling ? 'Цуцалж байна...' : 'Цуцлах',
          onPressed: _isCancelling ? null : _handleCancel,
          isLoading: _isCancelling,
          variant: CustomButtonVariant.tertiary,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInstruction(ThemeData theme, ExtendedColors extendedColors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Хэрхэн төлөх вэ?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _bulletText(theme, '1. Банкны апп-аа нээнэ үү'),
          _bulletText(theme, '2. QPAY скан хэсэгт орно уу'),
          _bulletText(theme, '3. Энэ QR кодыг уншуулна уу'),
          _bulletText(theme, '4. Төлбөрийг баталгаажуулна уу'),
        ],
      ),
    );
  }

  Widget _bulletText(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(text, style: theme.textTheme.bodySmall),
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
