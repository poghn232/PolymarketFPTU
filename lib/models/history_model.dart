import 'dart:convert';

class HistoryModel {
  final String id;
  final String userId;
  final String userName;
  final String? marketId;
  final String marketTitle;
  final String action; // 'bet_placed', 'bet_won', 'bet_lost', 'daily_claim', 'admin_reward'
  final String? outcome; // 'yes', 'no'
  final int amount; // Biến động số kẹo: âm nếu cược, dương nếu thắng/điểm danh
  final int balanceAfter; // Số dư kẹo sau khi giao dịch
  final String description;
  final DateTime createdAt;

  HistoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.marketId,
    required this.marketTitle,
    required this.action,
    this.outcome,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'market_id': marketId,
      'market_title': marketTitle,
      'action': action,
      'outcome': outcome,
      'amount': amount,
      'balance_after': balanceAfter,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? map['userId'] ?? '',
      userName: map['user_name'] ?? map['userName'] ?? '',
      marketId: map['market_id'] ?? map['marketId'],
      marketTitle: map['market_title'] ?? map['marketTitle'] ?? '',
      action: map['action'] ?? '',
      outcome: map['outcome'],
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      balanceAfter: (map['balance_after'] ?? map['balanceAfter'] as num?)?.toInt() ?? 0,
      description: map['description'] ?? '',
      createdAt: (map['created_at'] ?? map['createdAt']) != null
          ? DateTime.parse(map['created_at'] ?? map['createdAt'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoryModel.fromJson(String source) =>
      HistoryModel.fromMap(json.decode(source));
}
