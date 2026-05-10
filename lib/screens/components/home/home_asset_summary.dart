import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
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
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: AppTextStyles.light,
            color: extendedColors.neutral100,
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
                  Flexible(
                    child: Text(
                      _totalAssets,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: AppTextStyles.semiBold,
                        color: theme.colorScheme.onBackground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _totalAssetsDec,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: AppTextStyles.semiBold,
                      color: extendedColors.neutral300,
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              _assetChange,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.primaryMain,
                fontWeight: AppTextStyles.light,
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: extendedColors.primaryMain,
                fontWeight: AppTextStyles.light,
              ),
            ),
            Text(
              '(${l10n.last1Month})',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: AppTextStyles.light,
                color: extendedColors.neutral100,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
