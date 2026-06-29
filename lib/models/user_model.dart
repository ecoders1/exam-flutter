import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? avatarUrl;

  @HiveField(4)
  final bool isAdmin;

  @HiveField(5)
  final String? deviceId;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final List<String> unlockedDepartments;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.isAdmin = false,
    this.deviceId,
    required this.createdAt,
    this.unlockedDepartments = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      deviceId: json['device_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      unlockedDepartments: List<String>.from(json['unlocked_departments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'avatar_url': avatarUrl,
        'is_admin': isAdmin,
        'device_id': deviceId,
        'created_at': createdAt.toIso8601String(),
        'unlocked_departments': unlockedDepartments,
      };

  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    bool? isAdmin,
    String? deviceId,
    List<String>? unlockedDepartments,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt,
      unlockedDepartments: unlockedDepartments ?? this.unlockedDepartments,
    );
  }
}
