import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_api_service.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/mark_read_bottom_sheet.dart';
import '../widgets/notification_item.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedCategory = 'All';
  List<ApiNotification> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final service = context.read<NotificationApiService>();
      final feed = await service.list(limit: 100);
      if (!mounted) return;
      setState(() {
        _items = feed.items;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _onItemTap(ApiNotification n) async {
    // Дэлгэрэнгүй харах + read болгох
    final wasUnread = !n.isRead;
    await Navigator.pushNamed(
      context,
      '/notification_detail',
      arguments: {
        'title': n.title,
        'body': n.body.isNotEmpty ? n.body : null,
        'time': n.formattedTime,
        'icon': Icons.notifications_none_outlined,
      },
    );

    if (wasUnread) {
      try {
        await context.read<NotificationApiService>().markRead(n.id);
        // Локалд тэмдэглээд UI-г шинэчилнэ — server-аас дахин татах хэрэггүй
        if (!mounted) return;
        setState(() {
          final idx = _items.indexWhere((x) => x.id == n.id);
          if (idx >= 0) {
            final orig = _items[idx];
            _items[idx] = ApiNotification(
              id: orig.id,
              type: orig.type,
              title: orig.title,
              body: orig.body,
              data: orig.data,
              targetKind: orig.targetKind,
              isRead: true,
              createdAt: orig.createdAt,
            );
          }
        });
      } catch (_) {
        // алдаа гарвал чимээгүй (хэрэглэгчийн UX-д хүчтэй нөлөөлөхгүй)
      }
    }
  }

  Future<void> _markAllRead() async {
    try {
      await context.read<NotificationApiService>().markAllRead();
      if (!mounted) return;
      setState(() {
        _items = _items
            .map((n) => ApiNotification(
                  id: n.id,
                  type: n.type,
                  title: n.title,
                  body: n.body,
                  data: n.data,
                  targetKind: n.targetKind,
                  isRead: true,
                  createdAt: n.createdAt,
                ))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        type: CustomSnackbarType.error,
      );
    }
  }

  /// Сонгосон categorist-аар filter хийх (одоо type field ашиглана)
  List<ApiNotification> get _filtered {
    if (_selectedCategory == 'All') return _items;
    return _items.where((n) {
      switch (_selectedCategory) {
        case 'Trading':
          return n.type == 'order' || n.type == 'trading';
        case 'News':
          return n.type == 'news' || n.type == 'promo';
        case 'Others':
          return n.type == 'system' ||
              (n.type != 'order' &&
                  n.type != 'trading' &&
                  n.type != 'news' &&
                  n.type != 'promo');
        default:
          return true;
      }
    }).toList();
  }

  int get _unreadCount => _items.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final categories = {
      'All': l10n.allNotifications,
      'Trading': l10n.trading,
      'News': l10n.news,
      'Others': l10n.others,
    };

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: extendedColors.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: _unreadCount > 0 ? () => _showMarkReadPopup() : null,
              icon: Icon(
                Icons.check,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              label: Text(
                l10n.markAllAsRead,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Text(
                  l10n.notifications,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _unreadCount.toString(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          FilterChipBar(
            filters: categories.values.toList(),
            selectedFilter: categories[_selectedCategory]!,
            onFilterSelected: (selectedLabel) {
              setState(() {
                _selectedCategory = categories.entries
                    .firstWhere((entry) => entry.value == selectedLabel)
                    .key;
              });
            },
            horizontalPadding: 16,
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetch,
              child: _isLoading && _items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null && _items.isEmpty
                      ? _buildErrorState(theme, extendedColors)
                      : _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ExtendedColors c) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          _error ?? '',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: c.neutral200),
        ),
      ],
    );
  }

  Widget _buildList() {
    final list = _filtered;
    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Мэдэгдэл байхгүй')),
        ],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final n = list[i];
        return NotificationItem(
          title: n.title,
          subtitle: n.body,
          time: n.formattedTime,
          isUnread: !n.isRead,
          icon: Icons.notifications_none_outlined,
          onTap: () => _onItemTap(n),
        );
      },
    );
  }

  void _showMarkReadPopup() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MarkReadBottomSheet(),
    );

    if (result == true) {
      await _markAllRead();
    }
  }
}
