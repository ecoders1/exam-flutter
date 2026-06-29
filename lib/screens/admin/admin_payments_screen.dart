import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/payment_model.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_overlay.dart';

final _paymentsProvider = FutureProvider<List<PaymentModel>>((ref) async {
  return PaymentService.instance.fetchPendingPayments();
});

class AdminPaymentsScreen extends ConsumerWidget {
  const AdminPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(_paymentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_paymentsProvider),
          ),
        ],
      ),
      body: paymentsAsync.when(
        data: (payments) => payments.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppTheme.correctGreen, size: 80),
                    SizedBox(height: 16),
                    Text(
                      'No pending payments',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: payments.length,
                itemBuilder: (_, i) => _PaymentCard(
                  payment: payments[i],
                  onAction: () => ref.invalidate(_paymentsProvider),
                ).animate().fadeIn(
                      delay: Duration(milliseconds: i * 80)),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _PaymentCard extends StatefulWidget {
  final PaymentModel payment;
  final VoidCallback onAction;

  const _PaymentCard({required this.payment, required this.onAction});

  @override
  State<_PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends State<_PaymentCard> {
  bool _loading = false;

  Future<void> _approve() async {
    setState(() => _loading = true);
    try {
      await PaymentService.instance.approvePayment(widget.payment,
          note: 'Approved by admin');
      widget.onAction();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Payment approved & department unlocked'),
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

  Future<void> _reject() async {
    final noteCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Reject Payment', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: noteCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Reason for rejection...',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject',
                style: TextStyle(color: AppTheme.wrongRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      try {
        await PaymentService.instance.rejectPayment(
          widget.payment.id,
          note: noteCtrl.text,
        );
        widget.onAction();
      } catch (e) {
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;
    return LoadingOverlay(
      isLoading: _loading,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
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
                    color: AppTheme.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.gold.withOpacity(0.4)),
                  ),
                  child: Text(
                    'ETB ${p.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  p.method,
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                Text(
                  _formatDate(p.createdAt),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'User: ${p.userId.substring(0, 8)}...',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              'Dept: ${p.departmentId.substring(0, 8)}...',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),

            // Screenshot
            if (p.screenshotUrl != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showScreenshot(context, p.screenshotUrl!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    p.screenshotUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      color: AppTheme.surface,
                      child: const Center(
                        child: Icon(Icons.image, color: Colors.white24),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reject,
                    icon: const Icon(Icons.cancel, color: AppTheme.wrongRed),
                    label: const Text(
                      'Reject',
                      style: TextStyle(color: AppTheme.wrongRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.wrongRed),
                      minimumSize: const Size(0, 44),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _approve,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Approve & Unlock'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.correctGreen,
                      minimumSize: const Size(0, 44),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showScreenshot(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          child: Image.network(url),
        ),
      ),
    );
  }
}
