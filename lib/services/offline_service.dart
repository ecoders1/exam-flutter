import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';
import '../models/exam_model.dart';
import '../models/question_model.dart';
import '../models/result_model.dart';
import '../models/department_model.dart';
import '../models/user_model.dart';

/// Manages local Hive cache for offline-first operation.
class OfflineService {
  OfflineService._();
  static final OfflineService instance = OfflineService._();

  // ── Init ───────────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Hive type adapters are defined in .g.dart files (part of model files).
    // They are registered automatically on first access via generated code.
    // No manual registration needed when using build_runner.

    await Future.wait([
      Hive.openBox<Map>(AppConfig.hiveBoxExams),
      Hive.openBox<Map>(AppConfig.hiveBoxQuestions),
      Hive.openBox<Map>(AppConfig.hiveBoxProgress),
      Hive.openBox<Map>(AppConfig.hiveBoxUser),
      Hive.openBox<Map>('departments_box'),
      Hive.openBox<Map>('results_box'),
    ]);
  }

  // ── User cache ─────────────────────────────────────────────────────────────
  Box<Map> get _userBox => Hive.box<Map>(AppConfig.hiveBoxUser);

  Future<void> cacheUser(UserModel user) async {
    await _userBox.put('current_user', user.toJson().cast<String, dynamic>());
  }

  UserModel? getCachedUser() {
    final data = _userBox.get('current_user');
    if (data == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> clearUser() async => _userBox.clear();

  // ── Departments cache ──────────────────────────────────────────────────────
  Box<Map> get _deptsBox => Hive.box<Map>('departments_box');

  Future<void> cacheDepartments(List<DepartmentModel> depts) async {
    await _deptsBox.clear();
    for (final d in depts) {
      await _deptsBox.put(d.id, d.toJson().cast<String, dynamic>());
    }
  }

  List<DepartmentModel> getCachedDepartments() {
    return _deptsBox.values
        .map((e) => DepartmentModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ── Exams cache ────────────────────────────────────────────────────────────
  Box<Map> get _examsBox => Hive.box<Map>(AppConfig.hiveBoxExams);

  Future<void> cacheExams(String departmentId, List<ExamModel> exams) async {
    for (final e in exams) {
      await _examsBox.put(e.id, e.toJson().cast<String, dynamic>());
    }
  }

  List<ExamModel> getCachedExams(String departmentId) {
    return _examsBox.values
        .map((e) => ExamModel.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.departmentId == departmentId)
        .toList();
  }

  // ── Questions cache ────────────────────────────────────────────────────────
  Box<Map> get _questionsBox => Hive.box<Map>(AppConfig.hiveBoxQuestions);

  Future<void> cacheQuestions(String examId, List<QuestionModel> questions) async {
    for (final q in questions) {
      await _questionsBox.put(q.id, q.toJson().cast<String, dynamic>());
    }
  }

  List<QuestionModel> getCachedQuestions(String examId) {
    return _questionsBox.values
        .map((e) => QuestionModel.fromJson(Map<String, dynamic>.from(e)))
        .where((q) => q.examId == examId)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  // ── Progress cache ─────────────────────────────────────────────────────────
  Box<Map> get _progressBox => Hive.box<Map>(AppConfig.hiveBoxProgress);

  Future<void> saveProgress({
    required String examId,
    required int currentIndex,
    required Map<String, String> answers,
    required int elapsedSeconds,
  }) async {
    await _progressBox.put(examId, {
      'exam_id': examId,
      'current_index': currentIndex,
      'answers': answers,
      'elapsed_seconds': elapsedSeconds,
      'saved_at': DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic>? getProgress(String examId) {
    final data = _progressBox.get(examId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  Future<void> clearProgress(String examId) async {
    await _progressBox.delete(examId);
  }

  // ── Results cache ──────────────────────────────────────────────────────────
  Box<Map> get _resultsBox => Hive.box<Map>('results_box');

  Future<void> cacheResult(ResultModel result) async {
    await _resultsBox.put(result.id, result.toJson().cast<String, dynamic>());
  }

  List<ResultModel> getCachedResults() {
    return _resultsBox.values
        .map((e) => ResultModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ── Pending sync queue ─────────────────────────────────────────────────────
  Future<void> queueForSync(String key, Map<String, dynamic> data) async {
    final box = await Hive.openBox<Map>('sync_queue');
    await box.put(key, data);
  }

  Future<List<Map<String, dynamic>>> getPendingSync() async {
    final box = await Hive.openBox<Map>('sync_queue');
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> clearSyncItem(String key) async {
    final box = await Hive.openBox<Map>('sync_queue');
    await box.delete(key);
  }
}
