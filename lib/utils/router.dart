import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/department_model.dart';
import '../models/exam_model.dart';
import '../models/result_model.dart';
import '../providers/auth_provider.dart';
import '../providers/exam_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/department/department_screen.dart';
import '../screens/exam/exam_list_screen.dart';
import '../screens/question/question_screen.dart';
import '../screens/result/result_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_departments_screen.dart';
import '../screens/admin/admin_payments_screen.dart';
import '../screens/admin/admin_pricing_screen.dart';
import '../screens/admin/admin_upload_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import 'main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoading = authState.isLoading;
      final loc = state.uri.path;

      if (isLoading) return null;

      final publicRoutes = ['/splash', '/onboarding', '/auth'];
      final isPublic = publicRoutes.any((r) => loc.startsWith(r));

      if (!isLoggedIn && !isPublic) return '/auth';
      if (isLoggedIn && loc == '/auth') return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, __) => const AuthScreen(),
      ),

      // Main shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/departments',
            builder: (_, __) => const DepartmentScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),

      // Exam flow (outside shell — full screen)
      GoRoute(
        path: '/exams/:deptId',
        builder: (context, state) {
          final dept = state.extra as DepartmentModel;
          return ExamListScreen(department: dept);
        },
      ),
      GoRoute(
        path: '/question/:examId',
        builder: (context, state) {
          final exam = state.extra as ExamModel;
          return _QuestionScreenWrapper(exam: exam);
        },
      ),
      GoRoute(
        path: '/result',
        builder: (context, state) {
          final result = state.extra as ResultModel;
          return ResultScreen(result: result);
        },
      ),
      GoRoute(
        path: '/payment/:deptId',
        builder: (context, state) {
          final dept = state.extra as DepartmentModel;
          return PaymentScreen(department: dept);
        },
      ),

      // Admin routes
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'departments',
            builder: (_, __) => const AdminDepartmentsScreen(),
          ),
          GoRoute(
            path: 'exams',
            builder: (_, __) => const AdminUploadScreen(),
          ),
          GoRoute(
            path: 'payments',
            builder: (_, __) => const AdminPaymentsScreen(),
          ),
          GoRoute(
            path: 'pricing',
            builder: (_, __) => const AdminPricingScreen(),
          ),
          GoRoute(
            path: 'users',
            builder: (_, __) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: 'upload',
            builder: (_, __) => const AdminUploadScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri}',
          style: const TextStyle(color: Colors.white54),
        ),
      ),
    ),
  );
});

/// Wrapper that loads questions and starts exam session
class _QuestionScreenWrapper extends ConsumerStatefulWidget {
  final ExamModel exam;
  const _QuestionScreenWrapper({required this.exam});

  @override
  ConsumerState<_QuestionScreenWrapper> createState() =>
      _QuestionScreenWrapperState();
}

class _QuestionScreenWrapperState
    extends ConsumerState<_QuestionScreenWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndStart();
    });
  }

  Future<void> _loadAndStart() async {
    final questions = await ref
        .read(questionsProvider(widget.exam.id).future);
    if (mounted) {
      ref
          .read(examSessionProvider.notifier)
          .startExam(widget.exam, questions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(examSessionProvider);

    if (session != null && session.questions.isNotEmpty) {
      return QuestionScreen(exam: widget.exam);
    }

    return ref.watch(questionsProvider(widget.exam.id)).when(
      data: (_) => QuestionScreen(exam: widget.exam),
      loading: () => Scaffold(
        appBar: AppBar(title: Text(widget.exam.title)),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading questions...',
                  style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}
