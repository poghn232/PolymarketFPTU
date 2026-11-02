import 'package:flutter/material.dart';
import '../../models/market_model.dart';
import '../../services/app_service.dart';
import '../../theme/fpt_theme.dart';

class ResolveMarketScreen extends StatefulWidget {
  const ResolveMarketScreen({super.key});

  @override
  State<ResolveMarketScreen> createState() => _ResolveMarketScreenState();
}

class _ResolveMarketScreenState extends State<ResolveMarketScreen> {
  MarketModel? _selectedMarket;
  MarketOutcome _chosenOutcome = MarketOutcome.yes;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appService = AppService();
    final activeMarkets = appService.markets
        .where((m) => m.status == MarketStatus.active)
        .toList();

    return Scaffold(
      backgroundColor: FptColors.lightBg,
      appBar: AppBar(
        title: const Text('Admin: Chốt Kết Quả & Trả Kẹo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instruction
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gavel, color: Color(0xFFB45309), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Chọn một kèo đang hoạt động để công bố kết quả. Hệ thống sẽ tự động tính toán tỷ lệ, phát kẹo thưởng cho người thắng và chuyển kẹo về Admin nếu bên còn lại không ai chọn.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              '1. Chọn kèo cần chốt kết quả:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: FptColors.textDark),
            ),
            const SizedBox(height: 10),

            if (activeMarkets.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Hiện không có kèo nào đang hoạt động cần chốt.',
                    style: TextStyle(color: FptColors.textMuted),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeMarkets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final m = activeMarkets[index];
                  final isSelected = _selectedMarket?.id == m.id;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedMarket = m),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? FptColors.orange : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
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
                                  color: FptColors.gray100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  m.campus,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: FptColors.gray600,
                                  ),
                                ),
                              ),
                              Text(
                                '${m.totalVolume} 🍬 đã cược',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: FptColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: FptColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'CÓ: ${m.yesPool} 🍬 (${m.yesPercentage.toStringAsFixed(0)}%)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: FptColors.yesGreen,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'KHÔNG: ${m.noPool} 🍬 (${m.noPercentage.toStringAsFixed(0)}%)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: FptColors.noRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            if (_selectedMarket != null) ...[
              const Text(
                '2. Chọn kết quả thực tế chiến thắng:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: FptColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _chosenOutcome = MarketOutcome.yes),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _chosenOutcome == MarketOutcome.yes
                              ? FptColors.yesGreen
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _chosenOutcome == MarketOutcome.yes
                                ? FptColors.yesGreen
                                : const Color(0xFFCBD5E1),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: _chosenOutcome == MarketOutcome.yes
                                  ? Colors.white
                                  : FptColors.yesGreen,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'CỬA CÓ THẮNG',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: _chosenOutcome == MarketOutcome.yes
                                    ? Colors.white
                                    : FptColors.textDark,
                              ),
                            ),
                            Text(
                              'Pool: ${_selectedMarket!.yesPool} 🍬',
                              style: TextStyle(
                                fontSize: 11,
                                color: _chosenOutcome == MarketOutcome.yes
                                    ? Colors.white70
                                    : FptColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _chosenOutcome = MarketOutcome.no),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _chosenOutcome == MarketOutcome.no
                              ? FptColors.noRed
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _chosenOutcome == MarketOutcome.no
                                ? FptColors.noRed
                                : const Color(0xFFCBD5E1),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cancel,
                              color: _chosenOutcome == MarketOutcome.no
                                  ? Colors.white
                                  : FptColors.noRed,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'CỬA KHÔNG THẮNG',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: _chosenOutcome == MarketOutcome.no
                                    ? Colors.white
                                    : FptColors.textDark,
                              ),
                            ),
                            Text(
                              'Pool: ${_selectedMarket!.noPool} 🍬',
                              style: TextStyle(
                                fontSize: 11,
                                color: _chosenOutcome == MarketOutcome.no
                                    ? Colors.white70
                                    : FptColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Payout Simulation Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: FptColors.gray200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cơ chế phân phối kẹo:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: FptColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedMarket!.yesPool == 0 || _selectedMarket!.noPool == 0
                          ? '⚠️ Lưu ý: Kèo này có một bên chưa có ai cược. Theo quy tắc hệ thống, Admin sẽ kích hoạt quỹ bảo chứng ${_selectedMarket!.adminBackstopCandies} 🍬 để người thắng nhận kẹo, hoặc Admin thu toàn bộ kẹo nếu mọi người đều đoán sai.'
                          : '✅ Cả 2 bên đều có sinh viên cược. Tổng pool bên thua sẽ được chia đều theo tỷ lệ phần trăm cược cho những sinh viên chọn cửa ${_chosenOutcome == MarketOutcome.yes ? "CÓ" : "KHÔNG"}.',
                      style: const TextStyle(fontSize: 12, color: FptColors.gray800, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xác nhận chốt kết quả?'),
                              content: Text(
                                'Bạn có chắc chắn muốn chốt cửa ${_chosenOutcome == MarketOutcome.yes ? "CÓ" : "KHÔNG"} là cửa chiến thắng?\n\nKẹo sẽ được phát ngay lập tức cho các sinh viên!',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Hủy'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: FptColors.orange,
                                  ),
                                  child: const Text('Xác nhận chốt'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            setState(() => _isLoading = true);
                            await appService.resolveMarket(
                              marketId: _selectedMarket!.id,
                              winningOutcome: _chosenOutcome,
                            );
                            if (!mounted) return;
                            setState(() {
                              _isLoading = false;
                              _selectedMarket = null;
                            });

                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('🎉 Chốt kết quả thành công! Đã phát kẹo thưởng.'),
                                backgroundColor: FptColors.yesGreen,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.check_circle_outline),
                  label: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(
                          'CHỐT KẾT QUẢ: ${_chosenOutcome == MarketOutcome.yes ? "CÓ" : "KHÔNG"} THẮNG',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _chosenOutcome == MarketOutcome.yes
                        ? FptColors.yesGreen
                        : FptColors.noRed,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
