import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../models/department_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_overlay.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final DepartmentModel department;

  const PaymentScreen({super.key, required this.department});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'CBE';
  XFile? _screenshot;
  bool _loading = false;
  bool _submitted = false;

  final _methods = [
    {'label': 'CBE Bank', 'account': AppConfig.cbeBankAccount, 'key': 'CBE'},
    {'label': 'Telebirr', 'account': AppConfig.telebirrAccount, 'key': 'Telebirr'},
    {'label': 'CBE Birr', 'account': AppConfig.cbeBirrAccount, 'key': 'CBEBirr'},
  ];

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _screenshot = picked);
  }

  Future<void> _submitPayment() async {
    if (_screenshot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please attach your payment screenshot'),
          backgroundColor: AppTheme.wrongRed,
        ),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _loading = true);

    try {
      Uint8List? bytes;
      File? file;

      if (kIsWeb) {
        bytes = await _screenshot!.readAsBytes();
      } else {
        file = File(_screenshot!.path);
      }

      await PaymentService.instance.submitPayment(
        userId: user.id,
        departmentId: widget.department.id,
        amount: widget.department.price,
        method: _selectedMethod,
        screenshotFile: file,
        screenshotBytes: bytes,
      );

      setState(() {
        _loading = false;
        _submitted = true;
      });
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

  Future<void> _openTelegram() async {
    final uri = Uri.parse('https://t.me/milkibn');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Unlock ${widget.department.year}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: _submitted ? _buildSuccess() : _buildPaymentForm(),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Price card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '${widget.department.price.toStringAsFixed(0)} ETB',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'to unlock ${widget.department.name} (${widget.department.year})',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 24),

          const Text(
            'Select Payment Method',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Payment methods
          ..._methods.map((m) => _MethodTile(
                label: m['label']!,
                account: m['account']!,
                methodKey: m['key']!,
                isSelected: _selectedMethod == m['key'],
                onTap: () => setState(() => _selectedMethod = m['key']!),
              )),

          const SizedBox(height: 24),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.gold, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Payment Instructions',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '1. Send the exact amount shown above\n'
                  '2. Take a screenshot of the transaction\n'
                  '3. Upload the screenshot below\n'
                  '4. Send confirmation to @milkibn on Telegram\n'
                  '5. Admin will approve within 24 hours',
                  style: TextStyle(color: Colors.white70, height: 1.7),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Screenshot upload
          GestureDetector(
            onTap: _pickScreenshot,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _screenshot != null
                      ? AppTheme.correctGreen
                      : Colors.white24,
                  style: BorderStyle.solid,
                ),
              ),
              child: _screenshot != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppTheme.correctGreen),
                        const SizedBox(width: 8),
                        Text(
                          _screenshot!.name,
                          style: const TextStyle(color: AppTheme.correctGreen),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file,
                            color: Colors.white38, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Tap to upload payment screenshot',
                          style: TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _submitPayment,
            icon: const Icon(Icons.send),
            label: const Text('Submit Payment Request'),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _openTelegram,
            icon: const Icon(Icons.telegram, color: Colors.lightBlueAccent),
            label: const Text(
              'Contact Admin on Telegram',
              style: TextStyle(color: Colors.lightBlueAccent),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.lightBlueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppTheme.correctGreen, size: 80)
                .animate()
                .scale(begin: const Offset(0.3, 0.3))
                .fadeIn(),
            const SizedBox(height: 24),
            const Text(
              'Payment Request Submitted!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            const Text(
              'Your payment is under review.\nAdmin will approve within 24 hours.',
              style: TextStyle(color: Colors.white60, height: 1.6),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _openTelegram,
              icon: const Icon(Icons.telegram),
              label: const Text('Message Admin'),
            ).animate().fadeIn(delay: 700.ms),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/departments'),
              child: const Text('Back to Departments'),
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final String label;
  final String account;
  final String methodKey;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.label,
    required this.account,
    required this.methodKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.15)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primary : Colors.white38,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primary : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    account,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white54, size: 18),
                onPressed: () {
                  // Copy account number
                },
              ),
          ],
        ),
      ),
    );
  }
}
