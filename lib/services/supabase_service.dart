import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Singleton wrapper around the Supabase client.
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: AppConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );
    _initialized = true;
  }

  static bool get isInitialized => _initialized;

  // ── Auth helpers ──────────────────────────────────────────────────────────
  static User? get currentUser =>
      _initialized ? auth.currentUser : null;
  static Session? get currentSession =>
      _initialized ? auth.currentSession : null;
  static bool get isSignedIn => currentUser != null;

  // ── Tables ─────────────────────────────────────────────────────────────────
  static SupabaseQueryBuilder get usersTable =>
      client.from('users');
  static SupabaseQueryBuilder get departmentsTable =>
      client.from('departments');
  static SupabaseQueryBuilder get examsTable =>
      client.from('exams');
  static SupabaseQueryBuilder get questionsTable =>
      client.from('questions');
  static SupabaseQueryBuilder get resultsTable =>
      client.from('results');
  static SupabaseQueryBuilder get paymentsTable =>
      client.from('payments');
  static SupabaseQueryBuilder get uploadsTable =>
      client.from('uploads');
  static SupabaseQueryBuilder get deviceSessionsTable =>
      client.from('device_sessions');
  static SupabaseQueryBuilder get adminLogsTable =>
      client.from('admin_logs');

  // ── Storage ────────────────────────────────────────────────────────────────
  static SupabaseStorageClient get storage => client.storage;
  static StorageFileApi get uploadsBucket => storage.from('uploads');
  static StorageFileApi get paymentsBucket => storage.from('payments');
}
