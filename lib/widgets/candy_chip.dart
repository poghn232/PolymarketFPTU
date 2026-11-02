import 'package:flutter/material.dart';
import '../services/app_service.dart';
import '../theme/fpt_theme.dart';

class CandyChip extends StatelessWidget {
  final int candies;
  final VoidCallback? onTap;

  const CandyChip({
    super.key,
    required this.candies,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showCandyDetails(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFDBA74), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: FptColors.orange.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🍬',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 5),
            Text(
              '$candies',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Color(0xFFC2410C),
              ),
            ),
            const SizedBox(width: 3),
            const Text(
              'Kẹo',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: Color(0xFF9A3412),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCandyDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final appService = AppService();
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '🍬 Túi Kẹo Sinh Viên FPT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: FptColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Kẹo là đơn vị dự đoán vui trong khuôn viên ĐH FPT (không có giá trị quy đổi tiền mặt). Mỗi sinh viên mới được tặng 50 kẹo!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: FptColors.textMuted),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FptColors.gray50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FptColors.gray200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Số kẹo hiện tại',
                          style: TextStyle(fontSize: 12, color: FptColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$candies 🍬',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: FptColors.orangeDark,
                          ),
                        ),
                      ],
                    ),
                    Container(height: 36, width: 1, color: FptColors.gray200),
                    Column(
                      children: [
                        const Text(
                          'Cược đang mở',
                          style: TextStyle(fontSize: 12, color: FptColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${appService.myBets.where((b) => b.status.name == 'active').length} kèo',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: FptColors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: !appService.canClaimDaily
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final err = await appService.claimDailyCandy();
                          if (ctx.mounted) Navigator.pop(ctx);

                          if (err != null) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(err),
                                backgroundColor: FptColors.noRed,
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('🎉 Điểm danh thành công! Nhận +20 Kẹo vào tài khoản.'),
                                backgroundColor: FptColors.yesGreen,
                              ),
                            );
                          }
                        },
                  icon: Icon(
                    appService.canClaimDaily ? Icons.card_giftcard : Icons.check_circle,
                  ),
                  label: Text(
                    appService.canClaimDaily
                        ? 'Điểm danh nhận ngay +20 Kẹo'
                        : '✓ Đã điểm danh hôm nay (Quay lại ngày mai)',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appService.canClaimDaily ? FptColors.orange : FptColors.gray400,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: FptColors.gray200,
                    disabledForegroundColor: FptColors.gray600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
