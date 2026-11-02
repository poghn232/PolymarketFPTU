import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/user_model.dart';
import '../models/market_model.dart';
import '../models/bet_model.dart';
import '../models/notification_model.dart';
import '../models/history_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fpt_market.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedDatabase(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // 1. Table Users
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE,
        password TEXT,
        full_name TEXT,
        student_code TEXT,
        campus TEXT,
        role TEXT,
        candies INTEGER,
        last_daily_claim TEXT,
        created_at TEXT
      )
    ''');

    // 2. Table Markets
    await db.execute('''
      CREATE TABLE IF NOT EXISTS markets (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        category TEXT,
        campus TEXT,
        yes_pool INTEGER,
        no_pool INTEGER,
        yes_count INTEGER,
        no_count INTEGER,
        admin_backstop_candies INTEGER,
        status TEXT,
        winning_outcome TEXT,
        end_date TEXT,
        created_at TEXT,
        created_by TEXT
      )
    ''');

    // 3. Table Bets
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bets (
        id TEXT PRIMARY KEY,
        market_id TEXT,
        market_title TEXT,
        user_id TEXT,
        user_name TEXT,
        outcome TEXT,
        amount INTEGER,
        potential_payout INTEGER,
        status TEXT,
        actual_payout INTEGER,
        placed_at TEXT
      )
    ''');

    // 4. Table System Config
    await db.execute('''
      CREATE TABLE IF NOT EXISTS system_config (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // 5. Table Notifications (Bảng thông báo hệ thống và kết quả)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT,
        message TEXT,
        type TEXT,
        market_id TEXT,
        amount INTEGER,
        is_read INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // 6. Table History (Bảng lịch sử chi tiết cược và biến động kẹo)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        user_name TEXT,
        market_id TEXT,
        market_title TEXT,
        action TEXT,
        outcome TEXT,
        amount INTEGER,
        balance_after INTEGER,
        description TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> _seedDatabase(Database db) async {
    final now = DateTime.now();

    // Seed Users
    final defaultUsers = [
      UserModel(
        id: 'admin_root',
        email: 'admin@fpt.edu.vn',
        password: 'admin123',
        fullName: 'Admin Quản Trị FPT (Cán Bộ)',
        studentCode: 'ADMIN-FPT-01',
        campus: 'ĐH FPT Hà Nội',
        role: UserRole.admin,
        candies: 10000,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: 'student_1',
        email: 'student@fpt.edu.vn',
        password: 'student123',
        fullName: 'Nguyễn Văn Cóc',
        studentCode: 'SE180123',
        campus: 'Hà Nội (Hòa Lạc)',
        role: UserRole.student,
        candies: 50, // Đúng 50 kẹo mặc định
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      UserModel(
        id: 'student_2',
        email: 'linh.fpt@fe.edu.vn',
        password: '123456',
        fullName: 'Trần Mai Linh',
        studentCode: 'IA170456',
        campus: 'TP.HCM (Quận 9)',
        role: UserRole.student,
        candies: 140,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      UserModel(
        id: 'student_3',
        email: 'duc.fe@fe.edu.vn',
        password: '123456',
        fullName: 'Lê Hoàng Đức',
        studentCode: 'GD190789',
        campus: 'Đà Nẵng',
        role: UserRole.student,
        candies: 95,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    for (final u in defaultUsers) {
      await db.insert('users', u.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Seed Markets (Kèm yesCount và noCount)
    final defaultMarkets = [
      MarketModel(
        id: 'm_prn231',
        title: 'Môn PRN231 kỳ này: Tỉ lệ sinh viên qua môn lần 1 có trên 85% không?',
        description: 'Dự đoán kết quả thi Final môn PRN231 (.NET Core) kỳ Spring 2026. Nếu tỉ lệ pass toàn trường >= 85% thì CÓ thắng, ngược lại KHÔNG thắng.',
        category: 'Học tập & Thi cử',
        campus: 'Toàn quốc',
        yesPool: 85,
        noPool: 45,
        yesCount: 4,
        noCount: 2,
        adminBackstopCandies: 50,
        endDate: now.add(const Duration(days: 3, hours: 8, minutes: 30)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      MarketModel(
        id: 'm_cocvang',
        title: 'Danh hiệu Cóc Vàng kỳ Spring 2026 có thuộc về sinh viên ngành SE không?',
        description: 'Cóc Vàng là danh hiệu cao quý nhất mỗi kỳ tại ĐH FPT dành cho thủ khoa. Liệu sinh viên Kỹ thuật Phần mềm (SE) có ẵm giải?',
        category: 'Vinh danh & Cóc Vàng',
        campus: 'Hà Nội (Hòa Lạc)',
        yesPool: 120,
        noPool: 90,
        yesCount: 6,
        noCount: 5,
        adminBackstopCandies: 60,
        endDate: now.add(const Duration(days: 5, hours: 14)),
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      MarketModel(
        id: 'm_weather',
        title: 'Khuôn viên Hòa Lạc tuần tới có mưa to ngập cổng số 1 không?',
        description: 'Dự báo thời tiết và thực tế ngập đường tại campus Hòa Lạc từ thứ 2 đến chủ nhật tuần tới.',
        category: 'Đời sống Campus',
        campus: 'Hà Nội (Hòa Lạc)',
        yesPool: 30,
        noPool: 70,
        yesCount: 2,
        noCount: 4,
        adminBackstopCandies: 40,
        endDate: now.add(const Duration(days: 1, hours: 6)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      MarketModel(
        id: 'm_fcode',
        title: 'CLB F-Code có giành giải Quán quân FPT Edu Hackathon toàn quốc không?',
        description: 'Chung kết cuộc thi Hackathon công nghệ quy tụ các đội mạnh từ HN, ĐN, HCM, Cần Thơ, Quy Nhơn.',
        category: 'Sự kiện & CLB',
        campus: 'Toàn quốc',
        yesPool: 150,
        noPool: 65,
        yesCount: 8,
        noCount: 3,
        adminBackstopCandies: 80,
        endDate: now.add(const Duration(days: 7, hours: 12)),
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      MarketModel(
        id: 'm_canteen',
        title: 'Căn tin campus có bổ sung thêm quầy Trà Sữa trước kỳ thi PE không?',
        description: 'Sinh viên đang đề xuất mở thêm quầy đồ uống giải nhiệt mùa thi tại tầng 1 tòa Alpha.',
        category: 'Đời sống Campus',
        campus: 'TP.HCM (Quận 9)',
        yesPool: 60,
        noPool: 40,
        yesCount: 3,
        noCount: 2,
        adminBackstopCandies: 30,
        endDate: now.add(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      MarketModel(
        id: 'm_vovinam',
        title: 'Lớp VOV134: Hơn 95% sinh viên có đỗ kỳ thi lên đai Lam đai không?',
        description: 'Vovinam là môn giáo dục thể chất đặc trưng của ĐH FPT. Dự đoán kết quả kỳ thi thăng đai sắp tới.',
        category: 'Thể thao Vovinam',
        campus: 'Toàn quốc',
        yesPool: 110,
        noPool: 25,
        yesCount: 5,
        noCount: 1,
        adminBackstopCandies: 50,
        endDate: now.add(const Duration(days: 4, hours: 4)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      // Kèo đã có kết quả để test ngay khu vực "Đã có kết quả"
      MarketModel(
        id: 'm_hackathon_done',
        title: 'FPT Research Festival 2026: Đề tài AI có đạt giải Nhất toàn quốc?',
        description: 'Cuộc thi nghiên cứu khoa học sinh viên FPT toàn quốc. Dự án AI Chatbot thông minh cho sinh viên đã xuất sắc đạt Quán quân!',
        category: 'Sự kiện & Nghiên cứu',
        campus: 'Toàn quốc',
        yesPool: 140,
        noPool: 60,
        yesCount: 6,
        noCount: 3,
        adminBackstopCandies: 50,
        status: MarketStatus.resolved,
        winningOutcome: MarketOutcome.yes,
        endDate: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 6)),
      ),
    ];

    for (final m in defaultMarkets) {
      await db.insert('markets', m.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Seed Sample Bets (Theo yêu cầu: thêm mẫu record vụ bet vào SQLite để dễ test)
    final sampleBets = [
      // Cược đang chờ kết quả của student_1
      BetModel(
        id: 'b_sample_1',
        marketId: 'm_prn231',
        marketTitle: 'Môn PRN231 kỳ này: Tỉ lệ sinh viên qua môn lần 1 có trên 85% không?',
        userId: 'student_1',
        userName: 'Nguyễn Văn Cóc',
        outcome: MarketOutcome.yes,
        amount: 15,
        potentialPayout: 27,
        status: BetStatus.active,
        placedAt: now.subtract(const Duration(hours: 18)),
      ),
      BetModel(
        id: 'b_sample_2',
        marketId: 'm_cocvang',
        marketTitle: 'Danh hiệu Cóc Vàng kỳ Spring 2026 có thuộc về sinh viên ngành SE không?',
        userId: 'student_1',
        userName: 'Nguyễn Văn Cóc',
        outcome: MarketOutcome.no,
        amount: 10,
        potentialPayout: 19,
        status: BetStatus.active,
        placedAt: now.subtract(const Duration(hours: 12)),
      ),
      // Cược đã có kết quả (THẮNG) của student_1
      BetModel(
        id: 'b_sample_3',
        marketId: 'm_hackathon_done',
        marketTitle: 'FPT Research Festival 2026: Đề tài AI có đạt giải Nhất toàn quốc?',
        userId: 'student_1',
        userName: 'Nguyễn Văn Cóc',
        outcome: MarketOutcome.yes,
        amount: 20,
        potentialPayout: 38,
        status: BetStatus.won,
        actualPayout: 38,
        placedAt: now.subtract(const Duration(days: 3)),
      ),
      // Cược của sinh viên khác (student_2 và student_3)
      BetModel(
        id: 'b_sample_4',
        marketId: 'm_prn231',
        marketTitle: 'Môn PRN231 kỳ này: Tỉ lệ sinh viên qua môn lần 1 có trên 85% không?',
        userId: 'student_2',
        userName: 'Trần Mai Linh',
        outcome: MarketOutcome.yes,
        amount: 30,
        potentialPayout: 54,
        status: BetStatus.active,
        placedAt: now.subtract(const Duration(hours: 14)),
      ),
      BetModel(
        id: 'b_sample_5',
        marketId: 'm_hackathon_done',
        marketTitle: 'FPT Research Festival 2026: Đề tài AI có đạt giải Nhất toàn quốc?',
        userId: 'student_2',
        userName: 'Trần Mai Linh',
        outcome: MarketOutcome.no,
        amount: 25,
        potentialPayout: 46,
        status: BetStatus.lost,
        actualPayout: 0,
        placedAt: now.subtract(const Duration(days: 3)),
      ),
      BetModel(
        id: 'b_sample_6',
        marketId: 'm_weather',
        marketTitle: 'Khuôn viên Hòa Lạc tuần tới có mưa to ngập cổng số 1 không?',
        userId: 'student_3',
        userName: 'Lê Hoàng Đức',
        outcome: MarketOutcome.no,
        amount: 20,
        potentialPayout: 32,
        status: BetStatus.active,
        placedAt: now.subtract(const Duration(hours: 8)),
      ),
    ];

    for (final b in sampleBets) {
      await db.insert('bets', b.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Seed Notifications (Bảng thông báo SQLite)
    final sampleNotifications = [
      NotificationModel(
        id: 'notif_1',
        userId: 'student_1',
        title: '🎉 THẮNG CƯỢC +38 🍬',
        message: 'Chúc mừng bạn đã thắng cược kèo "FPT Research Festival 2026: Đề tài AI có đạt giải Nhất toàn quốc?" cửa CÓ! Tiền thưởng +38 🍬 đã được cộng vào tài khoản.',
        type: 'win',
        marketId: 'm_hackathon_done',
        amount: 38,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      NotificationModel(
        id: 'notif_2',
        userId: 'student_1',
        title: '🎁 Quà Chào Mừng Tân Sinh Viên',
        message: 'Bạn đã nhận 50 🍬 vốn ban đầu khi tạo tài khoản FPT Market. Chúc bạn có những phán đoán chính xác!',
        type: 'claim',
        amount: 50,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      NotificationModel(
        id: 'notif_3',
        userId: 'all',
        title: '📢 Kèo Campus Đã Chốt Kết Quả',
        message: 'Kèo chung kết nghiên cứu FPT Research Festival đã được Admin công bố: CỬA CÓ CHIẾN THẮNG!',
        type: 'market_resolved',
        marketId: 'm_hackathon_done',
        amount: 0,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
    ];

    for (final n in sampleNotifications) {
      await db.insert('notifications', n.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Seed History (Bảng lịch sử chi tiết cược & biến động kẹo SQLite)
    final sampleHistory = [
      HistoryModel(
        id: 'hist_1',
        userId: 'student_1',
        userName: 'Nguyễn Văn Cóc',
        marketTitle: 'Tặng vốn tân sinh viên FPT',
        action: 'welcome_bonus',
        amount: 50,
        balanceAfter: 50,
        description: 'Tặng 50 🍬 ban đầu cho tài khoản mới',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      HistoryModel(
        id: 'hist_2',
        userId: 'student_1',
        userName: 'Nguyễn Văn Cóc',
        marketId: 'm_hackathon_done',
        marketTitle: 'FPT Research Festival 2026: Đề tài AI có đạt giải Nhất toàn quốc?',
        action: 'bet_placed',
        outcome: 'yes',
        amount: -20,
        balanceAfter: 30,
        description: 'Đặt cược 20 🍬 vào cửa CÓ',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      HistoryModel(
        id: 'hist_3',
        userId: 'student_1',
        userName: 'Nguyễn Văn Cóc',
        marketId: 'm_hackathon_done',
        marketTitle: 'FPT Research Festival 2026: Đề tài AI có đạt giải Nhất toàn quốc?',
        action: 'bet_won',
        outcome: 'yes',
        amount: 38,
        balanceAfter: 68,
        description: 'Thắng cược nhận về +38 🍬 (Lãi +18 🍬)',
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      HistoryModel(
        id: 'hist_4',
        userId: 'student_1',
        userName: 'Nguyễn Văn Cóc',
        marketId: 'm_prn231',
        marketTitle: 'Môn PRN231 kỳ này: Tỉ lệ sinh viên qua môn lần 1 có trên 85% không?',
        action: 'bet_placed',
        outcome: 'yes',
        amount: -15,
        balanceAfter: 53,
        description: 'Đặt cược 15 🍬 vào cửa CÓ',
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
      HistoryModel(
        id: 'hist_5',
        userId: 'student_1',
        userName: 'Nguyễn Văn Cóc',
        marketId: 'm_cocvang',
        marketTitle: 'Danh hiệu Cóc Vàng kỳ Spring 2026 có thuộc về sinh viên ngành SE không?',
        action: 'bet_placed',
        outcome: 'no',
        amount: -10,
        balanceAfter: 43,
        description: 'Đặt cược 10 🍬 vào cửa KHÔNG',
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
    ];

    for (final h in sampleHistory) {
      await db.insert('history', h.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Seed Config
    await db.insert('system_config', {'key': 'admin_vault_candies', 'value': '5000'});
    await db.insert('system_config', {'key': 'current_session_user_id', 'value': ''});
  }

  // --- USER OPERATIONS ---
  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'candies DESC');
    return maps.map((m) => UserModel.fromMap(m)).toList();
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateUserCandies(String userId, int newCandies) async {
    final db = await database;
    await db.update(
      'users',
      {'candies': newCandies},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> addCandies(String userId, int amount) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE users SET candies = candies + ? WHERE id = ?',
      [amount, userId],
    );
  }

  Future<void> claimDailyCandyInDb(String userId, int amount, String dateStr) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE users SET candies = candies + ?, last_daily_claim = ? WHERE id = ?',
      [amount, dateStr, userId],
    );
  }

  // --- MARKET OPERATIONS ---
  Future<List<MarketModel>> getAllMarkets() async {
    final db = await database;
    final maps = await db.query('markets', orderBy: 'created_at DESC');
    return maps.map((m) => MarketModel.fromMap(m)).toList();
  }

  Future<List<MarketModel>> searchMarkets(String query) async {
    final db = await database;
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return getAllMarkets();
    }
    final maps = await db.query(
      'markets',
      where: 'LOWER(title) LIKE ? OR LOWER(description) LIKE ?',
      whereArgs: ['%${cleanQuery.toLowerCase()}%', '%${cleanQuery.toLowerCase()}%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => MarketModel.fromMap(m)).toList();
  }

  Future<MarketModel?> getMarketById(String id) async {
    final db = await database;
    final maps = await db.query('markets', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return MarketModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertMarket(MarketModel market) async {
    final db = await database;
    await db.insert('markets', market.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateMarketPool({
    required String marketId,
    required int yesPool,
    required int noPool,
    required int yesCount,
    required int noCount,
  }) async {
    final db = await database;
    await db.update(
      'markets',
      {
        'yes_pool': yesPool,
        'no_pool': noPool,
        'yes_count': yesCount,
        'no_count': noCount,
      },
      where: 'id = ?',
      whereArgs: [marketId],
    );
  }

  Future<void> expireMarketNow(String marketId) async {
    final db = await database;
    final pastTime = DateTime.now().subtract(const Duration(seconds: 10)).toIso8601String();
    await db.update(
      'markets',
      {'end_date': pastTime},
      where: 'id = ?',
      whereArgs: [marketId],
    );
  }

  Future<void> resolveMarketInDb(String marketId, String winningOutcome) async {
    final db = await database;
    await db.update(
      'markets',
      {
        'status': MarketStatus.resolved.name,
        'winning_outcome': winningOutcome,
      },
      where: 'id = ?',
      whereArgs: [marketId],
    );
  }

  // --- BET OPERATIONS ---
  Future<List<BetModel>> getAllBets() async {
    final db = await database;
    final maps = await db.query('bets', orderBy: 'placed_at DESC');
    return maps.map((m) => BetModel.fromMap(m)).toList();
  }

  Future<List<BetModel>> getBetsByUserId(String userId) async {
    final db = await database;
    final maps = await db.query(
      'bets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'placed_at DESC',
    );
    return maps.map((m) => BetModel.fromMap(m)).toList();
  }

  Future<List<BetModel>> getBetsByMarketId(String marketId) async {
    final db = await database;
    final maps = await db.query(
      'bets',
      where: 'market_id = ?',
      whereArgs: [marketId],
      orderBy: 'placed_at DESC',
    );
    return maps.map((m) => BetModel.fromMap(m)).toList();
  }

  Future<BetModel?> getUserBetForMarket(String userId, String marketId) async {
    final db = await database;
    final maps = await db.query(
      'bets',
      where: 'user_id = ? AND market_id = ?',
      whereArgs: [userId, marketId],
      orderBy: 'placed_at DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return BetModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertBet(BetModel bet) async {
    final db = await database;
    await db.insert('bets', bet.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateBetResolution({
    required String betId,
    required BetStatus status,
    required int actualPayout,
  }) async {
    final db = await database;
    await db.update(
      'bets',
      {
        'status': status.name,
        'actual_payout': actualPayout,
      },
      where: 'id = ?',
      whereArgs: [betId],
    );
  }

  // --- NOTIFICATION OPERATIONS ---
  Future<void> insertNotification(NotificationModel notification) async {
    final db = await database;
    await db.insert('notifications', notification.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NotificationModel>> getNotificationsForUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      'notifications',
      where: 'user_id = ? OR user_id = ?',
      whereArgs: [userId, 'all'],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => NotificationModel.fromMap(m)).toList();
  }

  Future<void> deleteNotification(String notificationId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final db = await database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> clearNotificationsForUser(String userId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'user_id = ? OR user_id = ?',
      whereArgs: [userId, 'all'],
    );
  }

  // --- HISTORY OPERATIONS ---
  Future<void> insertHistory(HistoryModel history) async {
    final db = await database;
    await db.insert('history', history.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<HistoryModel>> getHistoryForUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      'history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => HistoryModel.fromMap(m)).toList();
  }

  Future<List<HistoryModel>> getAllHistory() async {
    final db = await database;
    final maps = await db.query('history', orderBy: 'created_at DESC');
    return maps.map((m) => HistoryModel.fromMap(m)).toList();
  }

  // --- SYSTEM CONFIG ---
  Future<String?> getConfig(String key) async {
    final db = await database;
    final maps = await db.query('system_config', where: 'key = ?', whereArgs: [key]);
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  Future<void> setConfig(String key, String value) async {
    final db = await database;
    await db.insert(
      'system_config',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getAdminVaultCandies() async {
    final val = await getConfig('admin_vault_candies');
    return int.tryParse(val ?? '5000') ?? 5000;
  }

  Future<void> updateAdminVaultCandies(int amount) async {
    await setConfig('admin_vault_candies', amount.toString());
  }

  // Reset database to initial seed
  Future<void> resetDatabase() async {
    final db = await database;
    await _createTables(db);
    await db.delete('history');
    await db.delete('notifications');
    await db.delete('bets');
    await db.delete('markets');
    await db.delete('users');
    await db.delete('system_config');
    await _seedDatabase(db);
  }
}
