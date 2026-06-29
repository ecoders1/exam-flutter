import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/offline_service.dart';

// ── Current user state ─────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Try restoring session
      final user = await AuthService.instance.restoreSession();
      if (user != null) {
        await OfflineService.instance.cacheUser(user);
        state = AsyncValue.data(user);
        return;
      }

      // Try cached user for offline
      final cached = OfflineService.instance.getCachedUser();
      state = AsyncValue.data(cached);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
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

  Future<void> signIn({required String email, required String password}) async {
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
    await AuthService.instance.signOut();
    await OfflineService.instance.clearUser();
    state = const AsyncValue.data(null);
  }

  void updateUser(UserModel user) {
    state = AsyncValue.data(user);
    OfflineService.instance.cacheUser(user);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  (ref) => AuthNotifier(),
);

// Convenience: just the user or null
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).valueOrNull;
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  return AuthService.instance.isAdmin();
});
