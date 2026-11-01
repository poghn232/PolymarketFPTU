import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/market_model.dart';
import '../models/bet_model.dart';

class AppService extends ChangeNotifier {
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;
  AppService._internal();

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

  // Lấy các vụ cược của user hiện tại
  List<BetModel> get myBets {
    if (_currentUser == null) return [];
    return _bets.where((b) => b.userId == _currentUser!.id).toList()
      ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
  }

  // Khởi tạo dịch vụ & tải dữ liệu lưu trữ
  Future<void> init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // 1. Tải hoặc khởi tạo danh sách Users
    final usersJson = prefs.getString('fpt_users');
    if (usersJson != null && usersJson.isNotEmpty) {
      final List<dynamic> list = json.decode(usersJson);
      _users = list.map((e) => UserModel.fromMap(e)).toList();
    } else {
      _seedDefaultUsers();
      await _saveUsers();
    }

    // 2. Tải hoặc khởi tạo Markets
    final marketsJson = prefs.getString('fpt_markets');
    if (marketsJson != null && marketsJson.isNotEmpty) {
      final List<dynamic> list = json.decode(marketsJson);
      _markets = list.map((e) => MarketModel.fromMap(e)).toList();
    } else {
      _seedDefaultMarkets();
      await _saveMarkets();
    }

    // 3. Tải Bets
    final betsJson = prefs.getString('fpt_bets');
    if (betsJson != null && betsJson.isNotEmpty) {
      final List<dynamic> list = json.decode(betsJson);
      _bets = list.map((e) => BetModel.fromMap(e)).toList();
    }

    // 4. Tải Admin Candy Vault
    _adminVaultCandies = prefs.getInt('fpt_admin_vault') ?? 5000;

    // 5. Khôi phục phiên đăng nhập (mặc định đăng nhập student mẫu để dễ test ngay)
    final currentUserId = prefs.getString('fpt_current_user_id');
    if (currentUserId != null) {
      _currentUser = _users.cast<UserModel?>().firstWhere(
            (u) => u?.id == currentUserId,
            orElse: () => null,
          );
    }
    // Nếu chưa có phiên đăng nhập, mặc định vào tài khoản sinh viên để test ngay
    _currentUser ??= _users.firstWhere((u) => u.email == 'student@fpt.edu.vn');

