import 'package:flutter/material.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import 'components/order_detail/order_detail_header.dart';
import 'components/order_detail/order_detail_summary.dart';
import 'components/order_detail/order_detail_history.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OrderDetailHeader(),
            const SizedBox(height: 32),
            const OrderDetailSummary(),
            const SizedBox(height: 32),
            Divider(height: 1, thickness: 1, color: extendedColors.neutral500),
            const SizedBox(height: 32),
            const OrderDetailHistory(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
