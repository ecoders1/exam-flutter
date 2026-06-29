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

  // Lock orientation to portrait on mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Security: prevent screenshots (Android)
  // This is set per-screen where needed via FLAG_SECURE.
  // For global enforcement on Android, configure in MainActivity.kt

  // Initialize Supabase
  await SupabaseService.initialize();

  // Initialize Hive offline storage
  await OfflineService.initialize();

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
        Locale('en'), // English
        Locale('om'), // Afaan Oromoo
        Locale('am'), // Amharic
      ],
      builder: (context, child) {
        // Global: disable text selection menu copy on exam screens
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
