import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'browser_navigation.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFFE8734A));
  return ThemeData(
    colorScheme: scheme,
    // 網頁版關閉 Flutter 自己的 iOS 側滑返回手勢:手機瀏覽器(Safari)邊緣側滑本身就會
    // 觸發「上一頁」,兩套同時作用會造成頁面退出兩次與卡頓;改由瀏覽器單獨處理,
    // 且瀏覽器發起的返回不播動畫(見 WebPageTransitionsBuilder)。
    pageTransitionsTheme: kIsWeb
        ? PageTransitionsTheme(
            builders: {
              for (final platform in TargetPlatform.values)
                platform: const WebPageTransitionsBuilder(),
            },
          )
        : null,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
    ),
  );
}
