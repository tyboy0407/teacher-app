import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/motion.dart';

/// 按下會「彈一下」的圖示按鈕,給收藏、加入備課這類值得有手感的動作。
///
/// - 按下:圖示 1.0 → 1.25 → 1.0,整段 [AppMotion.pop],回彈用 [AppMotion.bounce]
/// - [badgeCount] 大於 0 時在圖示角落顯示數字(把資料帶到觸發器上,
///   不用打開備課頁就知道籃子裡有幾個);數字變動時也彈一下
/// - [haptic] 為真時在手機上給一下輕觸覺(網頁上自動略過)
/// - 系統開啟「減少動態效果」時不播動畫,只切換狀態
///
/// 觸控範圍維持 44×44 以上;[compact] 只縮小圖示,不縮小觸控範圍。
class BounceIconButton extends StatefulWidget {
  const BounceIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badgeCount,
    this.haptic = false,
    this.compact = false,
    this.padding,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final int? badgeCount;
  final bool haptic;
  final bool compact;
  final EdgeInsetsGeometry? padding;

  @override
  State<BounceIconButton> createState() => _BounceIconButtonState();
}

class _BounceIconButtonState extends State<BounceIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.pop,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.25,
      ).chain(CurveTween(curve: AppMotion.enter)),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.25,
        end: 1.0,
      ).chain(CurveTween(curve: AppMotion.bounce)),
      weight: 60,
    ),
  ]).animate(_controller);

  @override
  void didUpdateWidget(covariant BounceIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 徽章數字變了(例如在別頁加入了活動)也彈一下,讓變化被看見
    if (widget.badgeCount != oldWidget.badgeCount &&
        (widget.badgeCount ?? 0) > 0) {
      _play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    if (!mounted || AppMotion.reduced(context)) return;
    _controller.forward(from: 0);
  }

  void _handlePressed() {
    if (widget.haptic) HapticFeedback.lightImpact();
    _play();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.badgeCount ?? 0;
    Widget icon = ScaleTransition(scale: _scale, child: widget.icon);
    if (count > 0) {
      icon = Badge.count(
        count: count,
        offset: const Offset(10, -8),
        child: icon,
      );
    }
    return IconButton(
      tooltip: widget.tooltip,
      padding: widget.padding ?? (widget.compact ? EdgeInsets.zero : null),
      constraints: widget.compact
          ? const BoxConstraints(minWidth: 44, minHeight: 44)
          : null,
      iconSize: widget.compact ? 20 : null,
      onPressed: widget.onPressed == null ? null : _handlePressed,
      icon: icon,
    );
  }
}
