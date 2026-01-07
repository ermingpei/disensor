import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/sensor_manager.dart';
import 'features/onboarding_page.dart';
import 'features/debug_dashboard.dart';

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
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final manager = SensorManager();
        manager.initSync(Supabase.instance.client);
        return manager;
      },
      child: SensorSentinelApp(
          startPage: seenOnboarding ? DebugDashboard() : OnboardingPage()),
    ),
  );
}

class SensorSentinelApp extends StatelessWidget {
  final Widget startPage;
  SensorSentinelApp({required this.startPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DiSensor',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF121212),
        primarySwatch: Colors.cyan,
        useMaterial3: true,
      ),
      home: startPage,
    );
  }
}
