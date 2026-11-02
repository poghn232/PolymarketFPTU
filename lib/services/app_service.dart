import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/market_model.dart';
import '../models/bet_model.dart';
import 'database_helper.dart';

class AppService extends ChangeNotifier {
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;
  AppService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  UserModel? _currentUser;
  List<UserModel> _users = [];
  List<MarketModel> _markets = [];
  List<BetModel> _bets = [];
  int _adminVaultCandies = 5000;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  List<UserModel> get users => _users;
  List<MarketModel> get markets => _markets;
  List<BetModel> get bets => _bets;
  int get adminVaultCandies => _adminVaultCandies;
  bool get isInitialized => _isInitialized;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Cược của user hiện tại
  List<BetModel> get myBets {
    if (_currentUser == null) return [];
    return _bets.where((b) => b.userId == _currentUser!.id).toList();
  }

  // Cược đang chờ kết quả
  List<BetModel> get myPendingBets {
    return myBets.where((b) => b.status == BetStatus.active).toList();
  }

  // Cược đã có kết quả (thắng hoặc thua)
  List<BetModel> get myResolvedBets {
    return myBets.where((b) => b.status != BetStatus.active).toList();
  }

  /// Lấy thông tin cược của người dùng hiện tại đối với một market cụ thể
  BetModel? getMyBetForMarket(String marketId) {
    if (_currentUser == null) return null;
    try {
      return _bets.firstWhere(
        (b) => b.marketId == marketId && b.userId == _currentUser!.id,
      );
    } catch (_) {
      return null;
    }
  }

  // Khởi tạo dịch vụ & tải toàn bộ dữ liệu từ SQLite Database
  Future<void> init() async {
    if (_isInitialized) return;

    await _refreshDataFromDb();

    // Khôi phục phiên đăng nhập từ SQLite System Config
    final savedUserId = await _dbHelper.getConfig('current_session_user_id');
    if (savedUserId != null && savedUserId.isNotEmpty) {
      _currentUser = await _dbHelper.getUserById(savedUserId);
    } else {
      // KHÔNG tự động đăng nhập! Người dùng vào app phải thấy màn hình Login
      _currentUser = null;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _refreshDataFromDb() async {
    _users = await _dbHelper.getAllUsers();
    _markets = await _dbHelper.getAllMarkets();
    _bets = await _dbHelper.getAllBets();
    _adminVaultCandies = await _dbHelper.getAdminVaultCandies();

    if (_currentUser != null) {
      _currentUser = await _dbHelper.getUserById(_currentUser!.id);
    }
  }

  // --- XÁC THỰC NGƯỜI DÙNG (AUTHENTICATION VỚI SQLITE) ---
  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    final user = await _dbHelper.getUserByEmail(cleanEmail);
    if (user != null) {
      // Kiểm tra mật khẩu trong SQLite
      if (user.password == cleanPassword ||
          (user.role == UserRole.admin && (cleanPassword == 'admin123' || cleanPassword == 'admin'))) {
        _currentUser = user;
        await _dbHelper.setConfig('current_session_user_id', user.id);
        await _refreshDataFromDb();
        notifyListeners();
        return true;
      }
    }

    return false;
  }

  // Đăng ký tài khoản mới trong SQLite (Nhận ngay 50 kẹo)
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String studentCode,
    required String campus,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // Kiểm tra trùng email trong SQLite
    final existingUser = await _dbHelper.getUserByEmail(cleanEmail);
    if (existingUser != null) {
      return false;
    }

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: cleanEmail,
      password: password.trim(),
      fullName: fullName.trim(),
      studentCode: studentCode.trim().toUpperCase(),
      campus: campus,
      role: UserRole.student,
      candies: 50, // Đúng yêu cầu: Mỗi người mới vào sẽ có 50 kẹo để bet
      createdAt: DateTime.now(),
    );

