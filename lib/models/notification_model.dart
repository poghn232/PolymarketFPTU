import 'dart:convert';

class NotificationModel {
  final String id;
  final String userId; // ID của user nhận thông báo, hoặc 'all' cho toàn campus
  final String title;
  final String message;
  final String type;   // 'win', 'loss', 'market_resolved', 'claim', 'system'
  final String? marketId;
  final int amount;    // Số kẹo liên quan (ví dụ +38 hoặc -15)
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.marketId,
    this.amount = 0,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'market_id': marketId,
      'amount': amount,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'system',
      marketId: map['market_id'] ?? map['marketId'],
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      isRead: (map['is_read'] ?? map['isRead']) == 1 || (map['is_read'] ?? map['isRead']) == true,
      createdAt: (map['created_at'] ?? map['createdAt']) != null
          ? DateTime.parse(map['created_at'] ?? map['createdAt'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source));
}
