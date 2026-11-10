import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'browser_navigation.dart';

/// 教學寶盒的視覺語言(方向 B「便利貼拼貼」):米白圖畫紙上貼滿紙片——
/// 麥克筆藍的筆跡、螢光筆畫線、六色便利貼、紙膠帶、貼紙;首頁開頭仍是
/// 一塊黑板綠(老師的角落)。字型全用台灣開源圓體「粉圓」。
///
/// 原則:年輕感來自「手作與親切」,不是科技感。卡片是紙片——小圓角、硬陰影
/// (2px 偏移、不模糊)、微微歪一點;裝飾只給資源卡片與區塊標題,其餘安靜。
class AppColors {
  AppColors._();

  /// 麥克筆藍:主色(白字 5.5:1、當文字放在米白上 5.1:1)
  static const marker = Color(0xFF2B64CC);
  static const markerDeep = Color(0xFF1F4FAE);
  static const markerLight = Color(0xFFDCE8FF);

  /// 黑板綠:次要色,留給首頁的黑板區塊與少數強調
  static const chalkboard = Color(0xFF2F5D50);
  static const chalkboardDeep = Color(0xFF234639);

  /// 米白圖畫紙:底色(偏暖)
  static const paper = Color(0xFFFAF6EE);

  /// 粉筆白:卡片
  static const chalk = Color(0xFFFFFFFF);

  /// 螢光筆黃:標題底下的那一道、提示條的動作文字
  static const highlighter = Color(0xFFFFF275);

  /// 蠟筆黃便利貼:「本週備課」
  static const crayonYellow = Color(0xFFF2C94C);
  static const crayonYellowDeep = Color(0xFF4A3A05);

  /// 便利貼淡黃:詳情頁的簡介便利貼
  static const stickyNote = Color(0xFFFFF8C6);

  /// 紙膠帶:半透明的三種色帶
  static const tapeYellow = Color(0xB3FFE66D);
  static const tapePink = Color(0xB3FFADAD);
  static const tapeBlue = Color(0xB3A0C4FF);

  /// 墨色:文字
  static const ink = Color(0xFF1F2A26);
  static const inkSoft = Color(0xFF5B6660);

  /// 細線(暖灰,和米白約 1.5:1)
  static const line = Color(0xFFD9D2C3);

  /// 莓紅:收藏、審核提示
  static const berry = Color(0xFFB83B5E);

  /// 紙片的硬陰影(2px 偏移、不模糊)
  static const paperShadow = Color(0x1F1F2A26);
}

const String appFontFamily = 'Huninn';
const List<String> appFontFallback = [
  'Noto Sans TC',
  'PingFang TC',
  'Microsoft JhengHei',
  'sans-serif',
];

ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.marker,
    onPrimary: AppColors.chalk,
    primaryContainer: AppColors.markerLight,
    onPrimaryContainer: Color(0xFF0E2F6E),
    secondary: AppColors.chalkboard,
    onSecondary: AppColors.chalk,
    secondaryContainer: Color(0xFFDDEBE3),
    onSecondaryContainer: AppColors.chalkboardDeep,
    tertiary: AppColors.berry,
    onTertiary: AppColors.chalk,
    tertiaryContainer: Color(0xFFF8DCE4),
    onTertiaryContainer: Color(0xFF5E1A30),
    error: Color(0xFFB3261E),
    onError: AppColors.chalk,
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: AppColors.paper,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.inkSoft,
    surfaceContainerLowest: AppColors.chalk,
    surfaceContainerLow: AppColors.chalk,
    surfaceContainer: Color(0xFFF1ECE0),
    surfaceContainerHigh: Color(0xFFEAE4D6),
    surfaceContainerHighest: Color(0xFFE3DCCC),
    outline: Color(0xFF8C8A80),
    outlineVariant: AppColors.line,
    inverseSurface: AppColors.ink,
    onInverseSurface: AppColors.paper,
    inversePrimary: Color(0xFFA9C3F5),
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: AppColors.marker,
  );

  // 粉圓只有一個字重,層級靠字級與顏色,不靠粗細
  final baseText = Typography.material2021(platform: defaultTargetPlatform)
      .black
      .apply(
        fontFamily: appFontFamily,
        fontFamilyFallback: appFontFallback,
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      );
  final textTheme = baseText.copyWith(
    headlineSmall: baseText.headlineSmall?.copyWith(fontSize: 28, height: 1.25),
    titleLarge: baseText.titleLarge?.copyWith(fontSize: 22, height: 1.3),
    titleMedium: baseText.titleMedium?.copyWith(fontSize: 17, height: 1.35),
    titleSmall: baseText.titleSmall?.copyWith(fontSize: 15, height: 1.35),
    bodyLarge: baseText.bodyLarge?.copyWith(fontSize: 16, height: 1.6),
    // 手機上的內文至少 16px(老師多在手機上讀教案)
    bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 16, height: 1.55),
    bodySmall: baseText.bodySmall?.copyWith(fontSize: 13, height: 1.45),
    labelLarge: baseText.labelLarge?.copyWith(fontSize: 15),
    labelMedium: baseText.labelMedium?.copyWith(fontSize: 13),
    labelSmall: baseText.labelSmall?.copyWith(fontSize: 12, letterSpacing: 0),
  );

  // 一般卡片(我的、審核、備課籃):暖灰細線、圓角 10;資源卡片另有紙片樣式
  const cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    side: BorderSide(color: AppColors.line),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: appFontFamily,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.paper,
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
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.paper,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: const IconThemeData(color: AppColors.ink),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: AppColors.chalk,
      surfaceTintColor: Colors.transparent,
      shape: cardShape,
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.chalk,
      selectedColor: AppColors.marker,
      checkmarkColor: AppColors.chalk,
      shape: const StadiumBorder(),
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.selected)
              ? AppColors.marker
              : AppColors.line,
        ),
      ),
      labelStyle: WidgetStateTextStyle.resolveWith(
        (states) => textTheme.labelMedium!.copyWith(
          color: states.contains(WidgetState.selected)
              ? AppColors.chalk
              : AppColors.ink,
        ),
      ),
      iconTheme: const IconThemeData(size: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.chalk,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.highlighter,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(
        textTheme.labelMedium?.copyWith(color: AppColors.ink),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.ink
              : AppColors.inkSoft,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.markerDeep,
        side: const BorderSide(color: AppColors.marker),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.markerDeep,
        textStyle: textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.chalk,
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.marker, width: 1.6),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.paper),
      actionTextColor: AppColors.highlighter,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.chalk,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.chalk,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.markerDeep,
      unselectedLabelColor: AppColors.inkSoft,
      indicatorColor: AppColors.marker,
      dividerColor: AppColors.line,
      labelStyle: textTheme.labelLarge,
      unselectedLabelStyle: textTheme.labelLarge,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    listTileTheme: const ListTileThemeData(iconColor: AppColors.marker),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.marker,
      foregroundColor: AppColors.chalk,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
