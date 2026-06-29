import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../models/result_model.dart';
import '../../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final ResultModel result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isPassed = result.passed;
    final minutes = result.timeUsedSeconds ~/ 60;
    final seconds = result.timeUsedSeconds % 60;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isPassed
                  ? AppTheme.correctGreen.withOpacity(0.15)
                  : AppTheme.wrongRed.withOpacity(0.1),
              AppTheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Score circle
                _ScoreCircle(
                  score: result.scorePercent,
                  grade: result.grade,
                  passed: isPassed,
                ).animate().scale(
                      begin: const Offset(0.4, 0.4),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 24),

                Text(
                  isPassed ? '🎉 Congratulations!' : '📚 Keep Studying!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 8),

                Text(
                  isPassed
                      ? 'You passed the exam with ${result.scorePercent.toStringAsFixed(1)}%'
                      : 'You scored ${result.scorePercent.toStringAsFixed(1)}%. Try again!',
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 14),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 32),

                // Stats grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(
                      label: 'Total Questions',
                      value: '${result.totalQuestions}',
                      icon: Icons.quiz_outlined,
                      color: AppTheme.primary,
                    ),
                    _StatCard(
                      label: 'Correct',
                      value: '${result.correctAnswers}',
                      icon: Icons.check_circle_outline,
                      color: AppTheme.correctGreen,
                    ),
                    _StatCard(
                      label: 'Wrong',
                      value: '${result.wrongAnswers}',
                      icon: Icons.cancel_outlined,
                      color: AppTheme.wrongRed,
                    ),
                    _StatCard(
                      label: 'Time Used',
                      value: '${minutes}m ${seconds}s',
                      icon: Icons.timer_outlined,
                      color: AppTheme.gold,
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 32),

                // Action buttons
                ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
                ).animate().fadeIn(delay: 1000.ms),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () => context.go('/departments'),
                  icon: const Icon(Icons.replay),
                  label: const Text('Try Another Exam'),
                ).animate().fadeIn(delay: 1100.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  final double score;
  final String grade;
  final bool passed;

  const _ScoreCircle({
    required this.score,
    required this.grade,
    required this.passed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.cardColor,
        border: Border.all(
          color: passed ? AppTheme.correctGreen : AppTheme.wrongRed,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: (passed ? AppTheme.correctGreen : AppTheme.wrongRed)
                .withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${score.toStringAsFixed(1)}%',
            style: TextStyle(
              color: passed ? AppTheme.correctGreen : AppTheme.wrongRed,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: (passed ? AppTheme.correctGreen : AppTheme.wrongRed)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              grade,
              style: TextStyle(
                color: passed ? AppTheme.correctGreen : AppTheme.wrongRed,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            passed ? 'PASSED' : 'FAILED',
            style: TextStyle(
              color: passed ? AppTheme.correctGreen : AppTheme.wrongRed,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
