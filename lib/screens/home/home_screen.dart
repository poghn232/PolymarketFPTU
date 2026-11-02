import 'package:flutter/material.dart';
import '../../models/market_model.dart';
import '../../models/notification_model.dart';
import '../../services/app_service.dart';
import '../../theme/fpt_theme.dart';
import '../../widgets/candy_chip.dart';
import '../../widgets/fpt_logo.dart';
import '../../widgets/market_card.dart';
import '../market_detail/market_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filterStatus = 'all'; // 'all', 'active', 'my_bets', 'resolved'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appService = AppService();

    // Lọc markets trực tiếp từ danh sách dữ liệu SQLite
    var filteredMarkets = appService.markets.where((m) {
      if (_filterStatus == 'active' && m.status != MarketStatus.active) {
        return false;
      }
      if (_filterStatus == 'resolved' && m.status != MarketStatus.resolved) {
        return false;
      }
      if (_filterStatus == 'my_bets') {
        final hasBet = appService.getMyBetForMarket(m.id) != null;
        if (!hasBet) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final inTitle = m.title.toLowerCase().contains(_searchQuery);
        final inDesc = m.description.toLowerCase().contains(_searchQuery);
        if (!inTitle && !inDesc) return false;
      }
      return true;
    }).toList();

    // Dữ liệu thông báo từ SQLite bảng 'notifications'
    final List<NotificationModel> notifications = appService.notifications;
    final NotificationModel? latestNotif = notifications.isNotEmpty ? notifications.first : null;
    final notificationCount = appService.unreadNotificationCount > 0
        ? appService.unreadNotificationCount
        : notifications.length;

    return Scaffold(
      backgroundColor: FptColors.lightBg,
      appBar: AppBar(
        title: const FptLogo(size: 32),
        actions: [
          // Nút Chuông Thông Báo Kết Quả (Bảng notifications SQLite)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: FptColors.textDark),
                tooltip: 'Thông báo kết quả kèo (SQLite)',
                onPressed: () => _showNotificationCenter(context, appService),
              ),
              if (notificationCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: FptColors.noRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    alignment: Alignment.center,
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          CandyChip(candies: appService.currentUser?.candies ?? 0),
          const SizedBox(width: 12),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // BẢNG THÔNG BÁO KẾT QUẢ VỤ BET (Truy vấn từ SQLite bảng 'notifications')
          SliverToBoxAdapter(
            child: InkWell(
              onTap: () => _showNotificationCenter(context, appService),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: latestNotif?.type == 'win'
                        ? [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)]
                        : (latestNotif?.type == 'loss'
                            ? [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)]
                            : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)]),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: latestNotif?.type == 'win'
                        ? FptColors.yesGreen.withOpacity(0.5)
                        : (latestNotif?.type == 'loss'
                            ? FptColors.orange.withOpacity(0.4)
                            : const Color(0xFFBFDBFE)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      latestNotif?.type == 'win'
                          ? '🎉'
                          : (latestNotif?.type == 'loss'
                              ? '💔'
                              : (latestNotif?.type == 'claim'
                                  ? '🎁'
                                  : (latestNotif?.type == 'market_resolved' ? '📢' : '🔔'))),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            latestNotif?.title ?? 'THÔNG BÁO SÀN FPT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: latestNotif?.type == 'win'
                                  ? const Color(0xFF047857)
                                  : (latestNotif?.type == 'loss' ? FptColors.orangeDark : FptColors.blue),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            latestNotif?.message ??
                                'Chào ${appService.currentUser?.fullName ?? "bạn"}! Các kèo dự đoán campus đang mở.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: FptColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: FptColors.gray600),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar (Truy vấn theo database)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm kèo dự đoán (môn học, sự kiện, kỳ thi...)...',
                  hintStyle: const TextStyle(fontSize: 13, color: FptColors.textMuted),
                  prefixIcon: const Icon(Icons.search, color: FptColors.orange, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // Bộ lọc trạng thái
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _statusButton('Tất cả', 'all'),
                    const SizedBox(width: 6),
                    _statusButton('Đang mở', 'active'),
                    const SizedBox(width: 6),
                    _statusButton('Tôi đã cược', 'my_bets'),
                    const SizedBox(width: 6),
                    _statusButton('Đã chốt kèo', 'resolved'),
                  ],
                ),
              ),
            ),
          ),

          // Tiêu đề số lượng kèo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, size: 16, color: FptColors.orange),
                  const SizedBox(width: 6),
                  Text(
                    _filterStatus == 'resolved'
                        ? 'LỊCH SỬ CÁC VỤ BET ĐÃ CHỐT KẾT QUẢ (${filteredMarkets.length})'
                        : 'KÈO DỰ ĐOÁN (${filteredMarkets.length})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: FptColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Danh sách MarketCards
          if (filteredMarkets.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🍬', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 10),
                    Text(
                      'Không tìm thấy kèo nào phù hợp.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FptColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final market = filteredMarkets[index];
                  return MarketCard(
                    market: market,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MarketDetailScreen(marketId: market.id),
                        ),
                      );
                    },
                  );
                },
                childCount: filteredMarkets.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _statusButton(String title, String value) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? FptColors.orange : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? FptColors.orange : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: FptColors.orange.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : FptColors.gray800,
          ),
        ),
      ),
    );
  }

  // TRUNG TÂM THÔNG BÁO VỤ BET ĐÃ THẮNG / THUA (BẢNG NOTIFICATIONS TRONG SQLITE)
  void _showNotificationCenter(BuildContext context, AppService appService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return AnimatedBuilder(
          animation: appService,
          builder: (context, _) {
            final notifications = appService.notifications;

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.92,
              minChildSize: 0.4,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications_active, color: FptColors.orange, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Thông Báo Sàn FPT (${notifications.length})',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: FptColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          if (notifications.isNotEmpty)
                            TextButton.icon(
                              onPressed: () async {
                                await appService.clearAllNotifications();
                              },
                              icon: const Icon(Icons.delete_sweep, size: 16, color: FptColors.noRed),
                              label: const Text(
                                'Xóa tất cả',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: FptColors.noRed,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Dữ liệu bảng notifications trong SQLite. Bạn có thể xóa từng thông báo.',
                        style: TextStyle(fontSize: 12, color: FptColors.textMuted),
                      ),
                      const SizedBox(height: 14),

                      Expanded(
                        child: notifications.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 60),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.notifications_off_outlined, size: 48, color: FptColors.gray600),
                                      SizedBox(height: 12),
                                      Text(
                                        'Không có thông báo nào trong database.',
                                        style: TextStyle(
                                          color: FptColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  final notif = notifications[index];
                                  final isWin = notif.type == 'win';
                                  final isLoss = notif.type == 'loss';
                                  final isClaim = notif.type == 'claim';

                                  Color cardBg = Colors.white;
                                  Color borderColor = const Color(0xFFE2E8F0);
                                  String iconEmoji = '🔔';

                                  if (isWin) {
                                    cardBg = FptColors.yesGreenBg;
                                    borderColor = FptColors.yesGreen.withOpacity(0.3);
                                    iconEmoji = '🎉';
                                  } else if (isLoss) {
                                    cardBg = FptColors.noRedBg;
                                    borderColor = FptColors.noRed.withOpacity(0.25);
                                    iconEmoji = '💔';
                                  } else if (isClaim) {
                                    cardBg = const Color(0xFFFFFBEB);
                                    borderColor = const Color(0xFFFDE68A);
                                    iconEmoji = '🎁';
                                  } else if (notif.type == 'market_resolved') {
                                    cardBg = const Color(0xFFEFF6FF);
                                    borderColor = const Color(0xFFBFDBFE);
                                    iconEmoji = '📢';
                                  }

                                  final timeStr =
                                      '${notif.createdAt.hour.toString().padLeft(2, '0')}:${notif.createdAt.minute.toString().padLeft(2, '0')} ${notif.createdAt.day}/${notif.createdAt.month}';

                                  return Dismissible(
                                    key: Key(notif.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: FptColors.noRed,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.delete, color: Colors.white),
                                    ),
                                    onDismissed: (_) {
                                      appService.deleteNotification(notif.id);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(iconEmoji, style: const TextStyle(fontSize: 22)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        notif.title,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w800,
                                                          color: isWin
                                                              ? FptColors.yesGreen
                                                              : (isLoss ? FptColors.noRed : FptColors.textDark),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      timeStr,
                                                      style: const TextStyle(fontSize: 10, color: FptColors.textMuted),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  notif.message,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: FptColors.textDark,
                                                    height: 1.35,
                                                  ),
                                                ),
                                                if (notif.amount != 0) ...[
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: notif.amount > 0 ? FptColors.yesGreen : FptColors.noRed,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      notif.amount > 0 ? '+${notif.amount} 🍬' : '${notif.amount} 🍬',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, size: 16, color: FptColors.gray600),
                                            tooltip: 'Xóa thông báo',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              appService.deleteNotification(notif.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
