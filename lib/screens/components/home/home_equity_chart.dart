import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/finance_chart.dart';

class HomeEquityChart extends StatefulWidget {
  const HomeEquityChart({super.key});

  @override
  State<HomeEquityChart> createState() => _HomeEquityChartState();
}

class _HomeEquityChartState extends State<HomeEquityChart> {
  String _selectedFilter = '1C';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const FinanceChart(),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _timeFilter(theme, '1X'),
            _timeFilter(theme, '7X'),
            _timeFilter(theme, '1C'),
            _timeFilter(theme, '3C'),
            _timeFilter(theme, '1Ж'),
            _timeFilter(theme, l10n.all),
          ],
        ),
      ],
    );
  }

  Widget _timeFilter(ThemeData theme, String text) {
    bool isSelected = _selectedFilter == text;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = text),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.onSurface : theme.disabledColor,
        ),
      ),
    );
  }
}