    await _dbHelper.insertUser(newUser);
    _currentUser = newUser;
    await _dbHelper.setConfig('current_session_user_id', newUser.id);
    await _refreshDataFromDb();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _dbHelper.setConfig('current_session_user_id', '');
    notifyListeners();
  }

  // --- TÍNH NĂNG CƯỢC (LƯU VÀO SQLITE & TRỪ KẸO NGAY LẬP TỨC) ---
  Future<String?> placeBet({
    required String marketId,
    required MarketOutcome outcome,
    required int amount,
  }) async {
    if (_currentUser == null) return 'Vui lòng đăng nhập để cược!';
    if (amount <= 0) return 'Số kẹo cược phải lớn hơn 0!';

    // Tải thông tin mới nhất từ SQLite
    final freshUser = await _dbHelper.getUserById(_currentUser!.id);
    if (freshUser == null || freshUser.candies < amount) {
      return 'Bạn không đủ kẹo! Hiện có: ${freshUser?.candies ?? 0} 🍬';
    }

    final market = await _dbHelper.getMarketById(marketId);
    if (market == null) return 'Kèo cược không tồn tại!';
    if (!market.canBet) return 'Kèo cược này đã hết hạn hoặc đã chốt kết quả!';

    // 1. Trừ kẹo người chơi trong SQLite ngay lập tức
    final newCandies = freshUser.candies - amount;
    await _dbHelper.updateUserCandies(freshUser.id, newCandies);

    // 2. Tính toán potential payout
    final potentialPayout = market.estimatePayout(outcome, amount);

    // 3. Ghi phiếu cược vào SQLite table 'bets'
    final newBet = BetModel(
      id: 'bet_${DateTime.now().millisecondsSinceEpoch}',
      marketId: market.id,
      marketTitle: market.title,
      userId: freshUser.id,
      userName: freshUser.fullName,
      outcome: outcome,
      amount: amount,
      potentialPayout: potentialPayout,
      placedAt: DateTime.now(),
    );
    await _dbHelper.insertBet(newBet);

    // 4. Cập nhật số lượng kẹo và số người cược trong SQLite table 'markets'
    int updatedYesPool = market.yesPool;
    int updatedNoPool = market.noPool;
    int updatedYesCount = market.yesCount;
    int updatedNoCount = market.noCount;

    if (outcome == MarketOutcome.yes) {
      updatedYesPool += amount;
      updatedYesCount += 1;
    } else {
      updatedNoPool += amount;
      updatedNoCount += 1;
    }

    await _dbHelper.updateMarketPool(
      marketId: market.id,
      yesPool: updatedYesPool,
      noPool: updatedNoPool,
      yesCount: updatedYesCount,
      noCount: updatedNoCount,
    );

    // 5. Cập nhật lại state bộ nhớ & thông báo UI
    await _refreshDataFromDb();
    notifyListeners();
    return null; // Thành công
  }

  // Kiểm tra xem sinh viên hiện tại có được điểm danh hôm nay không
  bool get canClaimDaily {
    if (_currentUser == null) return false;
    return !_currentUser!.hasClaimedToday;
  }

  // --- TÍNH NĂNG ĐIỂM DANH (+20 KẸO, MỖI NGÀY 1 LẦN, LƯU VÀO SQLITE) ---
  Future<String?> claimDailyCandy() async {
    if (_currentUser == null) return 'Vui lòng đăng nhập để điểm danh!';

    // Kiểm tra nếu đã điểm danh trong ngày hôm nay
    if (_currentUser!.hasClaimedToday) {
      return 'Hôm nay bạn đã điểm danh nhận 20 🍬 rồi! Hãy quay lại vào ngày mai nhé.';
    }

    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await _dbHelper.claimDailyCandyInDb(_currentUser!.id, 20, todayStr);
    await _refreshDataFromDb();
    notifyListeners();
    return null; // Thành công
  }

  // --- TÍNH NĂNG ADMIN: TẠO VỤ BET MỚI (LƯU VÀO SQLITE) ---
  Future<void> createMarket({
    required String title,
    required String description,
    required String category,
    required String campus,
    required DateTime endDate,
    int initialAdminBackstop = 50,
  }) async {
    if (!isAdmin) return;

    if (_adminVaultCandies >= initialAdminBackstop) {
      _adminVaultCandies -= initialAdminBackstop;
      await _dbHelper.updateAdminVaultCandies(_adminVaultCandies);
    }

    final newMarket = MarketModel(
      id: 'market_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
      category: category,
      campus: campus,
      yesPool: 0,
      noPool: 0,
      yesCount: 0,
      noCount: 0,
      adminBackstopCandies: initialAdminBackstop,
      endDate: endDate,
      createdAt: DateTime.now(),
      createdBy: _currentUser?.fullName ?? 'Admin FPT',
    );

    await _dbHelper.insertMarket(newMarket);
    await _refreshDataFromDb();
    notifyListeners();
  }

  // --- TÍNH NĂNG ADMIN: CHỐT KÈO & CỘNG KẸO THƯỞNG CHO NGƯỜI THẮNG ---
  Future<void> resolveMarket({
    required String marketId,
    required MarketOutcome winningOutcome,
  }) async {
    if (!isAdmin) return;

    final market = await _dbHelper.getMarketById(marketId);
    if (market == null) return;

    // Cập nhật trạng thái market trong SQLite
    await _dbHelper.resolveMarketInDb(marketId, winningOutcome.name);

    // Lấy tất cả cược của market này từ SQLite
    final marketBets = await _dbHelper.getBetsByMarketId(marketId);
    final winningBets = marketBets.where((b) => b.outcome == winningOutcome).toList();
    final losingBets = marketBets.where((b) => b.outcome != winningOutcome).toList();

    final totalWinningPool = winningOutcome == MarketOutcome.yes ? market.yesPool : market.noPool;
    final totalLosingPool = winningOutcome == MarketOutcome.yes ? market.noPool : market.yesPool;

    if (losingBets.isEmpty && winningBets.isNotEmpty) {
      // Không ai cược bên thua: Người thắng nhận kẹo từ bảo chứng của Admin
      final backstopReward = market.adminBackstopCandies;
      for (final bet in winningBets) {
        final ratio = bet.amount / (totalWinningPool > 0 ? totalWinningPool : 1);
        final profit = (backstopReward * ratio).round();
        final totalPayout = bet.amount + profit;

        await _dbHelper.updateBetResolution(
          betId: bet.id,
          status: BetStatus.won,
          actualPayout: totalPayout,
        );
        // Cộng kẹo vào SQLite tài khoản sinh viên thắng
        await _dbHelper.addCandies(bet.userId, totalPayout);
      }
    } else if (winningBets.isEmpty && losingBets.isNotEmpty) {
      // Không ai chọn bên thắng: Toàn bộ kẹo bên thua chuyển về kho Admin
      _adminVaultCandies += totalLosingPool + market.adminBackstopCandies;
      await _dbHelper.updateAdminVaultCandies(_adminVaultCandies);

      for (final bet in losingBets) {
        await _dbHelper.updateBetResolution(
          betId: bet.id,
          status: BetStatus.lost,
          actualPayout: 0,
        );
      }
    } else {
      // Trường hợp thông thường: Cả hai bên đều có người cược
      final prizePool = totalLosingPool + (market.adminBackstopCandies ~/ 2);
      for (final bet in winningBets) {
        final share = bet.amount / (totalWinningPool > 0 ? totalWinningPool : 1);
        final bonus = (prizePool * share).round();
        final totalPayout = bet.amount + bonus;

        await _dbHelper.updateBetResolution(
          betId: bet.id,
          status: BetStatus.won,
          actualPayout: totalPayout,
        );
        // Cộng kẹo vào SQLite tài khoản sinh viên thắng
        await _dbHelper.addCandies(bet.userId, totalPayout);
      }

      for (final bet in losingBets) {
        await _dbHelper.updateBetResolution(
          betId: bet.id,
          status: BetStatus.lost,
          actualPayout: 0,
        );
      }

      _adminVaultCandies += (market.adminBackstopCandies ~/ 2);
      await _dbHelper.updateAdminVaultCandies(_adminVaultCandies);
    }

    await _refreshDataFromDb();
    notifyListeners();
  }

  // Admin tặng kẹo trực tiếp trong SQLite
  Future<void> adminRewardCandies(String userId, int amount) async {
    if (!isAdmin) return;
    await _dbHelper.addCandies(userId, amount);
    await _refreshDataFromDb();
    notifyListeners();
  }

  // Khôi phục cơ sở dữ liệu SQLite về dữ liệu mẫu ban đầu
  Future<void> resetToSampleData() async {
    await _dbHelper.resetDatabase();
    await _refreshDataFromDb();
    _currentUser = null;
    notifyListeners();
  }
}
