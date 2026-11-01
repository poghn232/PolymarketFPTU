import 'package:flutter/material.dart';
import '../../models/market_model.dart';
import '../../services/app_service.dart';
import '../../theme/fpt_theme.dart';
import '../../widgets/candy_chip.dart';
import '../../widgets/bet_bottom_sheet.dart';

class MarketDetailScreen extends StatelessWidget {
  final String marketId;

  const MarketDetailScreen({super.key, required this.marketId});

  @override
  Widget build(BuildContext context) {
    final appService = AppService();
    final market = appService.markets.firstWhere(
      (m) => m.id == marketId,
      orElse: () => MarketModel(
        id: '',
        title: 'Kèo không tồn tại',
        description: '',
        category: '',
        endDate: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );

    final marketBets = appService.bets.where((b) => b.marketId == marketId).toList()
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));

    final yesPct = market.yesPercentage;
    final noPct = market.noPercentage;
    final isResolved = market.status == MarketStatus.resolved;

    return Scaffold(
      backgroundColor: FptColors.lightBg,
      appBar: AppBar(
        title: const Text('Chi Tiết Kèo Dự Đoán'),
        actions: [
          CandyChip(candies: appService.currentUser?.candies ?? 0),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Tags
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: FptColors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    market.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: FptColors.orangeDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: FptColors.gray200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: FptColors.gray600),
                      const SizedBox(width: 3),
                      Text(
                        market.campus,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: FptColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isResolved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: market.winningOutcome == MarketOutcome.yes
                          ? FptColors.yesGreenBg
                          : FptColors.noRedBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      market.winningOutcome == MarketOutcome.yes ? '✅ CÓ ĐÃ THẮNG' : '❌ KHÔNG THẮNG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: market.winningOutcome == MarketOutcome.yes
                            ? FptColors.yesGreen
                            : FptColors.noRed,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Market Title
            Text(
              market.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: FptColors.textDark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // Big Polymarket Duel Probability Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
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
                            'CỬA CÓ (YES)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: FptColors.yesGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${yesPct.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: FptColors.yesGreen,
                            ),
                          ),
                          Text(
                            '${market.yesPool} 🍬 đã cược',
                            style: const TextStyle(fontSize: 11, color: FptColors.textMuted),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'CỬA KHÔNG (NO)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: FptColors.noRed,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${noPct.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: FptColors.noRed,
                            ),
                          ),
                          Text(
                            '${market.noPool} 🍬 đã cược',
                            style: const TextStyle(fontSize: 11, color: FptColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 10,
                      child: Row(
                        children: [
                          Expanded(
                            flex: (yesPct * 10).toInt(),
                            child: Container(color: FptColors.yesGreen),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            flex: (noPct * 10).toInt(),
                            child: Container(color: FptColors.noRed),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Market Rules / Description Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.description_outlined, size: 18, color: FptColors.orange),
                      SizedBox(width: 6),
                      Text(
                        'Thông tin & Quy tắc chốt kết quả',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: FptColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    market.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: FptColors.gray800,
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 16, color: FptColors.blue),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Quỹ kẹo bảo chứng từ Admin: ${market.adminBackstopCandies} 🍬\n(Đảm bảo nếu một bên không có ai cược, Admin sẽ đóng vai trò đối ứng chi trả).',
                          style: const TextStyle(
                            fontSize: 11,
                            color: FptColors.gray600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Community Betting Activity
            const Text(
              'Lịch sử cược của sinh viên',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: FptColors.textDark,
              ),
            ),
            const SizedBox(height: 10),

            if (marketBets.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FptColors.gray200),
                ),
                child: const Column(
                  children: [
                    Text('🍬', style: TextStyle(fontSize: 28)),
                    SizedBox(height: 6),
                    Text(
                      'Chưa có sinh viên nào đặt kẹo.',
                      style: TextStyle(fontSize: 13, color: FptColors.textMuted),
                    ),
                    Text(
                      'Hãy là người đầu tiên đặt kẹo dự đoán!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: FptColors.orangeDark,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: marketBets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final b = marketBets[index];
                  final isBetYes = b.outcome == MarketOutcome.yes;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: FptColors.gray200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: isBetYes ? FptColors.yesGreenBg : FptColors.noRedBg,
                          child: Icon(
                            isBetYes ? Icons.thumb_up : Icons.thumb_down,
                            size: 14,
                            color: isBetYes ? FptColors.yesGreen : FptColors.noRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.userName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: FptColors.textDark,
                                ),
                              ),
                              Text(
                                'Cửa ${isBetYes ? "CÓ" : "KHÔNG"} • ${b.placedAt.hour}:${b.placedAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 11, color: FptColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${b.amount} 🍬',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isBetYes ? FptColors.yesGreen : FptColors.noRed,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: market.canBet
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            BetBottomSheet.show(
                              context,
                              market: market,
                              initialOutcome: MarketOutcome.yes,
                            );
                          },
                          icon: const Icon(Icons.thumb_up, size: 16),
                          label: Text('CƯỢC CÓ (${yesPct.toStringAsFixed(0)}%)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FptColors.yesGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            BetBottomSheet.show(
                              context,
                              market: market,
                              initialOutcome: MarketOutcome.no,
                            );
                          },
                          icon: const Icon(Icons.thumb_down, size: 16),
                          label: Text('CƯỢC KHÔNG (${noPct.toStringAsFixed(0)}%)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FptColors.noRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
