import 'package:flutter/material.dart';
import 'components/order_detail/order_detail_header.dart';
import 'components/order_detail/order_detail_summary.dart';
import 'components/order_detail/order_detail_history.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrderDetailHeader(),
            SizedBox(height: 32),
            OrderDetailSummary(),
            SizedBox(height: 32),
            Divider(height: 1, thickness: 1),
            SizedBox(height: 32),
            OrderDetailHistory(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
