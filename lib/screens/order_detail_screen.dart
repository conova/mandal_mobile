import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import 'components/order_detail/order_detail_header.dart';
import 'components/order_detail/order_detail_summary.dart';
import 'components/order_detail/order_detail_history.dart';

/// Захиалгын дэлгэрэнгүй.
///
/// Route args: `{'order': Order}`
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final order = args?['order'] as Order?;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircleBackButton(),
          ),
        ),
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: order == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrderDetailHeader(order: order),
                  const SizedBox(height: 32),
                  OrderDetailSummary(order: order),
                  const SizedBox(height: 32),
                  // Биелэлт байгаа үед л түүхийн хэсэг гарна
                  if ((order.doneCnt ?? 0) > 0) ...[
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: extendedColors.neutral500,
                    ),
                    const SizedBox(height: 32),
                    OrderDetailHistory(order: order),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
