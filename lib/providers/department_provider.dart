import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/department_model.dart';
import '../services/department_service.dart';
import '../services/offline_service.dart';
import 'auth_provider.dart';

// ── All departments ────────────────────────────────────────────────────────
final departmentsProvider = FutureProvider<List<DepartmentModel>>((ref) async {
  try {
    final depts = await DepartmentService.instance.fetchDepartments();
    await OfflineService.instance.cacheDepartments(depts);
    return depts;
  } catch (_) {
    // Offline fallback
    final cached = OfflineService.instance.getCachedDepartments();
    if (cached.isNotEmpty) return cached;
    rethrow;
  }
});

// ── Check unlock status ────────────────────────────────────────────────────
final departmentUnlockedProvider =
    FutureProvider.family<bool, String>((ref, departmentId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;

  // Check local cache first
  if (user.unlockedDepartments.contains(departmentId)) return true;

  return DepartmentService.instance.isUnlocked(user.id, departmentId);
});

// ── Selected department ────────────────────────────────────────────────────
final selectedDepartmentProvider = StateProvider<DepartmentModel?>((ref) => null);
