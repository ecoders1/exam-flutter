import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/department_model.dart';
import '../../models/exam_model.dart';
import '../../providers/exam_provider.dart';
import '../../theme/app_theme.dart';

class ExamListScreen extends ConsumerWidget {
  final DepartmentModel department;

  const ExamListScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(examsProvider(department.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${department.year} — ${department.name}'),
      ),
      body: examsAsync.when(
        data: (exams) => exams.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_outlined, color: Colors.white24, size: 80),
                    SizedBox(height: 16),
                    Text(
                      'No exams available yet',
                      style: TextStyle(color: Colors.white38, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Check back soon',
                      style: TextStyle(color: Colors.white24),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: exams.length,
                itemBuilder: (_, i) => _ExamCard(exam: exams[i])
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: i * 80))
                    .slideX(begin: -0.1),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white38, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Using offline data',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(examsProvider(department.id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamCard extends ConsumerWidget {
  final ExamModel exam;

  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/question/${exam.id}', extra: exam),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'MCQ',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white38,
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                exam.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (exam.description != null) ...[
                const SizedBox(height: 6),
                Text(
                  exam.description!,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.quiz_outlined,
                    label: '${exam.questionCount} questions',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label: '${exam.durationMinutes} min',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.percent,
                    label: '${exam.passMarkPercent.toInt()}% to pass',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }
}
