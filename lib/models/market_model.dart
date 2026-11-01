import 'dart:convert';

enum MarketStatus {
  active,
  resolved,
  cancelled,
}

enum MarketOutcome {
  yes,
  no,
}

class MarketModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String campus;
  int yesPool;
  int noPool;
  int adminBackstopCandies; // Kẹo Admin bảo chứng cho kèo
  MarketStatus status;
  MarketOutcome? winningOutcome;
  final DateTime endDate;
  final DateTime createdAt;
  final String createdBy;

  MarketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.campus = 'Toàn quốc',
    this.yesPool = 0,
    this.noPool = 0,
    this.adminBackstopCandies = 50,
    this.status = MarketStatus.active,
    this.winningOutcome,
    required this.endDate,
    required this.createdAt,
    this.createdBy = 'Admin FPT',
  });

  int get totalVolume => yesPool + noPool;

  /// Tính tỉ lệ % CÓ (Polymarket style odds)
  double get yesPercentage {
    final effectiveYes = yesPool + (adminBackstopCandies / 2);
    final effectiveNo = noPool + (adminBackstopCandies / 2);
    final sum = effectiveYes + effectiveNo;
    if (sum == 0) return 50.0;
    return ((effectiveYes / sum) * 100).clamp(1.0, 99.0);
  }

  /// Tính tỉ lệ % KHÔNG
  double get noPercentage => 100.0 - yesPercentage;

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get canBet => status == MarketStatus.active && !isExpired;

  /// Ước tính số kẹo nhận được nếu cược một lượng kẹo vào một cửa
  int estimatePayout(MarketOutcome outcome, int betAmount) {
    if (betAmount <= 0) return 0;
    
    // Tổng pool kẹo bao gồm cả bảo chứng của Admin
    final totalPool = yesPool + noPool + adminBackstopCandies;
    final mySidePool = (outcome == MarketOutcome.yes ? yesPool : noPool) + betAmount;
    
    // Tỉ lệ ăn chia theo pari-mutuel pool
    if (mySidePool <= 0) return betAmount * 2;
    
    final payout = ((betAmount / mySidePool) * (totalPool + betAmount)).round();
    return payout > betAmount ? payout : (betAmount * 1.5).round();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'campus': campus,
      'yesPool': yesPool,
      'noPool': noPool,
      'adminBackstopCandies': adminBackstopCandies,
      'status': status.name,
      'winningOutcome': winningOutcome?.name,
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory MarketModel.fromMap(Map<String, dynamic> map) {
    return MarketModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Chung',
      campus: map['campus'] ?? 'Toàn quốc',
      yesPool: (map['yesPool'] as num?)?.toInt() ?? 0,
      noPool: (map['noPool'] as num?)?.toInt() ?? 0,
      adminBackstopCandies: (map['adminBackstopCandies'] as num?)?.toInt() ?? 50,
      status: MarketStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MarketStatus.active,
      ),
      winningOutcome: map['winningOutcome'] != null
          ? MarketOutcome.values.firstWhere(
              (e) => e.name == map['winningOutcome'],
              orElse: () => MarketOutcome.yes,
            )
          : null,
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'])
          : DateTime.now().add(const Duration(days: 7)),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      createdBy: map['createdBy'] ?? 'Admin FPT',
    );
  }

  String toJson() => json.encode(toMap());

  factory MarketModel.fromJson(String source) =>
      MarketModel.fromMap(json.decode(source));
}
