import 'package:flutter/material.dart';
import '../../services/app_service.dart';
import '../../theme/fpt_theme.dart';
import '../../widgets/fpt_logo.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = AppService();

    return ListenableBuilder(
      listenable: appService,
      builder: (context, _) {
        final user = appService.currentUser;

        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Chưa đăng nhập')),
          );
        }

        return Scaffold(
          backgroundColor: FptColors.lightBg,
          appBar: AppBar(
            title: const Text('Hồ Sơ Sinh Viên FPT'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: FptColors.noRed),
                tooltip: 'Đăng xuất',
                onPressed: () async {
                  await appService.logout();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: user.isAdmin ? FptColors.navy : FptColors.orange.withOpacity(0.15),
                    child: user.isAdmin
                        ? const Icon(Icons.admin_panel_settings, color: Colors.white, size: 36)
                        : Text(
                            user.fullName.isNotEmpty ? user.fullName[0] : 'C',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: FptColors.orangeDark,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: FptColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: user.isAdmin ? FptColors.navy : FptColors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.isAdmin ? '👑 TÀI KHOẢN ADMIN GỐC' : '🎓 SINH VIÊN CHÍNH THỨC',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: user.isAdmin ? Colors.white : FptColors.orangeDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),

                  // Candy Balance Big Tile
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDBA74)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Số kẹo đang có',
                              style: TextStyle(fontSize: 12, color: Color(0xFF9A3412), fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Kẹo Dự Đoán FPT',
                              style: TextStyle(fontSize: 10, color: Color(0xFF7C2D12)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${user.candies}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFC2410C),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('🍬', style: TextStyle(fontSize: 22)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Information Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.badge, 'Mã sinh viên (MSSV)', user.studentCode),
                  const Divider(height: 20),
                  _infoRow(Icons.email, 'Email FPT', user.email),
                  const Divider(height: 20),
                  _infoRow(Icons.location_city, 'Cơ sở đào tạo', user.campus),
                  const Divider(height: 20),
                  _infoRow(
                    Icons.monetization_on,
                    'Chính sách kẹo tân thủ',
                    '50 🍬 / sinh viên mới (SQLite)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await appService.logout();
                },
                icon: const Icon(Icons.logout, color: FptColors.noRed, size: 18),
                label: const Text('ĐĂNG XUẤT TÀI KHOẢN', style: TextStyle(color: FptColors.noRed, fontWeight: FontWeight.w800)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: FptColors.noRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Disclaimer Footer
            const FptLogo(size: 26),
            const SizedBox(height: 8),
            const Text(
              'Ứng dụng dự đoán nội bộ dành cho sinh viên ĐH FPT\nĐề tài phục vụ mục đích học tập môn học, không mang tính thương mại hoặc cờ bạc.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: FptColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: FptColors.gray600),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: FptColors.textMuted)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: FptColors.textDark),
            ),
          ],
        ),
      ],
    );
  }
}
