import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/app_service.dart';
import '../../theme/fpt_theme.dart';
import '../../widgets/candy_chip.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = AppService();

    return ListenableBuilder(
      listenable: appService,
      builder: (context, _) {
        // Lọc chỉ sinh viên trực tiếp từ SQLite Database và sắp xếp giảm dần theo số kẹo
        final students = appService.users
            .where((u) => u.role == UserRole.student)
            .toList()
          ..sort((a, b) => b.candies.compareTo(a.candies));

        final top1 = students.isNotEmpty ? students[0] : null;
        final top2 = students.length > 1 ? students[1] : null;
        final top3 = students.length > 2 ? students[2] : null;

        return Scaffold(
          backgroundColor: FptColors.lightBg,
          appBar: AppBar(
            title: const Text('Bảng Vàng Đại Gia Kẹo'),
            actions: [
              CandyChip(candies: appService.currentUser?.candies ?? 0),
              const SizedBox(width: 14),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header Podium Area
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🏆 TOP THỦ KHOA DỰ ĐOÁN FPT',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFDBA74),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Dữ liệu bảng xếp hạng được truy vấn trực tiếp từ Database SQLite',
                        style: TextStyle(fontSize: 11, color: Color(0xFFE2E8F0)),
                      ),
                      const SizedBox(height: 24),

                      // 3 Podium Columns (Top 2, Top 1, Top 3)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (top2 != null)
                            _podiumColumn(
                              user: top2,
                              rank: 2,
                              badge: '🥈',
                              badgeColor: const Color(0xFF94A3B8),
                              height: 90,
                            ),
                          const SizedBox(width: 12),
                          if (top1 != null)
                            _podiumColumn(
                              user: top1,
                              rank: 1,
                              badge: '🥇',
                              badgeColor: const Color(0xFFF59E0B),
                              height: 120,
                            ),
                          const SizedBox(width: 12),
                          if (top3 != null)
                            _podiumColumn(
                              user: top3,
                              rank: 3,
                              badge: '🥉',
                              badgeColor: const Color(0xFFB45309),
                              height: 70,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Ranking List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: students.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, index) {
                      final user = students[index];
                      final isMe = user.id == appService.currentUser?.id;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFFFF7ED) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isMe ? FptColors.orange : const Color(0xFFE2E8F0),
                            width: isMe ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: index < 3 ? FptColors.orangeDark : FptColors.gray600,
                                ),
                              ),
                            ),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: FptColors.orange.withOpacity(0.15),
                              child: Text(
                                user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: FptColors.orangeDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        user.fullName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: FptColors.textDark,
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: FptColors.orange,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Bạn',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    '${user.studentCode} • ${user.campus}',
                                    style: const TextStyle(fontSize: 11, color: FptColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${user.candies} 🍬',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: FptColors.orangeDark,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _podiumColumn({
    required UserModel user,
    required int rank,
    required String badge,
    required Color badgeColor,
    required double height,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(badge, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 2),
        Text(
          user.fullName.split(' ').last,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          '${user.candies} 🍬',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: badgeColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 76,
          height: height,
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: badgeColor.withOpacity(0.4)),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rank',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: badgeColor,
            ),
          ),
        ),
      ],
    );
  }
}
