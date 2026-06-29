import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exam_model.dart';
import '../models/question_model.dart';
import '../models/result_model.dart';
import '../services/exam_service.dart';
import '../services/offline_service.dart';
import 'auth_provider.dart';

// ── Exams per department ───────────────────────────────────────────────────
final examsProvider =
    FutureProvider.family<List<ExamModel>, String>((ref, departmentId) async {
  try {
    final exams = await ExamService.instance.fetchExams(departmentId);
    await OfflineService.instance.cacheExams(departmentId, exams);
    return exams;
  } catch (_) {
    return OfflineService.instance.getCachedExams(departmentId);
  }
});

// ── Questions per exam ─────────────────────────────────────────────────────
final questionsProvider =
    FutureProvider.family<List<QuestionModel>, String>((ref, examId) async {
  try {
    final questions = await ExamService.instance.fetchQuestions(examId);
    await OfflineService.instance.cacheQuestions(examId, questions);
    return questions;
  } catch (_) {
    return OfflineService.instance.getCachedQuestions(examId);
  }
});

// ── Active exam session ────────────────────────────────────────────────────
class ExamSessionState {
  final ExamModel exam;
  final List<QuestionModel> questions;
  final int currentIndex;
  final Map<String, String> answers;
  final int elapsedSeconds;
  final bool isFinished;

  const ExamSessionState({
    required this.exam,
    required this.questions,
    this.currentIndex = 0,
    this.answers = const {},
    this.elapsedSeconds = 0,
    this.isFinished = false,
  });

  ExamSessionState copyWith({
    int? currentIndex,
    Map<String, String>? answers,
    int? elapsedSeconds,
    bool? isFinished,
  }) {
    return ExamSessionState(
      exam: exam,
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  QuestionModel get currentQuestion => questions[currentIndex];
  bool get hasNext => currentIndex < questions.length - 1;
  bool get hasPrev => currentIndex > 0;
  double get progressPercent =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;
  int get answeredCount => answers.length;
}

class ExamSessionNotifier extends StateNotifier<ExamSessionState?> {
  ExamSessionNotifier() : super(null);

  void startExam(ExamModel exam, List<QuestionModel> questions) {
    // Restore saved progress if any
    final saved = OfflineService.instance.getProgress(exam.id);
    if (saved != null) {
      state = ExamSessionState(
        exam: exam,
        questions: questions,
        currentIndex: saved['current_index'] as int? ?? 0,
        answers: Map<String, String>.from(saved['answers'] as Map? ?? {}),
        elapsedSeconds: saved['elapsed_seconds'] as int? ?? 0,
      );
    } else {
      state = ExamSessionState(exam: exam, questions: questions);
    }
  }

  void answerQuestion(String questionId, String option) {
    if (state == null) return;
    final updated = Map<String, String>.from(state!.answers);
    updated[questionId] = option;
    state = state!.copyWith(answers: updated);
    _saveProgress();
  }

  void nextQuestion() {
    if (state == null || !state!.hasNext) return;
    state = state!.copyWith(currentIndex: state!.currentIndex + 1);
    _saveProgress();
  }

  void prevQuestion() {
    if (state == null || !state!.hasPrev) return;
    state = state!.copyWith(currentIndex: state!.currentIndex - 1);
  }

  void jumpTo(int index) {
    if (state == null) return;
    state = state!.copyWith(currentIndex: index);
  }

  void tick() {
    if (state == null || state!.isFinished) return;
    state = state!.copyWith(elapsedSeconds: state!.elapsedSeconds + 1);
  }

  void finishExam() {
    if (state == null) return;
    state = state!.copyWith(isFinished: true);
    OfflineService.instance.clearProgress(state!.exam.id);
  }

  void reset() => state = null;

  void _saveProgress() {
    if (state == null) return;
    OfflineService.instance.saveProgress(
      examId: state!.exam.id,
      currentIndex: state!.currentIndex,
      answers: state!.answers,
      elapsedSeconds: state!.elapsedSeconds,
    );
  }
}

final examSessionProvider =
    StateNotifierProvider<ExamSessionNotifier, ExamSessionState?>(
  (ref) => ExamSessionNotifier(),
);

// ── User results ───────────────────────────────────────────────────────────
final userResultsProvider = FutureProvider<List<ResultModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ExamService.instance.fetchUserResults(user.id);
});
