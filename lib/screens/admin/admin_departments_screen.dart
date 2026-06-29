import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/department_model.dart';
import '../../providers/department_provider.dart';
import '../../services/department_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_overlay.dart';

class AdminDepartmentsScreen extends ConsumerWidget {
  const AdminDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deptsAsync = ref.watch(departmentsProvider);

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Department'),
        backgroundColor: AppTheme.primary,
      ),
      body: deptsAsync.when(
        data: (depts) => depts.isEmpty
            ? const Center(
                child: Text('No departments yet',
                    style: TextStyle(color: Colors.white54)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: depts.length,
                itemBuilder: (_, i) => _DeptAdminCard(
                  dept: depts[i],
                  onChanged: () => ref.invalidate(departmentsProvider),
                ).animate().fadeIn(delay: Duration(milliseconds: i * 60)),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '200');
    bool isDefault = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('Add Department',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(yearCtrl, 'Year (e.g. 2015)', Icons.calendar_today),
                const SizedBox(height: 12),
                _dialogField(nameCtrl, 'Department Name', Icons.school),
                const SizedBox(height: 12),
                _dialogField(descCtrl, 'Description (optional)', Icons.description),
                const SizedBox(height: 12),
                _dialogField(priceCtrl, 'Price (ETB)', Icons.attach_money,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: isDefault,
                      onChanged: (v) => setState(() => isDefault = v ?? false),
                      activeColor: AppTheme.primary,
                    ),
                    const Text('Free (default unlock)',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || yearCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                try {
                  await DepartmentService.instance.createDepartment(
                    name: nameCtrl.text.trim(),
                    year: yearCtrl.text.trim(),
                    description: descCtrl.text.trim().isEmpty
                        ? null
                        : descCtrl.text.trim(),
                    price: double.tryParse(priceCtrl.text) ?? 200,
                    isDefault: isDefault,
                  );
                  ref.invalidate(departmentsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Department created'),
                        backgroundColor: AppTheme.correctGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white54, size: 18),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _DeptAdminCard extends StatefulWidget {
  final DepartmentModel dept;
  final VoidCallback onChanged;

  const _DeptAdminCard({required this.dept, required this.onChanged});

  @override
  State<_DeptAdminCard> createState() => _DeptAdminCardState();
}

class _DeptAdminCardState extends State<_DeptAdminCard> {
  bool _loading = false;

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Delete Department?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'This will delete "${widget.dept.name}" and all its exams. This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.wrongRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      await DepartmentService.instance.deleteDepartment(widget.dept.id);
      widget.onChanged();
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.dept.isDefault
                ? AppTheme.correctGreen.withOpacity(0.3)
                : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.dept.year,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.dept.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'ETB ${widget.dept.price.toStringAsFixed(0)} • ${widget.dept.examCount} exams',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (widget.dept.isDefault)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.lock_open,
                    color: AppTheme.correctGreen, size: 18),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppTheme.wrongRed, size: 20),
              onPressed: _delete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
