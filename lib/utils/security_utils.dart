import 'package:flutter/services.dart';

/// Security utilities — anti-screenshot, anti-copy, watermark, etc.
class SecurityUtils {
  SecurityUtils._();

  // ── FLAG_SECURE (Android) — prevents screenshots & screen recording ────────
  /// Call this in initState() of any exam/question screen.
  static Future<void> enableSecureMode() async {
    try {
      const channel = MethodChannel('com.exitexam.ethiopia/security');
      await channel.invokeMethod('setSecureMode', {'secure': true});
    } catch (_) {
      // Platform not supported — fail silently
    }
  }

  static Future<void> disableSecureMode() async {
    try {
      const channel = MethodChannel('com.exitexam.ethiopia/security');
      await channel.invokeMethod('setSecureMode', {'secure': false});
    } catch (_) {}
  }
}
