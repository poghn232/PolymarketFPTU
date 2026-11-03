import 'package:flutter/material.dart';
import '../models/market_model.dart';
import '../services/app_service.dart';
import '../theme/fpt_theme.dart';
import 'bet_bottom_sheet.dart';
import 'countdown_timer.dart';

class MarketCard extends StatelessWidget {
  final MarketModel market;
  final VoidCallback? onTap;

  const MarketCard({
    super.key,
    required this.market,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appService = AppService();

    return ListenableBuilder(
      listenable: appService,
      builder: (context, _) {
        final liveMarket = appService.markets.firstWhere(
          (m) => m.id == market.id,
          orElse: () => market,
        );
        final myBet = appService.getMyBetForMarket(liveMarket.id);

        final yesPct = liveMarket.yesPercentage;
        final noPct = liveMarket.noPercentage;
        final isResolved = liveMarket.status == MarketStatus.resolved;

        return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isResolved
              ? Colors.grey.shade300
              : (myBet != null ? FptColors.orange.withOpacity(0.5) : const Color(0xFFE2E8F0)),
          width: myBet != null ? 1.5 : 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Campus & Status / Countdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: FptColors.gray100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 11, color: FptColors.gray600),
                        const SizedBox(width: 3),
                        Text(
                          market.campus,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: FptColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isResolved)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: market.winningOutcome == MarketOutcome.yes
                            ? FptColors.yesGreenBg
                            : FptColors.noRedBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        market.winningOutcome == MarketOutcome.yes
                            ? '✅ CÓ THẮNG'
                            : '❌ KHÔNG THẮNG',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: market.winningOutcome == MarketOutcome.yes
                              ? FptColors.yesGreen
                              : FptColors.noRed,
                        ),
                      ),
                    )
                  else
                    CountdownTimerWidget(endDate: market.endDate, isCompact: true),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                market.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: FptColors.textDark,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),

              // Chance Probability Bar & Bettors count (Polymarket Visual)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'CÓ ${yesPct.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: FptColors.yesGreen,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${market.yesPool} 🍬 • ${market.yesCount} người)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: FptColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '(${market.noPool} 🍬 • ${market.noCount} người)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: FptColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'KHÔNG ${noPct.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: FptColors.noRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 8,
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

              // Khu vực hiển thị cược của bạn (Nếu đã cược)
              if (myBet != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: myBet.outcome == MarketOutcome.yes
                        ? FptColors.yesGreenBg
                        : FptColors.noRedBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: myBet.outcome == MarketOutcome.yes
                          ? FptColors.yesGreen.withOpacity(0.4)
                          : FptColors.noRed.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: myBet.outcome == MarketOutcome.yes
                            ? FptColors.yesGreen
                            : FptColors.noRed,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Bạn đã cược: ${myBet.outcome == MarketOutcome.yes ? "CÓ" : "KHÔNG"} (${myBet.amount} 🍬) • Dự kiến nhận: ~${myBet.potentialPayout} 🍬',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: myBet.outcome == MarketOutcome.yes
                                ? const Color(0xFF047857)
                                : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Bottom Row: Volume in Candies & Quick Bet Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🍬', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        '${market.totalVolume} Kẹo',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: FptColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${market.totalBettors} lượt)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: FptColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  if (market.canBet)
                    Row(
                      children: [
                        _betButton(
                          context,
                          label: myBet?.outcome == MarketOutcome.yes ? '✓ Đã cược CÓ' : 'Cược CÓ',
                          color: FptColors.yesGreen,
                          bgColor: myBet?.outcome == MarketOutcome.yes
                              ? FptColors.yesGreen
                              : FptColors.yesGreenBg,
                          textColor: myBet?.outcome == MarketOutcome.yes
                              ? Colors.white
                              : FptColors.yesGreen,
                          outcome: MarketOutcome.yes,
                        ),
                        const SizedBox(width: 8),
                        _betButton(
                          context,
                          label: myBet?.outcome == MarketOutcome.no ? '✓ Đã cược KHÔNG' : 'Cược KHÔNG',
                          color: FptColors.noRed,
                          bgColor: myBet?.outcome == MarketOutcome.no
                              ? FptColors.noRed
                              : FptColors.noRedBg,
                          textColor: myBet?.outcome == MarketOutcome.no
                              ? Colors.white
                              : FptColors.noRed,
                          outcome: MarketOutcome.no,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _betButton(
    BuildContext context, {
    required String label,
    required Color color,
    required Color bgColor,
    required Color textColor,
    required MarketOutcome outcome,
  }) {
    return InkWell(
      onTap: () {
        BetBottomSheet.show(context, market: market, initialOutcome: outcome);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
