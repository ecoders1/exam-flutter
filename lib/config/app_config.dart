/// Central app configuration.
/// All values injected via --dart-define-from-file=.env.local at build/run time.
class AppConfig {
  AppConfig._();

  // ── Supabase ───────────────────────────────────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-id.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key-here',
  );

  // ── OpenAI ─────────────────────────────────────────────────────────────────
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  // ── Admin ──────────────────────────────────────────────────────────────────
  static const String adminEmail = String.fromEnvironment(
    'ADMIN_EMAIL',
    defaultValue: 'milkiyaas43@gmail.com',
  );
  static const String adminPassword = String.fromEnvironment(
    'ADMIN_PASSWORD',
    defaultValue: '',
  );

  // ── Payment Accounts ───────────────────────────────────────────────────────
  static const String cbeBankAccount = String.fromEnvironment(
    'CBE_ACCOUNT',
    defaultValue: '1000458067857',
  );
  static const String telebirrAccount = String.fromEnvironment(
    'TELEBIRR_ACCOUNT',
    defaultValue: '0943133184',
  );
  static const String cbeBirrAccount = String.fromEnvironment(
    'CBE_BIRR_ACCOUNT',
    defaultValue: '0991575614',
  );

  // ── Telegram ───────────────────────────────────────────────────────────────
  static const String paymentTelegram = String.fromEnvironment(
    'PAYMENT_TELEGRAM',
    defaultValue: '@milkibn',
  );
  static const String supportTelegram = String.fromEnvironment(
    'COMMUNITY_TELEGRAM',
    defaultValue: 'https://t.me/exitexamethiopia1',
  );

  // ── Pricing & Exam Settings ────────────────────────────────────────────────
  static const double defaultDepartmentPrice = double.fromEnvironment(
    'DEFAULT_DEPARTMENT_PRICE',
    defaultValue: 200.0,
  );
  static const int examTimerMinutes = int.fromEnvironment(
    'EXAM_TIMER_MINUTES',
    defaultValue: 60,
  );
  static const int defaultQuestionsPerExam = int.fromEnvironment(
    'DEFAULT_QUESTIONS_PER_EXAM',
    defaultValue: 40,
  );
  static const double passMarkPercent = double.fromEnvironment(
    'PASS_MARK_PERCENT',
    defaultValue: 50.0,
  );

  // ── App Meta ───────────────────────────────────────────────────────────────
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Exit Exam Ethiopia',
  );
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  // ── Offline / Hive Box Keys ────────────────────────────────────────────────
  static const String hiveBoxExams       = 'exams_box';
  static const String hiveBoxQuestions   = 'questions_box';
  static const String hiveBoxProgress    = 'progress_box';
  static const String hiveBoxUser        = 'user_box';

  // ── Secure Storage Keys ────────────────────────────────────────────────────
  static const String secureStorageKeySession = 'session_token';
  static const String secureStorageKeyDevice  = 'device_id';
}
