import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/department_model.dart';
import '../../providers/department_provider.dart';
import '../../services/department_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_overlay.dart';

class AdminPricingScreen extends ConsumerWidget {
  const AdminPricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deptsAsync = ref.watch(departmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Pricing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(departmentsProvider),
          ),
        ],
      ),
      body: deptsAsync.when(
        data: (depts) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: depts.length,
          itemBuilder: (_, i) => _PricingCard(
            department: depts[i],
            onUpdated: () => ref.invalidate(departmentsProvider),
          ).animate().fadeIn(delay: Duration(milliseconds: i * 80)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _PricingCard extends StatefulWidget {
  final DepartmentModel department;
  final VoidCallback onUpdated;

  const _PricingCard({required this.department, required this.onUpdated});

  @override
  State<_PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<_PricingCard> {
  late TextEditingController _priceCtrl;
  bool _editing = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
      text: widget.department.price.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newPrice = double.tryParse(_priceCtrl.text.trim());
    if (newPrice == null || newPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid price'),
          backgroundColor: AppTheme.wrongRed,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await DepartmentService.instance.updatePrice(
        widget.department.id,
        newPrice,
      );
      setState(() {
        _editing = false;
        _loading = false;
      });
      widget.onUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Price updated successfully'),
            backgroundColor: AppTheme.correctGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.wrongRed,
          ),
        );
      }
    }
  }

  Future<void> _quickAdjust(double delta) async {
    final current = double.tryParse(_priceCtrl.text) ?? widget.department.price;
    final newPrice = (current + delta).clamp(0.0, 99999.0);
    _priceCtrl.text = newPrice.toStringAsFixed(0);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.department.isDefault
                ? AppTheme.correctGreen.withOpacity(0.3)
                : Colors.white12,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.department.year,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.department.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.department.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.correctGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'FREE',
                      style: TextStyle(
                        color: AppTheme.correctGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            if (_editing)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20),
                      decoration: InputDecoration(
                        prefixText: 'ETB ',
                        prefixStyle: const TextStyle(
                            color: AppTheme.gold,
                            fontWeight: FontWeight.w600),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppTheme.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.check_circle,
                        color: AppTheme.correctGreen, size: 32),
                    onPressed: _save,
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel,
                        color: AppTheme.wrongRed, size: 32),
                    onPressed: () {
                      setState(() {
                        _editing = false;
                        _priceCtrl.text =
                            widget.department.price.toStringAsFixed(0);
                      });
                    },
                  ),
                ],
              )
            else
              Row(
                children: [
                  // Price display
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Price',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                        Text(
                          'ETB ${widget.department.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppTheme.gold,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick adjust buttons
                  _QuickBtn(
                    label: '-50',
                    color: AppTheme.wrongRed,
                    onTap: () => _quickAdjust(-50),
                  ),
                  const SizedBox(width: 6),
                  _QuickBtn(
                    label: '+50',
                    color: AppTheme.correctGreen,
                    onTap: () => _quickAdjust(50),
                  ),
                  const SizedBox(width: 6),
                  _QuickBtn(
                    label: '+100',
                    color: AppTheme.primary,
                    onTap: () => _quickAdjust(100),
                  ),
                  const SizedBox(width: 8),

                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white54),
                    onPressed: () => setState(() => _editing = true),
                    tooltip: 'Set custom price',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
