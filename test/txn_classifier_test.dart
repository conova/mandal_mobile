import 'package:flutter_test/flutter_test.dart';
import 'package:mandal_capital/screens/components/transaction_history/transaction_filter_sheet.dart';
import 'package:mandal_capital/screens/components/transaction_history/txn_classifier.dart';

void main() {
  final withdrawal = {'TXNTYPE': 'Зарлага', 'TXNTYPE2': 'Withdrawal', 'STOCKGRP': 'mnt', 'TXNSIGN': '-1'};
  final bondBuy = {'TXNTYPE': 'Авсан', 'TXNTYPE2': 'Buy', 'STOCKGRP': 'bond', 'TXNSIGN': '1', 'SYMBOL': 'MAGN'};
  final deposit = {'TXNTYPE': 'Орлого', 'TXNTYPE2': 'Deposit', 'STOCKGRP': 'mnt', 'TXNSIGN': '1'};
  final stockSell = {'TXNTYPE': 'Зарсан', 'TXNTYPE2': 'Sell', 'STOCKGRP': 'stock', 'TXNSIGN': '-1'};
  final coupon = {'TXNTYPE': 'Бондын өгөөж', 'TXNTYPE2': 'Coupon', 'STOCKGRP': 'bond', 'TXNSIGN': '1'};
  final dividend = {'TXNTYPE': 'Ногдол ашиг', 'TXNTYPE2': 'Dividend', 'STOCKGRP': 'stock'};

  test('sample rows', () {
    expect(classifyTxn(withdrawal), (category: TxnCategory.cash, direction: TxnDirection.expense));
    expect(classifyTxn(bondBuy), (category: TxnCategory.bond, direction: TxnDirection.expense));
    expect(classifyTxn(deposit), (category: TxnCategory.cash, direction: TxnDirection.income));
    expect(classifyTxn(stockSell), (category: TxnCategory.stock, direction: TxnDirection.income));
    expect(classifyTxn(coupon), (category: TxnCategory.cash, direction: TxnDirection.income));
    expect(classifyTxn(dividend), (category: TxnCategory.cash, direction: TxnDirection.income));
  });

  test('filter combinations on the user sample', () {
    final rows = [withdrawal, bondBuy, withdrawal];
    List<Map> pick(TransactionFilter f) => rows.where((r) {
          final c = classifyTxn(r);
          return f.hasCategory(c.category) && f.hasDirection(c.direction);
        }).toList();
    expect(pick(const TransactionFilter(directions: {TxnDirection.expense})).length, 3);
    expect(pick(const TransactionFilter(directions: {TxnDirection.income})), isEmpty);
    expect(pick(const TransactionFilter(categories: {TxnCategory.bond})), [bondBuy]);
    expect(pick(const TransactionFilter(categories: {TxnCategory.cash})).length, 2);
    expect(pick(const TransactionFilter(
        directions: {TxnDirection.expense}, categories: {TxnCategory.stock})), isEmpty);
  });
}
