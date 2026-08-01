import 'package:flutter/material.dart';
import '../common/stock_row_format.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';

class WithdrawAmountScreen extends StatefulWidget {
  const WithdrawAmountScreen({super.key});

  @override
  State<WithdrawAmountScreen> createState() => _WithdrawAmountScreenState();
}

class _WithdrawAmountScreenState extends State<WithdrawAmountScreen> {
  String _amount = '0';

  /// Сонгогдсон хувь (25/50/75/100) — гараар оруулбал арилна
  int? _selectedPercent;

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
      _selectedPercent = null;
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
      _selectedPercent = null;
      if (_amount.length <= 1) {
        _amount = '0';
      } else {
        _amount = _amount.substring(0, _amount.length - 1);
      }
    });
  }

  /// Боломжит дүнгийн хувиар (25/50/75/100%) дүнг бөглөнө
  void _onPercent(int percent, double balance) {
    final value = balance * percent / 100;
    // 2 орны нарийвчлалтай, төгсгөлийн 0-уудыг хасна ("32000.10" → "32000.1")
    var text = value.toStringAsFixed(2);
    if (text.contains('.')) {
      text = text
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }
    setState(() {
      _selectedPercent = percent;
      _amount = text.isEmpty || text == '0' ? '0' : text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    // Args: Map {'currency': 'mnt'|'usd', 'balance': double} эсвэл
    // хуучин хэлбэрээр шууд String ('mnt'|'usd')
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final String? currency = rawArgs is Map
        ? rawArgs['currency']?.toString()
        : rawArgs as String?;
    final double balance = rawArgs is Map
        ? ((rawArgs['balance'] as num?)?.toDouble() ?? 0)
        : 0;
    final double rate = rawArgs is Map
        ? ((rawArgs['rate'] as num?)?.toDouble() ?? 0)
        : 0;
    final isMnt = currency != 'usd';
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
                  '$currencySymbol$_formattedAmount',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Боломжит үлдэгдэл
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${l10n.availableAmountLabel}: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral200,
                  ),
                ),
                Text(
                  formatStockAmount(balance, isForeign: !isMnt, decimals: 2),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Percent chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [25, 50, 75, 100].map((percent) {
                  final isSelected = _selectedPercent == percent;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () => _onPercent(percent, balance),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
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
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          '$percent%',
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: l10n.continueLabel,
                  onPressed: _hasValue
                      ? () => Navigator.pushNamed(
                            context,
                            '/withdraw_account',
                            arguments: {
                              'currency': isMnt ? 'mnt' : 'usd',
                              'amount': double.tryParse(
                                    _amount.replaceAll(',', ''),
                                  ) ??
                                  0.0,
                              'rate': rate,
                            },
                          )
                      : null,
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
