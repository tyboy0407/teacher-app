import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/supabase_config.dart';
import 'core/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installBrowserNavigationSync();
  // 未設定 Supabase 時直接使用內建示範資料,不初始化連線
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }
  runApp(const ProviderScope(child: TeacherApp()));
}
