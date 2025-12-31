import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/sensor_manager.dart';
import 'features/debug_dashboard.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 保持屏幕常亮 (防止 Samsung/Android 进入休眠导致断网)
  // 这对于 DePIN 挖矿应用是标准操作
  await WakelockPlus.enable();

  await Supabase.initialize(
    url: 'https://alczyftlhcdsifjntcbh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsY3p5ZnRsaGNkc2lmam50Y2JoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5NzE1MTAsImV4cCI6MjA4MjU0NzUxMH0.839c_boZy57LB-gBXuJjevubC2VVYmvNkQdTg1uB-y0',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final manager = SensorManager();
        if (Supabase.instance.client != null)
          manager.initSync(Supabase.instance.client);
        return manager;
      },
      child: SensorSentinelApp(),
    ),
  );
}

class SensorSentinelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiSensor',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: DebugDashboard(),
    );
  }
}
