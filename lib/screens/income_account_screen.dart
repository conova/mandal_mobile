import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../common/api_message.dart';
import '../l10n/app_localizations.dart';
import '../models/income_account.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../theme/extended_colors.dart';

import '../widgets/account_card.dart';
import '../widgets/custom_svg_icon.dart';

class IncomeAccountScreen extends StatefulWidget {
  const IncomeAccountScreen({super.key});

  @override
  State<IncomeAccountScreen> createState() => _IncomeAccountScreenState();
}

class _IncomeAccountScreenState extends State<IncomeAccountScreen> {
  bool _isLoading = false;
  String? _error;
  List<IncomeAccount> _accounts = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchAccounts());
  }

  Future<void> _fetchAccounts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get(ApiConfig.userAccounts);
      final body = response.data;

      if (!mounted) return;
      if (body is Map && body['code']?.toString() == '0') {
        final data = body['data'];
        setState(() {
          _accounts = data is List
              ? data
                    .whereType<Map>()
                    .map(
                      (e) => IncomeAccount.fromJson(
                        Map<String, dynamic>.from(e),
                      ),
                    )
                    .toList()
              : [];
        });
      } else {
        setState(() => _error = apiMessage(body));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildAccountCard(IncomeAccount account, {bool isPrimary = false}) {
    final bank = account.localizedBankName(
      Localizations.localeOf(context).languageCode,
    );
    final holder = account.accountName;
    return AccountCard(
      bankName: holder.isEmpty ? bank : '$bank - $holder',
      accountNumber: account.accountNumber,
      isPrimary: isPrimary,
      onTap: () async {
        final changed = await Navigator.pushNamed(
          context,
          '/income_account_detail',
          arguments: {
            'accountNumber': account.accountNumber,
            'bankName': bank,
            'bankCode': account.bankCode,
            'receiver': holder,
            'isPrimary': isPrimary,
          },
        );
        if (changed == true) _fetchAccounts();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final primaryAccounts = _accounts.where((a) => a.isPrimary).toList();
    final otherAccounts = _accounts.where((a) => !a.isPrimary).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.incomeAccount),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const CustomSvgIcon('close-button', size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: extendedColors.primaryMain,
              minimumSize: const Size(32, 32),
              maximumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
            icon: const CustomSvgIcon('plus', size: 20, color: AppColors.bgBase),
            onPressed: () async {
              final added = await Navigator.pushNamed(
                context,
                '/add_income_account',
              );
              if (added == true) _fetchAccounts();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAccounts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: _isLoading && _accounts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null && _accounts.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 120),
                        child: Center(
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: extendedColors.neutral500,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      for (final account in primaryAccounts) ...[
                        _buildAccountCard(account, isPrimary: true),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        l10n.incomeAccBenefitPrompt,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.neutral200,
                        ),
                      ),
                      if (otherAccounts.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Text(
                          l10n.otherAccounts,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final account in otherAccounts) ...[
                          _buildAccountCard(account),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
