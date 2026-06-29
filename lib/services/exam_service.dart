import '../models/exam_model.dart';
import '../models/question_model.dart';
import '../models/result_model.dart';
import 'supabase_service.dart';

class ExamService {
  ExamService._();
  static final ExamService instance = ExamService._();

  // ── Fetch exams for department ─────────────────────────────────────────────
  Future<List<ExamModel>> fetchExams(String departmentId) async {
    final data = await SupabaseService.examsTable
        .select()
        .eq('department_id', departmentId)
        .eq('is_published', true)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Fetch all exams (admin) ────────────────────────────────────────────────
  Future<List<ExamModel>> fetchAllExams() async {
    final data = await SupabaseService.examsTable
        .select()
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Fetch questions for exam ───────────────────────────────────────────────
  Future<List<QuestionModel>> fetchQuestions(String examId) async {
    final data = await SupabaseService.questionsTable
        .select()
        .eq('exam_id', examId)
        .order('order_index', ascending: true);

    return (data as List)
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Save exam result ───────────────────────────────────────────────────────
  Future<ResultModel> saveResult({
    required String userId,
    required String examId,
    required int totalQuestions,
    required int correctAnswers,
    required int timeUsedSeconds,
    required Map<String, String> answers,
    required double passMarkPercent,
  }) async {
    final wrongAnswers = totalQuestions - correctAnswers;
    final scorePercent = (correctAnswers / totalQuestions) * 100;
    final passed = scorePercent >= passMarkPercent;

    final data = await SupabaseService.resultsTable
        .insert({
          'user_id': userId,
          'exam_id': examId,
          'total_questions': totalQuestions,
          'correct_answers': correctAnswers,
          'wrong_answers': wrongAnswers,
          'score_percent': scorePercent,
          'passed': passed,
          'time_used_seconds': timeUsedSeconds,
          'completed_at': DateTime.now().toIso8601String(),
          'answers': answers,
        })
        .select()
        .single();

    return ResultModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Fetch user results ─────────────────────────────────────────────────────
  Future<List<ResultModel>> fetchUserResults(String userId) async {
    final data = await SupabaseService.resultsTable
        .select()
        .eq('user_id', userId)
        .order('completed_at', ascending: false);

    return (data as List)
        .map((e) => ResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Admin: Create exam ────────────────────────────────────────────────────
  Future<ExamModel> createExam({
    required String title,
    required String departmentId,
    String? description,
    int durationMinutes = 60,
    double passMarkPercent = 50.0,
  }) async {
    final data = await SupabaseService.examsTable
        .insert({
          'title': title,
          'department_id': departmentId,
          'description': description,
          'question_count': 0,
          'duration_minutes': durationMinutes,
          'pass_mark_percent': passMarkPercent,
          'is_published': false,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return ExamModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Admin: Bulk insert questions ───────────────────────────────────────────
  Future<void> insertQuestions(List<QuestionModel> questions) async {
    final batch = questions.map((q) => q.toJson()).toList();
    await SupabaseService.questionsTable.insert(batch);

    // Update exam question_count
    if (questions.isNotEmpty) {
      await SupabaseService.examsTable
          .update({'question_count': questions.length, 'is_published': true})
          .eq('id', questions.first.examId);

      // Update department exam_count
      final examData = await SupabaseService.examsTable
          .select('department_id')
          .eq('id', questions.first.examId)
          .single();

      final deptId = examData['department_id'] as String;
      final countData = await SupabaseService.examsTable
          .select('id')
          .eq('department_id', deptId)
          .eq('is_published', true);
      final count = (countData as List).length;

      await SupabaseService.departmentsTable
          .update({'exam_count': count})
          .eq('id', deptId);
    }
  }

  // ── Admin: Delete exam ────────────────────────────────────────────────────
  Future<void> deleteExam(String examId) async {
    await SupabaseService.questionsTable.delete().eq('exam_id', examId);
    await SupabaseService.examsTable.delete().eq('id', examId);
  }

  // ── Admin: Publish / Unpublish exam ──────────────────────────────────────
  Future<void> togglePublish(String examId, bool publish) async {
    await SupabaseService.examsTable
        .update({'is_published': publish})
        .eq('id', examId);
  }
}
