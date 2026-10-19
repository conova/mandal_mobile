import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandal_capital/theme/app_colors.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/widgets/finance_chart.dart';

void main() {
  Future<void> pump(WidgetTester tester, {List<double>? volumes, bool? rising, bool changeTooltip = false}) =>
      tester.pumpWidget(MaterialApp(
        theme: ThemeData(primaryColor: AppColors.primaryMain, extensions: [ExtendedColors(
                primaryMain: AppColors.primaryMain,
                primary500: AppColors.primary500,
                primary400: AppColors.primary400,
                primary300: AppColors.primary300,
                primary200: AppColors.primary200,
                primary100: AppColors.primary100,
                footerColor: Color(0xCCF1F1F1),
                neutral100: AppColors.neutral100,
                neutral200: AppColors.neutral200,
                neutral300: AppColors.neutral300,
                neutral400: AppColors.neutral400,
                neutral500: AppColors.neutral500,
                bgBase: AppColors.bgBase,
                bgSecondary: AppColors.bgSecondary,
                bgTertiary: AppColors.bgTertiary,
                purple: AppColors.purpleMain,
                purple500: AppColors.purple500,
                purple400: AppColors.purple400,
                purple300: AppColors.purple300,
                purple200: AppColors.purple200,
                purple100: AppColors.purple100,
                orange: AppColors.orangeMain,
                orange500: AppColors.orange500,
                orange400: AppColors.orange400,
                orange300: AppColors.orange300,
                orange200: AppColors.orange200,
                orange100: AppColors.orange100,
                yellow: AppColors.yellowMain,
                yellow500: AppColors.yellow500,
                yellow400: AppColors.yellow400,
                yellow300: AppColors.yellow300,
                yellow200: AppColors.yellow200,
                yellow100: AppColors.yellow100,
                red: AppColors.redMain,
                red500: AppColors.red500,
                red400: AppColors.red400,
                red300: AppColors.red300,
                red200: AppColors.red200,
                red100: AppColors.red100,
                material: AppColors.materialLight,
              )]),
        home: Scaffold(body: SizedBox(width: 375, child: FinanceChart(
          spots: const [FlSpot(0, 10), FlSpot(1, 12), FlSpot(2, 11), FlSpot(3, 9)],
          height: 250,
          volumes: volumes,
          isRising: rising,
          changeTooltip: changeTooltip,
        ))),
      ));

  testWidgets('volume bars render with matching length', (tester) async {
    await pump(tester, volumes: [100, 0, 50, 300], rising: false);
    final bars = find.byWidgetPredicate((w) =>
        w is CustomPaint && w.painter.runtimeType.toString() == '_VolumeBarsPainter');
    expect(bars, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no bars when volumes missing or mismatched', (tester) async {
    await pump(tester, volumes: [1, 2]);
    final bars = find.byWidgetPredicate((w) =>
        w is CustomPaint && w.painter.runtimeType.toString() == '_VolumeBarsPainter');
    expect(bars, findsNothing);
  });

  testWidgets('isRising overrides trend color', (tester) async {
    // Утга 10 → 9 буурсан ч isRising: true бол primary
    await pump(tester, rising: true);
    final chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.lineBarsData.first.color, AppColors.primaryMain);
    await pump(tester, rising: false);
    final chart2 = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart2.data.lineBarsData.first.color, isNot(AppColors.primaryMain));
  });

  testWidgets('change tooltip: price + signed change vs previous point', (tester) async {
    await pump(tester, changeTooltip: true, rising: false);
    final data = tester.widget<LineChart>(find.byType(LineChart)).data;
    final bar = data.lineBarsData.first;
    // spots: 10, 12, 11, 9 → index 2 (11) өмнөхөөс −1 (−8.33%)
    final items = data.lineTouchData.touchTooltipData
        .getTooltipItems([LineBarSpot(bar, 0, bar.spots[2])]);
    final item = items.first!;
    final change = item.children!.first as TextSpan;
    expect(item.text, contains('11'));
    expect(change.text, '\u00A0\u00A0-1.00\u00A0(-8.33%)');
    // Эхний цэг — өөрчлөлтгүй
    final first = data.lineTouchData.touchTooltipData
        .getTooltipItems([LineBarSpot(bar, 0, bar.spots[0])]).first!;
    expect(first.children, isEmpty);
  });
}
