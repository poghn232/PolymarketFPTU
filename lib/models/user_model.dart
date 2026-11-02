import 'dart:convert';

enum UserRole {
  student,
  admin,
}

class UserModel {
  final String id;
  final String email;
  final String password;
  final String fullName;
  final String studentCode; // MSSV ví dụ: SE180123
  final String campus;      // Hòa Lạc, TP.HCM, Đà Nẵng, Quy Nhơn, Cần Thơ
  final UserRole role;
  int candies;              // Số lượng kẹo
  final String? lastDailyClaim;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.password = '123456',
    required this.fullName,
    required this.studentCode,
    this.campus = 'Hà Nội (Hòa Lạc)',
    this.role = UserRole.student,
    this.candies = 50, // Mặc định 50 kẹo cho người mới
    this.lastDailyClaim,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  /// Kiểm tra xem sinh viên đã điểm danh nhận kẹo hôm nay chưa
  bool get hasClaimedToday {
    if (lastDailyClaim == null || lastDailyClaim!.isEmpty) return false;
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastDailyClaim == todayStr;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'full_name': fullName,
      'student_code': studentCode,
      'campus': campus,
      'role': role.name,
      'candies': candies,
      'last_daily_claim': lastDailyClaim,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '123456',
      fullName: map['full_name'] ?? map['fullName'] ?? '',
      studentCode: map['student_code'] ?? map['studentCode'] ?? '',
      campus: map['campus'] ?? 'Hà Nội (Hòa Lạc)',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.student,
      candies: (map['candies'] as num?)?.toInt() ?? 50,
      lastDailyClaim: map['last_daily_claim'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : (map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now()),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({
    String? id,
    String? email,
    String? password,
    String? fullName,
    String? studentCode,
    String? campus,
    UserRole? role,
    int? candies,
    String? lastDailyClaim,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      studentCode: studentCode ?? this.studentCode,
      campus: campus ?? this.campus,
      role: role ?? this.role,
      candies: candies ?? this.candies,
      lastDailyClaim: lastDailyClaim ?? this.lastDailyClaim,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
