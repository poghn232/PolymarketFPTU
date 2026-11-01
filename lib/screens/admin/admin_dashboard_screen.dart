import 'package:flutter/material.dart';
import '../../models/market_model.dart';
import '../../models/user_model.dart';
import '../../services/app_service.dart';
import '../../theme/fpt_theme.dart';
import 'create_market_screen.dart';
import 'resolve_market_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = AppService();
    final markets = appService.markets;
    final activeMarkets = markets.where((m) => m.status == MarketStatus.active).length;
    final resolvedMarkets = markets.where((m) => m.status == MarketStatus.resolved).length;
    final totalBets = appService.bets.length;
    final totalStudents = appService.users.where((u) => u.role == UserRole.student).length;

    return Scaffold(
      backgroundColor: FptColors.lightBg,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: FptColors.orange),
            SizedBox(width: 8),
            Text('Admin FPT Dashboard'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin Vault Card
            Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'QUỸ KẸO BẢO CHỨNG ADMIN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: FptColors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Root Admin Account',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: FptColors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '${appService.adminVaultCandies}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('🍬', style: TextStyle(fontSize: 26)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Số kẹo dùng để làm thanh khoản đối ứng nếu sinh viên không chọn bên còn lại.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Statistics Grid
            Row(
              children: [
                Expanded(child: _statBox('Kèo đang mở', '$activeMarkets', Icons.timelapse, FptColors.blue)),
                const SizedBox(width: 10),
                Expanded(child: _statBox('Đã chốt kèo', '$resolvedMarkets', Icons.check_circle, FptColors.yesGreen)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _statBox('Tổng lượt cược', '$totalBets', Icons.receipt_long, FptColors.orangeDark)),
                const SizedBox(width: 10),
                Expanded(child: _statBox('Sinh viên tham gia', '$totalStudents', Icons.groups, const Color(0xFF7C3AED))),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            const Text(
              'Tác vụ quản trị',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: FptColors.textDark,
              ),
            ),
            const SizedBox(height: 12),

            _adminActionTile(
              title: 'Tạo Kèo Dự Đoán Mới',
              subtitle: 'Thiết lập tiêu đề, danh mục, số kẹo bảo chứng và ngày kết thúc',
              icon: Icons.add_circle,
              color: FptColors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateMarketScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            _adminActionTile(
              title: 'Chốt Kết Quả & Trả Kẹo',
              subtitle: 'Công bố kết quả CÓ / KHÔNG và phát kẹo thưởng cho sinh viên',
              icon: Icons.gavel,
              color: FptColors.yesGreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResolveMarketScreen()),
                );
              },
            ),
            const SizedBox(height: 10),

            _adminActionTile(
              title: 'Tặng Kẹo Thưởng Cho Sinh Viên',
              subtitle: 'Airdrop/Cấp thêm kẹo cho sinh viên để phục vụ quá trình test môn học',
              icon: Icons.card_giftcard,
              color: FptColors.blue,
              onTap: () => _showRewardDialog(context),
            ),
            const SizedBox(height: 10),

            _adminActionTile(
              title: 'Khôi phục Dữ liệu Mẫu (Reset Data)',
              subtitle: 'Reset về trạng thái ban đầu gồm các kèo và tài khoản test để chấm điểm',
              icon: Icons.restart_alt,
              color: Colors.red.shade700,
              onTap: () => _showResetDialog(context),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: FptColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _adminActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: FptColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: FptColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: FptColors.gray400),
          ],
        ),
      ),
    );
  }

  void _showRewardDialog(BuildContext context) {
    final appService = AppService();
    final students = appService.users.where((u) => u.role == UserRole.student).toList();
    if (students.isEmpty) return;

    UserModel selectedStudent = students.first;
    int amount = 50;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Tặng Kẹo Sinh Viên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<UserModel>(
                initialValue: selectedStudent,
                decoration: const InputDecoration(labelText: 'Chọn sinh viên'),
                items: students.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text('${s.fullName} (${s.studentCode})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedStudent = val);
                },
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [20, 50, 100].map((amt) {
                  return ChoiceChip(
                    label: Text('+$amt 🍬'),
                    selected: amount == amt,
                    onSelected: (val) {
                      if (val) setState(() => amount = amt);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                appService.adminRewardCandies(selectedStudent.id, amount);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 Đã tặng $amount 🍬 cho ${selectedStudent.fullName}!'),
                    backgroundColor: FptColors.yesGreen,
                  ),
                );
              },
              child: const Text('Tặng ngay'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final appService = AppService();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Khôi phục dữ liệu mẫu?'),
        content: const Text(
          'Hành động này sẽ khôi phục lại các kèo ban đầu, danh sách tài khoản test và số dư kẹo mặc định.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              appService.resetToSampleData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã khôi phục dữ liệu mẫu thành công!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );
  }
}
