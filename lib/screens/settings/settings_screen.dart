import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

final _languageProvider = StateProvider<String>((ref) => 'en');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final lang = ref.watch(_languageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          _ProfileCard(user: user).animate().fadeIn(),

          const SizedBox(height: 20),

          // Language
          _SectionHeader(title: 'Language'),
          _LanguageTile(
            current: lang,
            onChange: (l) => ref.read(_languageProvider.notifier).state = l,
          ),

          const SizedBox(height: 20),

          // Account
          _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: user?.email ?? '',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.payment,
            title: 'My Payments',
            subtitle: 'View payment history',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.history,
            title: 'Exam History',
            subtitle: 'View all past exams',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // App info
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.telegram,
            title: 'Telegram Community',
            subtitle: AppConfig.supportTelegram,
            onTap: () async {
              final uri = Uri.parse(AppConfig.supportTelegram);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (_, snap) => _SettingsTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle:
                  '${snap.data?.version ?? AppConfig.appVersion} (${snap.data?.buildNumber ?? '1'})',
              onTap: () {},
            ),
          ),
          _SettingsTile(
            icon: Icons.phone_android,
            title: 'Device Info',
            subtitle: 'One account per device',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // Offline
          _SectionHeader(title: 'Storage'),
          _OfflineStatusTile(),

          const SizedBox(height: 32),

          // Logout
          ElevatedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppTheme.cardColor,
                  title: const Text('Logout', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'You will need to sign in again on next launch.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: AppTheme.wrongRed),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go('/auth');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.wrongRed,
              minimumSize: const Size(double.infinity, 52),
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final dynamic user;

  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Text(
              user?.fullName?.isNotEmpty == true
                  ? user!.fullName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Student',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          if (user?.isAdmin == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.gold),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChange;

  const _LanguageTile({required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final langs = [
      {'code': 'en', 'label': '🇬🇧  English'},
      {'code': 'om', 'label': '🇪🇹  Afaan Oromoo'},
      {'code': 'am', 'label': '🇪🇹  አማርኛ'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: langs.map((l) {
          final isSelected = current == l['code'];
          return ListTile(
            title: Text(
              l['label']!,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : Colors.white,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppTheme.primary)
                : null,
            onTap: () => onChange(l['code']!),
          );
        }).toList(),
      ),
    );
  }
}

class _OfflineStatusTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.correctGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: AppTheme.correctGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Offline Mode',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Exams and questions cached locally',
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.correctGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                color: AppTheme.correctGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
