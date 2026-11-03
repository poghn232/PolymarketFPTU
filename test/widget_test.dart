import 'package:flutter/material.dart';
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

  test('Admin can expire market immediately and resolve it', () async {
    final appService = AppService();
    await appService.init();

    await appService.login('admin@fpt.edu.vn', 'admin123');
    final market = appService.markets.firstWhere((m) => m.status == MarketStatus.active);

    // Expire market immediately
    await appService.expireMarketNow(market.id);

    final expiredMarket = await DatabaseHelper.instance.getMarketById(market.id);
    expect(expiredMarket!.isExpired, isTrue);
    expect(expiredMarket.canBet, isFalse);

    // Admin can still resolve the expired market
    await appService.resolveMarket(
      marketId: market.id,
      winningOutcome: MarketOutcome.yes,
    );

    final resolvedMarket = await DatabaseHelper.instance.getMarketById(market.id);
    expect(resolvedMarket!.status, equals(MarketStatus.resolved));
    expect(resolvedMarket.winningOutcome, equals(MarketOutcome.yes));
  });

  test('If only one side is bet on, Admin vault is deducted when that side wins', () async {
    final appService = AppService();
    await appService.init();

    // Admin creates brand new solo market with 50 backstop
    await appService.login('admin@fpt.edu.vn', 'admin123');
    await appService.createMarket(
      title: 'Solo Market Test',
      description: 'Test solo betting',
      category: 'Campus FPT',
      campus: 'Toàn quốc',
      endDate: DateTime.now().add(const Duration(days: 1)),
      initialAdminBackstop: 50,
    );

    final market = appService.markets.first;

    // Only 1 student bets on YES (0 people bet on NO)
    await appService.login('student@fpt.edu.vn', 'student123');
    await appService.placeBet(
      marketId: market.id,
      outcome: MarketOutcome.yes,
      amount: 20,
    );

    // Admin logs in and resolves YES as won
    await appService.login('admin@fpt.edu.vn', 'admin123');
    final vaultBeforeResolve = appService.adminVaultCandies;

    await appService.resolveMarket(
      marketId: market.id,
      winningOutcome: MarketOutcome.yes,
    );

    // Admin vault is deducted in SQLite because Admin paid the reward!
    expect(appService.adminVaultCandies, lessThan(vaultBeforeResolve));
    final vaultInDb = await DatabaseHelper.instance.getAdminVaultCandies();
    expect(vaultInDb, lessThan(vaultBeforeResolve));
  });

  test('History table in SQLite records bet placements, daily claims, and resolutions with balance tracking', () async {
    final appService = AppService();
    await appService.init();

    await appService.login('student@fpt.edu.vn', 'student123');
    final initialHistoryCount = appService.history.length;

    // 1. Daily Claim logs to SQLite history
    await appService.claimDailyCandy();
    expect(appService.history.length, equals(initialHistoryCount + 1));
    expect(appService.history.first.action, equals('daily_claim'));
    expect(appService.history.first.amount, equals(20));

    // 2. Bet placement logs to SQLite history
    final market = appService.markets.first;
    await appService.placeBet(
      marketId: market.id,
      outcome: MarketOutcome.yes,
      amount: 10,
    );

    expect(appService.history.first.action, equals('bet_placed'));
    expect(appService.history.first.amount, equals(-10));
    expect(appService.history.first.outcome, equals('yes'));

    // Check directly in SQLite 'history' table
    final dbHistory = await DatabaseHelper.instance.getHistoryForUser('student_1');
    expect(dbHistory.any((h) => h.action == 'bet_placed' && h.amount == -10), isTrue);
  });

  test('Notifications table in SQLite stores notifications and deleting record removes it from SQLite', () async {
    final appService = AppService();
    await appService.init();

    await appService.login('student@fpt.edu.vn', 'student123');
    expect(appService.notifications, isNotEmpty);

    final notifToDelete = appService.notifications.first;
    final initialCount = appService.notifications.length;

    // Delete single notification from SQLite
    await appService.deleteNotification(notifToDelete.id);

    // Verify removed from in-memory AppService
    expect(appService.notifications.length, equals(initialCount - 1));
    expect(appService.notifications.any((n) => n.id == notifToDelete.id), isFalse);

    // Verify completely deleted from SQLite database table 'notifications'
    final dbNotifs = await DatabaseHelper.instance.getNotificationsForUser('student_1');
    expect(dbNotifs.any((n) => n.id == notifToDelete.id), isFalse);

    // Test clear all notifications
    await appService.clearAllNotifications();
    expect(appService.notifications, isEmpty);
    final emptyDbNotifs = await DatabaseHelper.instance.getNotificationsForUser('student_1');
    expect(emptyDbNotifs, isEmpty);
  });

  testWidgets('HomeScreen, ProfileScreen, and CandyChip instantly update displayed candies when bet is placed', (WidgetTester tester) async {
    final appService = AppService();
    await appService.init();

    // Login as student
    await appService.login('student@fpt.edu.vn', 'student123');

    // Build the app (pump frame with duration to avoid infinite settle due to CountdownTimer periodic tickers)
    await tester.pumpWidget(const FptMarketApp());
    await tester.pump(const Duration(milliseconds: 200));

    final initialCandies = appService.currentUser!.candies;
    // Verify initial candies are displayed in CandyChip on HomeScreen
    expect(find.text('$initialCandies'), findsWidgets);

    // Place bet of 20 candies
    final market = appService.markets.first;
    await appService.placeBet(
      marketId: market.id,
      outcome: MarketOutcome.yes,
      amount: 20,
    );

    // Pump widget frame to reflect notifyListeners
    await tester.pump(const Duration(milliseconds: 200));

    final newCandies = initialCandies - 20;
    // Verify CandyChip on HomeScreen IMMEDIATELY displays newCandies without app restart!
    expect(find.text('$newCandies'), findsWidgets);
    expect(find.text('$initialCandies'), findsNothing);

    // Switch to Profile tab
    await tester.tap(find.text('Hồ Sơ'));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify ProfileScreen displays the updated newCandies directly
    expect(find.text('$newCandies 🍬'), findsOneWidget);

    // Unmount app to cancel all CountdownTimer periodic tickers and clean up
    await tester.pumpWidget(const SizedBox());
  });
}
