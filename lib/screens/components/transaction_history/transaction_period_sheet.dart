import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_svg_icon.dart';
import '../../../widgets/date_input_formatter.dart';

enum TimePeriod { last7Days, last1Month, last3Months, last6Months, last1Year, custom }

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
  // Short month abbreviations used in the month/year picker grid.
  static const List<String> _monthAbbreviations = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  // Initialize everything with defaults to avoid any LateInitializationError
  late TimePeriod _selectedPeriod;
  bool _showDatePicker = false;
  bool _showMonthYearPicker = false;

  DateTime _displayMonth = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _selectingStart = true;

  // Tracks whether the start/end text inputs are currently in an invalid
  // state (bad format, impossible date, or out-of-order relative to the
  // other field). While true, the corresponding input shows a red border
  // and the underlying date value is left untouched until fixed.
  bool _startDateError = false;
  bool _endDateError = false;

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Safely update state from widget properties
    _selectedPeriod = widget.initialPeriod;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _displayMonth = _startDate ?? DateTime.now();
    _startDateError = false;
    _endDateError = false;

    // Update controllers
    _startController.text = _startDate != null ? _formatDate(_startDate!) : '';
    _endController.text = _endDate != null ? _formatDate(_endDate!) : '';

    if (_selectedPeriod == TimePeriod.custom) {
      _showDatePicker = true;
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_displayMonth.year > now.year || (_displayMonth.year == now.year && _displayMonth.month >= now.month)) {
      return;
    }
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
  }

  void _selectDay(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day.isAfter(today)) {
      day = today;
    }

    setState(() {
      _startDateError = false;
      _endDateError = false;

      if (_selectingStart && _endDate == null) {
        _startDate = day;
        _startController.text = _formatDate(day);
        _selectingStart = false;
        return;
      }

      if (!_selectingStart && _startDate == null) {
        _endDate = day;
        _endController.text = _formatDate(day);
        _selectingStart = true;
        return;
      }

      if (!_selectingStart && _startDate != null) {
        if (day.isAfter(_startDate!)) {
          _endDate = day;
          _endController.text = _formatDate(day);
          _endDateError = false;
          _startDateError = false;
          return;
        } else {
          _endDate = day;
          _endController.text = _formatDate(day);
          _endDateError = true;
          return;
        }
      }

      if (_selectingStart && _endDate != null) {
        if (day.isBefore(_endDate!)) {
          _startDate = day;
          _startController.text = _formatDate(day);
          _endDateError = false;
          _startDateError = false;
          return;
        } else {
          _startDate = day;
          _startController.text = _formatDate(day);
          _startDateError = true;
          return;
        }
      }

      if ( _selectingStart && day.isAfter(_endDate!)) {
        _endDateError = true;
        _startDate = day;
        _startController.text = _formatDate(day);
        return;
      }

      if ( !_selectingStart && day.isBefore(_startDate!)) {
        _startDateError = true;
        _endDate = day;
        _endController.text = _formatDate(day);
        return;
      }
    });
  }

  // Called when the user picks a year in the year/month picker.
  // Per spec: selecting a year alone never closes the picker — it only
  // waits for a month to be picked afterwards.
  void _selectYearOption(int year) {
    setState(() {
      _displayMonth = DateTime(year, _displayMonth.month);
    });
  }

  // Called when the user picks a month in the year/month picker.
  // Per spec: selecting a month always applies the selection immediately
  // and closes the picker — whether or not a year was explicitly chosen
  // first (in which case the current/default year is used).
  void _selectMonthOption(int month) {
    final year = _displayMonth.year;
    setState(() {
      _displayMonth = DateTime(year, month);
      _applyYearMonthSelection(year, month);
      _showMonthYearPicker = false;
    });
  }

  // Applies a chosen year/month as either the start date (first day of
  // that month) or the end date (last day of that month), depending on
  // which field is currently active.
  void _applyYearMonthSelection(int year, int month) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime day = _selectingStart
        ? DateTime(year, month, 1) // 1st day of the month
        : DateTime(year, month + 1, 0); //last day of the month

    if (day.isAfter(today)) {
      day = today;
    }

    if (_selectingStart && _endDate == null) {
      _startDate = day;
      _startController.text = _formatDate(_startDate!);
      _selectingStart = false;
      return;
    }

    if (!_selectingStart && _startDate == null) {
      _endDate = day;
      _endController.text = _formatDate(day);
      _selectingStart = true;
      return;
    }

    if (_selectingStart && _endDate != null) {
      if (day.isBefore(_endDate!)) {
        _startDate = day;
        _startController.text = _formatDate(day);
        _startDateError = false;
        _endDateError = false;
        return;
      } else {
        _startDate = day;
        _startController.text = _formatDate(day);
        _startDateError = true;
        return;
      }
    }

    if (!_selectingStart && _startDate != null) {
      if (day.isAfter(_startDate!)) {
        _endDate = day;
        _endController.text = _formatDate(day);
        _endDateError = false;
        _startDateError = false;
        return;
      } else {
        _endDate = day;
        _endController.text = _formatDate(day);
        _endDateError = true;
        return;
      }
    }

    if ( _selectingStart && day.isAfter(_endDate!)) {
      _endDateError = true;
      _startDate = day;
      _startController.text = _formatDate(day);
      return;
    }

    if ( !_selectingStart && day.isBefore(_startDate!)) {
      _startDateError = true;
      _endDate = day;
      _endController.text = _formatDate(day);
      return;
    }
  }

  // Validates and applies a typed date for the start or end field.
  //
  // Behavior:
  // - Invalid format or an impossible calendar date (e.g. month 13,
  //   Feb 30) marks the field as errored and leaves the underlying date
  //   value untouched.
  // - A syntactically valid date that is out of order relative to the
  //   other field (end < start, or start > end) is ALSO treated as an
  //   error on the field being edited — it is never auto-swapped. The
  //   field stays red and keeps whatever the user typed until they
  //   correct it.
  // - The error on a field clears as soon as the user starts editing it
  //   again, even before a full date is retyped.
  void _onDateTyped(String value, bool isStart) {
    setState(() {
      if (isStart) {
        _startDateError = false;
      } else {
        _endDateError = false;
      }
    });

    if (value.length < 10) return; // wait until fully typed

    final parts = value.split('.');
    int? year, month, day;
    if (parts.length == 3) {
      year = int.tryParse(parts[0]);
      month = int.tryParse(parts[1]);
      day = int.tryParse(parts[2]);
    }

    final bool invalidFormat = year == null ||
        month == null ||
        day == null ||
        month < 1 ||
        month > 12 ||
        day < 1 ||
        day > 31;

    DateTime? date;
    if (!invalidFormat) {
      final candidate = DateTime(year, month, day);
      // DateTime silently normalizes overflowing components (e.g.
      // Feb 30 -> Mar 2), so round-trip the parts to catch impossible
      // dates instead of accepting a rolled-over date.
      if (candidate.year == year &&
          candidate.month == month &&
          candidate.day == day) {
        date = candidate;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        if (date.isAfter(today)) {
          date = today;
          if (isStart) {
            _startController.text = _formatDate(date);
          } else {
            _endController.text = _formatDate(date);
          }
        }
      }
    }

    if (date == null) {
      setState(() {
        if (isStart) {
          _startDateError = true;
        } else {
          _endDateError = true;
        }
      });
      return;
    }

    setState(() {
      if (isStart) {
        if (_endDate != null && date!.isAfter(_endDate!)) {
          _startDateError = true;
        } else {
          _startDate = date;
          //_displayMonth = DateTime(date.year, date.month);
          _startDateError = false;
        }
      } else {
        if (_startDate != null && date!.isBefore(_startDate!)) {
          _endDateError = true;
        } else {
          _endDate = date;
          _endDateError = false;
        }
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
      (TimePeriod.last1Year, l10n.last1Year),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (_selectedPeriod == p.$1)
                      ? extendedColors.neutral100
                      : extendedColors.bgSecondary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  p.$2,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: (_selectedPeriod == p.$1)
                        ?extendedColors.bgBase
                        :extendedColors.neutral200,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
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
              backgroundColor: (_selectedPeriod == TimePeriod.custom || _selectedPeriod == widget.initialPeriod)
                  ? extendedColors.bgTertiary
                  : extendedColors.primaryMain,
              foregroundColor: Colors.white,
              disabledBackgroundColor: extendedColors.bgTertiary,
              disabledForegroundColor: extendedColors.neutral300,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: Text(
              l10n.filterAction,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: (_selectedPeriod != TimePeriod.custom && _selectedPeriod != widget.initialPeriod)
                    ? extendedColors.bgBase
                    : extendedColors.neutral200,
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
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_displayMonth.year, _displayMonth.month, 1).weekday;
    // Monday = 1 in Dart, so offset is firstWeekday - 1
    final offset = firstWeekday - 1;

    final weekdays = ['ДА', 'МЯ', 'ЛХ', 'ПҮ', 'БА', 'БЯ', 'НЯ'];
    final bool canFilter = _startDate != null &&
        _endDate != null &&
        !_startDateError &&
        !_endDateError;

    final bool isCurrentMonth = _displayMonth.year == now.year && _displayMonth.month == now.month;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!_showMonthYearPicker)
              GestureDetector(
                onTap: _prevMonth,
                child: Container(
                  width: 56,
                  height: 44,
                  decoration: BoxDecoration(
                    color: extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomSvgIcon('chevron-left',
                        color: extendedColors.neutral100),
                  ),
                ),
              )
            else
              const SizedBox(width: 56, height: 44),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showMonthYearPicker = !_showMonthYearPicker;
                });
              },
              child: Row(
                children: [
                  Text(
                    '${_displayMonth.year}.${_displayMonth.month.toString().padLeft(2, '0')} ${l10n.monthLabel}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(width: 4),
                  CustomSvgIcon(
                    _showMonthYearPicker ? 'chevron-up' : 'chevron-down',
                    color: extendedColors.neutral100,
                    size: 16,
                  ),
                ],
              ),
            ),
            if (!_showMonthYearPicker)
              GestureDetector(
                onTap: isCurrentMonth ? null : _nextMonth,
                child: Container(
                  width: 56,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCurrentMonth ? extendedColors.bgTertiary : extendedColors.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomSvgIcon('chevron-right',
                        color: isCurrentMonth ? extendedColors.neutral300 : extendedColors.neutral100),
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () => setState(() => _showMonthYearPicker = false),
                child: Container(
                  width: 56,
                  height: 44,
                  decoration: BoxDecoration(
                    color: extendedColors.primaryMain,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Both the calendar (date inputs + weekday row + day grid) and the
        // year/month picker share the same overall height so the sheet
        // doesn't jump in size when toggling between them.
        LayoutBuilder(
          builder: (context, constraints) {
            const double dateInputHeight = 72;
            const double weekdayRowHeight = 32;
            final double gridHeight = (constraints.maxWidth / 7) * 6;
            final double contentHeight =
                dateInputHeight + 16 + weekdayRowHeight + 8 + gridHeight;

            if (_showMonthYearPicker) {
              return _buildMonthYearPicker(
                theme,
                l10n,
                extendedColors,
                contentHeight,
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDateInput(
                        label: l10n.startDate,
                        controller: _startController,
                        isActive: _selectingStart,
                        hasError: _startDateError,
                        extendedColors: extendedColors,
                        theme: theme,
                        onTap: () => setState(() => _selectingStart = true),
                        onChanged: (val) => _onDateTyped(val, true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateInput(
                        label: l10n.endDate,
                        controller: _endController,
                        isActive: !_selectingStart,
                        hasError: _endDateError,
                        extendedColors: extendedColors,
                        theme: theme,
                        onTap: () => setState(() => _selectingStart = false),
                        onChanged: (val) => _onDateTyped(val, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: weekdayRowHeight,
                  child: Row(
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
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: gridHeight,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemCount: 42, // Always show 6 rows (6 * 7 = 42) for constant height
                    itemBuilder: (context, index) {
                      if (index < offset) {
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
                      final isFuture = date.isAfter(today);
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
                        onTap: isFuture ? null : () => _selectDay(date),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: (isStartSelected || isEndSelected)
                                ? extendedColors.primaryMain
                                : isInRange
                                ? extendedColors.primary100
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
                                    color: isFuture
                                        ? extendedColors.neutral400
                                        : (isStartSelected || isEndSelected)
                                        ? Colors.white
                                        : isToday
                                        ? extendedColors.primaryMain
                                        : extendedColors.neutral100,
                                    fontWeight:
                                    (isStartSelected || isEndSelected || isToday)
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
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Divider(height: 1, color: extendedColors.neutral500),
        const SizedBox(height: 16),
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
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: CustomSvgIcon('close-button',
                      color: extendedColors.neutral100, size: 20),
                ),
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
                    disabledBackgroundColor: extendedColors.bgTertiary,
                    disabledForegroundColor: extendedColors.neutral300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    l10n.filterAction,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: canFilter
                          ? extendedColors.bgBase
                          : extendedColors.neutral200,
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

  // Year section on top, month section on the bottom (each takes half of
  // the shared [height]), months shown by abbreviation. Picking a year
  // alone just updates the displayed year and waits for a month pick;
  // picking a month applies immediately using whatever year is current.
  Widget _buildMonthYearPicker(
      ThemeData theme,
      AppLocalizations l10n,
      ExtendedColors extendedColors,
      double height,
      ) {
    final now = DateTime.now();
    final currentYear = now.year;
    final years = List.generate((currentYear - 1990) + 1, (index) => currentYear - index);

    return SizedBox(
      height: height,
      child: Column(
        children: [
          // Year selection (top half)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2,
              ),
              itemCount: years.length,
              itemBuilder: (context, index) {
                final year = years[index];
                final isSelected = year == _displayMonth.year;
                return InkWell(
                  onTap: () => _selectYearOption(year),
                  child: Center(
                    child: Text(
                      '$year',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isSelected ? extendedColors.primaryMain : extendedColors.neutral100,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10,),
          Divider(height: 1, color: extendedColors.neutral500),
          const SizedBox(height: 10,),
          // Month selection (bottom half)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = month == _displayMonth.month;
                final isFutureMonth = _displayMonth.year > now.year ||
                    (_displayMonth.year == now.year && month > now.month);

                return InkWell(
                  onTap: isFutureMonth ? null : () => _selectMonthOption(month),
                  child: Center(
                    child: Text(
                      _monthAbbreviations[index],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isFutureMonth
                            ? extendedColors.neutral400
                            : isSelected ? extendedColors.primaryMain : extendedColors.neutral100,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput({
    required String label,
    required TextEditingController controller,
    required bool isActive,
    required bool hasError,
    required ExtendedColors extendedColors,
    required ThemeData theme,
    required VoidCallback onTap,
    required ValueChanged<String> onChanged,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasError
                ? theme.colorScheme.error
                : isActive
                ? extendedColors.primaryMain
                : extendedColors.neutral500,
            width: (isActive || hasError) ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: hasError ? theme.colorScheme.error : extendedColors.neutral300,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onTap: onTap,
                onChanged: onChanged,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  DateInputFormatter(),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'YYYY.MM.DD',
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.neutral100,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
