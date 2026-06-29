import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings, color: AppTheme.gold, size: 22),
            SizedBox(width: 8),
            Text('Admin Panel'),
          ],
        ),
        backgroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin welcome
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF004D40)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🛡️ Super Admin',
                    style: TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Full control over departments, exams, users and payments.',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 24),

            // Admin menu grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _AdminMenuCard(
                  icon: Icons.school,
                  title: 'Departments',
                  subtitle: 'Add, edit, delete',
                  color: AppTheme.primary,
                  onTap: () => context.push('/admin/departments'),
                ),
                _AdminMenuCard(
                  icon: Icons.quiz,
                  title: 'Exams',
                  subtitle: 'Upload & manage',
                  color: AppTheme.secondary,
                  onTap: () => context.push('/admin/exams'),
                ),
                _AdminMenuCard(
                  icon: Icons.payment,
                  title: 'Payments',
                  subtitle: 'Approve requests',
                  color: AppTheme.gold,
                  onTap: () => context.push('/admin/payments'),
                ),
                _AdminMenuCard(
                  icon: Icons.people,
                  title: 'Users',
                  subtitle: 'Manage accounts',
                  color: Colors.purple,
                  onTap: () => context.push('/admin/users'),
                ),
                _AdminMenuCard(
                  icon: Icons.upload_file,
                  title: 'Upload File',
                  subtitle: 'PDF/DOCX/PPT',
                  color: Colors.orange,
                  onTap: () => context.push('/admin/upload'),
                ),
                _AdminMenuCard(
                  icon: Icons.price_change,
                  title: 'Pricing',
                  subtitle: 'Set dept prices',
                  color: Colors.teal,
                  onTap: () => context.push('/admin/pricing'),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
