import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Globe icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withOpacity(0.2),
                    border: Border.all(color: AppTheme.primary, width: 2),
                  ),
                  child: const Icon(
                    Icons.public,
                    size: 70,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.6, 0.6))
                    .shimmer(delay: 1000.ms, duration: 1500.ms),

                const SizedBox(height: 36),

                // Title
                Text(
                  'Welcome to',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                const SizedBox(height: 8),

                Text(
                  'Exit Exam\nEthiopia',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 20),

                // Tagline
                Text(
                  'AI-Powered • Offline-First • Secure\nPrepare for your university exit exam',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white60,
                        height: 1.6,
                      ),
                ).animate().fadeIn(delay: 600.ms),

                const Spacer(flex: 2),

                // Features row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _FeatureChip(icon: Icons.wifi_off, label: 'Offline'),
                    _FeatureChip(icon: Icons.psychology, label: 'AI MCQs'),
                    _FeatureChip(icon: Icons.security, label: 'Secure'),
                    _FeatureChip(icon: Icons.translate, label: 'Multilingual'),
                  ],
                ).animate().fadeIn(delay: 800.ms),

                const Spacer(flex: 3),

                // CTA Button
                ElevatedButton.icon(
                  onPressed: () => context.go('/auth'),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Get Started Free'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1000.ms)
                    .slideY(begin: 0.3)
                    .shimmer(delay: 1500.ms, duration: 2000.ms),

                const SizedBox(height: 16),

                // Telegram link
                TextButton.icon(
                  onPressed: () {/* launch telegram */},
                  icon: const Icon(Icons.telegram, color: Colors.lightBlueAccent),
                  label: const Text(
                    'Join our Telegram Community',
                    style: TextStyle(color: Colors.lightBlueAccent),
                  ),
                ).animate().fadeIn(delay: 1200.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
          ),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}
