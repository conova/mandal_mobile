import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/savings_card.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          l10n.mandalSavings,
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: colorScheme.onSurface),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: colorScheme.onSurface),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: theme.primaryColor,
              unselectedLabelColor: theme.disabledColor,
              indicatorColor: theme.primaryColor,
              indicatorWeight: 4,
              labelPadding: const EdgeInsets.only(right: 32),
              tabs: [
                Tab(text: l10n.mySavings),
                Tab(text: l10n.finished),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMySavingsList(),
          Center(
            child: Text(
              l10n.noCompletedSavings,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySavingsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SavingsCard(
          title: 'ХУГАЦААТАЙ ХАДГАЛАМЖ',
          amount: '30,128,000.53₮',
          tenure: '24 сар',
          rate: '11.5%',
          endDate: '2025.12.12',
        ),
        SavingsCard(
          title: 'ЕРӨНХИЙ ХАДГАЛАМЖ',
          amount: '2,500,000.00₮',
          tenure: '12 сар',
          rate: '9.0%',
          endDate: '2024.06.15',
        ),
        SizedBox(height: 80), // Space for FAB or Bottom Nav
      ],
    );
  }
}
