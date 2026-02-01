import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/api_service.dart';
import '../../../config/api_config.dart';
import '../../../theme/extended_colors.dart';

class HomeAssetSummary extends StatefulWidget {
  const HomeAssetSummary({super.key});

  @override
  State<HomeAssetSummary> createState() => _HomeAssetSummaryState();
}

class _HomeAssetSummaryState extends State<HomeAssetSummary> {
  bool _isLoading = false;
  String _totalAssets = '50,628,000';
  String _totalAssetsDec = '.21₮';
  String _assetChange = '+210,351.52₮';
  String _assetChangePercent = '9.71%';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchAssetData());
  }

  Future<void> _fetchAssetData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final dynamic response = await apiService.get(ApiConfig.profile);
      debugPrint('Asset data: $response');
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.totalAssets,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.disabledColor,
          ),
        ),
        const SizedBox(height: 4),
        _isLoading
            ? const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _totalAssets,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _totalAssetsDec,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              _assetChange,
              style: TextStyle(
                color: extendedColors.primaryMain,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_up,
              color: extendedColors.primaryMain,
              size: 18,
            ),
            Text(
              '$_assetChangePercent ',
              style: TextStyle(
                color: extendedColors.primaryMain,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              '(${l10n.last1Month})',
              style: TextStyle(color: theme.disabledColor, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
