import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/exam_model.dart';
import '../../services/exam_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_overlay.dart';

final _allExamsProvider = FutureProvider<List<ExamModel>>((ref) async {
  return ExamService.instance.fetchAllExams();
});

class AdminExamsScreen extends ConsumerWidget {
  const AdminExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(_allExamsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Exams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/upload'),
            tooltip: 'Upload & Generate',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_allExamsProvider),
          ),
        ],
      ),
      body: examsAsync.when(
        data: (exams) => exams.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.quiz_outlined,
                        color: Colors.white24, size: 80),
                    const SizedBox(height: 16),
                    const Text('No exams yet',
                        style: TextStyle(color: Colors.white54, fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/admin/upload'),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload & Generate'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: exams.length,
                itemBuilder: (_, i) => _ExamAdminCard(
                  exam: exams[i],
                  onChanged: () => ref.invalidate(_allExamsProvider),
                ).animate().fadeIn(delay: Duration(milliseconds: i * 60)),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ExamAdminCard extends StatefulWidget {
  final ExamModel exam;
  final VoidCallback onChanged;

  const _ExamAdminCard({required this.exam, required this.onChanged});

  @override
  State<_ExamAdminCard> createState() => _ExamAdminCardState();
}

class _ExamAdminCardState extends State<_ExamAdminCard> {
  bool _loading = false;

  Future<void> _togglePublish() async {
    setState(() => _loading = true);
    try {
      await ExamService.instance.togglePublish(
        widget.exam.id,
        !widget.exam.isPublished,
      );
      widget.onChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Delete Exam?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${widget.exam.title}" and all its questions?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.wrongRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      await ExamService.instance.deleteExam(widget.exam.id);
      widget.onChanged();
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exam;
    return LoadingOverlay(
      isLoading: _loading,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: e.isPublished
                ? AppTheme.correctGreen.withOpacity(0.3)
                : Colors.white12,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    e.title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                _StatusBadge(published: e.isPublished),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${e.questionCount} questions • ${e.durationMinutes} min • ${e.passMarkPercent.toInt()}% pass',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _togglePublish,
                    icon: Icon(
                      e.isPublished ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(e.isPublished ? 'Unpublish' : 'Publish'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      foregroundColor: e.isPublished
                          ? Colors.orange
                          : AppTheme.correctGreen,
                      side: BorderSide(
                        color: e.isPublished
                            ? Colors.orange
                            : AppTheme.correctGreen,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.wrongRed, size: 20),
                  onPressed: _delete,
                  tooltip: 'Delete exam',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool published;

  const _StatusBadge({required this.published});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: published
            ? AppTheme.correctGreen.withOpacity(0.1)
            : Colors.white12,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        published ? 'Published' : 'Draft',
        style: TextStyle(
          color: published ? AppTheme.correctGreen : Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
