import 'package:flutter/material.dart';
import '../models/market_model.dart';
import '../theme/fpt_theme.dart';
import 'bet_bottom_sheet.dart';

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
    final yesPct = market.yesPercentage;
    final noPct = market.noPercentage;
    final isResolved = market.status == MarketStatus.resolved;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isResolved ? Colors.grey.shade300 : const Color(0xFFE2E8F0),
          width: 1.2,
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
              // Top tags row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: FptColors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          market.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: FptColors.orangeDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: FptColors.gray100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 10, color: FptColors.gray600),
                            const SizedBox(width: 2),
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
                    ],
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
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: FptColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          'Còn ${_daysRemaining(market.endDate)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: FptColors.textMuted,
                          ),
                        ),
                      ],
                    ),
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

              // Chance Probability Bar (Polymarket Visual)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CÓ ${yesPct.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: FptColors.yesGreen,
                        ),
                      ),
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
                      const Text(
                        'đã cược',
                        style: TextStyle(
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
                          label: 'Cược CÓ',
                          color: FptColors.yesGreen,
                          bgColor: FptColors.yesGreenBg,
                          outcome: MarketOutcome.yes,
                        ),
                        const SizedBox(width: 8),
                        _betButton(
                          context,
                          label: 'Cược KHÔNG',
                          color: FptColors.noRed,
                          bgColor: FptColors.noRedBg,
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
  }

  Widget _betButton(
    BuildContext context, {
    required String label,
    required Color color,
    required Color bgColor,
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
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }

  String _daysRemaining(DateTime endDate) {
    final diff = endDate.difference(DateTime.now());
    if (diff.isNegative) return 'Hết hạn';
    if (diff.inDays > 0) return '${diff.inDays} ngày';
    if (diff.inHours > 0) return '${diff.inHours} giờ';
    return '${diff.inMinutes} phút';
  }
}
