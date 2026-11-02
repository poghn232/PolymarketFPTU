import 'dart:convert';
import 'market_model.dart';

enum BetStatus {
  active,
  won,
  lost,
  refunded,
}

class BetModel {
  final String id;
  final String marketId;
  final String marketTitle;
  final String userId;
  final String userName;
  final MarketOutcome outcome;
  final int amount; // Số kẹo đã cược
  final int potentialPayout; // Số kẹo dự kiến nhận
  BetStatus status;
  int actualPayout; // Số kẹo thực tế nhận khi chốt kèo
  final DateTime placedAt;

  BetModel({
    required this.id,
    required this.marketId,
    required this.marketTitle,
    required this.userId,
    required this.userName,
    required this.outcome,
    required this.amount,
    required this.potentialPayout,
    this.status = BetStatus.active,
    this.actualPayout = 0,
    required this.placedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'market_id': marketId,
      'market_title': marketTitle,
      'user_id': userId,
      'user_name': userName,
      'outcome': outcome.name,
      'amount': amount,
      'potential_payout': potentialPayout,
      'status': status.name,
      'actual_payout': actualPayout,
      'placed_at': placedAt.toIso8601String(),
    };
  }

  factory BetModel.fromMap(Map<String, dynamic> map) {
    final outcomeStr = map['outcome'] ?? 'yes';
    return BetModel(
      id: map['id'] ?? '',
      marketId: map['market_id'] ?? map['marketId'] ?? '',
      marketTitle: map['market_title'] ?? map['marketTitle'] ?? '',
      userId: map['user_id'] ?? map['userId'] ?? '',
      userName: map['user_name'] ?? map['userName'] ?? '',
      outcome: outcomeStr == 'yes' ? MarketOutcome.yes : MarketOutcome.no,
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      potentialPayout: (map['potential_payout'] ?? map['potentialPayout'] as num?)?.toInt() ?? 0,
      status: BetStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BetStatus.active,
      ),
      actualPayout: (map['actual_payout'] ?? map['actualPayout'] as num?)?.toInt() ?? 0,
      placedAt: (map['placed_at'] ?? map['placedAt']) != null
          ? DateTime.parse(map['placed_at'] ?? map['placedAt'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory BetModel.fromJson(String source) =>
      BetModel.fromMap(json.decode(source));
}
