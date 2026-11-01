import 'dart:convert';

enum UserRole {
  student,
  admin,
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String studentCode; // MSSV ví dụ: SE180123
  final String campus;      // Hòa Lạc, TP.HCM, Đà Nẵng, Quy Nhơn, Cần Thơ
  final UserRole role;
  int candies;              // Số lượng kẹo
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentCode,
    this.campus = 'Hà Nội (Hòa Lạc)',
    this.role = UserRole.student,
    this.candies = 50, // Mặc định 50 kẹo cho người mới
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'studentCode': studentCode,
      'campus': campus,
      'role': role.name,
      'candies': candies,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      studentCode: map['studentCode'] ?? '',
      campus: map['campus'] ?? 'Hà Nội (Hòa Lạc)',
      role: map['role'] == 'admin' ? UserRole.admin : UserRole.student,
      candies: (map['candies'] as num?)?.toInt() ?? 50,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? studentCode,
    String? campus,
    UserRole? role,
    int? candies,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      studentCode: studentCode ?? this.studentCode,
      campus: campus ?? this.campus,
      role: role ?? this.role,
      candies: candies ?? this.candies,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
