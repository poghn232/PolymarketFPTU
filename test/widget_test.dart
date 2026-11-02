import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:polymarket_fpt/main.dart';
import 'package:polymarket_fpt/services/app_service.dart';
import 'package:polymarket_fpt/services/database_helper.dart';
import 'package:polymarket_fpt/models/user_model.dart';
import 'package:polymarket_fpt/models/market_model.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final appService = AppService();
    await DatabaseHelper.instance.resetDatabase();
    await appService.init();
    await appService.logout();
  });

  testWidgets('FPT Market App initializes on Login Screen when not logged in', (WidgetTester tester) async {
    final appService = AppService();
    await appService.init();

    await tester.pumpWidget(const FptMarketApp());
    await tester.pumpAndSettle();

    // Verify user sees Login Screen on launch (not automatically logged in!)
    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);
    expect(find.textContaining('Đăng ký (+50 🍬)'), findsOneWidget);
  });

  test('New user registration receives exactly 50 candies in SQLite', () async {
    final appService = AppService();
    await appService.init();

    final success = await appService.register(
      email: 'test_candies@fpt.edu.vn',
      password: 'password123',
      fullName: 'Test Candidate',
      studentCode: 'SE199999',
      campus: 'Hà Nội (Hòa Lạc)',
    );

    expect(success, isTrue);
    expect(appService.currentUser?.candies, equals(50));
    expect(appService.currentUser?.role, equals(UserRole.student));

    // Verify persisted in SQLite
    final userInDb = await DatabaseHelper.instance.getUserByEmail('test_candies@fpt.edu.vn');
    expect(userInDb?.candies, equals(50));
  });

  test('Placing bet deducts candies immediately and updates bet count & pool in SQLite', () async {
    final appService = AppService();
    await appService.init();

    // Login as student
    final loggedIn = await appService.login('student@fpt.edu.vn', 'student123');
    expect(loggedIn, isTrue);

    final initialCandies = appService.currentUser!.candies;
    final market = appService.markets.first;
    final initialYesPool = market.yesPool;
    final initialYesCount = market.yesCount;

    // Bet 20 candies on YES
    final error = await appService.placeBet(
      marketId: market.id,
      outcome: MarketOutcome.yes,
      amount: 20,
    );
    expect(error, isNull);

    // Verify candies deducted immediately from current user
    expect(appService.currentUser!.candies, equals(initialCandies - 20));

    // Verify database reflects new pool and count
    final updatedMarket = await DatabaseHelper.instance.getMarketById(market.id);
    expect(updatedMarket?.yesPool, equals(initialYesPool + 20));
    expect(updatedMarket?.yesCount, equals(initialYesCount + 1));

    // Verify user's bet can be retrieved
    final myBet = appService.getMyBetForMarket(market.id);
    expect(myBet, isNotNull);
    expect(myBet?.outcome, equals(MarketOutcome.yes));
    expect(myBet?.amount, equals(20));
  });

  test('Claiming daily candy adds +20 candies once per day and prevents duplicate claims', () async {
    final appService = AppService();
    await appService.init();

    await appService.login('student@fpt.edu.vn', 'student123');
    final beforeCandies = appService.currentUser!.candies;

    // First claim today: succeeds
    final firstResult = await appService.claimDailyCandy();
    expect(firstResult, isNull);
    expect(appService.currentUser!.candies, equals(beforeCandies + 20));

    // Second claim today: blocked
    final secondResult = await appService.claimDailyCandy();
    expect(secondResult, isNotNull);
    expect(appService.currentUser!.candies, equals(beforeCandies + 20)); // Candies do not increase again

    final inDb = await DatabaseHelper.instance.getUserById(appService.currentUser!.id);
    expect(inDb?.candies, equals(beforeCandies + 20));
  });

  test('Admin login and resolving market adds payout candies to winning user', () async {
    final appService = AppService();
    await appService.init();

    // Student places bet
    await appService.login('student@fpt.edu.vn', 'student123');
    final market = appService.markets.first;
    await appService.placeBet(
      marketId: market.id,
      outcome: MarketOutcome.yes,
      amount: 25,
    );

    final candiesAfterBet = appService.currentUser!.candies;

    // Admin logs in and resolves market as YES won
    await appService.login('admin@fpt.edu.vn', 'admin123');
    expect(appService.isAdmin, isTrue);

    await appService.resolveMarket(
      marketId: market.id,
      winningOutcome: MarketOutcome.yes,
    );

    // Check student candies in SQLite
    final studentInDb = await DatabaseHelper.instance.getUserByEmail('student@fpt.edu.vn');
    expect(studentInDb!.candies, greaterThan(candiesAfterBet));
  });
}
