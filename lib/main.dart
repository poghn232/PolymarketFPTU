import 'package:flutter/material.dart';
import 'services/app_service.dart';
import 'theme/fpt_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appService = AppService();
  await appService.init();
  runApp(const FptMarketApp());
}

class FptMarketApp extends StatelessWidget {
  const FptMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appService = AppService();

    return ListenableBuilder(
      listenable: appService,
      builder: (context, _) {
        return MaterialApp(
          title: 'FPT Market - Sàn Kẹo Dự Đoán',
          debugShowCheckedModeBanner: false,
          theme: FptTheme.lightTheme,
          home: appService.currentUser == null
              ? const LoginScreen()
              : const MainNavigationScreen(),
        );
      },
    );
  }
}
