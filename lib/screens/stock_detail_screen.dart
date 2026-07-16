import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/stock_row_format.dart';
import '../services/auth_service.dart';
import 'components/stock_detail/stock_detail_header.dart';
import 'components/stock_detail/stock_detail_chart.dart';
import 'components/stock_detail/stock_detail_general_info.dart';
import 'components/stock_detail/stock_detail_dividend_history.dart';
import 'components/stock_detail/stock_detail_bottom_bar.dart';

/// Route args:
///   { symbol: String, name: String, price: String, change: String,
///     isGrowing: bool?, stockcode: String? }
///
/// Дэлгэц нээгдэхэд /stocks/info API-г stockcode-оор дуудаж дэлгэрэнгүй
/// мэдээллийг татна.
class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({super.key});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  Map<String, dynamic> _args = const {};
  bool _initialized = false;

  /// /stocks/info-ийн мөрүүд. Эхний мөр = одоогийн ерөнхий мэдээлэл,
  /// мөр бүрийн DIVAMOUNT/DIVDATE = ногдол ашгийн түүх.
  List<Map<String, dynamic>> _infoRows = const [];

  Map<String, dynamic>? get _info => _infoRows.isEmpty ? null : _infoRows.first;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            const {};
    _fetchInfo();
  }

  Future<void> _fetchInfo() async {
    final stockcode = _args['stockcode']?.toString() ?? '';
    if (stockcode.isEmpty) return;
    try {
      final rows = await context.read<AuthService>().getStockInfo(stockcode);
      if (!mounted || rows.isEmpty) return;
      setState(() => _infoRows = rows);
    } catch (_) {
      // Мэдээлэл татагдаагүй ч args-аар ирсэн утгуудаа харуулсаар байна
    }
  }

  /// Бүх мөрийн DIVDATE/DIVAMOUNT-аас ногдол ашгийн түүх угсарна
  List<Map<String, String>> get _dividendHistory {
    final items = <Map<String, String>>[];
    for (final row in _infoRows) {
      final date = parseStockDate(row['DIVDATE']);
      final amount = row['DIVAMOUNT']?.toString() ?? '';
      if (date == null || amount.isEmpty) continue;
      items.add({
        'year': date.year.toString(),
        'amount': formatStockAmount(amount, decimals: 0),
      });
    }
    return items;
  }

  /// info-гийн талбар байвал түүнийг, үгүй бол args-ийн утгыг ашиглана
  String _display(String argKey, List<String> infoKeys, String fallback) {
    for (final key in infoKeys) {
      final v = _info?[key]?.toString();
      if (v != null && v.isNotEmpty) return v;
    }
    return (_args[argKey] as String?) ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final symbol = _display('symbol', ['SYMBOL'], '');
    final name = _display('name', ['STOCKNAME', 'COMPNAME'], '');

    // Ханш/өөрчлөлт — info-гоос тоо ирвэл форматлана, үгүй бол args
    final infoPrice = _info?['CLOSEPRICE'];
    final price = infoPrice != null && infoPrice.toString().isNotEmpty
        ? formatStockAmount(infoPrice, decimals: 0)
        : (_args['price'] as String?) ?? '-';

    final infoChange =
        double.tryParse(_info?['PRICECHANGE']?.toString() ?? '');
    final change = infoChange != null
        ? '${infoChange.abs().toStringAsFixed(2)}%'
        : (_args['change'] as String?) ?? '-';
    final isGrowing =
        infoChange != null ? infoChange >= 0 : _args['isGrowing'] as bool?;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.star_border, color: theme.colorScheme.onSurface),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StockDetailHeader(
              symbol: symbol,
              name: name,
              price: price,
              change: change,
              isGrowing: isGrowing,
            ),
            const SizedBox(height: 32),
            StockDetailChart(symbol: symbol),
            const SizedBox(height: 32),
            // Эхний мөрийн мэдээллээр ерөнхий мэдээллийг бөглөнө
            StockDetailGeneralInfo(
              marketCap: _info?['MARKETVALUE'] == null
                  ? '-'
                  : '₮${formatCompactAmount(_info!['MARKETVALUE'])}',
              peRatio: _info?['PERATIO']?.toString() ?? '-',
              pbRatio: _info?['PBRATIO']?.toString() ?? '-',
              dividendYield: _info?['DIVYEILD'] == null
                  ? '-'
                  : '${_info!['DIVYEILD']}%',
            ),
            const SizedBox(height: 48),
            // Бүх мөрийн DIVAMOUNT/DIVDATE = өнгөрсөн ногдол ашгууд
            StockDetailDividendHistory(items: _dividendHistory),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: StockDetailBottomBar(
        onTrade: () => Navigator.pushNamed(
          context,
          '/stock_trading',
          arguments: {..._args, if (_info != null) 'info': _info},
        ),
      ),
    );
  }
}
