import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_config.dart';
import 'services/supabase_service.dart';
import 'services/offline_service.dart';
import 'theme/app_theme.dart';
import 'utils/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only on mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize offline storage first (always works)
  await OfflineService.initialize();

  // Initialize Supabase — graceful fallback if keys are placeholder
  if (AppConfig.hasRealSupabase) {
    try {
      await SupabaseService.initialize();
    } catch (e) {
      debugPrint('⚠️  Supabase init failed: $e');
      debugPrint('→ Running in offline/demo mode');
    }
  } else {
    debugPrint('ℹ️  No real Supabase keys — running in offline/demo mode');
    debugPrint('→ Set SUPABASE_URL and SUPABASE_ANON_KEY in .env.local');
  }

  runApp(
    const ProviderScope(
      child: ExitExamApp(),
    ),
  );
}

class ExitExamApp extends ConsumerWidget {
  const ExitExamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('om'),
        Locale('am'),
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
    );
  }
}
