import 'package:hive/hive.dart';

part 'exam_model.g.dart';

@HiveType(typeId: 2)
class ExamModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String departmentId;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final int questionCount;

  @HiveField(5)
  final int durationMinutes;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final String? sourceFileUrl;

  @HiveField(8)
  final String? sourceFileType;

  @HiveField(9)
  final bool isPublished;

  @HiveField(10)
  final double passMarkPercent;

  ExamModel({
    required this.id,
    required this.title,
    required this.departmentId,
    this.description,
    required this.questionCount,
    this.durationMinutes = 60,
    required this.createdAt,
    this.sourceFileUrl,
    this.sourceFileType,
    this.isPublished = false,
    this.passMarkPercent = 50.0,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as String,
      title: json['title'] as String,
      departmentId: json['department_id'] as String,
      description: json['description'] as String?,
      questionCount: json['question_count'] as int? ?? 0,
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      createdAt: DateTime.parse(json['created_at'] as String),
      sourceFileUrl: json['source_file_url'] as String?,
      sourceFileType: json['source_file_type'] as String?,
      isPublished: json['is_published'] as bool? ?? false,
      passMarkPercent: (json['pass_mark_percent'] as num?)?.toDouble() ?? 50.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'department_id': departmentId,
        'description': description,
        'question_count': questionCount,
        'duration_minutes': durationMinutes,
        'created_at': createdAt.toIso8601String(),
        'source_file_url': sourceFileUrl,
        'source_file_type': sourceFileType,
        'is_published': isPublished,
        'pass_mark_percent': passMarkPercent,
      };
}
