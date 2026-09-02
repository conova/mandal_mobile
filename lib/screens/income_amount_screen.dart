import 'package:flutter/material.dart';
import '../common/payment_webview.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';

class IncomeAmountScreen extends StatefulWidget {
  const IncomeAmountScreen({super.key});

  @override
  State<IncomeAmountScreen> createState() => _IncomeAmountScreenState();
}

class _IncomeAmountScreenState extends State<IncomeAmountScreen> {
  String _amount = '0';

  /// Сонгогдсон quick amount (сая) — гараар оруулбал арилна
  int? _selectedQuickAmount;

  bool get _hasValue => _amount != '0';

  String get _formattedAmount {
    if (_amount == '0') return '0';
    // Remove leading zeros
    final cleaned = _amount.replaceFirst(RegExp(r'^0+'), '');
    if (cleaned.isEmpty) return '0';

    // Handle decimal
    if (cleaned.contains('.')) {
      final parts = cleaned.split('.');
      final intPart = _formatNumber(parts[0].isEmpty ? '0' : parts[0]);
      return '$intPart.${parts[1]}';
    }

    return _formatNumber(cleaned);
  }

  String _formatNumber(String number) {
    if (number.isEmpty) return '0';
    final buffer = StringBuffer();
    final len = number.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write(',');
      buffer.write(number[i]);
    }
    return buffer.toString();
  }

  void _onDigit(String digit) {
    setState(() {
      _selectedQuickAmount = null;
      if (_amount == '0' && digit != '.') {
        _amount = digit;
      } else if (digit == '.') {
        if (!_amount.contains('.')) {
          _amount = '$_amount.';
        }
      } else {
        // Limit length
        if (_amount.length < 15) {
          _amount = '$_amount$digit';
        }
      }
    });
  }

  bool _isSubmitting = false;

  /// Орлого нэмэх — NEGDI төлбөрийн линкийг app доторх webview-ээр нээнэ
  Future<void> _submit() async {
    if (_isSubmitting) return;
    final amount = double.tryParse(_amount.replaceAll(',', '')) ?? 0.0;
    // Валют — route args ('mnt' | 'usd')
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    final currency = args == 'usd' ? 'USD' : 'MNT';
    setState(() => _isSubmitting = true);
    try {
      final result = await openPaymentWebview(
        context,
        amount: amount,
        txntype: 'CHARGE',
        currency: currency,
        title: 'Орлого нэмэх',
      );
      if (!mounted) return;
      if (result == 'success') {
        CustomSnackbar.show(context, message: 'Төлбөр амжилттай боллоо');
        Navigator.pop(context);
        return;
      } else if (result != null) {
        CustomSnackbar.show(
          context,
          message: 'Төлбөр амжилтгүй боллоо',
          type: CustomSnackbarType.error,
        );
      }
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _onDelete() {
    setState(() {
      _selectedQuickAmount = null;
      if (_amount.length <= 1) {
        _amount = '0';
      } else {
        _amount = _amount.substring(0, _amount.length - 1);
      }
    });
  }

  void _onQuickAmount(int amount) {
    setState(() {
      _selectedQuickAmount = amount;
      _amount = amount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    final isMnt = args != 'usd';
    final currencySymbol = isMnt ? '₮' : '\$';

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircleBackButton(),
              ),
            ),
            const Spacer(),
            // Amount display
            Text(
              l10n.enterAmount,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral200,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$_formattedAmount$currencySymbol',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Quick amount chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [1, 5, 10, 50].map((amount) {
                  final isSelected =
                      _selectedQuickAmount == amount * 1000000;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () => _onQuickAmount(amount * 1000000),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? extendedColors.primaryMain
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? extendedColors.primaryMain
                                : extendedColors.neutral500,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$amount ${l10n.million}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? extendedColors.bgBase
                                : extendedColors.neutral100,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Number pad
            _buildNumberPad(theme, extendedColors),
            const SizedBox(height: 8),
            Divider(height: 1, color: extendedColors.neutral500),
            // Submit button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: l10n.makeIncome,
                  isLoading: _isSubmitting,
                  onPressed: _hasValue && !_isSubmitting ? _submit : null,
                  variant: CustomButtonVariant.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad(ThemeData theme, ExtendedColors extendedColors) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', 'del'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: keys.map((row) {
          return Row(
            children: row.map((key) {
              return Expanded(
                child: GestureDetector(
                  // opaque — зөвхөн текст/icon дээр биш нүдний бүх талбайд
                  // (хоосон зайд ч) tap бүртгэгдэнэ
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (key == 'del') {
                      _onDelete();
                    } else {
                      _onDigit(key);
                    }
                  },
                  child: Container(
                    height: 72,
                    alignment: Alignment.center,
                    child: key == 'del'
                        ? Icon(
                            Icons.backspace_outlined,
                            color: extendedColors.neutral100,
                            size: 28,
                          )
                        : Text(
                            key,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: extendedColors.neutral100,
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
