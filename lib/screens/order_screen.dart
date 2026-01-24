import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/order_card.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedFilter;
  
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
    final List<String> filters = [l10n.all, l10n.bond, l10n.stocks];
    _selectedFilter ??= l10n.all;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.book, color: colorScheme.onSurface),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            icon: Icon(Icons.notifications_outlined, color: colorScheme.onSurface),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: Icon(Icons.person_outline, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            indicatorColor: theme.primaryColor,
            indicatorWeight: 3,
            labelColor: colorScheme.onSurface,
            unselectedLabelColor: theme.disabledColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: l10n.activeOrders),
              Tab(text: l10n.orderHistory),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(context, theme, l10n, filters),
          Center(
            child: Text(
              'History WIP', 
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, ThemeData theme, AppLocalizations l10n, List<String> filters) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilterChipBar(
            filters: filters,
            selectedFilter: _selectedFilter!,
            onFilterSelected: (selected) {
              setState(() {
                _selectedFilter = selected;
              });
            },
            horizontalPadding: 0,
          ),
          const SizedBox(height: 16),
          OrderCard(
            companyName: 'GSB Capital',
            subtitle: 'ЖИЭСБ капитал',
            amount: '9,955,000₮',
            price: '1,001,000₮',
            execution: '0/10 (0%)',
            date: '2025.11.3 17:22',
            type: OrderType.buy,
            status: OrderStatus.open,
            market: MarketType.bond,
            onEdit: () {},
          ),
          OrderCard(
            companyName: 'Net Capital',
            subtitle: 'Нэт Капитал',
            amount: '9,910,000₮',
            price: '991,000₮',
            execution: '0/10 (0%)',
            date: '2025.11.3 17:22',
            type: OrderType.sell,
            status: OrderStatus.closed,
            market: MarketType.bond,
            onEdit: () {},
          ),
          OrderCard(
            companyName: 'MIK',
            subtitle: 'Мик',
            amount: '2,468.53\$',
            price: '494.2\$',
            execution: '0/5 (0%)',
            date: '2025.11.3 17:22',
            type: OrderType.sell,
            status: OrderStatus.open,
            market: MarketType.foreign,
            onEdit: () {},
          ),
          OrderCard(
            companyName: 'Net Capital',
            subtitle: 'Нэт Капитал',
            amount: '42,042,000₮',
            price: '1,001,000₮',
            execution: '0/42 (0%)',
            date: '2025.11.3 17:22',
            type: OrderType.buy,
            status: OrderStatus.closed,
            market: MarketType.bond,
            onEdit: () {},
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
