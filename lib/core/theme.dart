import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'browser_navigation.dart';

/// 教學寶盒的視覺語言(方向 A「鼠尾草綠」,簡約時尚):暖白圖畫紙上,
/// 一個主色(鼠尾草綠)加一個點綴色(杏色),其餘都是墨色與暖灰。
/// 卡片是乾淨的白紙加一條細線,沒有陰影、沒有裝飾;區塊標題底下一道杏色短線。
/// 字型全用台灣開源圓體「粉圓」。
///
/// 原則:安靜、留白、只用一個主色;年輕感來自乾淨與秩序,不是顏色的數量。
class AppColors {
  AppColors._();

  /// 鼠尾草綠:主色(白字 5.3:1、當文字放在暖白上 4.9:1)
  static const sage = Color(0xFF557263);
  static const sageDeep = Color(0xFF3F5649);
  static const sageLight = Color(0xFFE6EDE8);

  /// 首頁開頭的那一塊(老師的角落)用主色,名稱沿用
  static const chalkboard = sage;
  static const chalkboardDeep = sageDeep;

  /// 暖白圖畫紙:底色
  static const paper = Color(0xFFF7F5F0);

  /// 白紙:卡片
  static const chalk = Color(0xFFFFFFFF);

  /// 杏色:唯一的點綴色——標題短線、本週備課便利貼、提示條的動作文字
  static const apricot = Color(0xFFE8C9A8);
  static const apricotDeep = Color(0xFF5C3F20);

  /// 陶土:杏色的深一階,給收藏愛心與需要跳出來的小東西(白底上 3.9:1)
  static const terracotta = Color(0xFFB8703F);

  /// 標題底線用的點綴色(沿用舊名)
  static const highlighter = apricot;

  /// 「本週備課」便利貼(沿用舊名)
  static const crayonYellow = Color(0xFFEFD9BE);
  static const crayonYellowDeep = apricotDeep;

  /// 詳情頁的簡介底色:比底色再深一點的暖灰
  static const stickyNote = Color(0xFFF1ECE3);

  /// 墨色:文字
  static const ink = Color(0xFF262A28);
  static const inkSoft = Color(0xFF626864);

  /// 細線(暖灰,和底色約 1.3:1)
  static const line = Color(0xFFDCD6CA);

  /// 審核提示等語意色(沿用舊名)
  static const berry = Color(0xFFB83B5E);

  /// 卡片的影子:幾乎看不見的一層,只讓紙片離開底色一點點
  static const paperShadow = Color(0x14262A28);
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
    primary: AppColors.sage,
    onPrimary: AppColors.chalk,
    primaryContainer: AppColors.sageLight,
    onPrimaryContainer: AppColors.sageDeep,
    secondary: AppColors.terracotta,
    onSecondary: AppColors.chalk,
    secondaryContainer: Color(0xFFF3E3D2),
    onSecondaryContainer: AppColors.apricotDeep,
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
    surfaceContainer: Color(0xFFF0EDE6),
    surfaceContainerHigh: Color(0xFFEAE6DD),
    surfaceContainerHighest: Color(0xFFE4DFD5),
    outline: Color(0xFF8A8E88),
    outlineVariant: AppColors.line,
    inverseSurface: AppColors.ink,
    onInverseSurface: AppColors.paper,
    inversePrimary: Color(0xFFB7CBBE),
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: AppColors.sage,
  );

  // 粉圓只有一個字重,層級靠字級、留白與顏色,不靠粗細
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
      selectedColor: AppColors.sage,
      checkmarkColor: AppColors.chalk,
      shape: const StadiumBorder(),
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.selected)
              ? AppColors.sage
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
      indicatorColor: AppColors.sageLight,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(
        textTheme.labelMedium?.copyWith(color: AppColors.ink),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.sageDeep
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
        foregroundColor: AppColors.sageDeep,
        side: const BorderSide(color: AppColors.sage),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.sageDeep,
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
        borderSide: const BorderSide(color: AppColors.sage, width: 1.6),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.paper),
      actionTextColor: AppColors.apricot,
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
      labelColor: AppColors.sageDeep,
      unselectedLabelColor: AppColors.inkSoft,
      indicatorColor: AppColors.sage,
      dividerColor: AppColors.line,
      labelStyle: textTheme.labelLarge,
      unselectedLabelStyle: textTheme.labelLarge,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    listTileTheme: const ListTileThemeData(iconColor: AppColors.sage),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.sage,
      foregroundColor: AppColors.chalk,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
