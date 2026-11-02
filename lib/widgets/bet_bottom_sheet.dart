import 'package:flutter/material.dart';
import '../models/market_model.dart';
import '../services/app_service.dart';
import '../theme/fpt_theme.dart';

class BetBottomSheet extends StatefulWidget {
  final MarketModel market;
  final MarketOutcome initialOutcome;

  const BetBottomSheet({
    super.key,
    required this.market,
    this.initialOutcome = MarketOutcome.yes,
  });

  static Future<void> show(
    BuildContext context, {
    required MarketModel market,
    MarketOutcome initialOutcome = MarketOutcome.yes,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BetBottomSheet(
        market: market,
        initialOutcome: initialOutcome,
      ),
    );
  }

  @override
  State<BetBottomSheet> createState() => _BetBottomSheetState();
}

class _BetBottomSheetState extends State<BetBottomSheet> {
  late MarketOutcome _selectedOutcome;
  final TextEditingController _amountController = TextEditingController(text: '10');
  int _betAmount = 10;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedOutcome = widget.initialOutcome;
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final val = int.tryParse(_amountController.text) ?? 0;
    if (val != _betAmount) {
      setState(() {
        _betAmount = val;
      });
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  void _setAmount(int amount) {
    _amountController.text = amount.toString();
    setState(() {
      _betAmount = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appService = AppService();
    final currentMarket = appService.markets.firstWhere(
      (m) => m.id == widget.market.id,
      orElse: () => widget.market,
    );
    final userCandies = appService.currentUser?.candies ?? 0;
    final estimatedPayout = currentMarket.estimatePayout(_selectedOutcome, _betAmount);
    final potentialProfit = estimatedPayout - _betAmount;
    final isYes = _selectedOutcome == MarketOutcome.yes;
    final color = isYes ? FptColors.yesGreen : FptColors.noRed;

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: bottomPadding + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentMarket.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: FptColors.textDark,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: FptColors.gray600,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selector: CÓ vs KHÔNG (Polymarket Toggle)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: FptColors.gray100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedOutcome = MarketOutcome.yes),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isYes ? FptColors.yesGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isYes
                              ? [
                                  BoxShadow(
                                    color: FptColors.yesGreen.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.thumb_up_rounded,
                              size: 16,
                              color: isYes ? Colors.white : FptColors.gray600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CÓ (${currentMarket.yesPercentage.toStringAsFixed(0)}%)',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isYes ? Colors.white : FptColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedOutcome = MarketOutcome.no),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isYes ? FptColors.noRed : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: !isYes
                              ? [
                                  BoxShadow(
                                    color: FptColors.noRed.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.thumb_down_rounded,
                              size: 16,
                              color: !isYes ? Colors.white : FptColors.gray600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'KHÔNG (${currentMarket.noPercentage.toStringAsFixed(0)}%)',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: !isYes ? Colors.white : FptColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Số kẹo muốn cược + Balance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Số kẹo cược',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: FptColors.textDark,
                  ),
                ),
                Text(
                  'Số dư: $userCandies 🍬',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: FptColors.orangeDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Input TextField
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: FptColors.textDark,
              ),
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 10),
                  child: Text('🍬', style: TextStyle(fontSize: 24)),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                suffixText: 'Kẹo',
                suffixStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: FptColors.gray600,
                ),
                filled: true,
                fillColor: FptColors.gray50,
              ),
            ),
            const SizedBox(height: 10),

            // Quick Amount Buttons (+5, +10, +25, +50, Max)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickPill('+5', 5),
                  _quickPill('+10', 10),
                  _quickPill('+25', 25),
                  _quickPill('+50', 50),
                  _quickPill('Tất tay (All-in)', userCandies, isSpecial: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Polymarket Payout Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dự kiến nhận về nếu thắng:',
                        style: TextStyle(fontSize: 13, color: FptColors.textDark),
                      ),
                      Text(
                        '~$estimatedPayout 🍬',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lợi nhuận kẹo ước tính:',
                        style: TextStyle(fontSize: 12, color: FptColors.textMuted),
                      ),
                      Text(
                        '+$potentialProfit 🍬 (${_betAmount > 0 ? (potentialProfit / _betAmount * 100).toStringAsFixed(0) : 0}%)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Ghi chú cơ chế Admin kẹo
            Row(
              children: [
                const Icon(Icons.shield_outlined, size: 14, color: FptColors.gray600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Admin bảo chứng quỹ ${currentMarket.adminBackstopCandies} 🍬 nếu không có ai chọn bên còn lại.',
                    style: const TextStyle(fontSize: 11, color: FptColors.gray600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Confirm Bet Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading || _betAmount <= 0 || _betAmount > userCandies
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);

                        setState(() => _isLoading = true);
                        final error = await appService.placeBet(
                          marketId: widget.market.id,
                          outcome: _selectedOutcome,
                          amount: _betAmount,
                        );
                        if (!mounted) return;
                        setState(() => _isLoading = false);

                        if (error != null) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(error),
                              backgroundColor: FptColors.noRed,
                            ),
                          );
                        } else {
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                '🎉 Cược thành công $_betAmount 🍬 vào cửa ${isYes ? "CÓ" : "KHÔNG"}!',
                              ),
                              backgroundColor: FptColors.yesGreen,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  disabledBackgroundColor: FptColors.gray200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _betAmount > userCandies
                            ? 'Không đủ kẹo (Cần $_betAmount 🍬)'
                            : 'XÁC NHẬN CƯỢC $_betAmount 🍬',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickPill(String label, int amount, {bool isSpecial = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isSpecial ? FptColors.orangeDark : FptColors.textDark,
        ),
        backgroundColor: isSpecial
            ? FptColors.orange.withOpacity(0.15)
            : FptColors.gray100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSpecial ? FptColors.orange : Colors.transparent,
            width: 1,
          ),
        ),
        onPressed: () => _setAmount(amount),
      ),
    );
  }
}
