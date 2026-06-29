import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exam_provider.dart';
import '../../providers/department_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/offline_banner.dart';
import '../../widgets/exam/exam_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final resultsAsync = ref.watch(userResultsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Text(
                                user?.fullName.isNotEmpty == true
                                    ? user!.fullName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${user?.fullName.split(' ').first ?? 'Student'} 👋',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Text(
                                    'Ready to excel today?',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Offline indicator
                            const _ConnectivityDot(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OfflineBanner(),

                // Daily motivation
                _MotivationCard(),

                // Stats row
                resultsAsync.when(
                  data: (results) => _StatsRow(results: results),
                  loading: () => const SizedBox(height: 80),
                  error: (_, __) => const SizedBox(),
                ),

                // Department quick access
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Departments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/departments'),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),

                // Recent results
                if (resultsAsync.valueOrNull?.isNotEmpty == true) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: const Text(
                      'Recent Exams',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ...resultsAsync.value!.take(3).map(
                        (r) => ExamResultTile(result: r),
                      ),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectivityDot extends StatelessWidget {
  const _ConnectivityDot();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOnline = snapshot.data?.any((r) => r != ConnectivityResult.none) ?? true;
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline ? AppTheme.correctGreen : AppTheme.wrongRed,
          ),
        );
      },
    );
  }
}

class _MotivationCard extends StatelessWidget {
  static const _quotes = [
    '"Success is the result of preparation, hard work, and learning from failure." — Colin Powell',
    '"Education is the most powerful weapon which you can use to change the world." — Nelson Mandela',
    '"The secret of getting ahead is getting started." — Mark Twain',
    '"Believe you can and you\'re halfway there." — Theodore Roosevelt',
    '"Excellence is not a skill, it\'s an attitude." — Ralph Marston',
    '"ስኬት ትጋት ምርኮ ናት — ጽናት ተጽናና" — Ethiopian Proverb',
  ];

  @override
  Widget build(BuildContext context) {
    final quote = _quotes[DateTime.now().weekday % _quotes.length];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF004D40)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: AppTheme.gold, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _StatsRow extends StatelessWidget {
  final List results;

  const _StatsRow({required this.results});

  @override
  Widget build(BuildContext context) {
    final total = results.length;
    final passed = results.where((r) => r.passed == true).length;
    final avgScore = total > 0
        ? results.fold<double>(0, (s, r) => s + (r.scorePercent as double)) /
            total
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _StatCard(
            label: 'Total Exams',
            value: '$total',
            icon: Icons.quiz_outlined,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Passed',
            value: '$passed',
            icon: Icons.check_circle_outline,
            color: AppTheme.correctGreen,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Avg Score',
            value: '${avgScore.toStringAsFixed(0)}%',
            icon: Icons.trending_up,
            color: AppTheme.gold,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
