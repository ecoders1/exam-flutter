import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/exam_model.dart';
import '../../models/question_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exam_provider.dart';
import '../../services/exam_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_overlay.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  final ExamModel exam;

  const QuestionScreen({super.key, required this.exam});

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  Timer? _timer;
  String? _selectedOption;
  bool _answered = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Prevent screenshots on Android (FLAG_SECURE)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(examSessionProvider.notifier).tick();

      final session = ref.read(examSessionProvider);
      if (session != null &&
          session.elapsedSeconds >=
              session.exam.durationMinutes * 60) {
        _finishExam();
      }
    });
  }

  void _selectOption(String option) {
    if (_answered) return;
    setState(() {
      _selectedOption = option;
      _answered = true;
    });
    ref
        .read(examSessionProvider.notifier)
        .answerQuestion(
          ref.read(examSessionProvider)!.currentQuestion.id,
          option,
        );
  }

  void _next() {
    final session = ref.read(examSessionProvider);
    if (session == null) return;

    if (session.hasNext) {
      ref.read(examSessionProvider.notifier).nextQuestion();
      setState(() {
        _selectedOption = null;
        _answered = false;
      });
    } else {
      _finishExam();
    }
  }

  Future<void> _finishExam() async {
    _timer?.cancel();
    final session = ref.read(examSessionProvider);
    if (session == null) return;

    ref.read(examSessionProvider.notifier).finishExam();
    setState(() => _saving = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        int correct = 0;
        for (final q in session.questions) {
          final ans = session.answers[q.id];
          if (ans != null && q.isCorrect(ans)) correct++;
        }

        final result = await ExamService.instance.saveResult(
          userId: user.id,
          examId: session.exam.id,
          totalQuestions: session.questions.length,
          correctAnswers: correct,
          timeUsedSeconds: session.elapsedSeconds,
          answers: session.answers,
          passMarkPercent: session.exam.passMarkPercent,
        );

        if (mounted) {
          setState(() => _saving = false);
          context.pushReplacement('/result', extra: result);
        }
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving result: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _optionColor(QuestionModel q, String option) {
    if (!_answered) return AppTheme.cardColor;
    if (option == q.correctOption) return AppTheme.correctGreen.withOpacity(0.25);
    if (option == _selectedOption) return AppTheme.wrongRed.withOpacity(0.25);
    return AppTheme.cardColor;
  }

  Color _optionBorder(QuestionModel q, String option) {
    if (!_answered) {
      return _selectedOption == option ? AppTheme.primary : Colors.white12;
    }
    if (option == q.correctOption) return AppTheme.correctGreen;
    if (option == _selectedOption) return AppTheme.wrongRed;
    return Colors.white12;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(examSessionProvider);

    if (session == null || _saving) {
      return LoadingOverlay(
        isLoading: true,
        child: Scaffold(
          appBar: AppBar(title: Text(widget.exam.title)),
          body: const SizedBox(),
        ),
      );
    }

    final q = session.currentQuestion;
    final remaining =
        (session.exam.durationMinutes * 60) - session.elapsedSeconds;
    final isTimeLow = remaining < 60;

    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: const Text('Quit Exam?', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Your progress will be saved. You can continue later.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Quit', style: TextStyle(color: AppTheme.wrongRed)),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: AppTheme.surface,
                child: Row(
                  children: [
                    // Progress
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q ${session.currentIndex + 1} of ${session.questions.length}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: session.progressPercent,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation(
                                  AppTheme.primary),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isTimeLow
                            ? AppTheme.wrongRed.withOpacity(0.2)
                            : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isTimeLow
                              ? AppTheme.wrongRed
                              : Colors.white12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            color: isTimeLow
                                ? AppTheme.wrongRed
                                : Colors.white54,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(remaining.clamp(0, 99999)),
                            style: TextStyle(
                              color: isTimeLow
                                  ? AppTheme.wrongRed
                                  : Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Question + Options
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question text
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: SelectionArea(
                          child: Text(
                            q.questionText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ).animate().fadeIn().slideY(begin: -0.1),

                      const SizedBox(height: 20),

                      // Options
                      ...['A', 'B', 'C', 'D'].map((opt) {
                        final text = q.getOption(opt);
                        return _OptionTile(
                          option: opt,
                          text: text,
                          bgColor: _optionColor(q, opt),
                          borderColor: _optionBorder(q, opt),
                          isCorrect: _answered && opt == q.correctOption,
                          isWrong: _answered &&
                              opt == _selectedOption &&
                              opt != q.correctOption,
                          onTap: () => _selectOption(opt),
                        ).animate().fadeIn(
                              delay: Duration(
                                  milliseconds:
                                      ['A', 'B', 'C', 'D'].indexOf(opt) * 60),
                            );
                      }),

                      // Explanation
                      if (_answered && q.explanation != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.secondary.withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.lightbulb_outline,
                                      color: AppTheme.gold, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Explanation',
                                    style: TextStyle(
                                        color: AppTheme.gold,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                q.explanation!,
                                style: const TextStyle(
                                    color: Colors.white70, height: 1.5),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().slideY(begin: 0.1),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Bottom navigation
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                color: AppTheme.surface,
                child: Row(
                  children: [
                    if (session.hasPrev)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref
                                .read(examSessionProvider.notifier)
                                .prevQuestion();
                            setState(() {
                              _selectedOption = null;
                              _answered = false;
                            });
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                          ),
                        ),
                      ),
                    if (session.hasPrev) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _answered ? _next : null,
                        icon: Icon(session.hasNext
                            ? Icons.arrow_forward
                            : Icons.done_all),
                        label: Text(session.hasNext ? 'Next' : 'Finish Exam'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          backgroundColor: session.hasNext
                              ? AppTheme.primary
                              : AppTheme.correctGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final String text;
  final Color bgColor;
  final Color borderColor;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.text,
    required this.bgColor,
    required this.borderColor,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCorrect
                    ? AppTheme.correctGreen
                    : isWrong
                        ? AppTheme.wrongRed
                        : borderColor.withOpacity(0.2),
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: isCorrect
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : isWrong
                        ? const Icon(Icons.close, color: Colors.white, size: 16)
                        : Text(
                            option,
                            style: TextStyle(
                              color: borderColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isCorrect
                      ? AppTheme.correctGreen
                      : isWrong
                          ? AppTheme.wrongRed
                          : Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
