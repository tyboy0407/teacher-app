import 'package:flutter/material.dart';

/// 動態 token:全 App 共用的時長與曲線,讓所有互動的節奏一致。
///
/// 原則:進場慢、離場快;只動 transform 與 opacity;同一畫面同時最多動
/// 1~2 個元素;任何動畫都不阻擋輸入。系統開啟「減少動態效果」時,
/// 用 [AppMotion.reduced] 判斷後直接切換到終態。
abstract final class AppMotion {
  /// 按下回饋、開關切換
  static const fast = Duration(milliseconds: 120);

  /// 出現、狀態切換、收合
  static const normal = Duration(milliseconds: 200);

  /// 頁面轉場、骨架 → 內容
  static const slow = Duration(milliseconds: 300);

  /// 按鈕「彈一下」:放大再回彈,整段 240ms
  static const pop = Duration(milliseconds: 240);

  /// 成功勾勾、首次加入的慶祝
  static const celebrate = Duration(milliseconds: 450);

  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const standard = Curves.easeInOutCubic;

  /// 只給「加入備課」「收藏」這類值得慶祝一下的動作
  static const bounce = Curves.easeOutBack;

  /// 使用者在系統設定開了「減少動態效果」
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}
