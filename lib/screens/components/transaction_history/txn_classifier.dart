import 'transaction_filter_sheet.dart';

/// /account/statement-ийн нэг мөрийг шүүлтүүрийн ангилал, төрөлд хуваана.
///
/// Талбарууд:
///   • STOCKGRP — mnt / usd (бэлэн мөнгө), stock, bond
///   • TXNTYPE / TXNTYPE2 — "Зарлага"/"Withdrawal", "Авсан"/"Buy",
///     "Зарсан"/"Sell", өгөөж / ногдол ашиг г.м.
///   • TXNSIGN — бэлэн мөнгөний мөрөнд 1 орлого, −1 зарлага; арилжааны
///     мөрөнд үнэт цаасны тоо ширхгийн чиглэл (авсан = 1), тиймээс мөнгөний
///     хувьд эсрэг утгатай
({TxnCategory category, TxnDirection direction}) classifyTxn(
  Map<String, dynamic> row,
) {
  final group = row['STOCKGRP']?.toString().toLowerCase() ?? '';
  final type = '${row['TXNTYPE'] ?? ''} ${row['TXNTYPE2'] ?? ''}'.toLowerCase();
  final sign = int.tryParse(row['TXNSIGN']?.toString() ?? '');

  // Хүүний орлого, ногдол ашиг — бэлэн мөнгөний орлого
  final isPassiveIncome = type.contains('өгөөж') ||
      type.contains('coupon') ||
      type.contains('interest') ||
      type.contains('хүү') ||
      type.contains('ногдол') ||
      type.contains('dividend');
  if (isPassiveIncome) {
    return (category: TxnCategory.cash, direction: TxnDirection.income);
  }

  if (group == 'stock' || group == 'bond') {
    final category = group == 'stock' ? TxnCategory.stock : TxnCategory.bond;
    final isBuy = type.contains('buy') || type.contains('авсан');
    final isSell = type.contains('sell') || type.contains('зарсан');
    final direction = isBuy
        ? TxnDirection.expense
        : isSell
            ? TxnDirection.income
            // Тодорхойгүй бол TXNSIGN-ийн эсрэг (тоо ширхэг нэмэгдсэн = мөнгө гарсан)
            : (sign != null && sign < 0)
                ? TxnDirection.income
                : TxnDirection.expense;
    return (category: category, direction: direction);
  }

  // Бэлэн мөнгө (mnt / usd) — TXNSIGN, байхгүй бол текстээр
  final direction = sign != null
      ? (sign < 0 ? TxnDirection.expense : TxnDirection.income)
      : (type.contains('зарлага') ||
              type.contains('withdraw') ||
              type.contains('expense'))
          ? TxnDirection.expense
          : TxnDirection.income;
  return (category: TxnCategory.cash, direction: direction);
}
