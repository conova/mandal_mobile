import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_snackbar.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Future<Uint8List> _fetchPdf() async {
    try {
      final response = await Dio().get<Uint8List>(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.data == null) {
        throw Exception("Failed to load PDF data");
      }
      return response.data!;
    } catch (e) {
      debugPrint('Error fetching PDF: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: extendedColors.neutral100,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
          child: CircleBackButton(),
        ),
      ),
      body: PdfPreview(
        build: (format) => _fetchPdf(),
        useActions: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        onError: (context, error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: extendedColors.red),
                const SizedBox(height: 16),
                Text(
                  'PDF-ийг ачаалахад алдаа гарлаа',
                  style: TextStyle(color: extendedColors.neutral100),
                ),
                TextButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Дахин оролдох'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
