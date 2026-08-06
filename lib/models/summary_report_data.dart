/// /portfolio/summary_report хариуны типжүүлсэн загварууд.

double _toDouble(dynamic v) =>
    double.tryParse(v?.toString().replaceAll(',', '') ?? '') ?? 0;

/// portfolio мөр — тухайн огнооны нэг төрлийн үлдэгдэл
class PortfolioSnapshot {
  final String date; // TXNDATE "2026.07.16"
  final String type; // bond | cash | stock (dynamic байж болно)
  final String codeName;
  final double amount;
  final double amountMnt;
  final int count;
  final double usdRate;

  const PortfolioSnapshot({
    required this.date,
    required this.type,
    required this.codeName,
    required this.amount,
    required this.amountMnt,
    required this.count,
    required this.usdRate,
  });

  factory PortfolioSnapshot.fromJson(Map<String, dynamic> json) =>
      PortfolioSnapshot(
        date: json['TXNDATE']?.toString() ?? '',
        type: json['TYPE']?.toString().toLowerCase() ?? '',
        codeName: json['CODENAME']?.toString() ?? '',
        amount: _toDouble(json['AMOUNT']),
        amountMnt: _toDouble(json['AMOUNTMNT']),
        usdRate: _toDouble(json['USDRATE']),
        count: int.tryParse(json['CNT']?.toString() ?? '') ?? 0,
      );
}

/// transactions мөр — төрөл бүрээс нэг л мөр ирнэ
class TransactionSummary {
  final String date;
  final String type; // stock | cash | rateincome | dividend | bond
  final double amountMnt;
  final double usdRate;

  const TransactionSummary({
    required this.date,
    required this.type,
    required this.amountMnt,
    required this.usdRate,
  });

  factory TransactionSummary.fromJson(Map<String, dynamic> json) =>
      TransactionSummary(
        date: json['TXNDATE']?.toString() ?? '',
        type: json['TYPE']?.toString().toLowerCase() ?? '',
        amountMnt: _toDouble(json['AMOUNTMNT']),
        usdRate: _toDouble(json['USDRATE']),
      );
}

/// Тайлангийн бүтэн хариу + түгээмэл тооцооллууд
class SummaryReportData {
  final List<PortfolioSnapshot> portfolio;
  final List<TransactionSummary> transactions;

  const SummaryReportData({
    required this.portfolio,
    required this.transactions,
  });

  static const empty = SummaryReportData(portfolio: [], transactions: []);

  factory SummaryReportData.fromJson(Map<String, dynamic>? json) {
    List<Map<String, dynamic>> rows(String key) =>
        (json?[key] as List? ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

    return SummaryReportData(
      portfolio: rows('portfolio').map(PortfolioSnapshot.fromJson).toList(),
      transactions:
          rows('transactions').map(TransactionSummary.fromJson).toList(),
    );
  }

  bool get isEmpty => portfolio.isEmpty;

  /// Эрэмбэлэгдсэн огноонууд ("yyyy.MM.dd" — үсгийн эрэмбэ ажиллана)
  List<String> get dates {
    final set = <String>{for (final p in portfolio) p.date}..remove('');
    return set.toList()..sort();
  }

  /// Тухайн огнооны тухайн төрлийн дүн (₮)
  double typeOf(String date, String type) => portfolio
      .where((p) => p.date == date && p.type == type)
      .fold(0, (s, p) => s + p.amountMnt);

  /// Тухайн огнооны нийт хөрөнгө — бүх төрлийн нийлбэр
  double totalOf(String date) => portfolio
      .where((p) => p.date == date)
      .fold(0, (s, p) => s + p.amountMnt);

  /// Гүйлгээний төрлийн дүн — тухайн төрөл ирээгүй бол 0
  double txnAmount(String type) => transactions
      .where((t) => t.type == type)
      .fold(0, (s, t) => s + t.amountMnt);
}
