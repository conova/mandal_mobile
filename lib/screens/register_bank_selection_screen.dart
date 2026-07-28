import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/auth/auth_step_app_bar.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import 'components/register/register_bank_list.dart';

class RegisterBankSelectionScreen extends StatefulWidget {
  const RegisterBankSelectionScreen({super.key});

  @override
  State<RegisterBankSelectionScreen> createState() =>
      _RegisterBankSelectionScreenState();
}

class _RegisterBankSelectionScreenState
    extends State<RegisterBankSelectionScreen> {
  String? _selectedBank;
  List<Map<String, dynamic>> _banks = [];
  bool _isLoading = true;

  // Банкны нэр → өнгө маппинг (UI)
  static const Map<String, Color> _bankColors = {
    'Хаан банк': Color(0xFF2D5F3E),
    'Худалдаа хөгжлийн банк': Color(0xFF1E5FA8),
    'M bank': Color(0xFF00BFA5),
    'Хас банк': Color(0xFFFF6B35),
    'Төрийн банк': Color(0xFF1B4B7F),
    'Голомт банк': Color(0xFFE53935),
    'Богд банк': Color(0xFF6A1B9A),
    'Капитрон банк': Color(0xFF0277BD),
  };

  @override
  void initState() {
    super.initState();
    _fetchBanks();
  }

  Future<void> _fetchBanks() async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get(ApiConfig.banksList);
      final body = response.data;

      if (mounted) {
        if (body is Map && body['code']?.toString() == '0' && body['data'] != null) {
          final banksData = body['data'] as List;
          setState(() {
            _banks = banksData.map((b) {
              final name = b['name']?.toString() ?? b.toString();
              return {
                'name': name,
                'icon': '🏦',
                'color': _bankColors[name] ?? const Color(0xFF607D8B),
                'data': b,
              };
            }).toList();
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Fallback: хардкод банкны жагсаалт
          _banks = [
            {'name': 'Хаан банк', 'icon': '🏦', 'color': const Color(0xFF2D5F3E)},
            {'name': 'Худалдаа хөгжлийн банк', 'icon': '🏦', 'color': const Color(0xFF1E5FA8)},
            {'name': 'M bank', 'icon': '🏦', 'color': const Color(0xFF00BFA5)},
            {'name': 'Хас банк', 'icon': '🏦', 'color': const Color(0xFFFF6B35)},
            {'name': 'Төрийн банк', 'icon': '🏦', 'color': const Color(0xFF1B4B7F)},
          ];
        });
      }
    }
  }

  void _handleContinue() {
    if (_selectedBank == null) return;
    Navigator.pushNamed(context, '/register_success');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: const AuthStepAppBar(stepText: '4/5'),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            l10n.selectYourBank,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: extendedColors.neutral200,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₮5,000',
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 30),
              Text(
                l10n.selectYourBank,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.neutral100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RegisterBankList(
                    banks: _banks,
                    selectedBank: _selectedBank,
                    onSelect: (bankName) {
                      setState(() {
                        _selectedBank = bankName;
                      });
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: CustomButton(
              label: l10n.selectBankToContinue,
              onPressed: _selectedBank != null ? _handleContinue : null,
              variant: CustomButtonVariant.primary,
            ),
          ),
        ],
      ),
    );
  }
}
