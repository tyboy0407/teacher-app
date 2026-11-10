import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/app_update.dart';
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
  void initState() {
    super.initState();
    // 網頁版:開啟時檢查有沒有新版本,有就自動更新(見 AppUpdater)
    AppUpdater.instance.start();
  }

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
      child: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AppUpdater.instance.updating,
            builder: (context, updating, _) => updating
                ? const Positioned.fill(child: _UpdatingOverlay())
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// 發現新版本、正在清快取重新載入時的全頁畫面(幾秒鐘)
class _UpdatingOverlay extends StatelessWidget {
  const _UpdatingOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.paper,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 20),
            Text('有新版本,更新中…', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '幾秒後會自動重新載入',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
