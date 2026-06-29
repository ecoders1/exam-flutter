import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';
import 'supabase_service.dart';
import 'department_service.dart';

class PaymentService {
  PaymentService._();
  static final PaymentService instance = PaymentService._();

  // ── Submit payment request ─────────────────────────────────────────────────
  Future<PaymentModel> submitPayment({
    required String userId,
    required String departmentId,
    required double amount,
    required String method,
    File? screenshotFile,
    Uint8List? screenshotBytes, // for web
  }) async {
    String? screenshotUrl;

    // Upload screenshot
    if (screenshotFile != null || screenshotBytes != null) {
      final fileName = 'payment_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      if (kIsWeb && screenshotBytes != null) {
        await SupabaseService.paymentsBucket.uploadBinary(fileName, screenshotBytes);
      } else if (screenshotFile != null) {
        await SupabaseService.paymentsBucket.upload(fileName, screenshotFile);
      }
      screenshotUrl = SupabaseService.paymentsBucket.getPublicUrl(fileName);
    }

    final data = await SupabaseService.paymentsTable
        .insert({
          'user_id': userId,
          'department_id': departmentId,
          'amount': amount,
          'method': method,
          'screenshot_url': screenshotUrl,
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return PaymentModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Admin: Fetch all pending payments ─────────────────────────────────────
  Future<List<PaymentModel>> fetchPendingPayments() async {
    final data = await SupabaseService.paymentsTable
        .select('*, users(full_name, email), departments(name, year)')
        .eq('status', 'pending')
        .order('created_at', ascending: true);

    return (data as List)
        .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Admin: Fetch all payments ──────────────────────────────────────────────
  Future<List<PaymentModel>> fetchAllPayments() async {
    final data = await SupabaseService.paymentsTable
        .select()
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Admin: Approve payment ─────────────────────────────────────────────────
  Future<void> approvePayment(PaymentModel payment, {String? note}) async {
    await SupabaseService.paymentsTable.update({
      'status': 'approved',
      'approved_at': DateTime.now().toIso8601String(),
      'admin_note': note,
    }).eq('id', payment.id);

    // Unlock the department for the user
    await DepartmentService.instance.unlockDepartment(
      payment.userId,
      payment.departmentId,
    );

    // Log admin action
    await SupabaseService.adminLogsTable.insert({
      'action': 'approve_payment',
      'target_id': payment.id,
      'admin_id': SupabaseService.currentUser?.id,
      'note': note ?? 'Payment approved',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ── Admin: Reject payment ──────────────────────────────────────────────────
  Future<void> rejectPayment(String paymentId, {String? note}) async {
    await SupabaseService.paymentsTable.update({
      'status': 'rejected',
      'admin_note': note,
    }).eq('id', paymentId);
  }

  // ── User: Get own payments ─────────────────────────────────────────────────
  Future<List<PaymentModel>> fetchUserPayments(String userId) async {
    final data = await SupabaseService.paymentsTable
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
