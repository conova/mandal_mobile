import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../theme/extended_colors.dart';

import '../widgets/account_card.dart';

class IncomeAccountScreen extends StatefulWidget {
  const IncomeAccountScreen({super.key});

  @override
  State<IncomeAccountScreen> createState() => _IncomeAccountScreenState();
}

class _IncomeAccountScreenState extends State<IncomeAccountScreen> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _accounts = [];

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
              ? data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
              : [];
        });
      } else {
        setState(() => _error = body is Map ? body['message']?.toString() : null);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _bankName(BuildContext context, Map<String, dynamic> account) {
    final isEnglish =
        Localizations.localeOf(context).languageCode == 'en';
    final name = isEnglish
        ? account['BANKNAME2']?.toString()
        : account['BANKNAME']?.toString();
    return (name == null || name.isEmpty)
        ? account['BANKNAME']?.toString() ?? ''
        : name;
  }

  Widget _buildAccountCard(Map<String, dynamic> account, {bool isPrimary = false}) {
    final bank = _bankName(context, account);
    final holder = account['TXNACNTNAME']?.toString() ?? '';
    return AccountCard(
      bankName: holder.isEmpty ? bank : '$bank - $holder',
      accountNumber: account['TXNACNTNO']?.toString() ?? '',
      isPrimary: isPrimary,
      onTap: () async {
        final changed = await Navigator.pushNamed(
          context,
          '/income_account_detail',
          arguments: {
            'accountNumber': account['TXNACNTNO']?.toString() ?? '',
            'bankName': _bankName(context, account),
            'bankCode': account['TXNBANKNO']?.toString() ?? '',
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

    final primaryAccounts =
        _accounts.where((a) => a['ISPRIMARY']?.toString() == '1').toList();
    final otherAccounts =
        _accounts.where((a) => a['ISPRIMARY']?.toString() != '1').toList();

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(l10n.incomeAccount),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle,
              color: extendedColors.primaryMain,
              size: 32,
            ),
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
                          color: extendedColors.neutral500,
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
