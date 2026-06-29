import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../config/app_config.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _globeController;

  @override
  void initState() {
    super.initState();
    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    // Check if user has active session
    final user = await AuthService.instance.restoreSession();
    if (!mounted) return;

    if (user != null) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _globeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.splashGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🌍 Animated Globe
                AnimatedBuilder(
                  animation: _globeController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _globeController.value * 6.28318,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.public,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.5, 0.5)),

                const SizedBox(height: 32),

                // 🇪🇹 Ethiopian Flag Colors Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _flagBar(const Color(0xFF078930)),
                    _flagBar(const Color(0xFFFCDD09)),
                    _flagBar(const Color(0xFFDA121A)),
                  ],
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: 24),

                // App Title
                Text(
                  'EXIT EXAM',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        fontSize: 36,
                      ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

                Text(
                  'ETHIOPIA',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                        fontSize: 22,
                      ),
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),

                const SizedBox(height: 8),

                Text(
                  'AI-Powered Exam Platform',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white60,
                        letterSpacing: 2,
                      ),
                ).animate().fadeIn(delay: 900.ms),

                const SizedBox(height: 60),

                // Loading dots
                _LoadingDots()
                    .animate()
                    .fadeIn(delay: 1200.ms),

                const SizedBox(height: 32),

                Text(
                  'v${AppConfig.appVersion}',
                  style: const TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _flagBar(Color color) {
    return Container(
      width: 30,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween(begin: 0.0, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final offset = i / 3;
            final scale = 0.5 +
                0.5 *
                    (1 -
                        ((_anim.value - offset).abs() % 1.0)
                            .clamp(0.0, 1.0));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10 * scale,
              height: 10 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(scale),
              ),
            );
          }),
        );
      },
    );
  }
}
