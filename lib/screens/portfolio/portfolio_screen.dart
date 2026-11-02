import 'package:flutter/material.dart';
import '../../models/bet_model.dart';
import '../../models/market_model.dart';
import '../../services/app_service.dart';
import '../../theme/fpt_theme.dart';
import '../../widgets/candy_chip.dart';
import '../../widgets/countdown_timer.dart';
import '../market_detail/market_detail_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appService = AppService();
    final myBets = appService.myBets;

    // Phân loại rõ ràng 2 khu vực: Đang chờ kết quả & Đã có kết quả
    final pendingBets = appService.myPendingBets;
    final resolvedBets = appService.myResolvedBets;

    final int totalLockedCandies = pendingBets.fold(0, (sum, b) => sum + b.amount);
    final int totalWonCandies = resolvedBets
        .where((b) => b.status == BetStatus.won)
        .fold(0, (sum, b) => sum + b.actualPayout);

    return Scaffold(
      backgroundColor: FptColors.lightBg,
      appBar: AppBar(
        title: const Text('Cược Của Tôi'),
        actions: [
          CandyChip(candies: appService.currentUser?.candies ?? 0),
          const SizedBox(width: 14),
        ],
      ),
      body: Column(
        children: [
          // Portfolio Summary Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KẸO KHẢ DỤNG',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${appService.currentUser?.candies ?? 0}',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('🍬', style: TextStyle(fontSize: 22)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: !appService.canClaimDaily
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final err = await appService.claimDailyCandy();
                                if (err != null) {
                                  messenger.showSnackBar(
                                    SnackBar(content: Text(err), backgroundColor: FptColors.noRed),
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('🎉 Nhận thành công +20 Kẹo điểm danh!'),
                                      backgroundColor: FptColors.yesGreen,
                                    ),
                                  );
                                }
                              },
                        icon: Icon(
                          appService.canClaimDaily ? Icons.card_giftcard : Icons.check,
                          size: 16,
                        ),
                        label: Text(
                          appService.canClaimDaily ? '+20 Kẹo' : 'Đã nhận',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appService.canClaimDaily ? FptColors.orange : const Color(0xFF475569),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF334155),
                          disabledForegroundColor: const Color(0xFF94A3B8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFF334155)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryStat('Đang cược', '$totalLockedCandies 🍬', const Color(0xFF38BDF8)),
                      Container(height: 28, width: 1, color: const Color(0xFF334155)),
                      _summaryStat('Đã thắng', '+$totalWonCandies 🍬', FptColors.yesGreen),
                      Container(height: 28, width: 1, color: const Color(0xFF334155)),
                      _summaryStat('Tổng kèo', '${myBets.length}', Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Two Distinct Navigation Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: FptColors.orangeDark,
              unselectedLabelColor: FptColors.gray600,
              indicatorColor: FptColors.orange,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timelapse, size: 16),
                      const SizedBox(width: 6),
                      Text('Chờ Kết Quả (${pendingBets.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16),
                      const SizedBox(width: 6),
                      Text('Đã Có Kết Quả (${resolvedBets.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TabBarView with the two regions
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // KHU VỰC 1: KÈO ĐANG CHỜ KẾT QUẢ
                _buildPendingBetsList(pendingBets, appService),

                // KHU VỰC 2: KÈO ĐÃ CÓ KẾT QUẢ (THẮNG / THUA)
                _buildResolvedBetsList(resolvedBets, appService),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBetsList(List<BetModel> bets, AppService appService) {
    if (bets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⏳', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            const Text(
              'Không có vụ cược nào đang chờ kết quả.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: FptColors.textMuted),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hãy vào Sàn Kèo để đặt kẹo dự đoán!',
              style: TextStyle(fontSize: 12, color: FptColors.orangeDark, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: bets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (ctx, index) {
        final bet = bets[index];
        final isYes = bet.outcome == MarketOutcome.yes;
        final market = appService.markets.cast<MarketModel?>().firstWhere(
              (m) => m?.id == bet.marketId,
              orElse: () => null,
            );

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MarketDetailScreen(marketId: bet.marketId)),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isYes ? FptColors.yesGreenBg : FptColors.noRedBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isYes ? 'BẠN CƯỢC CÓ' : 'BẠN CƯỢC KHÔNG',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isYes ? FptColors.yesGreen : FptColors.noRed,
                        ),
                      ),
                    ),
                    if (market != null)
                      CountdownTimerWidget(endDate: market.endDate, isCompact: true)
                    else
                      const Text(
                        '⏳ Đang chờ chốt',
                        style: TextStyle(fontSize: 11, color: FptColors.blue, fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  bet.marketTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: FptColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã cược: ${bet.amount} 🍬',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FptColors.gray800),
                    ),
                    Text(
                      'Dự kiến nhận: ~${bet.potentialPayout} 🍬',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: FptColors.orangeDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResolvedBetsList(List<BetModel> bets, AppService appService) {
    if (bets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            const Text(
              'Chưa có vụ cược nào có kết quả.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: FptColors.textMuted),
            ),
            const SizedBox(height: 6),
            const Text(
              'Khi Admin chốt kèo, kết quả thắng/thua sẽ xuất hiện tại đây!',
              style: TextStyle(fontSize: 12, color: FptColors.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: bets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (ctx, index) {
        final bet = bets[index];
        final isYes = bet.outcome == MarketOutcome.yes;
        final isWon = bet.status == BetStatus.won;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MarketDetailScreen(marketId: bet.marketId)),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isWon ? FptColors.yesGreen.withOpacity(0.5) : FptColors.noRed.withOpacity(0.3),
                width: isWon ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isYes ? FptColors.yesGreenBg : FptColors.noRedBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isYes ? 'BẠN ĐÃ CƯỢC CÓ' : 'BẠN ĐÃ CƯỢC KHÔNG',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isYes ? FptColors.yesGreen : FptColors.noRed,
                        ),
                      ),
                    ),
                    if (isWon)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: FptColors.yesGreenBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '🎉 THẮNG +${bet.actualPayout} 🍬',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: FptColors.yesGreen,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: FptColors.noRedBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '💔 THUA 0 🍬',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: FptColors.noRed,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  bet.marketTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: FptColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã cược: ${bet.amount} 🍬',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FptColors.gray800),
                    ),
                    Text(
                      isWon
                          ? 'Đã nhận thưởng: +${bet.actualPayout} 🍬'
                          : 'Mất: -${bet.amount} 🍬',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isWon ? FptColors.yesGreen : FptColors.noRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
