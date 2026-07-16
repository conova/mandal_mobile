/// /stocks/order_book-ийн нэг мөр (авах эсвэл зарах тал)
class OrderBookEntry {
  final double price;
  final int quantity;
  final int rank;

  const OrderBookEntry({
    required this.price,
    required this.quantity,
    required this.rank,
  });

  factory OrderBookEntry.fromJson(Map<String, dynamic> json) => OrderBookEntry(
        price: double.tryParse(json['PRICE']?.toString() ?? '') ?? 0,
        quantity: int.tryParse(json['TOTAL_CNT']?.toString() ?? '') ?? 0,
        rank: int.tryParse(json['PRICE_RANK']?.toString() ?? '') ?? 0,
      );

  /// Түүхий мөрүүдээс тухайн талын (BUY/SELL) захиалгуудыг
  /// PRICE_RANK-аар эрэмбэлж буцаана
  static List<OrderBookEntry> sideFromJson(
    List<Map<String, dynamic>> rows,
    String orderType,
  ) {
    return rows
        .where(
          (r) => r['ORDER_TYPE']?.toString().toUpperCase() == orderType,
        )
        .map(OrderBookEntry.fromJson)
        .toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
  }
}
