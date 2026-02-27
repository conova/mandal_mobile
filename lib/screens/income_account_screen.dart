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
  List<dynamic> _accounts = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchAccounts());
  }

  Future<void> _fetchAccounts() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get(ApiConfig.accounts);
      // In a real app: setState(() => _accounts = response.data);
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
            onPressed: () =>
                Navigator.pushNamed(context, '/add_income_account'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAccounts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isLoading && _accounts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : AccountCard(
                      bankName: 'Гололмт - Алтанцоож Энхтүвшин',
                      accountNumber: 'MN650039008000110088',
                      isPrimary: true,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/income_account_detail',
                      ),
                    ),
              const SizedBox(height: 12),
              Text(
                l10n.incomeAccBenefitPrompt,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral500,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.otherAccounts,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              AccountCard(
                bankName: 'М банк - Алтанцоож Энхтүвшин',
                accountNumber: 'MN650039008000110088',
                onTap: () =>
                    Navigator.pushNamed(context, '/income_account_detail'),
              ),
              const SizedBox(height: 12),
              AccountCard(
                bankName: 'Хаан банк - Алтанцоож Энхтү...',
                accountNumber: 'MN650039008000110088',
                onTap: () =>
                    Navigator.pushNamed(context, '/income_account_detail'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
