/// Central app configuration — values injected via --dart-define at build time
/// or read from environment on Flutter Web via js interop.
class AppConfig {
  AppConfig._();

  // ── Supabase ───────────────────────────────────────────────────────────────
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://YOUR_PROJECT.supabase.co');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'YOUR_ANON_KEY');

  // ── App Meta ───────────────────────────────────────────────────────────────
  static const String appName = 'Exit Exam Ethiopia';
  static const String appVersion = '1.0.0';
  static const String supportTelegram = 'https://t.me/exitexamethiopia1';
  static const String paymentTelegram = '@milkibn';

  // ── Admin ──────────────────────────────────────────────────────────────────
  static const String adminEmail = 'milkiyaas43@gmail.com';

  // ── Payment Accounts ───────────────────────────────────────────────────────
  static const String cbeBankAccount = '1000458067857';
  static const String telebirrAccount = '0943133184';
  static const String cbeBirrAccount = '0991575614';

  // ── Pricing ───────────────────────────────────────────────────────────────
  static const double defaultDepartmentPrice = 200.0;

  // ── Exam Settings ─────────────────────────────────────────────────────────
  static const int defaultQuestionsPerExam = 40;
  static const int examTimerMinutes = 60;

  // ── Offline Cache ─────────────────────────────────────────────────────────
  static const String hiveBoxExams = 'exams_box';
  static const String hiveBoxQuestions = 'questions_box';
  static const String hiveBoxProgress = 'progress_box';
  static const String hiveBoxUser = 'user_box';

  // ── Security ──────────────────────────────────────────────────────────────
  static const String secureStorageKeySession = 'session_token';
  static const String secureStorageKeyDevice = 'device_id';
}
