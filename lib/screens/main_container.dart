import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'bond/bond_main_screen.dart';
import 'stock_screen.dart';
import 'order_screen.dart';
import 'settings_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BondMainScreen(),
    const StockScreen(),
    const OrderScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.extension<ExtendedColors>()!.footerColor,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.disabledColor,
        showUnselectedLabels: true,
        selectedLabelStyle: theme.textTheme.labelSmall,
        unselectedLabelStyle: theme.textTheme.labelSmall,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            activeIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.portfolio,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.money_outlined),
            activeIcon: const Icon(Icons.money),
            label: l10n.bonds,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.swap_horizontal_circle_outlined),
            activeIcon: const Icon(Icons.swap_horizontal_circle),
            label: l10n.stocks,
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: const Text('2'),
              backgroundColor: theme.colorScheme.error,
              child: const Icon(Icons.article_outlined),
            ),
            activeIcon: Badge(
              label: const Text('2'),
              backgroundColor: theme.colorScheme.error,
              child: const Icon(Icons.article),
            ),
            label: l10n.orders,
          ),
        ],
      ),
    );
  }
}
