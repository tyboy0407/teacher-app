import 'dart:async';

import 'package:flutter/material.dart';

/// 追蹤「由瀏覽器發起」的返回(Safari 邊緣側滑、瀏覽器/手機返回鍵)。
///
/// 側滑時瀏覽器先顯示上一頁的快照,手勢結束才把控制權交回 App;此時若再播
/// 退出動畫,使用者會看到「快照 → 詳情頁閃一下 → 動畫」。所以瀏覽器發起的
/// 返回一律直接切換頁面、不播動畫;App 內按鈕發起的返回(經 [popPage] 呼叫
/// history.back())則維持動畫。
class BrowserNavigation {
  BrowserNavigation._();

  static bool _expectingOwnBack = false;
  static Timer? _ownBackTimer;
  static Timer? _suppressTimer;

  /// 目前是否應略過頁面轉場動畫。
  static bool suppressTransitions = false;

  /// App 自己即將呼叫 history.back():接下來那一次 popstate 不是瀏覽器發起的。
  static void markOwnBack() {
    _expectingOwnBack = true;
    _ownBackTimer?.cancel();
    _ownBackTimer = Timer(const Duration(milliseconds: 500), () {
      _expectingOwnBack = false;
    });
  }

  /// 平台層在瀏覽器 popstate 事件時呼叫。
  static void onPopState() {
    if (_expectingOwnBack) {
      _expectingOwnBack = false;
      _ownBackTimer?.cancel();
      return;
    }
    suppressTransitions = true;
    _suppressTimer?.cancel();
    _suppressTimer = Timer(
      WebPageTransitionsBuilder.duration + const Duration(milliseconds: 150),
      () => suppressTransitions = false,
    );
  }
}

/// 網頁版用的頁面轉場:平常用 Android 風格的淡入推移(沒有側滑手勢,避免和
/// Safari 自己的側滑打架);瀏覽器發起返回時則直接切換、不播動畫。
class WebPageTransitionsBuilder extends PageTransitionsBuilder {
  const WebPageTransitionsBuilder();

  static const _inner = FadeForwardsPageTransitionsBuilder();
  static Duration get duration => _inner.transitionDuration;

  @override
  Duration get transitionDuration => duration;

  @override
  DelegatedTransitionBuilder? get delegatedTransition => (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        bool allowSnapshotting,
        Widget? child,
      ) {
        if (BrowserNavigation.suppressTransitions) return child;
        return _inner.delegatedTransition!(
          context,
          animation,
          secondaryAnimation,
          allowSnapshotting,
          child,
        );
      };

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (BrowserNavigation.suppressTransitions) {
      // 正在退出的頁面立刻隱藏(動畫仍會跑完才真正移除),進入的頁面立刻完整顯示。
      final leaving = animation.status == AnimationStatus.reverse ||
          animation.status == AnimationStatus.dismissed;
      return Offstage(offstage: leaving, child: child);
    }
    return _inner.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}
