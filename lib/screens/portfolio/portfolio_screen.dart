import 'package:flutter/material.dart';
import '../../models/bet_model.dart';
import '../../models/market_model.dart';
import '../../services/app_service.dart';
import '../../theme/fpt_theme.dart';
import '../../widgets/candy_chip.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String _filter = 'all'; // 'all', 'active', 'won', 'lost'

  @override
  Widget build(BuildContext context) {
    final appService = AppService();
    final myBets = appService.myBets;

    final activeBets = myBets.where((b) => b.status == BetStatus.active).toList();
    final wonBets = myBets.where((b) => b.status == BetStatus.won).toList();
    final lostBets = myBets.where((b) => b.status == BetStatus.lost).toList();

    final int totalLockedCandies = activeBets.fold(0, (sum, b) => sum + b.amount);
    final int totalWonCandies = wonBets.fold(0, (sum, b) => sum + b.actualPayout);

    final filteredBets = myBets.where((b) {
      if (_filter == 'active') return b.status == BetStatus.active;
      if (_filter == 'won') return b.status == BetStatus.won;
      if (_filter == 'lost') return b.status == BetStatus.lost;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: FptColors.lightBg,
      appBar: AppBar(
        title: const Text('Cược Của Tôi'),
        actions: [
          CandyChip(candies: appService.currentUser?.candies ?? 0),
          const SizedBox(width: 14),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Summary Card
            Container(
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
                        onPressed: () {
                          appService.claimDailyCandy();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 Nhận thành công +20 Kẹo điểm danh!'),
                              backgroundColor: FptColors.yesGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.card_giftcard, size: 16),
                        label: const Text('+20 Kẹo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FptColors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF334155)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryStat('Đang cược', '$totalLockedCandies 🍬', const Color(0xFF38BDF8)),
                      Container(height: 30, width: 1, color: const Color(0xFF334155)),
                      _summaryStat('Đã thắng', '+$totalWonCandies 🍬', FptColors.yesGreen),
                      Container(height: 30, width: 1, color: const Color(0xFF334155)),
                      _summaryStat('Tổng kèo', '${myBets.length}', Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Tất cả (${myBets.length})', 'all'),
                  _filterChip('Đang mở (${activeBets.length})', 'active'),
                  _filterChip('Thắng (${wonBets.length})', 'won'),
                  _filterChip('Thua (${lostBets.length})', 'lost'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Bets List
            if (filteredBets.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FptColors.gray200),
                ),
                child: const Column(
                  children: [
                    Text('🍬', style: TextStyle(fontSize: 36)),
                    SizedBox(height: 10),
                    Text(
                      'Chưa có dữ liệu cược trong mục này.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FptColors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredBets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final bet = filteredBets[index];
                  final isYes = bet.outcome == MarketOutcome.yes;
                  final isWon = bet.status == BetStatus.won;
                  final isLost = bet.status == BetStatus.lost;
                  final isActive = bet.status == BetStatus.active;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isWon
                            ? FptColors.yesGreen.withOpacity(0.5)
                            : isLost
                                ? FptColors.noRed.withOpacity(0.3)
                                : const Color(0xFFE2E8F0),
                        width: isWon ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isYes ? FptColors.yesGreenBg : FptColors.noRedBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isYes ? 'ĐÃ CƯỢC CÓ' : 'ĐÃ CƯỢC KHÔNG',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isYes ? FptColors.yesGreen : FptColors.noRed,
                                ),
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '⏳ Đang chờ kết quả',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: FptColors.blue,
                                  ),
                                ),
                              )
                            else if (isWon)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: FptColors.yesGreenBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '🎉 THẮNG +${bet.actualPayout} 🍬',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: FptColors.yesGreen,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: FptColors.noRedBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '💔 THUA 0 🍬',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
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
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: FptColors.gray800,
                              ),
                            ),
                            Text(
                              isActive
                                  ? 'Dự kiến: ~${bet.potentialPayout} 🍬'
                                  : 'Nhận về: ${bet.actualPayout} 🍬',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isWon ? FptColors.yesGreen : FptColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
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

  Widget _filterChip(String label, String value) {
    final isSelected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Colors.white : FptColors.gray800,
        ),
        selectedColor: FptColors.orange,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? FptColors.orange : const Color(0xFFCBD5E1),
          ),
        ),
        onSelected: (val) {
          if (val) setState(() => _filter = value);
        },
      ),
    );
  }
}
