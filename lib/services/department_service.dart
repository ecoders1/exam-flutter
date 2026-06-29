import '../models/department_model.dart';
import 'supabase_service.dart';

class DepartmentService {
  DepartmentService._();
  static final DepartmentService instance = DepartmentService._();

  // ── Fetch all active departments ───────────────────────────────────────────
  Future<List<DepartmentModel>> fetchDepartments() async {
    final data = await SupabaseService.departmentsTable
        .select()
        .eq('is_active', true)
        .order('year', ascending: true);

    return (data as List)
        .map((e) => DepartmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Check if user unlocked department ─────────────────────────────────────
  Future<bool> isUnlocked(String userId, String departmentId) async {
    // Default dept (2015) is always unlocked
    final dept = await SupabaseService.departmentsTable
        .select('is_default')
        .eq('id', departmentId)
        .single();
    if (dept['is_default'] == true) return true;

    final data = await SupabaseService.usersTable
        .select('unlocked_departments')
        .eq('id', userId)
        .single();

    final List<dynamic> unlocked = data['unlocked_departments'] ?? [];
    return unlocked.contains(departmentId);
  }

  // ── Unlock department for user (after admin approval) ─────────────────────
  Future<void> unlockDepartment(String userId, String departmentId) async {
    final data = await SupabaseService.usersTable
        .select('unlocked_departments')
        .eq('id', userId)
        .single();

    final List<dynamic> current = List.from(data['unlocked_departments'] ?? []);
    if (!current.contains(departmentId)) {
      current.add(departmentId);
    }

    await SupabaseService.usersTable
        .update({'unlocked_departments': current})
        .eq('id', userId);
  }

  // ── Admin: Create department ───────────────────────────────────────────────
  Future<DepartmentModel> createDepartment({
    required String name,
    required String year,
    String? description,
    required double price,
    bool isDefault = false,
  }) async {
    final data = await SupabaseService.departmentsTable
        .insert({
          'name': name,
          'year': year,
          'description': description,
          'price': price,
          'is_default': isDefault,
          'is_active': true,
          'exam_count': 0,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return DepartmentModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Admin: Update department ───────────────────────────────────────────────
  Future<void> updateDepartment(
    String departmentId, {
    String? name,
    String? description,
    double? price,
    bool? isActive,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (price != null) updates['price'] = price;
    if (isActive != null) updates['is_active'] = isActive;

    await SupabaseService.departmentsTable
        .update(updates)
        .eq('id', departmentId);
  }

  // ── Admin: Update price only ───────────────────────────────────────────────
  Future<void> updatePrice(String departmentId, double newPrice) async {
    await SupabaseService.departmentsTable
        .update({'price': newPrice})
        .eq('id', departmentId);
  }

  // ── Admin: Delete department ───────────────────────────────────────────────
  Future<void> deleteDepartment(String departmentId) async {
    await SupabaseService.departmentsTable.delete().eq('id', departmentId);
  }
}
