import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/constants.dart';
import 'core/router.dart';
import 'core/theme.dart';

class TeacherApp extends StatefulWidget {
  const TeacherApp({super.key});

  @override
  State<TeacherApp> createState() => _TeacherAppState();
}

class _TeacherAppState extends State<TeacherApp> {
  late final GoRouter _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
      // 桌機/平板瀏覽器:內容寬度上限,行長才讀得舒服;手機不受影響
      builder: (context, child) => _ContentFrame(child: child!),
      locale: const Locale('zh', 'TW'),
      supportedLocales: const [Locale('zh', 'TW'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

/// 寬螢幕時把整個 App 置中、限制最大寬度(像一張攤在桌上的圖畫紙)。
class _ContentFrame extends StatelessWidget {
  const _ContentFrame({required this.child});

  final Widget child;

  static const maxWidth = 720.0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.paper,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
