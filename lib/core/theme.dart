import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'browser_navigation.dart';

/// 教學寶盒的視覺語言:幼兒園教室的材料——黑板綠、圖畫紙、粉筆白、蠟筆黃,
/// 搭配台灣開源圓體「粉圓」(jf open 粉圓,學習區標示牌常見的字)。
///
/// 原則:大膽只放在一處(首頁的黑板區塊),其餘安靜——卡片用細線不用陰影、
/// 封面平塗不用漸層、圓角分三級(黑板 28 / 卡片 14 / 便利貼 10)。
class AppColors {
  AppColors._();

  /// 黑板綠:主色
  static const chalkboard = Color(0xFF2F5D50);
  static const chalkboardDeep = Color(0xFF234639);

  /// 圖畫紙:底色(偏冷的紙白)
  static const paper = Color(0xFFF5F6F2);

  /// 粉筆白:卡片
  static const chalk = Color(0xFFFFFFFF);

  /// 蠟筆黃:唯一的強調色,只給「本週備課」便利貼
  static const crayonYellow = Color(0xFFF2C94C);
  static const crayonYellowDeep = Color(0xFF4A3A05);

  /// 墨色:文字
  static const ink = Color(0xFF1F2A26);
  static const inkSoft = Color(0xFF5B6660);

  /// 細線
  static const line = Color(0xFFDCE2DB);

  /// 莓紅:收藏、審核提示
  static const berry = Color(0xFFB83B5E);
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
    primary: AppColors.chalkboard,
    onPrimary: AppColors.chalk,
    primaryContainer: Color(0xFFDDEBE3),
    onPrimaryContainer: AppColors.chalkboardDeep,
    secondary: Color(0xFF8A6D1F),
    onSecondary: AppColors.chalk,
    secondaryContainer: Color(0xFFFBEFC2),
    onSecondaryContainer: AppColors.crayonYellowDeep,
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
    surfaceContainer: Color(0xFFEDF0EA),
    surfaceContainerHigh: Color(0xFFE6EAE4),
    surfaceContainerHighest: Color(0xFFE0E5DE),
    outline: Color(0xFF8C958F),
    outlineVariant: AppColors.line,
    inverseSurface: AppColors.ink,
    onInverseSurface: AppColors.paper,
    inversePrimary: Color(0xFFA9D3C1),
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: AppColors.chalkboard,
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
    headlineSmall: baseText.headlineSmall?.copyWith(fontSize: 26, height: 1.25),
    titleLarge: baseText.titleLarge?.copyWith(fontSize: 21, height: 1.3),
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
    borderRadius: BorderRadius.all(Radius.circular(14)),
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
      selectedColor: AppColors.chalkboard,
      checkmarkColor: AppColors.chalk,
      shape: const StadiumBorder(),
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.selected)
              ? AppColors.chalkboard
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
      indicatorColor: scheme.primaryContainer,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(
        textTheme.labelMedium?.copyWith(color: AppColors.ink),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.chalkboardDeep
              : AppColors.inkSoft,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.chalkboardDeep,
        side: const BorderSide(color: AppColors.chalkboard),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.chalkboardDeep,
        textStyle: textTheme.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.chalk,
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.chalkboard, width: 1.6),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.paper),
      actionTextColor: AppColors.crayonYellow,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.chalk,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.chalk,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.chalkboardDeep,
      unselectedLabelColor: AppColors.inkSoft,
      indicatorColor: AppColors.chalkboard,
      dividerColor: AppColors.line,
      labelStyle: textTheme.labelLarge,
      unselectedLabelStyle: textTheme.labelLarge,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    listTileTheme: const ListTileThemeData(iconColor: AppColors.chalkboard),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.chalkboard,
      foregroundColor: AppColors.chalk,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
