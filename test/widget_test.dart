import 'package:flutter_test/flutter_test.dart';
import 'package:polymarket_fpt/main.dart';
import 'package:polymarket_fpt/services/app_service.dart';
import 'package:polymarket_fpt/models/user_model.dart';
import 'package:polymarket_fpt/models/market_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FPT Market App initializes and renders properly', (WidgetTester tester) async {
    final appService = AppService();
    await appService.init();

    await tester.pumpWidget(const FptMarketApp());
    await tester.pumpAndSettle();

    // Verify app renders with candies and market elements
    expect(find.textContaining('Kẹo'), findsWidgets);
    expect(find.textContaining('Sàn'), findsWidgets);
  });

  test('New user receives 50 candies on registration', () async {
    final appService = AppService();
    await appService.init();

    final success = await appService.register(
      email: 'test_student@fpt.edu.vn',
      fullName: 'Test Student',
      studentCode: 'SE199999',
      campus: 'Hà Nội (Hòa Lạc)',
    );

    expect(success, isTrue);
    expect(appService.currentUser?.candies, equals(50));
    expect(appService.currentUser?.role, equals(UserRole.student));
  });

  test('Root admin account exists with high liquidity vault', () async {
    final appService = AppService();
    await appService.init();

    await appService.quickLoginAsAdmin();
    expect(appService.isAdmin, isTrue);
    expect(appService.currentUser?.email, equals('admin@fpt.edu.vn'));
    expect(appService.adminVaultCandies, greaterThanOrEqualTo(5000));
  });

  test('Admin backstop payout logic works when no opposing bets exist', () async {
    final appService = AppService();
    await appService.init();

    // Create market with 50 candies backstop
    await appService.quickLoginAsAdmin();
    await appService.createMarket(
      title: 'Test Solo Market',
      description: 'Solo test',
      category: 'Học tập & Thi cử',
      campus: 'Toàn quốc',
      endDate: DateTime.now().add(const Duration(days: 1)),
      initialAdminBackstop: 50,
    );

    final market = appService.markets.first;

    // Student bets 20 candies on YES
    await appService.quickLoginAsStudent();
    final initialCandies = appService.currentUser!.candies;
    await appService.placeBet(
      marketId: market.id,
      outcome: MarketOutcome.yes,
      amount: 20,
    );
    expect(appService.currentUser!.candies, equals(initialCandies - 20));

    // Admin resolves market as YES won
    await appService.quickLoginAsAdmin();
    await appService.resolveMarket(
      marketId: market.id,
      winningOutcome: MarketOutcome.yes,
    );

    // Switch back to student and check if backstop rewarded them
    await appService.quickLoginAsStudent();
    expect(appService.currentUser!.candies, greaterThan(initialCandies));
  });
}
