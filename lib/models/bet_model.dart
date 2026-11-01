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
      'marketId': marketId,
      'marketTitle': marketTitle,
      'userId': userId,
      'userName': userName,
      'outcome': outcome.name,
      'amount': amount,
      'potentialPayout': potentialPayout,
      'status': status.name,
      'actualPayout': actualPayout,
      'placedAt': placedAt.toIso8601String(),
    };
  }

  factory BetModel.fromMap(Map<String, dynamic> map) {
    return BetModel(
      id: map['id'] ?? '',
      marketId: map['marketId'] ?? '',
      marketTitle: map['marketTitle'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      outcome: map['outcome'] == 'yes' ? MarketOutcome.yes : MarketOutcome.no,
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      potentialPayout: (map['potentialPayout'] as num?)?.toInt() ?? 0,
      status: BetStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BetStatus.active,
      ),
      actualPayout: (map['actualPayout'] as num?)?.toInt() ?? 0,
      placedAt: map['placedAt'] != null
          ? DateTime.parse(map['placedAt'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory BetModel.fromJson(String source) =>
      BetModel.fromMap(json.decode(source));
}
