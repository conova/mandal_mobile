import '../common/stock_row_format.dart';

/// /orders/active, /orders/activebonds, /orders/activestocks API-ийн
/// мөрийн типжүүлсэн загвар.
class Order {
  final String txnId;
  final String orderNo;
  final String stockcode;
  final String symbol;

  /// STOCKNAME → COMPNAME → SYMBOL дарааллаар эхний хоосон биш нэр
  final String name;

  /// Латин нэр (COMPNAME2)
  final String name2;

  /// Авах/Зарах (TXNNAME / TXNNAME2)
  final String txnName;
  final String txnName2;

  /// bond / stock (STOCKGRP)
  final String stockGrp;

  /// Захиалгын төрөл — НӨХЦӨЛТ/LIMIT, ЗАХ ЗЭЭЛИЙН ҮНЭ/MARKET
  final String orderName;
  final String orderName2;

  /// Захиалгын нөхцөл — GOOD TILL CANCEL гэх мэт
  final String condName;
  final String condName2;

  /// Захиалга үүсгэсэн огноо ("2025/04/28 20:53:03")
  final String orderDate;

  /// Захиалсан тоо ширхэг (CNT)
  final double? cnt;

  /// Захиалсан нэгж үнэ (PRICE)
  final double? price;

  final double? fee;

  /// Төлөв — Биелэсэн/Done, Цуцлагдсан/Canceled гэх мэт
  final String statusName;
  final String statusName2;

  final String doneDate;

  /// Биелэсэн тоо ширхэг (DONECNT)
  final double? doneCnt;

  /// Биелэсэн нэгж үнэ (DONEPRICE)
  final double? donePrice;

  final double? feeAmount;
  final String settleDate;

  final String curCode;
  final double? curRate;
  final bool isOpen;
  final bool isForeign;

  final String payPeriod;
  final String payPeriod2;
  final String descr;
  final String srcName;

  /// API-ийн анхны мөр — дэлгэрэнгүй дэлгэц рүү дамжуулахад
  final Map<String, dynamic> raw;

  const Order({
    required this.txnId,
    required this.orderNo,
    required this.stockcode,
    required this.symbol,
    required this.name,
    required this.name2,
    required this.txnName,
    required this.txnName2,
    required this.stockGrp,
    required this.orderName,
    required this.orderName2,
    required this.condName,
    required this.condName2,
    required this.orderDate,
    required this.cnt,
    required this.price,
    required this.fee,
    required this.statusName,
    required this.statusName2,
    required this.doneDate,
    required this.doneCnt,
    required this.donePrice,
    required this.feeAmount,
    required this.settleDate,
    required this.curCode,
    required this.curRate,
    required this.isOpen,
    required this.isForeign,
    required this.payPeriod,
    required this.payPeriod2,
    required this.descr,
    required this.srcName,
    required this.raw,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    String str(String key) => json[key]?.toString() ?? '';
    double? num_(String key) =>
        double.tryParse(json[key]?.toString().replaceAll(',', '') ?? '');
    String firstNonEmpty(List<String> keys) {
      for (final key in keys) {
        final v = str(key).trim();
        if (v.isNotEmpty) return v;
      }
      return '';
    }

    return Order(
      txnId: str('TXNID'),
      orderNo: str('ORDERNO'),
      stockcode: str('STOCKCODE'),
      symbol: str('SYMBOL'),
      name: firstNonEmpty(['STOCKNAME', 'COMPNAME', 'SYMBOL']),
      name2: str('COMPNAME2'),
      txnName: str('TXNNAME'),
      txnName2: str('TXNNAME2'),
      stockGrp: str('STOCKGRP'),
      orderName: str('ORDERNAME'),
      orderName2: str('ORDERNAME2'),
      condName: str('CONDNAME'),
      condName2: str('CONDNAME2'),
      orderDate: str('ORDERDATE'),
      cnt: num_('CNT'),
      price: num_('PRICE'),
      fee: num_('FEE'),
      statusName: str('STATUSNAME'),
      statusName2: str('STATUSNAME2'),
      doneDate: str('DONEDATE'),
      doneCnt: num_('DONECNT'),
      donePrice: num_('DONEPRICE'),
      feeAmount: num_('FEEAMOUNT'),
      settleDate: str('SETTLEDATE'),
      curCode: str('CURCODE'),
      curRate: num_('CURRATE'),
      isOpen: str('ISOPEN') == '1',
      isForeign: str('ISFOREIGN') == '1',
      payPeriod: str('PAYPERIOD'),
      payPeriod2: str('PAYPERIOD2'),
      descr: str('DESCR'),
      srcName: str('SRCNAME'),
      raw: json,
    );
  }

  static List<Order> listFromJson(List<Map<String, dynamic>> rows) =>
      rows.map(Order.fromJson).toList();

  // ── Туслах getter-ууд ──────────────────────────────────────────────

  /// mn бол монгол, бусад хэлэнд англи утга (хоосон бол монголоороо)
  static String _pick(String mn, String en, String lang) =>
      lang == 'mn' || en.isEmpty ? mn : en;

  String nameOf(String lang) => _pick(name, name2, lang);
  String txnNameOf(String lang) => _pick(txnName, txnName2, lang);
  String statusNameOf(String lang) => _pick(statusName, statusName2, lang);
  String orderNameOf(String lang) => _pick(orderName, orderName2, lang);
  String condNameOf(String lang) => _pick(condName, condName2, lang);

  bool get isBuy => txnName2.toLowerCase() == 'buy' || txnName == 'Авах';
  bool get isBond => stockGrp == 'bond';
  bool get isStock => stockGrp == 'stock';
  bool get isDone => statusName2.toLowerCase() == 'done';
  bool get isCanceled => statusName2.toLowerCase() == 'canceled';

  /// Гадаад валюттай эсэх ($-аар харуулах)
  bool get isForeignCurrency => isForeign || curCode.isNotEmpty && curCode != 'MNT';

  /// Нийт дүн = захиалсан тоо × нэгж үнэ
  double get totalAmount => (cnt ?? 0) * (price ?? 0);

  /// Биелэлт: "534/534 (100%)"
  String get executionLabel {
    final total = cnt ?? 0;
    final done = doneCnt ?? 0;
    final pct = total == 0 ? 0 : (done / total * 100).round();
    return '${formatStockAmount(done, decimals: 0).replaceAll('₮', '')}/'
        '${formatStockAmount(total, decimals: 0).replaceAll('₮', '')} ($pct%)';
  }

  /// "2025/04/28 20:53:03" → "2025.04.28 20:53"
  String get orderDateLabel {
    if (orderDate.isEmpty) return '-';
    final parts = orderDate.split(' ');
    final date = parts.first.replaceAll('/', '.');
    final time = parts.length > 1
        ? parts[1].split(':').take(2).join(':')
        : '';
    return time.isEmpty ? date : '$date $time';
  }
}
