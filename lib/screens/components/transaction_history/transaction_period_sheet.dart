import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_svg_icon.dart';

enum TimePeriod { last7Days, last1Month, last3Months, last6Months, custom }

class PeriodResult {
  final TimePeriod period;
  final DateTime? startDate;
  final DateTime? endDate;

  const PeriodResult({
    required this.period,
    this.startDate,
    this.endDate,
  });
}

class TransactionPeriodSheet extends StatefulWidget {
  final TimePeriod initialPeriod;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const TransactionPeriodSheet({
    super.key,
    this.initialPeriod = TimePeriod.last3Months,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<TransactionPeriodSheet> createState() => _TransactionPeriodSheetState();
}

class _TransactionPeriodSheetState extends State<TransactionPeriodSheet> {
  late TimePeriod _selectedPeriod;
  bool _showDatePicker = false;
  late DateTime _displayMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _selectingStart = true;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPeriod;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _displayMonth = DateTime.now();
    if (_selectedPeriod == TimePeriod.custom) {
      _showDatePicker = true;
    }
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      if (_selectingStart) {
        _startDate = day;
        _selectingStart = false;
        // Reset end if start is after end
        if (_endDate != null && day.isAfter(_endDate!)) {
          _endDate = null;
        }
      } else {
        if (day.isBefore(_startDate!)) {
          // If selecting end before start, swap
          _endDate = _startDate;
          _startDate = day;
        } else {
          _endDate = day;
        }
        _selectingStart = true;
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(color: extendedColors.bgBase),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: extendedColors.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (!_showDatePicker)
            _buildPeriodSelection(theme, l10n, extendedColors)
          else
            _buildCalendarView(theme, l10n, extendedColors),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPeriodSelection(
    ThemeData theme,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    final periods = [
      (TimePeriod.last7Days, l10n.last7Days),
      (TimePeriod.last1Month, l10n.last1MonthFilter),
      (TimePeriod.last3Months, l10n.last3Months),
      (TimePeriod.last6Months, l10n.last6Months),
      (TimePeriod.custom, l10n.selectDateRange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectPeriod,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: extendedColors.neutral100,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: periods.map((p) {
            final isSelected = _selectedPeriod == p.$1;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = p.$1;
                  if (p.$1 == TimePeriod.custom) {
                    _showDatePicker = true;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? extendedColors.bgBase
                      : extendedColors.bgBase,
                  border: Border.all(
                    color: isSelected
                        ? extendedColors.neutral100
                        : extendedColors.neutral400,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  p.$2,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Filter button
        Divider(height: 1, color: extendedColors.neutral500),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _selectedPeriod != TimePeriod.custom
                ? () => Navigator.pop(
                      context,
                      PeriodResult(period: _selectedPeriod),
                    )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: extendedColors.primaryMain,
              foregroundColor: Colors.white,
              disabledBackgroundColor: extendedColors.bgSecondary,
              disabledForegroundColor: extendedColors.neutral300,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              l10n.filterAction,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView(
    ThemeData theme,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    final now = DateTime.now();
    final daysInMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_displayMonth.year, _displayMonth.month, 1).weekday;
    // Monday = 1 in Dart, so offset is firstWeekday - 1
    final offset = firstWeekday - 1;

    final weekdays = ['ДА', 'МЯ', 'ЛХ', 'ПҮ', 'БА', 'БЯ', 'НЯ'];

    final bool canFilter = _startDate != null && _endDate != null;

    return Column(
      children: [
        // Month navigator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _prevMonth,
              child: Container(
                width: 56,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: extendedColors.bgSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CustomSvgIcon('chevron-left', color: extendedColors.neutral100),
                ),
              ),
            ),
            Text(
              '${_displayMonth.year}.${_displayMonth.month.toString().padLeft(2, '0')} ${l10n.monthLabel}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: extendedColors.neutral100,
              ),
            ),
            GestureDetector(
              onTap: _nextMonth,
              child: Container(
                width: 56,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: extendedColors.bgSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CustomSvgIcon('chevron-right', color: extendedColors.neutral100),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Date input boxes
        Row(
          children: [
            Expanded(
              child: _buildDateInput(
                label: l10n.startDate,
                date: _startDate,
                isActive: _selectingStart,
                extendedColors: extendedColors,
                theme: theme,
                onTap: () => setState(() => _selectingStart = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateInput(
                label: l10n.endDate,
                date: _endDate,
                isActive: !_selectingStart,
                extendedColors: extendedColors,
                theme: theme,
                onTap: () {
                  if (_startDate != null) {
                    setState(() => _selectingStart = false);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Weekday headers
        Row(
          children: weekdays.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: extendedColors.neutral300,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: offset + daysInMonth + _trailingDays(offset, daysInMonth),
          itemBuilder: (context, index) {
            if (index < offset) {
              // Previous month trailing days
              final prevMonthDays =
                  DateTime(_displayMonth.year, _displayMonth.month, 0).day;
              final day = prevMonthDays - offset + index + 1;
              return Center(
                child: Text(
                  '$day',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral400,
                  ),
                ),
              );
            }

            final dayNum = index - offset + 1;
            if (dayNum > daysInMonth) {
              // Next month leading days
              final nextDay = dayNum - daysInMonth;
              return Center(
                child: Text(
                  '$nextDay',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral400,
                  ),
                ),
              );
            }

            final date = DateTime(_displayMonth.year, _displayMonth.month, dayNum);
            final isToday = date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
            final isStartSelected = _startDate != null &&
                date.year == _startDate!.year &&
                date.month == _startDate!.month &&
                date.day == _startDate!.day;
            final isEndSelected = _endDate != null &&
                date.year == _endDate!.year &&
                date.month == _endDate!.month &&
                date.day == _endDate!.day;
            final isInRange = _startDate != null &&
                _endDate != null &&
                date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                date.isBefore(_endDate!.add(const Duration(days: 1)));

            return GestureDetector(
              onTap: () => _selectDay(date),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: (isStartSelected || isEndSelected)
                      ? extendedColors.primaryMain
                      : isInRange
                          ? extendedColors.primary100.withValues(alpha: 0.2)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$dayNum',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: (isStartSelected || isEndSelected)
                              ? Colors.white
                              : isToday
                                  ? extendedColors.primaryMain
                                  : extendedColors.neutral100,
                          fontWeight: (isStartSelected || isEndSelected || isToday)
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (isToday && !isStartSelected && !isEndSelected)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: extendedColors.primaryMain,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Divider(height: 1, color: extendedColors.neutral500),
        const SizedBox(height: 16),
        // Bottom: back + filter
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showDatePicker = false),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: extendedColors.bgSecondary,
                ),
                child: Icon(Icons.arrow_back, color: extendedColors.neutral100, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: canFilter
                      ? () => Navigator.pop(
                            context,
                            PeriodResult(
                              period: TimePeriod.custom,
                              startDate: _startDate,
                              endDate: _endDate,
                            ),
                          )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: extendedColors.primaryMain,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: extendedColors.bgSecondary,
                    disabledForegroundColor: extendedColors.neutral300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.filterAction,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateInput({
    required String label,
    required DateTime? date,
    required bool isActive,
    required ExtendedColors extendedColors,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? extendedColors.primaryMain : extendedColors.neutral400,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: extendedColors.neutral300,
              ),
            ),
            if (date != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(date),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral100,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _trailingDays(int offset, int daysInMonth) {
    final total = offset + daysInMonth;
    final remainder = total % 7;
    return remainder == 0 ? 0 : 7 - remainder;
  }
}
