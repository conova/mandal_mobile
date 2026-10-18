import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mandal_capital/l10n/app_localizations.dart';
import 'package:mandal_capital/screens/components/transaction_history/transaction_filter_sheet.dart';
import 'package:mandal_capital/theme/app_colors.dart';
import 'package:mandal_capital/theme/extended_colors.dart';

void main() {
  testWidgets('filter sheet fits 375x812 and returns selection', (tester) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    TransactionFilter? result;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('mn'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(extensions: [ExtendedColors(
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
      home: Builder(builder: (context) => Scaffold(
        body: Center(child: ElevatedButton(
          onPressed: () async {
            result = await showModalBottomSheet<TransactionFilter>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const TransactionFilterSheet(),
            );
          },
          child: const Text('open'),
        )),
      )),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
        expect(find.text('Гүйлгээний төрөл'), findsOneWidget);
    expect(find.text('Хувьцааны арилжаа'), findsOneWidget);
    await tester.tap(find.text('+ Орлого'));
    await tester.tap(find.text('Бондын арилжаа'));
    await tester.pump();
    await tester.tap(find.text('Шүүх'));
    await tester.pumpAndSettle();
    expect(result!.directions, {TxnDirection.income});
    expect(result!.categories, {TxnCategory.bond});
    expect(tester.takeException(), isNull);
  });
}
