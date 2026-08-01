import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/api_notification.dart';
import '../services/notification_api_service.dart';
import '../services/notification_mocks.dart';
import '../services/notification_service.dart' show NotificationService;
import '../theme/app_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_svg_icon.dart';
import '../widgets/mark_read_bottom_sheet.dart';
import '../widgets/notification_filter_chip_bar.dart';
import '../widgets/notification_item.dart';
import 'notification_detail_screen.dart' show notificationIconForType;

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
  bool _usingMock = false;

  /// Pagination — 10-аар хуудаслаж татна, scroll доошлоход дараагийн
  /// хуудсыг дуудна
  static const int _pageSize = 10;
  bool _hasMore = false;
  int _nextOffset = 0;
  bool _isLoadingMore = false;

  /// Server-ийн unread_count — жагсаалт бүрэн ачаалагдаагүй ч нийт
  /// уншаагүй тоог зөв харуулна
  int _serverUnread = 0;

  final ScrollController _scrollController = ScrollController();

  /// FCM push сонсогч — дэлгэц нээлттэй байхад шинэ push ирвэл
  /// жагсаалтыг server-ээс дахин татаж дээр нь нэмэгдсэн байдлаар харуулна
  NotificationService? _fcmService;

  @override
  void initState() {
    super.initState();
    _fetch();
    // Жагсаалтын төгсгөлд ойртоход дараагийн 10-ыг татна
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        _fcmService = context.read<NotificationService>();
      } on ProviderNotFoundException {
        return; // FCM ажиллаагүй орчин
      }
      _fcmService!.addListener(_onPushReceived);
      // Дэлгэц нээгдмэгц хонхны цэгийг арилгана
      _fcmService!.markSeen();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fcmService?.removeListener(_onPushReceived);
    super.dispose();
  }

  void _onPushReceived() {
    final service = _fcmService;
    // markSeen-ийн notify давталтаас сэргийлж зөвхөн шинэ push ирсэн
    // (hasUnseen=true) үед л ажиллана
    if (!mounted || service == null || !service.hasUnseen) return;
    service.markSeen();
    _fetch();
  }

  /// Эхний хуудсыг татна (нээх үед болон pull-to-refresh)
  Future<void> _fetch() async {
    try {
      final service = context.read<NotificationApiService>();
      final feed = await service.list(limit: _pageSize);
      if (!mounted) return;
      // API хариу хоосон бол dev preview-д mock fallback харуулна.
      // Production-д backend feed-тэй болсон даруйд энэ branch ажиллахгүй.
      if (feed.items.isEmpty) {
        setState(() {
          _items = mockNotifications();
          _isLoading = false;
          _error = null;
          _usingMock = true;
          _hasMore = false;
        });
        return;
      }
      setState(() {
        _items = feed.items;
        _isLoading = false;
        _error = null;
        _usingMock = false;
        _hasMore = feed.hasMore;
        _nextOffset = feed.nextOffset;
        _serverUnread = feed.unreadCount;
      });
    } catch (e) {
      if (!mounted) return;
      // Backend холбогдоогүй / алдаа — UI-аа preview-р mock-аар дүүргэнэ.
      // Caller-т нь алдаа ил харагдсаар үлдэхийн тулд `_error` талбарт
      // тэмдэглэнэ (хэдийгээр content нь mock data байсан ч).
      setState(() {
        _items = mockNotifications();
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
        _usingMock = true;
        _hasMore = false;
      });
    }
  }

  /// Scroll төгсгөлд хүрэхэд дараагийн хуудсыг нэмж татна
  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _usingMock || _isLoading) return;
    setState(() => _isLoadingMore = true);
    try {
      final feed = await context
          .read<NotificationApiService>()
          .list(limit: _pageSize, offset: _nextOffset);
      if (!mounted) return;
      setState(() {
        // Шинэ мэдэгдэл нэмэгдсэнээс offset гулссан бол давхардлыг хасна
        final ids = _items.map((e) => e.id).toSet();
        _items.addAll(feed.items.where((e) => !ids.contains(e.id)));
        _hasMore = feed.hasMore;
        _nextOffset = feed.nextOffset;
        _serverUnread = feed.unreadCount;
        _isLoadingMore = false;
      });
    } catch (_) {
      // Дараагийн scroll дээр дахин оролдоно
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onItemTap(ApiNotification n) async {
    // Нээгдмэгц шууд read болгоно — detail дэлгэцээс буцахыг хүлээхгүй
    // (өмнө нь буцаж ирсний дараа л API дуудагддаг байсан тул detail
    // дээрээс өөр тийш явахад уншсан тэмдэглэгээ хийгдэхгүй байсан).
    if (!n.isRead) {
      // Mock mode-д API дуудалгүй зөвхөн local тэмдэглэгээ хийнэ.
      if (!_usingMock) {
        // fire-and-forget — алдаа гарвал чимээгүй (UX-д нөлөөлөхгүй)
        context
            .read<NotificationApiService>()
            .markRead(n.id)
            .catchError((_) {});
      }
      setState(() {
        final idx = _items.indexWhere((x) => x.id == n.id);
        if (idx >= 0) {
          _items[idx] = _items[idx].copyWith(isRead: true);
        }
        if (_serverUnread > 0) _serverUnread--;
      });
    }

    // Дэлгэрэнгүй харах — бүх холбогдох мэдээлэл (type, data, target_kind)
    // дэлгэрэнгүй screen руу дамжина.
    await Navigator.pushNamed(
      context,
      '/notification_detail',
      arguments: n,
    );
  }

  Future<void> _markAllRead() async {
    try {
      if (!_usingMock) {
        await context.read<NotificationApiService>().markAllRead();
      }
      if (!mounted) return;
      setState(() {
        _items = _items.map((n) => n.copyWith(isRead: true)).toList();
        _serverUnread = 0;
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

  /// Нийт уншаагүй тоо — server-ийн unread_count (жагсаалт хуудасласан
  /// тул зөвхөн ачаалагдсан хэсгээс тоолж болохгүй); mock үед local
  int get _unreadCount => _usingMock
      ? _items.where((n) => !n.isRead).length
      : _serverUnread;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 10),
            child: TextButton.icon(
              onPressed: _unreadCount > 0 ? () => _showMarkReadPopup() : null,
              icon: CustomSvgIcon(
                'checked',
                size: 10,
                color: (_unreadCount > 0)
                  ?extendedColors.neutral200
                  :extendedColors.neutral100,
              ),
              label: Text(
                l10n.markAllAsRead,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: (_unreadCount > 0)
                    ?extendedColors.neutral200
                    :extendedColors.neutral100,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: (_unreadCount > 0)
                  ?extendedColors.bgTertiary
                  :extendedColors.bgSecondary,
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                      color: AppColors.redMain,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      _unreadCount.toString(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          NotificationFilterChipBar(
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
          if (_usingMock) _buildMockBanner(theme, extendedColors),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetch,
              child: _isLoading && _items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null && _items.isEmpty
                      ? _buildErrorState(theme, extendedColors)
                      : _buildList(l10n, extendedColors, theme),
            ),
          ),
        ],
      ),
    );
  }

  /// Dev/preview-ийн mock notification-ууд харагдаж байгааг хэрэглэгчид
  /// сануулах нимгэн banner. Backend ажиллах үед `_usingMock=false` бөгөөд
  /// banner огт render хийгдэхгүй.
  Widget _buildMockBanner(ThemeData theme, ExtendedColors c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: c.bgSecondary,
      child: Row(
        children: [
          Icon(Icons.science_outlined, size: 16, color: c.neutral300),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Жишээ мэдэгдлүүд харагдаж байна (Demo)',
              style: theme.textTheme.labelMedium?.copyWith(color: c.neutral300),
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
        Icon(Icons.error_outline, size: 48, color: AppColors.redMain),
        const SizedBox(height: 16),
        Text(
          _error ?? '',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: c.neutral200),
        ),
      ],
    );
  }

  Widget _buildList(AppLocalizations l10n, ExtendedColors extendedColors, ThemeData theme) {
    final list = _filtered;
    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/Notification.png',
                  height: 177,
                  width: 177,
                ),
                const SizedBox(height: 10,),
                Text(
                  l10n.noNotifications,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral200,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      // Дараагийн хуудас ачаалж байгааг үзүүлэх сүүлийн мөр
      itemCount: list.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= list.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final n = list[i];
        return NotificationItem(
          title: n.title,
          subtitle: n.body,
          time: n.formattedTime,
          isUnread: !n.isRead,
          icon: notificationIconForType(n.type),
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
