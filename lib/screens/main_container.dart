import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../widgets/custom_svg_icon.dart';
import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'bond/bond_main_screen.dart';
import 'stock_screen.dart';
import 'order_screen.dart';

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
            icon: const CustomSvgIcon('wallet-01'),
            activeIcon: const CustomSvgIcon('wallet-01'),
            label: l10n.portfolio,
          ),
          BottomNavigationBarItem(
            icon: const CustomSvgIcon('bank-note-01'),
            activeIcon: const CustomSvgIcon('bank-note-01'),
            label: l10n.bonds,
          ),
          BottomNavigationBarItem(
            icon: const CustomSvgIcon('coins-swap-02'),
            activeIcon: const CustomSvgIcon('coins-swap-02'),
            label: l10n.stocks,
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: const Text('2'),
              backgroundColor: theme.colorScheme.error,
              child: const CustomSvgIcon('file-02'),
            ),
            activeIcon: Badge(
              label: const Text('2'),
              backgroundColor: theme.colorScheme.error,
              child: const CustomSvgIcon('file-02'),
            ),
            label: l10n.orders,
          ),
        ],
      ),
    );
  }
}
