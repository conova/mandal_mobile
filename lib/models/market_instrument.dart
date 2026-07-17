/// /stocks/* API-уудын (bondlist, mybonds, mystocks, nbo, info) мөрийн
/// нэгдсэн типжүүлсэн загвар. Raw map-аас [MarketInstrument.fromJson]-оор
/// угсарч, дэлгэцүүд түүхий түлхүүр (`row['ISOPEN']` г.м.) ашиглахын
/// оронд типтэй талбаруудыг хэрэглэнэ.
class MarketInstrument {
  final String stockcode;
  final String symbol;

  /// STOCKNAME → COMPNAME → SYMBOL дарааллаар эхний хоосон биш нэр
  final String name;

  /// COMPNAME2 → TYPENAME дарааллаар — дэд нэр
  final String subtitle;

  final String typeName;
  final String market;
  final String marketName;
  final String stockGrp;

  /// Бондын хугацаа — огноо ("2027/07/07") эсвэл сарын тоо байж болно
  final String term;

  /// Дараагийн хүү төлөх огноо ("2026/07/18")
  final String payday;

  /// Хүү төлөх давтамж (монгол / англи)
  final String payPeriod;
  final String payPeriod2;

  final double? intRate;
  final double? amt;
  final double? orderedAmt;
  final double? closePrice;
  final double? openPrice;
  final double? priceChange;
  final double? stockFee;

  // /stocks/info-ийн нэмэлт талбарууд (бусад API-д null)
  final double? peRatio;
  final double? pbRatio;
  final double? marketValue;
  final double? divYield;
  final double? divAmount;
  final double? divPrice;
  final double? avgTrade;
  final double? dayTrade;
  final String divDate;

  // /stocks/mybonds-ийн нэмэлт талбарууд (бусад API-д null)
  /// Хүү авсан тоо / нийт авах тоо (DIVCNT / DIVTOTAL)
  final int? divCnt;
  final int? divTotal;

  /// Нийт авсан өгөөж (RCVYEILD)
  final double? rcvYield;

  /// Ирээдүйд авах өгөөж (EXPYEILD)
  final double? expYield;

  /// Эзэмшиж буй ширхэг (CURRENTBAL)
  final double? currentBal;

  /// Дундаж үнэ (AVGPRICE)
  final double? avgPrice;

  final String curCode;
  final double? curRate;

  final bool isOpen;
  final bool isForeign;

  /// API-ийн анхны мөр — route arguments-аар цааш дамжуулахад ашиглана
  final Map<String, dynamic> raw;

  const MarketInstrument({
    required this.stockcode,
    required this.symbol,
    required this.name,
    required this.subtitle,
    required this.typeName,
    required this.market,
    required this.marketName,
    required this.stockGrp,
    required this.term,
    required this.payday,
    required this.payPeriod,
    required this.payPeriod2,
    required this.intRate,
    required this.amt,
    required this.orderedAmt,
    required this.closePrice,
    required this.openPrice,
    required this.priceChange,
    required this.stockFee,
    this.peRatio,
    this.pbRatio,
    this.marketValue,
    this.divYield,
    this.divAmount,
    this.divPrice,
    this.avgTrade,
    this.dayTrade,
    this.divDate = '',
    this.divCnt,
    this.divTotal,
    this.rcvYield,
    this.expYield,
    this.currentBal,
    this.avgPrice,
    this.curCode = '',
    this.curRate,
    required this.isOpen,
    required this.isForeign,
    required this.raw,
  });

  factory MarketInstrument.fromJson(Map<String, dynamic> json) {
    String str(String key) => json[key]?.toString() ?? '';
    double? num_(String key) =>
        double.tryParse(json[key]?.toString().replaceAll(',', '') ?? '');
    String firstNonEmpty(List<String> keys) {
      for (final key in keys) {
        final v = str(key);
        if (v.isNotEmpty) return v;
      }
      return '';
    }

    return MarketInstrument(
      stockcode: str('STOCKCODE'),
      symbol: str('SYMBOL'),
      name: firstNonEmpty(['STOCKNAME', 'COMPNAME', 'SYMBOL']),
      subtitle: firstNonEmpty(['COMPNAME2', 'TYPENAME']),
      typeName: str('TYPENAME'),
      market: str('MARKET'),
      marketName: str('MARKETNAME'),
      stockGrp: str('STOCKGRP'),
      term: str('TERM'),
      payday: str('PAYDAY'),
      payPeriod: str('PAYPERIOD'),
      payPeriod2: str('PAYPERIOD2'),
      intRate: num_('INTRATE'),
      amt: num_('AMT'),
      orderedAmt: num_('ORDEREDAMT'),
      closePrice: num_('CLOSEPRICE'),
      openPrice: num_('OPENPRICE'),
      priceChange: num_('PRICECHANGE'),
      stockFee: num_('STOCKFEE'),
      peRatio: num_('PERATIO'),
      pbRatio: num_('PBRATIO'),
      marketValue: num_('MARKETVALUE'),
      divYield: num_('DIVYEILD'),
      divAmount: num_('DIVAMOUNT'),
      divPrice: num_('DIVPRICE'),
      avgTrade: num_('AVGTRADE'),
      dayTrade: num_('DAYTRADE'),
      divDate: str('DIVDATE'),
      divCnt: int.tryParse(str('DIVCNT')),
      divTotal: int.tryParse(str('DIVTOTAL')),
      rcvYield: num_('RCVYEILD'),
      expYield: num_('EXPYEILD'),
      currentBal: num_('CURRENTBAL'),
      avgPrice: num_('AVGPRICE'),
      curCode: str('CURCODE'),
      curRate: num_('CURRATE'),
      isOpen: str('ISOPEN') == '1',
      isForeign: str('ISFOREIGN') == '1',
      raw: json,
    );
  }

  static List<MarketInstrument> listFromJson(List<Map<String, dynamic>> rows) =>
      rows.map(MarketInstrument.fromJson).toList();

  /// Анхдагч зах зээлийнх эсэх
  bool get isPrimaryMarket => market.toLowerCase() == 'primary';
}
