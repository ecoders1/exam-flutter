/// Central app configuration.
/// Values injected via --dart-define-from-file=.env.local
class AppConfig {
  AppConfig._();

  // ── Supabase ───────────────────────────────────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.placeholder',
  );
  // Service role key — only used in secure server-side calls, never in client UI
  static const String supabaseServiceRoleKey = String.fromEnvironment(
    'SUPABASE_SERVICE_ROLE_KEY',
    defaultValue: '',
  );

  /// True when running with real Supabase credentials
  static bool get hasRealSupabase =>
      !supabaseUrl.contains('placeholder') &&
      !supabaseAnonKey.contains('placeholder') &&
      supabaseUrl.startsWith('https://') &&
      supabaseUrl.endsWith('.supabase.co');

  // ── JWT ────────────────────────────────────────────────────────────────────
  static const String jwtSecret = String.fromEnvironment(
    'JWT_SECRET',
    defaultValue: 'eee_exit_exam_ethiopia_super_secret_jwt_key_2024',
  );

  // ── OpenAI ─────────────────────────────────────────────────────────────────
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );
  static bool get hasOpenAi => openAiApiKey.isNotEmpty;

  // ── Admin ──────────────────────────────────────────────────────────────────
  static const String adminEmail = String.fromEnvironment(
    'ADMIN_EMAIL',
    defaultValue: 'milkiyaas43@gmail.com',
  );
  static const String adminPassword = String.fromEnvironment(
    'ADMIN_PASSWORD',
    defaultValue: 'Ayyuu@4313@',
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

  // ── Exam Settings ──────────────────────────────────────────────────────────
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

  // ── Hive Box Keys ──────────────────────────────────────────────────────────
  static const String hiveBoxExams     = 'exams_box';
  static const String hiveBoxQuestions = 'questions_box';
  static const String hiveBoxProgress  = 'progress_box';
  static const String hiveBoxUser      = 'user_box';

  // ── Secure Storage Keys ────────────────────────────────────────────────────
  static const String secureStorageKeySession = 'session_token';
  static const String secureStorageKeyDevice  = 'device_id';
}
