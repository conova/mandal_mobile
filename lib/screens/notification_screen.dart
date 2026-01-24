import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/mark_read_bottom_sheet.dart';

import '../widgets/filter_chip_bar.dart';
import '../widgets/notification_item.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final categories = {
      'All': l10n.allNotifications,
      'Trading': l10n.trading,
      'News': l10n.news,
      'Others': l10n.others,
    };

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: () => _showMarkReadPopup(context),
              icon: Icon(Icons.check, size: 18, color: colorScheme.onSurfaceVariant),
              label: Text(
                l10n.markAllAsRead,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant, 
                  fontSize: 13, 
                  fontWeight: FontWeight.bold
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
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
            child: ListView(
              children: [
                NotificationItem(
                  title: 'Гарчиг',
                  subtitle: 'Тайлбар текст урт байж болох ба энэ урт нь 2-с илүү мөр бичигдэхгүй байна. 3 дах мөр...',
                  time: '2025.10.30 19:32',
                  isUnread: true,
                  icon: Icons.notifications_none_outlined,
                ),
                NotificationItem(
                  title: 'Unread messages',
                  subtitle: 'Here’s description text for users to notify what happened in Mandal',
                  time: '2025.10.30 19:32',
                  isUnread: true,
                  icon: Icons.notifications_none_outlined,
                ),
                NotificationItem(
                  title: 'Мэдээ',
                  subtitle: 'Ямар мэдээллүүд дээр мэдэгдэл өгөх эсэхээ ярилцаж шийдвэрлээ.',
                  time: '2025.10.30 19:32',
                  isUnread: false,
                  icon: Icons.notifications_none_outlined,
                ),
                NotificationItem(
                  title: 'Simple бонд - Захиалга биелэлээ',
                  subtitle: 'Таны 10,000,000₮ захиалга биелэлээ. Бондын мөнгө 2025.10.30-нд орох болно.',
                  time: '2025.10.30 19:32',
                  isUnread: false,
                  icon: Icons.notifications_none_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkReadPopup(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MarkReadBottomSheet(),
    );

    if (result == true) {
      // Logic to mark all as read
      print('Marked all as read');
    }
  }
}
