import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_svg_icon.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
        scrolledUnderElevation: 0.0,
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
          child: CircleBackButton(),
        ),
      ),
      body: InteractiveViewer(
        panEnabled: true, // Allows dragging/panning
        minScale: 0.5,
        maxScale: 4.0, // Allows zooming up to 4x
        child: PdfPreview(
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
                  CustomSvgIcon('info-circle', size: 48, color: extendedColors.red),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorLoadingPDF,
                    style: TextStyle(color: extendedColors.neutral100),
                  ),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
