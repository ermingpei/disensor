import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/sensor_manager.dart';
import 'core/auth_service.dart';
import 'features/onboarding_page.dart';
import 'features/debug_dashboard.dart';
import 'features/auth_page.dart';

// Environment variables (injected via --dart-define)
const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://alczyftlhcdsifjntcbh.supabase.co',
);
const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsY3p5ZnRsaGNkc2lmam50Y2JoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5NzE1MTAsImV4cCI6MjA4MjU0NzUxMH0.839c_boZy57LB-gBXuJjevubC2VVYmvNkQdTg1uB-y0',
);
const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WakelockPlus.enable();

  // Initialize Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  // Initialize Sentry (if DSN configured)
  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
        options.environment =
            const String.fromEnvironment('ENV', defaultValue: 'development');
      },
      appRunner: () => _runApp(seenOnboarding),
    );
  } else {
    // Run without Sentry in development
    _runApp(seenOnboarding);
  }
}

void _runApp(bool seenOnboarding) {
  final supabaseClient = Supabase.instance.client;

  runApp(
    MultiProvider(
      providers: [
        // Auth Service
        ChangeNotifierProvider(
          create: (_) => AuthService(supabaseClient),
        ),
        // Sensor Manager
        ChangeNotifierProvider(
          create: (context) {
            final manager = SensorManager();
            manager.initSync(supabaseClient);
            // Load persisted earnings from local storage
            manager.loadEarnings();
            return manager;
          },
        ),
      ],
      child: SensorSentinelApp(seenOnboarding: seenOnboarding),
    ),
  );
}

class SensorSentinelApp extends StatelessWidget {
  final bool seenOnboarding;

  const SensorSentinelApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DiSensor',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primarySwatch: Colors.cyan,
        useMaterial3: true,
      ),
      home: _AuthGate(seenOnboarding: seenOnboarding),
    );
  }
}

/// Auth gate widget to handle authentication flow
class _AuthGate extends StatelessWidget {
  final bool seenOnboarding;

  const _AuthGate({required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // User is logged in or chose anonymous mode
        if (authService.isLoggedIn || authService.isAnonymous) {
          // Show onboarding if first time
          if (!seenOnboarding) {
            return OnboardingPage();
          }
          return DebugDashboard();
        }

        // Show auth page
        return AuthPage(
          onAuthSuccess: () {
            // Navigate to appropriate page based on onboarding status
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) =>
                    seenOnboarding ? DebugDashboard() : OnboardingPage(),
              ),
            );
          },
        );
      },
    );
  }
}
