import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../services/auth_service.dart';
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
  bool _argsApplied = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BondMainScreen(),
    const StockScreen(),
    const OrderScreen(),
  ];

  /// Route args-аар эхлэх tab зааж болно:
  ///   Navigator.pushNamed(context, '/main', arguments: {'tab': 1})
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsApplied) return;
    _argsApplied = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['tab'] is int) {
      _selectedIndex = (args['tab'] as int).clamp(0, _screens.length - 1);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final footerColor = theme.extension<ExtendedColors>()?.footerColor ?? Colors.black;

    // Профайл (өөрийн/хүүхдийн) солигдоход бүх tab-ийн state дахин үүсэж,
    // дэлгэц бүр шинэ token-той датагаа дахин татна
    final profileKey =
        context.watch<AuthService>().activeSubAccount?.custId ?? 'own';

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        key: ValueKey(profileKey),
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: footerColor.withOpacity(0.8),
            elevation: 0,
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
        ),
      ),
    );
  }
}
