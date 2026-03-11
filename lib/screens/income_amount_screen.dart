import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';

class IncomeAmountScreen extends StatefulWidget {
  const IncomeAmountScreen({super.key});

  @override
  State<IncomeAmountScreen> createState() => _IncomeAmountScreenState();
}

class _IncomeAmountScreenState extends State<IncomeAmountScreen> {
  String _amount = '0';

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

  void _onDelete() {
    setState(() {
      if (_amount.length <= 1) {
        _amount = '0';
      } else {
        _amount = _amount.substring(0, _amount.length - 1);
      }
    });
  }

  void _onQuickAmount(int amount) {
    setState(() {
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
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: extendedColors.bgSecondary,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: extendedColors.neutral100,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Amount display
            Text(
              l10n.enterAmount,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.neutral300,
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () => _onQuickAmount(amount * 1000000),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: extendedColors.neutral400),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$amount ${l10n.million}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: extendedColors.neutral100,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            // Number pad
            _buildNumberPad(theme, extendedColors),
            const SizedBox(height: 8),
            Divider(height: 1, color: extendedColors.neutral500),
            // Submit button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasValue
                      ? () => Navigator.pushReplacementNamed(
                            context,
                            '/income_success',
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasValue
                        ? extendedColors.primaryMain
                        : extendedColors.bgSecondary,
                    foregroundColor: _hasValue
                        ? Colors.white
                        : extendedColors.neutral300,
                    disabledBackgroundColor: extendedColors.bgSecondary,
                    disabledForegroundColor: extendedColors.neutral300,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.makeIncome,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _hasValue
                          ? Colors.white
                          : extendedColors.neutral300,
                    ),
                  ),
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
                  onTap: () {
                    if (key == 'del') {
                      _onDelete();
                    } else {
                      _onDigit(key);
                    }
                  },
                  child: Container(
                    height: 64,
                    alignment: Alignment.center,
                    child: key == 'del'
                        ? Icon(
                            Icons.backspace_outlined,
                            color: extendedColors.neutral100,
                            size: 24,
                          )
                        : Text(
                            key,
                            style: theme.textTheme.headlineMedium?.copyWith(
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
