import 'package:flutter/material.dart';
import '../../models/market_model.dart';
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

    return Scaffold(
      backgroundColor: FptColors.lightBg,
      appBar: AppBar(
        title: const FptLogo(size: 32),
        actions: [
          CandyChip(candies: appService.currentUser?.candies ?? 0),
          const SizedBox(width: 14),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Thông Báo Hệ Thống (Dạng thông báo trang nhã, không còn hiện tặng 50 kẹo)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.campaign_rounded, color: FptColors.blue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Thông báo: Chào mừng ${appService.currentUser?.fullName ?? "bạn"}! Các kèo dự đoán campus đang mở thưởng.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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

          // Bộ lọc trạng thái (Đã bỏ các tag học tập & thi cử theo yêu cầu)
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
                    'KÈO DỰ ĐOÁN (${filteredMarkets.length})',
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
}
