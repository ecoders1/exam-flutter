import 'package:hive/hive.dart';

part 'question_model.g.dart';

@HiveType(typeId: 3)
class QuestionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String examId;

  @HiveField(2)
  final String questionText;

  @HiveField(3)
  final String optionA;

  @HiveField(4)
  final String optionB;

  @HiveField(5)
  final String optionC;

  @HiveField(6)
  final String optionD;

  @HiveField(7)
  final String correctOption; // 'A' | 'B' | 'C' | 'D'

  @HiveField(8)
  final String? explanation;

  @HiveField(9)
  final int orderIndex;

  @HiveField(10)
  final String? imageUrl;

  QuestionModel({
    required this.id,
    required this.examId,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    this.explanation,
    required this.orderIndex,
    this.imageUrl,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      questionText: json['question_text'] as String,
      optionA: json['option_a'] as String,
      optionB: json['option_b'] as String,
      optionC: json['option_c'] as String,
      optionD: json['option_d'] as String,
      correctOption: json['correct_option'] as String,
      explanation: json['explanation'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'exam_id': examId,
        'question_text': questionText,
        'option_a': optionA,
        'option_b': optionB,
        'option_c': optionC,
        'option_d': optionD,
        'correct_option': correctOption,
        'explanation': explanation,
        'order_index': orderIndex,
        'image_url': imageUrl,
      };

  String getOption(String key) {
    switch (key.toUpperCase()) {
      case 'A':
        return optionA;
      case 'B':
        return optionB;
      case 'C':
        return optionC;
      case 'D':
        return optionD;
      default:
        return '';
    }
  }

  bool isCorrect(String selected) =>
      selected.toUpperCase() == correctOption.toUpperCase();
}
