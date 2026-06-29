import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/offline_service.dart';
import '../services/supabase_service.dart';

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // If Supabase not initialized, use cached user for offline mode
      if (!SupabaseService.isInitialized) {
        final cached = OfflineService.instance.getCachedUser();
        state = AsyncValue.data(cached);
        return;
      }

      final user = await AuthService.instance.restoreSession();
      if (user != null) {
        await OfflineService.instance.cacheUser(user);
        state = AsyncValue.data(user);
        return;
      }

      // Fall back to cached user (offline)
      final cached = OfflineService.instance.getCachedUser();
      state = AsyncValue.data(cached);
    } catch (e, st) {
      // On any error, try cached user
      final cached = OfflineService.instance.getCachedUser();
      if (cached != null) {
        state = AsyncValue.data(cached);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (!SupabaseService.isInitialized) {
      state = AsyncValue.error(
        'No Supabase connection. Please add your SUPABASE_URL and SUPABASE_ANON_KEY to .env.local',
        StackTrace.current,
      );
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await AuthService.instance.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
      await OfflineService.instance.cacheUser(user);
      return user;
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (!SupabaseService.isInitialized) {
      state = AsyncValue.error(
        'No Supabase connection. Please add your SUPABASE_URL and SUPABASE_ANON_KEY to .env.local',
        StackTrace.current,
      );
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await AuthService.instance.signIn(
        email: email,
        password: password,
      );
      await OfflineService.instance.cacheUser(user);
      return user;
    });
  }

  Future<void> signOut() async {
    if (SupabaseService.isInitialized) {
      await AuthService.instance.signOut();
    }
    await OfflineService.instance.clearUser();
    state = const AsyncValue.data(null);
  }

  void updateUser(UserModel user) {
    state = AsyncValue.data(user);
    OfflineService.instance.cacheUser(user);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  (ref) => AuthNotifier(),
);

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).valueOrNull;
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  if (!SupabaseService.isInitialized) return false;
  return AuthService.instance.isAdmin();
});

/// Whether Supabase is connected
final isOnlineProvider = Provider<bool>((ref) {
  return SupabaseService.isInitialized && AppConfig.hasRealSupabase;
});
