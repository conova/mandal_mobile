import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class DeviceItem extends StatelessWidget {
  final String deviceName;
  final String status;
  final bool isActive;
  final String date;
  final String ip;
  final VoidCallback? onRemove;

  const DeviceItem({
    super.key,
    required this.deviceName,
    required this.status,
    required this.isActive,
    required this.date,
    required this.ip,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  deviceName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 90),
                child: CustomButton(
                  onPressed: onRemove,
                  label: l10n.remove,
                  isLoading: false,
                  variant: CustomButtonVariant.error,
                  size: CustomButtonSize.small,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? extendedColors.primary100
                  : extendedColors.bgSecondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isActive
                    ? extendedColors.primaryMain
                    : extendedColors.neutral100,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.date,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ipAddress,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: extendedColors.neutral200,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ip,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: extendedColors.neutral100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
