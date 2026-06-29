import 'package:hive/hive.dart';

part 'payment_model.g.dart';

enum PaymentStatus { pending, approved, rejected }

@HiveType(typeId: 4)
class PaymentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String departmentId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String method; // 'CBE' | 'Telebirr' | 'CBEBirr'

  @HiveField(5)
  final String? screenshotUrl;

  @HiveField(6)
  final String statusString; // store enum as string for Hive

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? approvedAt;

  @HiveField(9)
  final String? adminNote;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.departmentId,
    required this.amount,
    required this.method,
    this.screenshotUrl,
    required this.statusString,
    required this.createdAt,
    this.approvedAt,
    this.adminNote,
  });

  PaymentStatus get status => PaymentStatus.values.firstWhere(
        (e) => e.name == statusString,
        orElse: () => PaymentStatus.pending,
      );

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      departmentId: json['department_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      screenshotUrl: json['screenshot_url'] as String?,
      statusString: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      adminNote: json['admin_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'department_id': departmentId,
        'amount': amount,
        'method': method,
        'screenshot_url': screenshotUrl,
        'status': statusString,
        'created_at': createdAt.toIso8601String(),
        'approved_at': approvedAt?.toIso8601String(),
        'admin_note': adminNote,
      };
}
