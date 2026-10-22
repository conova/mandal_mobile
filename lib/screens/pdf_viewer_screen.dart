import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
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
  // Auto-retry configuration
  static const int _maxAutoRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 6);

  late Future<Uint8List> _pdfFuture;
  final ScrollController _scrollController = ScrollController();

  // Zoom/pan state for InteractiveViewer
  final TransformationController _transformController =
  TransformationController();

  // Auto-retry state for render errors
  int _renderRetries = 0;
  bool _reloadScheduled = false;

  @override
  void initState() {
    super.initState();
    _pdfFuture = _fetchPdf();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  /// Downloads the PDF. On failure, waits [_retryDelay] (spinner stays visible
  /// because the Future is still pending) and retries up to [_maxAutoRetries]
  /// times before rethrowing.
  ///
  /// [delayFirst] is used when reloading after a render error, so the spinner
  /// is shown for a few seconds before the new request starts.
  Future<Uint8List> _fetchPdf({bool delayFirst = false}) async {
    if (delayFirst) {
      await Future.delayed(_retryDelay);
    }

    for (var attempt = 0;; attempt++) {
      try {
        if (!mounted) throw Exception('Screen disposed');
        final response = await Dio().get<Uint8List>(
          widget.url,
          options: Options(responseType: ResponseType.bytes),
        );
        if (response.data == null) {
          throw Exception("Failed to load PDF data");
        }
        return response.data!;
      } catch (e) {
        debugPrint('Error fetching PDF (attempt ${attempt + 1}): $e');
        if (attempt >= _maxAutoRetries || !mounted) rethrow;
        // Keep the loading spinner visible while waiting before the next try
        await Future.delayed(_retryDelay);
      }
    }
  }

  /// Resets zoom to default (useful as a "fit to width" button)
  void _resetZoom() {
    _transformController.value = Matrix4.identity();
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
        leading: const Padding(
          padding: EdgeInsets.only(left: 20, top: 8, bottom: 8),
          child: CircleBackButton(),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset zoom',
            icon: Icon(Icons.fit_screen, color: extendedColors.neutral100),
            onPressed: _resetZoom,
          ),
        ],
      ),
      body: FutureBuilder<Uint8List>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildError(extendedColors, l10n);
          }

          return PdfPreview.builder(
            build: (format) => snapshot.data!,
            useActions: true,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            loadingWidget: const Center(child: CircularProgressIndicator()),
            onError: (context, error) {
              if (_renderRetries < _maxAutoRetries) {
                if (!_reloadScheduled) {
                  _reloadScheduled = true;
                  _renderRetries++;
                  // Can't call setState during build, so defer it
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _reloadScheduled = false;
                    if (!mounted) return;
                    setState(() => _pdfFuture = _fetchPdf(delayFirst: true));
                  });
                }
                return const Center(child: CircularProgressIndicator());
              }
              return _buildError(extendedColors, l10n);
            },
            pagesBuilder: (context, pages) {
              return _PdfPagesView(
                pages: pages,
                extendedColors: extendedColors,
                scrollController: _scrollController,
                transformController: _transformController,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildError(ExtendedColors extendedColors, AppLocalizations l10n) {
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
            onPressed: () => setState(() {
              _renderRetries = 0;
              _pdfFuture = _fetchPdf();
            }),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _PdfPagesView extends StatefulWidget {
  final List<PdfPreviewPageData> pages;
  final ExtendedColors extendedColors;
  final ScrollController scrollController;
  final TransformationController transformController;

  const _PdfPagesView({
    required this.pages,
    required this.extendedColors,
    required this.scrollController,
    required this.transformController,
  });

  @override
  State<_PdfPagesView> createState() => _PdfPagesViewState();
}

class _PdfPagesViewState extends State<_PdfPagesView> {
  int _currentPage = 0;

  // One key per page, created lazily so it never goes out of range
  // (PdfPreview may add pages to the same list while rendering)
  final Map<int, GlobalKey> _itemKeys = {};
  GlobalKey _keyFor(int index) =>
      _itemKeys.putIfAbsent(index, () => GlobalKey());
  final GlobalKey _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    // Initial calculation after first layout
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final controller = widget.scrollController;
    if (!controller.hasClients) return;

    final pageCount = widget.pages.length;
    if (pageCount == 0) return;

    int newPage = _currentPage;
    final pos = controller.position;

    // 1) At the bottom -> always the last page
    if (pos.maxScrollExtent > 0 && pos.pixels >= pos.maxScrollExtent - 4) {
      newPage = pageCount - 1;
    }
    // 2) At the top -> always the first page
    else if (pos.pixels <= 4) {
      newPage = 0;
    }
    // 3) Otherwise: the page that covers the viewport's vertical center
    else {
      final listBox =
      _listKey.currentContext?.findRenderObject() as RenderBox?;
      if (listBox == null || !listBox.hasSize) return;

      final listTop = listBox.localToGlobal(Offset.zero).dy;
      final centerY = listTop + listBox.size.height / 2;

      for (int i = 0; i < pageCount; i++) {
        final ctx = _itemKeys[i]?.currentContext;
        if (ctx == null) continue; // not built (off-screen)
        final box = ctx.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) continue;

        final top = box.localToGlobal(Offset.zero).dy;
        final bottom = top + box.size.height;

        if (top <= centerY && bottom >= centerY) {
          newPage = i;
          break;
        }
      }
    }

    if (newPage != _currentPage) {
      setState(() => _currentPage = newPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Snapshot: PdfPreview mutates/clears its page list while re-rendering,
    // which makes pages[index] throw RangeError inside the lazy itemBuilder.
    final pages = List<PdfPreviewPageData>.of(widget.pages);
    final currentPage =
    pages.isEmpty ? 0 : _currentPage.clamp(0, pages.length - 1);
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Zoomable + scrollable content
        InteractiveViewer(
          transformationController: widget.transformController,
          panEnabled: false, // scrolling is handled by ListView
          scaleEnabled: true,
          minScale: 1.0,
          maxScale: 4.0,
          child: Scrollbar(
            controller: widget.scrollController,
            thumbVisibility: true,
            interactive: true,
            child: ListView.builder(
              key: _listKey,
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return Padding(
                  key: _keyFor(index),
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image(
                      image: pages[index].image,
                      width: screenWidth - 24,
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Floating "current page / total" indicator
        Positioned(
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentPage + 1} / ${pages.length}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}