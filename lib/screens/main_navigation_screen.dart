import 'package:flutter/material.dart';
import '../services/app_service.dart';
import '../theme/fpt_theme.dart';
import 'home/home_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'portfolio/portfolio_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appService = AppService();
    final isAdmin = appService.isAdmin;

    final List<Widget> screens = [
      const HomeScreen(),
      const LeaderboardScreen(),
      const PortfolioScreen(),
      if (isAdmin) const AdminDashboardScreen(),
      const ProfileScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.show_chart_rounded),
        activeIcon: Icon(Icons.show_chart_rounded, color: FptColors.orange),
        label: 'Sàn Kèo',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.leaderboard_outlined),
        activeIcon: Icon(Icons.leaderboard, color: FptColors.orange),
        label: 'Xếp Hạng',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long_outlined),
        activeIcon: Icon(Icons.receipt_long, color: FptColors.orange),
        label: 'Cược Của Tôi',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings, color: FptColors.orange),
          label: 'Admin FPT',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person, color: FptColors.orange),
        label: 'Hồ Sơ',
      ),
    ];

    // Tránh overflow index khi chuyển đổi từ admin sang student
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: FptColors.orange,
          unselectedItemColor: FptColors.gray600,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          elevation: 0,
          items: navItems,
        ),
      ),
    );
  }
}
