import 'package:hive/hive.dart';

part 'result_model.g.dart';

@HiveType(typeId: 5)
class ResultModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String examId;

  @HiveField(3)
  final int totalQuestions;

  @HiveField(4)
  final int correctAnswers;

  @HiveField(5)
  final int wrongAnswers;

  @HiveField(6)
  final double scorePercent;

  @HiveField(7)
  final bool passed;

  @HiveField(8)
  final int timeUsedSeconds;

  @HiveField(9)
  final DateTime completedAt;

  @HiveField(10)
  final Map<String, String> answers; // questionId → selectedOption

  ResultModel({
    required this.id,
    required this.userId,
    required this.examId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.scorePercent,
    required this.passed,
    required this.timeUsedSeconds,
    required this.completedAt,
    required this.answers,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      examId: json['exam_id'] as String,
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      wrongAnswers: json['wrong_answers'] as int,
      scorePercent: (json['score_percent'] as num).toDouble(),
      passed: json['passed'] as bool,
      timeUsedSeconds: json['time_used_seconds'] as int,
      completedAt: DateTime.parse(json['completed_at'] as String),
      answers: Map<String, String>.from(json['answers'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'exam_id': examId,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'wrong_answers': wrongAnswers,
        'score_percent': scorePercent,
        'passed': passed,
        'time_used_seconds': timeUsedSeconds,
        'completed_at': completedAt.toIso8601String(),
        'answers': answers,
      };

  String get grade {
    if (scorePercent >= 90) return 'A+';
    if (scorePercent >= 80) return 'A';
    if (scorePercent >= 70) return 'B';
    if (scorePercent >= 60) return 'C';
    if (scorePercent >= 50) return 'D';
    return 'F';
  }
}
