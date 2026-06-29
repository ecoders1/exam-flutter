import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/department_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/department_provider.dart';
import '../../theme/app_theme.dart';

class DepartmentScreen extends ConsumerWidget {
  const DepartmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deptsAsync = ref.watch(departmentsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(departmentsProvider),
          ),
        ],
      ),
      body: deptsAsync.when(
        data: (depts) => depts.isEmpty
            ? const Center(
                child: Text(
                  'No departments available',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: depts.length,
                itemBuilder: (context, i) {
                  final dept = depts[i];
                  return _DepartmentCard(
                    department: dept,
                    userId: user?.id ?? '',
                  ).animate().fadeIn(delay: Duration(milliseconds: i * 80));
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white38, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Offline — showing cached data',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(departmentsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepartmentCard extends ConsumerWidget {
  final DepartmentModel department;
  final String userId;

  const _DepartmentCard({
    required this.department,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedAsync = ref.watch(departmentUnlockedProvider(department.id));

    return unlockedAsync.when(
      data: (isUnlocked) => _buildCard(context, isUnlocked),
      loading: () => _buildCard(context, false, loading: true),
      error: (_, __) => _buildCard(context, false),
    );
  }

  Widget _buildCard(BuildContext context, bool isUnlocked, {bool loading = false}) {
    return GestureDetector(
      onTap: () {
        if (loading) return;
        if (isUnlocked || department.isDefault) {
          context.push('/exams/${department.id}', extra: department);
        } else {
          context.push('/payment/${department.id}', extra: department);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? AppTheme.correctGreen.withOpacity(0.4)
                : Colors.white12,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Year badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: isUnlocked
                      ? const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.secondary],
                        )
                      : const LinearGradient(
                          colors: [AppTheme.lockedGrey, Color(0xFF424242)],
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    department.year,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${department.examCount} exams available',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    if (!isUnlocked && !department.isDefault) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${department.price.toStringAsFixed(0)} ETB to unlock',
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Lock/unlock icon
              if (loading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (isUnlocked || department.isDefault)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.correctGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock_open,
                    color: AppTheme.correctGreen,
                    size: 22,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white38,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
