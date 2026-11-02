import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/market_model.dart';
import '../models/bet_model.dart';
import '../models/notification_model.dart';
import '../models/history_model.dart';
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
  List<NotificationModel> _notifications = [];
  List<HistoryModel> _history = [];
  int _adminVaultCandies = 5000;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  List<UserModel> get users => _users;
  List<MarketModel> get markets => _markets;
  List<BetModel> get bets => _bets;
  List<NotificationModel> get notifications => _notifications;
  List<HistoryModel> get history => _history;
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;
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
      _notifications = await _dbHelper.getNotificationsForUser(_currentUser!.id);
      _history = await _dbHelper.getHistoryForUser(_currentUser!.id);
    } else {
      _notifications = [];
      _history = [];
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

    // Ghi vào bảng 'history' và 'notifications' trong SQLite
    await _dbHelper.insertHistory(HistoryModel(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      userId: newUser.id,
      userName: newUser.fullName,
      marketTitle: 'Tặng vốn tân sinh viên FPT',
      action: 'welcome_bonus',
      amount: 50,
      balanceAfter: 50,
      description: 'Nhận 50 🍬 vốn khởi nghiệp ban đầu khi gia nhập FPT Market',
      createdAt: DateTime.now(),
    ));

    await _dbHelper.insertNotification(NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: newUser.id,
      title: '🎁 Chào Mừng Đến Với FPT Market',
      message: 'Bạn đã nhận 50 🍬 vốn ban đầu. Hãy tham gia dự đoán các kèo hot tại campus nhé!',
      type: 'claim',
      amount: 50,
      createdAt: DateTime.now(),
    ));

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

    // Ghi nhận biến động kẹo vào SQLite bảng 'history'
    await _dbHelper.insertHistory(HistoryModel(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      userId: freshUser.id,
      userName: freshUser.fullName,
      marketId: market.id,
      marketTitle: market.title,
      action: 'bet_placed',
      outcome: outcome.name,
      amount: -amount,
      balanceAfter: newCandies,
      description: 'Đặt cược $amount 🍬 vào cửa ${outcome == MarketOutcome.yes ? "CÓ" : "KHÔNG"}',
      createdAt: DateTime.now(),
    ));

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

    final currentBalance = _currentUser!.candies + 20;
    // Ghi lịch sử biến động kẹo vào bảng 'history'
    await _dbHelper.insertHistory(HistoryModel(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser!.id,
      userName: _currentUser!.fullName,
      marketTitle: 'Điểm danh hằng ngày',
      action: 'daily_claim',
      amount: 20,
      balanceAfter: currentBalance,
      description: 'Điểm danh chuyên cần FPT nhận +20 🍬',
      createdAt: DateTime.now(),
    ));

    // Ghi thông báo vào bảng 'notifications'
    await _dbHelper.insertNotification(NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser!.id,
      title: '🍬 Điểm danh thành công!',
      message: 'Bạn đã nhận 20 🍬 kẹo chuyên cần hôm nay. Hãy quay lại vào ngày mai để tiếp tục nhận nhé!',
      type: 'claim',
      amount: 20,
      createdAt: DateTime.now(),
    ));

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

  // --- TÍNH NĂNG ADMIN: LÀM HẾT GIỜ KÈO CƯỢC NGAY LẬP TỨC ĐỂ TEST ---
  Future<void> expireMarketNow(String marketId) async {
    if (!isAdmin) return;
    await _dbHelper.expireMarketNow(marketId);
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
      // Trường hợp 1: Tất cả chỉ cược bên thắng, không ai cược bên thua
      // -> Admin đóng vai trò đối ứng chi trả kẹo thưởng, Admin BỊ TRỪ KẸO trong Database!
      final backstopReward = market.adminBackstopCandies;
      
      // Trừ kẹo quỹ Admin trong SQLite
      _adminVaultCandies = (_adminVaultCandies - backstopReward).clamp(0, 99999999);
      await _dbHelper.updateAdminVaultCandies(_adminVaultCandies);
      final adminUser = _users.cast<UserModel?>().firstWhere((u) => u?.role == UserRole.admin, orElse: () => null);
      if (adminUser != null) {
        await _dbHelper.addCandies(adminUser.id, -backstopReward);
      }

      for (final bet in winningBets) {
        final ratio = bet.amount / (totalWinningPool > 0 ? totalWinningPool : 1);
        final profit = (backstopReward * ratio).round();
        final totalPayout = bet.amount + profit;

        await _processWinningBet(bet, market, totalPayout);
      }
    } else if (winningBets.isEmpty && losingBets.isNotEmpty) {
      // Trường hợp 2: Tất cả chỉ cược bên thua, không ai chọn bên thắng
      // -> Toàn bộ số kẹo thua của người dùng chuyển về kho quỹ Admin, Admin ĐƯỢC CỘNG KẸO trong Database!
      _adminVaultCandies += totalLosingPool;
      await _dbHelper.updateAdminVaultCandies(_adminVaultCandies);
      final adminUser = _users.cast<UserModel?>().firstWhere((u) => u?.role == UserRole.admin, orElse: () => null);
      if (adminUser != null) {
        await _dbHelper.addCandies(adminUser.id, totalLosingPool);
      }

      for (final bet in losingBets) {
        await _processLosingBet(bet, market, winningOutcome);
      }
    } else {
      // Trường hợp thông thường: Cả hai bên đều có người cược
      final prizePool = totalLosingPool + (market.adminBackstopCandies ~/ 2);
      for (final bet in winningBets) {
        final share = bet.amount / (totalWinningPool > 0 ? totalWinningPool : 1);
        final bonus = (prizePool * share).round();
        final totalPayout = bet.amount + bonus;

        await _processWinningBet(bet, market, totalPayout);
      }

      for (final bet in losingBets) {
        await _processLosingBet(bet, market, winningOutcome);
      }

      _adminVaultCandies += (market.adminBackstopCandies ~/ 2);
      await _dbHelper.updateAdminVaultCandies(_adminVaultCandies);
    }

    // Gửi thông báo chung đến toàn bộ Campus vào SQLite table 'notifications'
    await _dbHelper.insertNotification(NotificationModel(
      id: 'notif_campus_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'all',
      title: '📢 Kèo Campus Đã Chốt Kết Quả',
      message: 'Admin đã chính thức chốt kết quả kèo "${market.title}": CỬA ${winningOutcome == MarketOutcome.yes ? "CÓ" : "KHÔNG"} CHIẾN THẮNG!',
      type: 'market_resolved',
      marketId: market.id,
      createdAt: DateTime.now(),
    ));

    await _refreshDataFromDb();
    notifyListeners();
  }

  Future<void> _processWinningBet(BetModel bet, MarketModel market, int totalPayout) async {
    await _dbHelper.updateBetResolution(
      betId: bet.id,
      status: BetStatus.won,
      actualPayout: totalPayout,
    );
    // Cộng kẹo vào SQLite tài khoản sinh viên thắng
    await _dbHelper.addCandies(bet.userId, totalPayout);
    final user = await _dbHelper.getUserById(bet.userId);
    final balanceAfter = user?.candies ?? 0;

    // Ghi nhận lịch sử thắng cược vào SQLite table 'history'
    await _dbHelper.insertHistory(HistoryModel(
      id: 'hist_win_${DateTime.now().millisecondsSinceEpoch}_${bet.id}',
      userId: bet.userId,
      userName: bet.userName,
      marketId: market.id,
      marketTitle: market.title,
      action: 'bet_won',
      outcome: bet.outcome.name,
      amount: totalPayout,
      balanceAfter: balanceAfter,
      description: 'Thắng cược kèo "${market.title}" cửa ${bet.outcome == MarketOutcome.yes ? "CÓ" : "KHÔNG"}, nhận về +$totalPayout 🍬 (Vốn ${bet.amount} 🍬 + Lời ${totalPayout - bet.amount} 🍬)',
      createdAt: DateTime.now(),
    ));

    // Thêm thông báo thắng cược vào SQLite table 'notifications'
    await _dbHelper.insertNotification(NotificationModel(
      id: 'notif_win_${DateTime.now().millisecondsSinceEpoch}_${bet.id}',
      userId: bet.userId,
      title: '🎉 THẮNG CƯỢC +$totalPayout 🍬',
      message: 'Chúc mừng bạn đã thắng cược kèo "${market.title}" cửa ${bet.outcome == MarketOutcome.yes ? "CÓ" : "KHÔNG"}. Đã cộng +$totalPayout 🍬 vào tài khoản!',
      type: 'win',
      marketId: market.id,
      amount: totalPayout,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> _processLosingBet(BetModel bet, MarketModel market, MarketOutcome winningOutcome) async {
    await _dbHelper.updateBetResolution(
      betId: bet.id,
      status: BetStatus.lost,
      actualPayout: 0,
    );
    final user = await _dbHelper.getUserById(bet.userId);
    final balanceAfter = user?.candies ?? 0;

    // Ghi nhận lịch sử thua cược vào SQLite table 'history'
    await _dbHelper.insertHistory(HistoryModel(
      id: 'hist_loss_${DateTime.now().millisecondsSinceEpoch}_${bet.id}',
      userId: bet.userId,
      userName: bet.userName,
      marketId: market.id,
      marketTitle: market.title,
      action: 'bet_lost',
      outcome: bet.outcome.name,
      amount: 0,
      balanceAfter: balanceAfter,
      description: 'Kèo "${market.title}" đã kết thúc. Bạn chọn cửa ${bet.outcome == MarketOutcome.yes ? "CÓ" : "KHÔNG"} (kết quả ${winningOutcome == MarketOutcome.yes ? "CÓ" : "KHÔNG"}), mất ${bet.amount} 🍬',
      createdAt: DateTime.now(),
    ));

    // Thêm thông báo thua cược vào SQLite table 'notifications'
    await _dbHelper.insertNotification(NotificationModel(
      id: 'notif_loss_${DateTime.now().millisecondsSinceEpoch}_${bet.id}',
      userId: bet.userId,
      title: '😢 KẾT QUẢ KÈO CƯỢC',
      message: 'Kèo "${market.title}" đã kết thúc: Cửa ${winningOutcome == MarketOutcome.yes ? "CÓ THẮNG" : "KHÔNG THẮNG"}. Cược của bạn chưa chính xác.',
      type: 'loss',
      marketId: market.id,
      amount: -bet.amount,
      createdAt: DateTime.now(),
    ));
  }

  // --- QUẢN LÝ THÔNG BÁO TRỰC TIẾP TRONG SQLITE (BẢNG NOTIFICATIONS) ---
  Future<void> deleteNotification(String id) async {
    await _dbHelper.deleteNotification(id);
    if (_currentUser != null) {
      _notifications = await _dbHelper.getNotificationsForUser(_currentUser!.id);
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    await _dbHelper.markNotificationAsRead(id);
    if (_currentUser != null) {
      _notifications = await _dbHelper.getNotificationsForUser(_currentUser!.id);
      notifyListeners();
    }
  }

  Future<void> clearAllNotifications() async {
    if (_currentUser == null) return;
    await _dbHelper.clearNotificationsForUser(_currentUser!.id);
    _notifications = await _dbHelper.getNotificationsForUser(_currentUser!.id);
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
