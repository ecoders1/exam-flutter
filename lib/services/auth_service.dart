import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Device ID ──────────────────────────────────────────────────────────────
  Future<String> getDeviceId() async {
    String? cached = await _secureStorage.read(key: AppConfig.secureStorageKeyDevice);
    if (cached != null) return cached;

    final info = DeviceInfoPlugin();
    String id;

    if (kIsWeb) {
      id = 'web_${DateTime.now().millisecondsSinceEpoch}';
    } else if (Platform.isAndroid) {
      final android = await info.androidInfo;
      id = android.id;
    } else if (Platform.isIOS) {
      final ios = await info.iosInfo;
      id = ios.identifierForVendor ?? 'ios_unknown';
    } else {
      id = 'desktop_${DateTime.now().millisecondsSinceEpoch}';
    }

    await _secureStorage.write(key: AppConfig.secureStorageKeyDevice, value: id);
    return id;
  }

  // ── Sign Up ────────────────────────────────────────────────────────────────
  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // Check duplicate email
    final existing = await SupabaseService.usersTable
        .select('id')
        .eq('email', email)
        .maybeSingle();
    if (existing != null) {
      throw Exception('An account with this email already exists.');
    }

    final response = await SupabaseService.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    if (response.user == null) {
      throw Exception('Sign up failed. Please try again.');
    }

    final deviceId = await getDeviceId();

    // Insert user profile
    await SupabaseService.usersTable.insert({
      'id': response.user!.id,
      'full_name': fullName,
      'email': email,
      'device_id': deviceId,
      'is_admin': false,
      'unlocked_departments': [],
      'created_at': DateTime.now().toIso8601String(),
    });

    // Register device session
    await _registerDevice(response.user!.id, deviceId);

    return UserModel(
      id: response.user!.id,
      fullName: fullName,
      email: email,
      deviceId: deviceId,
      createdAt: DateTime.now(),
    );
  }

  // ── Sign In ────────────────────────────────────────────────────────────────
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final deviceId = await getDeviceId();

    // Check if device is registered to a different user
    final deviceCheck = await SupabaseService.deviceSessionsTable
        .select('user_id')
        .eq('device_id', deviceId)
        .maybeSingle();

    final response = await SupabaseService.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Invalid credentials.');
    }

    // One-device rule: if this device is registered to another user → block
    if (deviceCheck != null && deviceCheck['user_id'] != response.user!.id) {
      await SupabaseService.auth.signOut();
      throw Exception('This device is already linked to a different account.');
    }

    // Fetch or create user profile
    final profileData = await SupabaseService.usersTable
        .select()
        .eq('id', response.user!.id)
        .single();

    final user = UserModel.fromJson(profileData);

    // Update device id if needed
    if (user.deviceId != deviceId) {
      await SupabaseService.usersTable
          .update({'device_id': deviceId})
          .eq('id', user.id);
    }

    await _registerDevice(user.id, deviceId);
    await _saveSession(response.session);

    return user;
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await SupabaseService.auth.signOut();
    await _secureStorage.delete(key: AppConfig.secureStorageKeySession);
  }

  // ── Session Restore ────────────────────────────────────────────────────────
  Future<UserModel?> restoreSession() async {
    final session = SupabaseService.currentSession;
    if (session == null) return null;

    try {
      final profileData = await SupabaseService.usersTable
          .select()
          .eq('id', session.user.id)
          .single();
      return UserModel.fromJson(profileData);
    } catch (_) {
      return null;
    }
  }

  // ── Admin Check ────────────────────────────────────────────────────────────
  Future<bool> isAdmin() async {
    final user = SupabaseService.currentUser;
    if (user == null) return false;
    if (user.email == AppConfig.adminEmail) return true;

    final data = await SupabaseService.usersTable
        .select('is_admin')
        .eq('id', user.id)
        .maybeSingle();
    return data?['is_admin'] == true;
  }

  // ── Private ────────────────────────────────────────────────────────────────
  Future<void> _registerDevice(String userId, String deviceId) async {
    await SupabaseService.deviceSessionsTable.upsert({
      'user_id': userId,
      'device_id': deviceId,
      'last_seen': DateTime.now().toIso8601String(),
    }, onConflict: 'device_id');
  }

  Future<void> _saveSession(Session? session) async {
    if (session == null) return;
    await _secureStorage.write(
      key: AppConfig.secureStorageKeySession,
      value: session.accessToken,
    );
  }
}
