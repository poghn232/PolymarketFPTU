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
  String _selectedCategory = 'Tất cả';
  String _selectedCampus = 'Tất cả';
  String _filterStatus = 'all'; // 'all', 'active', 'resolved'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'Tất cả',
    'Học tập & Thi cử',
    'Vinh danh & Cóc Vàng',
    'Đời sống Campus',
    'Sự kiện & CLB',
    'Thể thao Vovinam',
  ];

  final List<String> _campuses = [
    'Tất cả',
    'Toàn quốc',
    'Hà Nội (Hòa Lạc)',
    'TP.HCM (Quận 9)',
    'Đà Nẵng',
  ];

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

    // Lọc markets
    var filteredMarkets = appService.markets.where((m) {
      if (_selectedCategory != 'Tất cả' && m.category != _selectedCategory) {
        return false;
      }
      if (_selectedCampus != 'Tất cả' && m.campus != _selectedCampus && m.campus != 'Toàn quốc') {
        return false;
      }
      if (_filterStatus == 'active' && m.status != MarketStatus.active) {
        return false;
      }
      if (_filterStatus == 'resolved' && m.status != MarketStatus.resolved) {
        return false;
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
          // Banner Đề tài Học tập & Chào mừng
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0054A6), Color(0xFF003366)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: FptColors.blue.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🎓', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sàn Dự Đoán Kẹo Campus FPT',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sinh viên: ${appService.currentUser?.fullName ?? ""} • ${appService.currentUser?.studentCode ?? ""}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFBFDBFE),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: FptColors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '50 🍬 Free',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm kèo dự đoán (môn học, thi cử, canteen...)...',
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

          // Categories Horizontal List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (ctx, idx) {
                  final cat = _categories[idx];
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : FptColors.gray800,
                      ),
                      selectedColor: FptColors.orange,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? FptColors.orange : const Color(0xFFE2E8F0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Status & Campus Filters row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Campus Filter Dropdown Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCampus,
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FptColors.textDark,
                        ),
                        items: _campuses.map((c) {
                          return DropdownMenuItem(value: c, child: Text('📍 $c'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCampus = val);
                        },
                      ),
                    ),
                  ),

                  // Status Segment
                  Row(
                    children: [
                      _statusButton('Tất cả', 'all'),
                      const SizedBox(width: 4),
                      _statusButton('Đang mở', 'active'),
                      const SizedBox(width: 4),
                      _statusButton('Đã chốt', 'resolved'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Markets Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 2),
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

          // Markets List
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? FptColors.orange.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? FptColors.orangeDark : FptColors.gray600,
          ),
        ),
      ),
    );
  }
}