    _isInitialized = true;
    notifyListeners();
  }

  void _seedDefaultUsers() {
    _users = [
      // Account Admin Gốc (Theo yêu cầu người dùng)
      UserModel(
        id: 'admin_root',
        email: 'admin@fpt.edu.vn',
        fullName: 'Admin Quản Trị FPT (Cán Bộ)',
        studentCode: 'ADMIN-FPT-01',
        campus: 'ĐH FPT Hà Nội',
        role: UserRole.admin,
        candies: 10000,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      // Tài khoản sinh viên mẫu 1 (50 kẹo ban đầu)
      UserModel(
        id: 'student_1',
        email: 'student@fpt.edu.vn',
        fullName: 'Nguyễn Văn Cóc',
        studentCode: 'SE180123',
        campus: 'Hà Nội (Hòa Lạc)',
        role: UserRole.student,
        candies: 50, // Mặc định 50 kẹo
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      // Tài khoản sinh viên mẫu 2
      UserModel(
        id: 'student_2',
        email: 'linh.fpt@fe.edu.vn',
        fullName: 'Trần Mai Linh',
        studentCode: 'IA170456',
        campus: 'TP.HCM (Quận 9)',
        role: UserRole.student,
        candies: 140,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      // Tài khoản sinh viên mẫu 3
      UserModel(
        id: 'student_3',
        email: 'duc.fe@fe.edu.vn',
        fullName: 'Lê Hoàng Đức',
        studentCode: 'GD190789',
        campus: 'Đà Nẵng',
        role: UserRole.student,
        candies: 95,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  void _seedDefaultMarkets() {
    final now = DateTime.now();
    _markets = [
      MarketModel(
        id: 'm_prn231',
        title: 'Môn PRN231 kỳ này: Tỉ lệ sinh viên qua môn lần 1 có trên 85% không?',
        description: 'Dự đoán kết quả thi Final môn PRN231 (.NET Core) kỳ Spring 2026. Nếu tỉ lệ pass toàn trường >= 85% thì CÓ thắng, ngược lại KHÔNG thắng.',
        category: 'Học tập & Thi cử',
        campus: 'Toàn quốc',
        yesPool: 85,
        noPool: 45,
        adminBackstopCandies: 50,
        endDate: now.add(const Duration(days: 5)),
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
        adminBackstopCandies: 60,
        endDate: now.add(const Duration(days: 12)),
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
        adminBackstopCandies: 40,
        endDate: now.add(const Duration(days: 4)),
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
        adminBackstopCandies: 80,
        endDate: now.add(const Duration(days: 8)),
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
        adminBackstopCandies: 30,
        endDate: now.add(const Duration(days: 14)),
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
        adminBackstopCandies: 50,
        endDate: now.add(const Duration(days: 6)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  // --- LƯU TRỮ DỮ LIỆU ---
  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(_users.map((u) => u.toMap()).toList());
    await prefs.setString('fpt_users', jsonStr);
  }

  Future<void> _saveMarkets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(_markets.map((m) => m.toMap()).toList());
    await prefs.setString('fpt_markets', jsonStr);
  }

  Future<void> _saveBets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(_bets.map((b) => b.toMap()).toList());
    await prefs.setString('fpt_bets', jsonStr);
  }

  Future<void> _saveAdminVault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fpt_admin_vault', _adminVaultCandies);
  }

  // --- XÁC THỰC NGƯỜI DÙNG (AUTHENTICATION) ---
  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    
    // Kiểm tra tài khoản admin gốc
    if ((cleanEmail == 'admin@fpt.edu.vn' || cleanEmail == 'admin') &&
        (password == 'admin123' || password == 'admin')) {
      _currentUser = _users.firstWhere((u) => u.role == UserRole.admin);
      await _persistLogin();
      notifyListeners();
      return true;
    }

    // Kiểm tra tài khoản trong danh sách
    final user = _users.cast<UserModel?>().firstWhere(
          (u) => u?.email.toLowerCase() == cleanEmail,
          orElse: () => null,
        );

    if (user != null) {
      _currentUser = user;
      await _persistLogin();
      notifyListeners();
      return true;
    }

    return false;
  }

  // Đăng nhập nhanh để test
  Future<void> quickLoginAsAdmin() async {
    _currentUser = _users.firstWhere((u) => u.role == UserRole.admin);
    await _persistLogin();
    notifyListeners();
  }

  Future<void> quickLoginAsStudent() async {
    _currentUser = _users.firstWhere((u) => u.email == 'student@fpt.edu.vn');
    await _persistLogin();
    notifyListeners();
  }

  // Đăng ký tài khoản sinh viên mới (Nhận ngay 50 kẹo)
  Future<bool> register({
    required String email,
    required String fullName,
    required String studentCode,
    required String campus,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    
    // Kiểm tra trùng email
    if (_users.any((u) => u.email.toLowerCase() == cleanEmail)) {
      return false;
    }

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: cleanEmail,
      fullName: fullName.trim(),
      studentCode: studentCode.trim().toUpperCase(),
      campus: campus,
      role: UserRole.student,
      candies: 50, // Đúng yêu cầu: Mỗi người mới vào sẽ có 50 kẹo để bet
      createdAt: DateTime.now(),
    );

    _users.add(newUser);
    _currentUser = newUser;
    await _saveUsers();
    await _persistLogin();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fpt_current_user_id');
    notifyListeners();
  }

  Future<void> _persistLogin() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fpt_current_user_id', _currentUser!.id);
    }
  }

  // --- TÍNH NĂNG CƯỢC (BETTING) ---
  Future<String?> placeBet({
    required String marketId,
    required MarketOutcome outcome,
    required int amount,
  }) async {
    if (_currentUser == null) return 'Vui lòng đăng nhập để cược!';
    if (amount <= 0) return 'Số kẹo cược phải lớn hơn 0!';
    if (_currentUser!.candies < amount) {
      return 'Bạn không đủ kẹo! Hiện có: ${_currentUser!.candies} 🍬';
    }

    final marketIndex = _markets.indexWhere((m) => m.id == marketId);
    if (marketIndex == -1) return 'Kèo cược không tồn tại!';
    final market = _markets[marketIndex];

    if (!market.canBet) return 'Kèo cược này đã kết thúc hoặc bị đóng!';

    final potentialPayout = market.estimatePayout(outcome, amount);

    // 1. Trừ kẹo người chơi
    _currentUser!.candies -= amount;
    final userIndex = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (userIndex != -1) {
      _users[userIndex].candies = _currentUser!.candies;
    }

    // 2. Thêm vào pool kèo
    if (outcome == MarketOutcome.yes) {
      market.yesPool += amount;
    } else {
      market.noPool += amount;
    }

    // 3. Tạo phiếu cược
    final newBet = BetModel(
      id: 'bet_${DateTime.now().millisecondsSinceEpoch}',
      marketId: market.id,
      marketTitle: market.title,
      userId: _currentUser!.id,
      userName: _currentUser!.fullName,
      outcome: outcome,
      amount: amount,
      potentialPayout: potentialPayout,
      placedAt: DateTime.now(),
    );

    _bets.add(newBet);

    await _saveUsers();
    await _saveMarkets();
    await _saveBets();
    notifyListeners();
    return null; // Thành công
  }

  // --- TÍNH NĂNG ADMIN: TẠO VỤ BET MỚI ---
  Future<void> createMarket({
    required String title,
    required String description,
    required String category,
    required String campus,
    required DateTime endDate,
    int initialAdminBackstop = 50,
  }) async {
    if (!isAdmin) return;

    // Trừ kẹo bảo chứng từ Admin Vault (nếu cần)
    if (_adminVaultCandies >= initialAdminBackstop) {
      _adminVaultCandies -= initialAdminBackstop;
    }

    final newMarket = MarketModel(
      id: 'market_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
      category: category,
      campus: campus,
      yesPool: 0,
      noPool: 0,
      adminBackstopCandies: initialAdminBackstop,
      endDate: endDate,
      createdAt: DateTime.now(),
      createdBy: _currentUser?.fullName ?? 'Admin FPT',
    );

    _markets.insert(0, newMarket);
    await _saveMarkets();
    await _saveAdminVault();
    notifyListeners();
  }

  // --- TÍNH NĂNG ADMIN: CHỐT KÈO & TRẢ KẸO (RESOLVE BET) ---
  /// Theo logic đề bài:
  /// - Thắng thì được kẹo, thua thì mất kẹo.
  /// - Admin sẽ có lượng kẹo nhất định nếu vụ bet đó không ai chọn bên còn lại.
  Future<void> resolveMarket({
    required String marketId,
    required MarketOutcome winningOutcome,
  }) async {
    if (!isAdmin) return;

    final marketIndex = _markets.indexWhere((m) => m.id == marketId);
    if (marketIndex == -1) return;
    final market = _markets[marketIndex];

    market.status = MarketStatus.resolved;
    market.winningOutcome = winningOutcome;

    // Tìm tất cả các cược cho market này
    final marketBets = _bets.where((b) => b.marketId == marketId).toList();
    
    final winningBets = marketBets.where((b) => b.outcome == winningOutcome).toList();
    final losingBets = marketBets.where((b) => b.outcome != winningOutcome).toList();

    final totalWinningPool = winningOutcome == MarketOutcome.yes ? market.yesPool : market.noPool;
    final totalLosingPool = winningOutcome == MarketOutcome.yes ? market.noPool : market.yesPool;

    // Trường hợp 1: Không có ai cược bên thua (không ai chọn bên còn lại)
    // -> Admin bảo chứng hoặc Admin thu lại kẹo/nhận kẹo từ kèo!
    if (losingBets.isEmpty && winningBets.isNotEmpty) {
      // Vì không ai cược bên thua, người thắng nhận kẹo từ quỹ bảo chứng của Admin (Admin Backstop)
      final backstopReward = market.adminBackstopCandies;
      for (final bet in winningBets) {
        final ratio = bet.amount / (totalWinningPool > 0 ? totalWinningPool : 1);
        final profit = (backstopReward * ratio).round();
        final totalPayout = bet.amount + profit;

        bet.status = BetStatus.won;
        bet.actualPayout = totalPayout;

        _payoutUser(bet.userId, totalPayout);
      }
    } else if (winningBets.isEmpty && losingBets.isNotEmpty) {
      // Toàn bộ người chơi đều chọn bên THUA -> Admin nhận toàn bộ số kẹo cược bên thua!
      // (Đúng quy tắc: Admin có lượng kẹo nếu kèo đó không ai chọn bên thắng)
      _adminVaultCandies += totalLosingPool + market.adminBackstopCandies;
      for (final bet in losingBets) {
        bet.status = BetStatus.lost;
        bet.actualPayout = 0;
      }
    } else {
      // Trường hợp thông thường: Cả 2 bên đều có người cược
      // Toàn bộ pool bên thua + tiền bảo chứng được chia đều theo tỷ lệ cho người thắng
      final prizePool = totalLosingPool + (market.adminBackstopCandies ~/ 2);
      
      for (final bet in winningBets) {
        final share = bet.amount / (totalWinningPool > 0 ? totalWinningPool : 1);
        final bonus = (prizePool * share).round();
        final totalPayout = bet.amount + bonus;

        bet.status = BetStatus.won;
        bet.actualPayout = totalPayout;

        _payoutUser(bet.userId, totalPayout);
      }

      for (final bet in losingBets) {
        bet.status = BetStatus.lost;
        bet.actualPayout = 0;
      }

      // Phần kẹo bảo chứng còn lại hoàn về cho Admin
      _adminVaultCandies += (market.adminBackstopCandies ~/ 2);
    }

    await _saveMarkets();
    await _saveBets();
    await _saveUsers();
    await _saveAdminVault();
    notifyListeners();
  }

  void _payoutUser(String userId, int candies) {
    final uIndex = _users.indexWhere((u) => u.id == userId);
    if (uIndex != -1) {
      _users[uIndex].candies += candies;
    }
    if (_currentUser != null && _currentUser!.id == userId) {
      _currentUser!.candies += candies;
    }
  }

  // Nhận kẹo điểm danh hàng ngày (để sinh viên test không lo hết kẹo)
  Future<void> claimDailyCandy() async {
    if (_currentUser == null) return;
    _currentUser!.candies += 20;
    final idx = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (idx != -1) {
      _users[idx].candies = _currentUser!.candies;
    }
    await _saveUsers();
    notifyListeners();
  }

  // Admin tặng kẹo cho sinh viên
  Future<void> adminRewardCandies(String userId, int amount) async {
    if (!isAdmin) return;
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _users[idx].candies += amount;
      if (_currentUser?.id == userId) {
        _currentUser!.candies += amount;
      }
      await _saveUsers();
      notifyListeners();
    }
  }

  // Khôi phục lại dữ liệu mẫu gốc
  Future<void> resetToSampleData() async {
    _seedDefaultUsers();
    _seedDefaultMarkets();
    _bets = [];
    _adminVaultCandies = 5000;
    _currentUser = _users.firstWhere((u) => u.email == 'student@fpt.edu.vn');
    await _saveUsers();
    await _saveMarkets();
    await _saveBets();
    await _saveAdminVault();
    await _persistLogin();
    notifyListeners();
  }
}
