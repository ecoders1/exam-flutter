import 'package:flutter/material.dart';
import '../../models/result_model.dart';
import '../../theme/app_theme.dart';

class ExamResultTile extends StatelessWidget {
  final ResultModel result;

  const ExamResultTile({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.passed
              ? AppTheme.correctGreen.withOpacity(0.2)
              : AppTheme.wrongRed.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (result.passed ? AppTheme.correctGreen : AppTheme.wrongRed)
                  .withOpacity(0.1),
              border: Border.all(
                color: result.passed
                    ? AppTheme.correctGreen
                    : AppTheme.wrongRed,
              ),
            ),
            child: Center(
              child: Text(
                result.grade,
                style: TextStyle(
                  color:
                      result.passed ? AppTheme.correctGreen : AppTheme.wrongRed,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.scorePercent.toStringAsFixed(1)}% — ${result.passed ? "Passed" : "Failed"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${result.correctAnswers}/${result.totalQuestions} correct',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(result.completedAt),
            style: const TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
